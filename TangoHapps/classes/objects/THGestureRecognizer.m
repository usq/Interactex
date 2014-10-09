//
//  THGestureRecognition.m
//  TangoHapps
//
//  Created by Michael Conrads on 01/05/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THGestureRecognizer.h"
#import "Classifier.h"
#import "FeatureExtractor.h"
#import "Helper.h"


@interface THGestureRecognizer ()
@property (nonatomic, assign, readwrite) Signal *signalWindow;
@property (nonatomic, strong, readwrite) NSMutableArray *registeredGestures;
@property (nonatomic, strong, readwrite) Classifier *classifier;
@property (nonatomic, strong, readwrite) FeatureExtractor *featureExtractor;

@property (nonatomic, assign, readwrite) NSUInteger index;

@property (nonatomic, strong, readwrite) NSMutableString *history;


@property (nonatomic, assign, readwrite) BOOL trainedGesture;
@end
short lastLabel = 9999;
@implementation THGestureRecognizer


+ (instancetype)sharedRecognizer
{
    static THGestureRecognizer *sharedRecognizer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedRecognizer = [[self alloc] init];
    });
    return sharedRecognizer;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.classifier = [[Classifier alloc] init];
        self.featureExtractor = [[FeatureExtractor alloc] init];
        self.registeredGestures = [NSMutableArray array];
        
        self.signalWindow = calloc(self.halfWindowSize * 2, sizeof(Signal));
        self.halfWindowSize = HALF_WINDOW_SIZE_DEFAULT;
        self.history = [NSMutableString string];
        self.trainedGesture = NO;
    }
    return self;
}


- (short)registerGesture:(THGestureClassifier *)gesture
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    short label = gesture.label;
    if([self.registeredGestures containsObject:gesture] == NO)
    {
        [self.registeredGestures addObject:gesture];
    }
    
    if(label == 0)
    {
        label = [self.registeredGestures count];
    }
    return label;
}


- (void)deregisterGesture:(THGestureClassifier *)gesture
{
    if([self.registeredGestures containsObject:gesture])
    {
        [self.registeredGestures removeObject:gesture];
        if(gesture.isCalibrationGesture)
        {
            [self.classifier removeValuesWithLabel:9999];
            self.trainedGesture = NO;
        }
        [self.classifier removeValuesWithLabel:gesture.label];
    }
}

- (void)observeSignal:(Signal)signal
{
    //correctSignal
    
    if(self.index == self.halfWindowSize)
    {
        for (int i = self.halfWindowSize; i < self.halfWindowSize * 2; i++)
        {
            self.signalWindow[i - self.halfWindowSize] = self.signalWindow[i]; //
        }
        self.signalWindow[self.index] = signal;
        self.index++;
    }
    else if(self.index == self.halfWindowSize * 2 -1)
    {
        self.signalWindow[self.index] = signal;
        self.index = self.halfWindowSize;
        
        if(self.trainedGesture)
        {
            [self checkWindow];
        }
    }
    else
    {
        self.signalWindow[self.index] = signal;
        self.index++;
    }
}

- (void)setHalfWindowSize:(NSUInteger)halfWindowSize
{
    
    _halfWindowSize = halfWindowSize;
    
    if(self.signalWindow)
    {
        free(self.signalWindow);
    }
    
    self.signalWindow = calloc(_halfWindowSize * 2, sizeof(Signal));
    self.index = 0;
    
}

- (void)trainRecognizerWithGesture:(THGestureClassifier *)gesture
                   addedFeatureSet:(THFeatureSet *)featureSet
{
    //    NSArray *gestureFeatureSets = gesture.trainedFeatureSets;
    
    if(self.trainedGesture == NO)
    {
        
        [self.classifier appendFeatureSets:@[featureSet]
                                  forLabel:9999];
        gesture.isCalibrationGesture = YES;
        NSLog(@"inserted 0 vector");
    }
    else
    {
        [self.classifier appendFeatureSets:@[featureSet]
                                  forLabel:gesture.label];
        
    }
    
    self.trainedGesture = YES;
    
}

- (void)trainRecognizerWithGesture:(THGestureClassifier *)gesture
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    for (THFeatureSet *featureSet in gesture.trainedFeatureSets)
    {
        [self trainRecognizerWithGesture:gesture
                         addedFeatureSet:featureSet];
    }
    
}


