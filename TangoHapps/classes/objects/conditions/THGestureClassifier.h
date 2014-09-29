//
//  THGesture.h
//  TangoHapps
//
//  Created by Michael Conrads on 13/03/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "TFSimulableObject.h"
#import "THSignalSource.h"
@interface THGestureClassifier : TFSimulableObject
@property (nonatomic, assign, readonly) NSUInteger numberOfTicksToDetect;
@property (nonatomic, assign, readwrite) NSUInteger halfWindowSize;
@property (nonatomic, assign, readwrite) Signal currentSignal;
@property (nonatomic, assign, readwrite) BOOL hasAlreadyBeenRecognized;
- (void)addSignal:(Signal)signal;
- (void)finishedGesture:(NSArray *)gestureData;
- (void)recognized;
@end
