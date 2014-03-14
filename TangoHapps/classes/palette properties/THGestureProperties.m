//
//  THGestureProperties.m
//  TangoHapps
//
//  Created by Michael Conrads on 13/03/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THGestureProperties.h"
#import "THGestureEditable.h"

@interface THGestureProperties ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *tickControll;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *windowLabel;

@end

@implementation THGestureProperties

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
    
    THGestureEditable *editable = (THGestureEditable *)self.editableObject;
    [self.slider setValue:editable.halfWindowSize];
    self.windowLabel.text = [NSString stringWithFormat:@"%i",editable.halfWindowSize];
    
    [self.tickControll setSelectedSegmentIndex:fmax(editable.numberOfTicksToDetect-1,0)];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)detectTickChanged:(UISegmentedControl *)sender
{
    THGestureEditable *editable = (THGestureEditable *)self.editableObject;
    editable.numberOfTicksToDetect = sender.selectedSegmentIndex +1;
}

- (IBAction)sliderChanged:(UISlider *)sender
{
    THGestureEditable *editable = (THGestureEditable *)self.editableObject;
    editable.halfWindowSize = sender.value;
    self.windowLabel.text = [NSString stringWithFormat:@"%i",(NSUInteger)sender.value];
}

@end
