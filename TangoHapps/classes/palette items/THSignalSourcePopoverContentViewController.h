//
//  THSignalSourcePopoverContentViewController.h
//  TangoHapps
//
//  Created by Michael Conrads on 05/03/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THSignalSourceEditable.h"
#import "THSignalSourceProperties.h"

@interface THSignalSourcePopoverContentViewController : UIViewController

@property (nonatomic, assign, readwrite) UIPopoverController *currentPopoverController;
@property (nonatomic, strong, readwrite) THSignalSourceProperties *signalSourceProperties;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
         signalSourceEditable:(THSignalSourceEditable *)signalSourceEditable;
@end
