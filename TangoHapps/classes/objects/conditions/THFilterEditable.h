//
//  THFilterEditable.h
//  TangoHapps
//
//  Created by Michael Conrads on 13/03/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THProgrammingElementEditable.h"

@interface THFilterEditable : THProgrammingElementEditable
@property (nonatomic, assign, readwrite) NSUInteger numberOfSamples;
- (void)addInput:(float)input;
@end
