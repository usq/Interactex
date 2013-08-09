//
//  IFFirmataViewController.m
//  iFirmata
//
//  Created by Juan Haladjian on 6/27/13.
//  Copyright (c) 2013 TUM. All rights reserved.
//

#import "IFFirmataViewController.h"
#import "IFPinCell.h"
#import "IFPin.h"
#import "IFFirmataController.h"
#import "BLEDiscovery.h"
#import "IFI2CComponentCell.h"
#import "AppDelegate.h"
#import "IFI2CComponent.h"

@implementation IFFirmataViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    self.firmataController = appDelegate.firmataController;
    
    [self loadPersistedObjects];
}

-(void) viewWillAppear:(BOOL)animated{
    self.firmataController.bleService = [BLEDiscovery sharedInstance].connectedService;
    [BLEDiscovery sharedInstance].connectedService.dataDelegate = self.firmataController;
    
    if(self.firmataController.numAnalogPins == 0 && self.firmataController.numDigitalPins == 0){
        
        //[self.firmataController stop];
        [self.firmataController start];
    }
    
    [self.table deselectRowAtIndexPath:self.table.indexPathForSelectedRow animated:NO];
}

-(void) viewDidAppear:(BOOL)animated{
    
    if(self.removingComponent){
    [self removeComponentAnimated];
    }
}

-(void) viewWillDisappear:(BOOL)animated{
    if(!goingToI2CScene){
        
        [self.firmataController stopReportingI2CComponents];
        [self.firmataController stopReportingAnalogPins];
        [self persistObjects];
    }
    goingToI2CScene = NO;
}

-(void) loadPersistedObjects{
        
    NSData * data = [[NSUserDefaults standardUserDefaults] objectForKey:IFDefaultsI2CComponents];
    if(data){
        self.firmataController.i2cComponents = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
}

-(void) persistObjects{
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:self.firmataController.i2cComponents];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:IFDefaultsI2CComponents];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setFirmataController:(IFFirmataController *)firmataController{
    if(_firmataController != firmataController){
        _firmataController = firmataController;
        _firmataController.delegate = self;
    }
}

#pragma mark FirmataDelegate

-(void) firmataDidUpdateDigitalPins:(IFFirmataController *)firmataController{
    [self.table reloadData];
    /*
    NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:0];
    [self.table reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];*/
}

-(void) firmataDidUpdateAnalogPins:(IFFirmataController *)firmataController{
    [self.table reloadData];/*
    NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:1];
    [self.table reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];*/
}

-(void) firmataDidUpdateI2CComponents:(IFFirmataController *)firmataController{

    //[self.table reloadData];
    
    NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:2];
    [self.table reloadSections:indexSet withRowAnimation:UITableViewRowAnimationTop];
}

-(void) firmata:(IFFirmataController *)firmataController didUpdateTitle:(NSString *)title{
    self.title = title;
}

#pragma mark TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0) {
        return @"Digital";
    } else if(section == 1){
        return @"Analog";
    } else {
        return @"I2C";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return self.firmataController.digitalPins.count;
    } else if(section == 1){
        return self.firmataController.analogPins.count;
    } else {
        return self.firmataController.i2cComponents.count;
    }
}

-(float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell;
    
    if(indexPath.section == 0 || indexPath.section == 1){
        NSInteger pinNumber = indexPath.row;
        BOOL digital = (indexPath.section == 0);
        IFPin * pin = (digital ? [self.firmataController.digitalPins objectAtIndex:pinNumber] : [self.firmataController.analogPins objectAtIndex:pinNumber]);
        
        if(digital){
            cell = [self.table dequeueReusableCellWithIdentifier:@"digitalCell"];
        } else {
            cell = [self.table dequeueReusableCellWithIdentifier:@"analogCell"];
        }
        
        ((IFPinCell*)cell).pin = pin;
    } else {
        
        NSInteger idx = indexPath.row;
        IFI2CComponent * component = [self.firmataController.i2cComponents objectAtIndex:idx];
        
         cell = [self.table dequeueReusableCellWithIdentifier:@"i2cCell"];
        ((IFI2CComponentCell*) cell).component = component;
    }
    
    return cell;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if( [segue.identifier isEqualToString:@"toI2CDeviceSegue"]){
        IFI2CComponentViewController * viewController = segue.destinationViewController;
        viewController.delegate = self;
        
        IFI2CComponentCell * cell = (IFI2CComponentCell*) [self.table cellForRowAtIndexPath:self.table.indexPathForSelectedRow];
        viewController.component = cell.component;
        
        goingToI2CScene = YES;
    }
}

#pragma mark - i2cComponent Delegate

//called after view did appear when there is a component to remove
-(void) removeComponentAnimated{
    
    IFI2CComponentCell * cell = (IFI2CComponentCell*) [self.table cellForRowAtIndexPath:self.removingComponentPath];
    [cell removeComponentObservers];
    
    [self.table scrollToRowAtIndexPath:self.removingComponentPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    [self.table deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.removingComponentPath] withRowAnimation:UITableViewRowAnimationFade];
    
    self.removingComponent = nil;
}

-(void) i2cComponentRemoved:(IFI2CComponent*) component{
    NSInteger row = [self.firmataController.i2cComponents indexOfObject:component];
    self.removingComponentPath = [NSIndexPath indexPathForRow:row inSection:2];
    
    self.firmataController.delegate = nil;
    [self.firmataController removeI2CComponent:component];
    self.firmataController.delegate = self;
    
    self.removingComponent = component;
}

-(void) i2cComponent:(IFI2CComponent*) component wroteData:(NSString*) data toRegister:(IFI2CRegister*) reg{
    
    [self.firmataController sendI2CWriteData:data forRegister:reg fromComponent:component];
}

-(void) i2cComponent:(IFI2CComponent*) component startedNotifyingRegister:(IFI2CRegister*) reg{
    [self.firmataController sendI2CStartStopReportingRequestForRegister:reg fromComponent:component];
}

-(void) i2cComponent:(IFI2CComponent*) component stoppedNotifyingRegister:(IFI2CRegister*) reg{
    [self.firmataController sendI2CStartStopReportingRequestForRegister:reg fromComponent:component];
}

-(void) i2cComponent:(IFI2CComponent *)component addedRegister:(IFI2CRegister *)reg{
    [self.firmataController addI2CRegister:reg toComponent:component];
}

-(void) i2cComponent:(IFI2CComponent *)component removedRegister:(IFI2CRegister *)reg{
    [self.firmataController removeI2CRegister:reg fromComponent:component];
}

#pragma mark - Additional Options

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0){
        [self addI2CComponent];
    }else if(buttonIndex == 1){
        [self.firmataController sendResetRequest];
        [self.firmataController stop];
        [self.firmataController start];
    }
    
    NSLog(@"%d",buttonIndex);
}

-(void) addI2CComponent{
    IFI2CComponent * component = [[IFI2CComponent alloc] init];
    component.name = @"New I2C Component";
    component.address = 24;
    
    [self.firmataController addI2CComponent:component];
    
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:self.firmataController.i2cComponents.count-1 inSection:2];
    [self.table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (IBAction)optionsMenuTapped:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Add I2C Component",@"Reset Firmata", nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    [actionSheet showInView:[self view]];
    
}

@end