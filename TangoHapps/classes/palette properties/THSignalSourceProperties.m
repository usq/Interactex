//
//  THSignalSourceProperties.m
//  TangoHapps
//
//  Created by Michael Conrads on 28/02/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THSignalSourceProperties.h"
#import "THSignalSourceEditable.h"
#import "THSignalSourcePopoverContentViewController.h"
#import "THGestureSample.h"
#import "THGestureSet.h"

#import "THSignalSourceGestureSetViewController.h"

@interface THSignalSourceProperties ()<UITableViewDataSource, UITableViewDelegate, UIPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *addRecordingButton;
@property (weak, nonatomic) IBOutlet UILabel *headline;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong, readwrite) NSMutableArray *gestureSets;
@property (nonatomic, strong, readwrite) UIPopoverController *popoverViewController;
@property (nonatomic, assign, readwrite) NSUInteger lastSampleIndex;

@property (nonatomic, strong, readwrite) UINavigationController *navController;
@end

@implementation THSignalSourceProperties


- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{

//    self.navController = [[UINavigationController alloc] initWithRootViewController:self];
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self)
    {
        self.gestureSets = [NSMutableArray array];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    
//    [self updateHeadlineWithFileName:[self.gestures firstObject]];
	// Do any additional setup after loading the view.
}


- (NSString *)title
{
    return @"Signal Source";
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    NSUInteger numberOfGesturesInGestureSet = 0;
    if([self.gestureSets count] > 0)
    {
        THGestureSet *gestureSet = self.gestureSets[0];
        numberOfGesturesInGestureSet = [gestureSet.gestures count];
    }
    return numberOfGesturesInGestureSet;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.gestureSets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *cellIdentifier = @"THSignalSourcePropertiesTableCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    if(cell == nil)
//    {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
//                                      reuseIdentifier:cellIdentifier];
//    }

//    cell.textLabel.text = self.gestures[indexPath.row];
//    return cell;
    return nil;
}


- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    
//    NSString *fileName = self.gestures[indexPath.row];
//    THSignalSourceEditable *signalSourceEditable = (THSignalSourceEditable *)self.editableObject;
//    [signalSourceEditable switchSourceFile:fileName];
//    [self updateHeadlineWithFileName:fileName];
//    
//    
//    THSignalSourcePopoverContentViewController *contentViewController = [[THSignalSourcePopoverContentViewController alloc] initWithNibName:@"THSignalSourcePopoverContentViewController"
//                                                                                                                                     bundle:[NSBundle mainBundle]
//                                                                                                                       signalSourceEditable:signalSourceEditable];
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    CCDirector *director = [CCDirector sharedDirector];
//    
//    CGRect rect = [cell.contentView convertRect:cell.contentView.frame toView:director.view];
//    [self presentPopoverWithConcentViewController:contentViewController
//                                         fromRect:rect];
}

- (void)presentPopoverWithConcentViewController:(THSignalSourcePopoverContentViewController *)contentViewController
                                       fromRect:(CGRect)rect
{
    self.popoverViewController = [[UIPopoverController alloc] initWithContentViewController:contentViewController];
    self.popoverViewController.backgroundColor = [UIColor colorWithRed:0.321 green:0.402 blue:0.341 alpha:1.000];
    self.popoverViewController.delegate = self;
    
    CCDirector *director = [CCDirector sharedDirector];
    
    contentViewController.currentPopoverController = self.popoverViewController;
    contentViewController.signalSourceProperties = self;
    
    [self.popoverViewController presentPopoverFromRect:rect
                                                inView:director.view
                              permittedArrowDirections:UIPopoverArrowDirectionLeft
                                              animated:YES];
    
}

- (void)didPressSave
{
//    NSString *currentFilename = [self filePathWithIndex:self.lastSampleIndex];
//    THSignalSourceEditable *editableObject = (THSignalSourceEditable *) self.editableObject;
//    editableObject.
}

- (void)didPressStop
{
    // Add method implement code here.
    
}



- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return NO;
}


- (IBAction)addRecordingPressed:(UIButton *)sender
{
    THGestureSet *newGestureSet = [[THGestureSet alloc] init];
    [self.gestureSets addObject:newGestureSet];

    THSignalSourceGestureSetViewController *viewController = [[THSignalSourceGestureSetViewController alloc]
                                                              initWithGestureSet:newGestureSet];
    
//    [self.navController pushViewController:viewController
//                                  animated:YES];
    
    [self presentViewController:viewController
                       animated:YES completion:nil];
//    
//    
//    
//    UIPopoverController *p = [[UIPopoverController alloc] initWithContentViewController:namingViewController];
//    
//    
//    
//    
//    
//    CCDirector *director = [CCDirector sharedDirector];
//    CGRect rect = [sender convertRect:sender.bounds
//                               toView:director.view];
//    
//    
//    [self presentPopoverWithConcentViewController:namingViewController
//                                         fromRect:rect];
//    
//    //get new name
    //create new empty sample
    /*
    while([[NSFileManager defaultManager] fileExistsAtPath:[self filePathWithIndex:self.lastSampleIndex]])
    {
        self.lastSampleIndex ++;
    }
    NSString *newFile = [self filePathWithIndex:self.lastSampleIndex];
    NSString *fileName = [[newFile componentsSeparatedByString:@"/"] lastObject];
    self.gestures = [@[fileName] arrayByAddingObjectsFromArray:self.gestures];
    [self.tableView reloadData];
    
    THSignalSourceEditable *signalSourceEditable = (THSignalSourceEditable *)self.editableObject;
    [signalSourceEditable recordeNewGesture];
    THSignalSourcePopoverContentViewController *contentViewController = [[THSignalSourcePopoverContentViewController alloc] initWithNibName:@"THSignalSourcePopoverContentViewController"
                                                                                                                                     bundle:[NSBundle mainBundle]
                                                                                                                       signalSourceEditable:signalSourceEditable];
    
   
     */
}


- (void)updateHeadlineWithFileName:(NSString *)fileName
{
    self.headline.text = [NSString stringWithFormat:@"current: %@",fileName];
}

@end
