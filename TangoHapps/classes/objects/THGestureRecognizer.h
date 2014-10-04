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

#define HALF_WINDOW_SIZE_DEFAULT 20

@interface THGestureRecognizer : NSObject
@property (nonatomic, assign, readwrite) NSUInteger halfWindowSize;

+ (instancetype)sharedRecognizer;

//this one is fishy
- (BOOL)registerGesture:(THGestureClassifier *)gesture;
- (void)trainRecognizerWithGesture:(THGestureClassifier *)gesture;
//- (void)updateFeatureSetForGesture:(THGestureClassifier *)gesture;

- (void)observeSignal:(Signal)signal;
- (void)printFeaturesForWindow:(NSArray *)data;
//- (NSUInteger)peaksInWindow:(NSArray *)data;
//- (void)retrainWithTrainingsSets:(NSArray *)trainings;

- (THFeatureSet *)featureSetFromSignals:(NSArray *)signals
                                   name:(NSString *)name;

- (void)removeTrainingAtIndex:(NSUInteger)index
                    withLabel:(short)label
                   forGesture:(THGestureClassifier *)gesture;
@end
