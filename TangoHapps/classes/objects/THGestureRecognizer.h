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

#define HALF_WINDOW_SIZE_DEFAULT 40

@interface THGestureRecognizer : NSObject

+ (instancetype)sharedRecognizer;
- (BOOL)registerGesture:(THGestureClassifier *)gesture;
- (void)trainRecognizerWithTrainingSet:(THTrainingsSet *)trainingsSet;
- (void)observeSignal:(Signal)signal;
- (void)printFeaturesForWindow:(NSArray *)data;
@property (nonatomic, assign, readwrite) NSUInteger halfWindowSize;

@end
