//
//  THSignalSourceGestureSetViewController.m
//  TangoHapps
//
//  Created by Michael Conrads on 03/05/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THSignalSourceGestureSetViewController.h"


@interface THSignalSourceGestureSetViewController ()
@property (nonatomic, weak, readwrite) THGestureSet *gestureSet;
@end

@implementation THSignalSourceGestureSetViewController

- (instancetype)initWithGestureSet:(THGestureSet *)gestureSet
{
    self = [super init];
    if(self)
    {
        _gestureSet = gestureSet;
    }
    
    return self;
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end