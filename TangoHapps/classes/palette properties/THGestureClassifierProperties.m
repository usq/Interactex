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

@interface THGestureClassifierProperties ()<UIPopoverControllerDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *tickControll;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *windowLabel;
@property (nonatomic, strong, readwrite) UIPopoverController *recordingPopoverController;

@end

@implementation THGestureClassifierProperties

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    THGestureClassifierEditable *editable = (THGestureClassifierEditable *)self.editableObject;
    [self.slider setValue:editable.halfWindowSize];
    self.windowLabel.text = [NSString stringWithFormat:@"%i",editable.halfWindowSize];
    
//    [self.tickControll setSelectedSegmentIndex:fmax(editable.numberOfTicksToDetect-1,0)];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)detectTickChanged:(UISegmentedControl *)sender
{
//    THGestureClassifierEditable *editable = (THGestureClassifierEditable *)self.editableObject;
//    editable.numberOfTicksToDetect = sender.selectedSegmentIndex +1;
}

- (IBAction)sliderChanged:(UISlider *)sender
{
    THGestureClassifierEditable *editable = (THGestureClassifierEditable *)self.editableObject;
    editable.halfWindowSize = sender.value;
    self.windowLabel.text = [NSString stringWithFormat:@"%i",(NSUInteger)sender.value];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
        [[THSignalSourceEditable sharedSignalSourceEditable] stopRecording];
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
    self.recordingPopoverController.delegate = self;
    
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



@end
