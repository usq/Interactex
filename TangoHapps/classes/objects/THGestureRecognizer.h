//
//  THGestureRecognition.h
//  TangoHapps
//
//  Created by Michael Conrads on 01/05/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "THGestureClassifier.h"
#import "THTrainingsSet.h"
#import "THSignalSource.h"
#import "THFeatureSet.h"

#define HALF_WINDOW_SIZE_DEFAULT 30

@interface THGestureRecognizer : NSObject
@property (nonatomic, assign, readwrite) NSUInteger halfWindowSize;

+ (instancetype)sharedRecognizer;

//this one is fishy
- (short)registerGesture:(THGestureClassifier *)gesture;
- (void)deregisterGesture:(THGestureClassifier *)gesture;

- (void)trainRecognizerWithGesture:(THGestureClassifier *)gesture
                   addedFeatureSet:(THFeatureSet *)featureSet;
- (void)trainRecognizerWithGesture:(THGestureClassifier *)gesture;

- (void)observeSignal:(Signal)signal;
- (void)printFeaturesForWindow:(NSArray *)data;

- (THFeatureSet *)featureSetFromSignals:(NSArray *)signals
                                   name:(NSString *)name;

- (void)removeTrainingAtIndex:(NSUInteger)index
                    withLabel:(short)label
                   forGesture:(THGestureClassifier *)gesture;

@end
