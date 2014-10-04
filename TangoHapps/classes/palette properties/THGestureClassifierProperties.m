//
//  THGestureProperties.m
//  TangoHapps
//
//  Created by Michael Conrads on 13/03/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THGestureClassifierProperties.h"
#import "THGestureClassifierEditable.h"
#import "THGestureClassifierPopoverContentViewController.h"
#import "THSignalSourceEditable.h"
#import "THGestureClassifier.h"
#import "THFeatureSet.h"

@interface THGestureClassifierProperties ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong, readwrite) UIPopoverController *recordingPopoverController;
@property (nonatomic, strong, readwrite) IBOutlet UITableView *tableView;

@end

@implementation THGestureClassifierProperties


- (void)viewDidLoad
{
    [super viewDidLoad];
}



- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [[THSignalSourceEditable sharedSignalSourceEditable] stopRecording];
    if(self.tableView)
    {
        [self.tableView reloadData];
    }
}

- (IBAction)recordGesturePressed:(UIButton *)sender
{
    CCDirector *director = [CCDirector sharedDirector];
    CGRect rect = [sender convertRect:sender.bounds
                               toView:director.view];
    
    THGestureClassifierPopoverContentViewController *contentViewController =
    [[THGestureClassifierPopoverContentViewController alloc] initWithNibName:@"THGestureClassifierPopoverContentViewController"
                                                                      bundle:[NSBundle mainBundle]
                                                 gestureClassifierProperties:self];
    
    self.recordingPopoverController = [[UIPopoverController alloc] initWithContentViewController:contentViewController];
    self.recordingPopoverController.delegate = self;
    self.recordingPopoverController.backgroundColor = [UIColor colorWithRed:0.321 green:0.402 blue:0.341 alpha:1.000];

    
    contentViewController.currentPopoverController = self.recordingPopoverController;

    NSLog(@"start recording");
    [[THSignalSourceEditable sharedSignalSourceEditable] recordeNewGesture];
    
    [self.recordingPopoverController presentPopoverFromRect:rect
                                                     inView:director.view
                                   permittedArrowDirections:UIPopoverArrowDirectionLeft
                                                   animated:YES];
    
    
    //    [self presentPopoverWithConcentViewController:namingViewController
    //                                         fromRect:rect];
    
    //    //get new name
    //create new empty sample
    
    //    while([[NSFileManager defaultManager] fileExistsAtPath:[self filePathWithIndex:self.lastSampleIndex]])
    //    {
    //        self.lastSampleIndex ++;
    //    }
    //    NSString *newFile = [self filePathWithIndex:self.lastSampleIndex];
    //    NSString *fileName = [[newFile componentsSeparatedByString:@"/"] lastObject];
    //    self.gestures = [@[fileName] arrayByAddingObjectsFromArray:self.gestures];
    /*
     THSignalSourceEditable *signalSourceEditable = (THSignalSourceEditable *)self.editableObject;
     [signalSourceEditable recordeNewGesture];
     THSignalSourcePopoverContentViewController *contentViewController = [[THSignalSourcePopoverContentViewController alloc] initWithNibName:@"THSignalSourcePopoverContentViewController"
     bundle:[NSBundle mainBundle]
     signalSourceEditable:signalSourceEditable];
     
     [self presentPopoverWithConcentViewController:contentViewController
     fromRect:self.addRecordingButton.frame];
     */
    
}

- (NSArray *)trainedFeatureSets
{
    return ((THGestureClassifier *)((THGestureClassifierEditable *)self.editableObject).simulableObject).trainedFeatureSets;
}


#pragma mark - tableview delegates

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        //delete training here
        [[NSNotificationCenter defaultCenter] postNotificationName:kGestureClassifierShouldDeleteTraining
                                                            object:self
                                                          userInfo:@{
                                                                     @"index":@(indexPath.row)
                                                                     }];
        [self.tableView reloadData];
    }
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[self trainedFeatureSets] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"THGestureClassifierTrainedFeatureSetsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
    }
    THFeatureSet *featureSet = [self trainedFeatureSets][indexPath.row];
    cell.textLabel.text = featureSet.name;
    
    return cell;
}



@end