- (void)checkWindow
{
    
    double features[FEATURE_COUNT];
    int featureCount;
    [self.featureExtractor computeAllFeaturesFromWindow:self.signalWindow
                                                  count:self.halfWindowSize *2
                                               features:features
                                           featureCount:&featureCount];
    
    
    [Helper scaleFeatures:features];
    short label = [self.classifier classifyInputVector:features
                                                ignore:-1];
    
    
    NSLog(@"--------------- i think its label %i",label);
    short recognizedLabel = 0;
    
    if (label == 9999 && lastLabel != 9999)
    {
        recognizedLabel  = lastLabel;
    } else if(label < lastLabel && lastLabel != 9999)
    {
        recognizedLabel = lastLabel;
        label = lastLabel;
        
    }
    
    if(recognizedLabel != 0)
    {
        //recognized lastlabel
        for (THGestureClassifier *oneGesture in self.registeredGestures)
        {
            if(oneGesture.hasAlreadyBeenRecognized == NO && oneGesture.label == recognizedLabel)
            {
                [oneGesture recognized];
            }
            else
            {
                [oneGesture notRecognized];
            }
        }
    }
    
  if(label == 9999)
  {
      for (THGestureClassifier *oneGesture in self.registeredGestures)
      {
          if(oneGesture.hasAlreadyBeenRecognized)
          {
              
              oneGesture.hasAlreadyBeenRecognized = NO;
          }
      }
  }
    
    lastLabel = label;
}

- (THFeatureSet *)featureSetFromSignals:(NSArray *)signals
                                   name:(NSString *)name
{
    Signal recordedSignals[[signals count]];
    
    for (int i = 0; i < [signals count]; i++)
    {
        Signal s;
        [signals[i] getValue:&s];
        recordedSignals[i] = s;
    }
    
    
    double features[FEATURE_COUNT];
    int featureCount;
    [self.featureExtractor computeAllFeaturesFromWindow:recordedSignals
                                                  count:[signals count]
                                               features:features
                                           featureCount:&featureCount];
    
    NSLog(@"added features:");
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  %f %f %f %f %f",features[0],features[1],features[2],features[3],features[4]);
    
    NSMutableArray *featureArray = [NSMutableArray array];
    for (int i = 0; i < featureCount; i++)
    {
        [featureArray addObject:@(features[i])];
    }
    
    
    
    THFeatureSet *featureSet = [[THFeatureSet alloc] initWithFeatures:featureArray
                                                                 name:name];
    return featureSet;
}


- (void)removeTrainingAtIndex:(NSUInteger)index
                    withLabel:(short)label
                   forGesture:(THGestureClassifier *)gesture
{
    short labelToDelete = gesture.label;
    if(gesture.isCalibrationGesture)
    {
        index --;
    }
    [self.classifier removeValuesForLabel:labelToDelete
                                  atIndex:index];
    [self.classifier calculateScaleMatrix];
}

- (void)printFeaturesForWindow:(NSArray *)data
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    
    //MC_TODO:implement
    
    /*
     self.halfWindowSize = [data count]/2;
     
     for (int i = 0; i < self.halfWindowSize*2; i++)
     {
     self.signalWindow[i] = [data[i] floatValue];
     }
     
     
     double features[8];
     self.featureExtractor.peakDetectionTolerance = 30;
     [self.featureExtractor computeAllFeaturesFromWindow:self.signalWindow
     count:self.halfWindowSize *2 / 3
     features:features];
     
     double means =           features[0];
     double magnitude =       features[1];
     double deviations =      features[2];
     double minMaxDiffs =     features[3];
     double numPeaks =        features[4];
     double correlations1 =   features[5];
     double correlations2 =   features[6];
     double correlations3 =   features[7];
     
     
     
     NSLog(@"---");
     NSString *featuresInWindow = [NSString stringWithFormat:@"means: %.3f numPeaks: %.3f minmaxdiffs: %.3f  deviation: %.3f\n", means, numPeaks, minMaxDiffs, deviations];
     NSLog(@"--- %@",featuresInWindow);
     NSString *txt = [NSString stringWithFormat:@"%.3f,%.3f,%.3f,%.3f\n",means, numPeaks, minMaxDiffs, deviations];
     
     [self.history appendString:txt];
     */
}

@end
