//
//  THMacbookProperties.m
//  TangoHapps
//
//  Created by Michael Conrads on 11/07/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THMacbookProperties.h"
#import "THMacbookEditable.h"

@interface THMacbookProperties ()

@end

@implementation THMacbookProperties

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
    
    THMacbook *editable = (THGestureClassifierEditable *)self.editableObject;
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

@end
