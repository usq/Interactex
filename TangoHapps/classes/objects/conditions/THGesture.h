//
//  THGesture.h
//  TangoHapps
//
//  Created by Michael Conrads on 13/03/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "TFSimulableObject.h"

@interface THGesture : TFSimulableObject
@property (nonatomic, assign, readwrite) int numberOfTicksToDetect;
@property (nonatomic, assign, readwrite) NSUInteger halfWindowSize;
- (void)addSignal:(float)signal;
@end
