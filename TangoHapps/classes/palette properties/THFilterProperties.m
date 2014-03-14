//
//  THFilterProperties.m
//  TangoHapps
//
//  Created by Michael Conrads on 13/03/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THFilterProperties.h"
#import "THFilterEditable.h"
@interface THFilterProperties ()
@property (weak, nonatomic) IBOutlet UILabel *samplesLabel;
@property (weak, nonatomic) IBOutlet UISlider *samplesSlider;

@end

@implementation THFilterProperties

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    THFilterEditable *ed = (THFilterEditable *)self.editableObject;
    self.samplesLabel.text = [NSString stringWithFormat:@"%i",ed.numberOfSamples];
    self.samplesSlider.value = ed.numberOfSamples;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)samplesSliderChanged:(UISlider *)sender
{
    self.samplesLabel.text = [NSString stringWithFormat:@"%i",(NSUInteger)sender.value];
    THFilterEditable *ed = (THFilterEditable *)self.editableObject;
    ed.numberOfSamples = sender.value;
}


@end
