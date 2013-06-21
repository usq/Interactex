//
//  THTimerProperties.h
//  TangoHapps
//
//  Created by Juan Haladjian on 2/21/13.
//  Copyright (c) 2013 Technische Universität München. All rights reserved.
//

#import "TFEditableObjectProperties.h"

@interface THTimerProperties : TFEditableObjectProperties

@property (weak, nonatomic) IBOutlet UILabel *secondsLabel;
@property (weak, nonatomic) IBOutlet UISlider *secondsSlider;
@property (weak, nonatomic) IBOutlet UISwitch *alwaysSwitch;
@property (weak, nonatomic) IBOutlet UITextField *milisecondsText;

- (IBAction)secondsChanged:(id)sender;
- (IBAction)typeChanged:(id)sender;
- (IBAction)milisecondsChanged:(id)sender;

@end
