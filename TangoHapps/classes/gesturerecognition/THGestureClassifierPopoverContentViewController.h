//
//  THGestureClassifierPopoverContentViewController.h
//  TangoHapps
//
//  Created by Michael Conrads on 10/07/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THGestureClassifierProperties.h"


@interface THGestureClassifierPopoverContentViewController : UIViewController
@property (nonatomic, weak, readwrite) UIPopoverController *currentPopoverController;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
    gestureClassifierProperties:(THGestureClassifierProperties *)gestureClassifierProperties;

@end
