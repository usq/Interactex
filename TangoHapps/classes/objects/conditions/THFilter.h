//
//  THFilter.h
//  TangoHapps
//
//  Created by Michael Conrads on 13/03/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "TFSimulableObject.h"

@interface THFilter : TFSimulableObject
@property (nonatomic, assign, readonly) float outputValue;
@property (nonatomic, assign, readwrite) NSUInteger numberOfSamples;
- (void)addInput:(float)input;
@end
