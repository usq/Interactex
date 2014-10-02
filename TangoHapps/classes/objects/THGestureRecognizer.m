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



@interface THGestureRecognizer ()
@property (nonatomic, assign, readwrite) Signal *signalWindow;
@property (nonatomic, strong, readwrite) NSMutableArray *registeredGestures;
@property (nonatomic, strong, readwrite) Classifier *classifier;
@property (nonatomic, strong, readwrite) FeatureExtractor *featureExtractor;

@property (nonatomic, assign, readwrite) NSUInteger index;

@property (nonatomic, strong, readwrite) NSMutableString *history;


@property (nonatomic, assign, readwrite) BOOL trainedGesture;
@end

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


- (BOOL)registerGesture:(THGestureClassifier *)gesture
{
    if([self.registeredGestures containsObject:gesture] == NO)
    {
        [self.registeredGestures addObject:gesture];
    }

    return [self.registeredGestures count];
}


//- (void)trainRecognizerWithTrainingSet:(THTrainingsSet *)trainingsSet
//{
//    NSLog(@"training new set");
//    [self.classifier loadTrainingDataFromTrainingsSet:trainingsSet];
//}

- (void)observeSignal:(Signal)signal
{
    //correctSignal
    
    if(self.index == self.halfWindowSize)
    {
        for (int i = self.halfWindowSize; i < self.halfWindowSize * 2; i++)
        {
            self.signalWindow[i - self.halfWindowSize] = self.signalWindow[i];
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
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    NSArray *gestureFeatureSets = gesture.trainedFeatureSets;
    
    if(self.trainedGesture == NO)
    {
        [self.classifier appendFeatureSets:@[[gestureFeatureSets lastObject]]
                                  forLabel:9999];
        NSLog(@"inserted 0 vector");
    }
    else
    {
        [self.classifier appendFeatureSets:@[[gestureFeatureSets lastObject]]
                                  forLabel:gesture.label];
        
    }
    
    self.trainedGesture = YES;
    

    
//    - (void)fillPrimitivesFeatures:(double ***)features
//labels:(short **)labels
//nSamples:(int *)nSamples
//nFeatures:(int *)nFeatures
//    {
//        NSParameterAssert([self.allInputs count] > 0);                      //we have at lease one input
//        NSParameterAssert([self.labels count] == [self.allInputs count]);   //every input has a label
//        NSParameterAssert([[self.allInputs firstObject] count] > 0);        //we have at least one feature per input
//        
//        NSInteger inputCount = [self.allInputs count];
//        NSInteger featuresCount = [[self.allInputs firstObject] count];
//        
//        *nSamples = inputCount;
//        *nFeatures = featuresCount;
//        
//        *features = [Helper emptyMatrixWithN:inputCount m:featuresCount];
//        *labels = malloc(inputCount * sizeof(short));
//        
//        
//        for (int n = 0; n < [self.allInputs count]; n++)
//        {
//            NSArray *inputVector = self.allInputs[n];
//            
//            NSParameterAssert([inputVector count] == featuresCount);           //every input has same number of features
//            
//            for (int i = 0; i < [inputVector count]; i++)
//            {
//                (*features)[n][i] = [inputVector[i] doubleValue];
//            }
//            
//            (*labels)[n] = [self.labels[n] integerValue];
//        }
//    }

    
}


- (void)checkWindow
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    double features[8];
    int featureCount;
    [self.featureExtractor computeAllFeaturesFromWindow:self.signalWindow
                                                  count:self.halfWindowSize *2
                                               features:features
                                           featureCount:&featureCount];
    
    
    short label = [self.classifier classifyInputVector:features
                                                ignore:-1];
    
    
    NSLog(@"--------------- i think its label %i",label);
    
    /*
    NSLog(@"--", self.halfWindowSize);

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

    
    
    
    NSString *featuresInWindow = [NSString stringWithFormat:@"means: %.3f numPeaks: %.3f minmaxdiffs: %.3f  deviation: %.3f\n", means, numPeaks, minMaxDiffs, deviations];
    NSLog(@"%@",featuresInWindow);
    
    NSString *txt = [NSString stringWithFormat:@"%.3f,%.3f,%.3f,%.3f\n",means, numPeaks, minMaxDiffs, deviations];
    
    [self.history appendString:txt];



    int numPeaks = [self computeNumPeaksFromWindow:self.signalWindow
                                             count:self.halfWindowSize * 2
                                         tolerance:100];
    */
    
    
    
//    int numPeaks =[self.featureExtractor computeNumPeaksFromWindow:self.signalWindow
//                                                             count:self.halfWindowSize *2 / 3
//                                                         tolerance:20];
    
    

    
    
    int numPeaks = 0;
    for (THGestureClassifier *oneGesture in self.registeredGestures)
    {
        if(oneGesture.hasAlreadyBeenRecognized)
        {
            oneGesture.hasAlreadyBeenRecognized = NO;
        }
        else
        {
            if(oneGesture.numberOfTicksToDetect == numPeaks)
            {
                oneGesture.hasAlreadyBeenRecognized = YES;
                [oneGesture recognized];
            }
        }
    }
//    NSLog(@"-----numpeaks: %i",numPeaks);
}
//
//- (NSUInteger)peaksInWindow:(NSArray *)data
//{
//    self.featureExtractor.peakDetectionTolerance = 20;
//    self.halfWindowSize = [data count]/2;
//    
//    for (int i = 0; i < self.halfWindowSize*2; i++)
//    {
//        NSValue *v = data[i];
//        Signal s;
//        [v getValue:&s];
//        self.signalWindow[i] = s;
//    }
//    
//    int numPeaks =[self.featureExtractor computeNumPeaksFromWindow:self.signalWindow
//                                                             count:self.halfWindowSize *2 / 3
//                                                         tolerance:20];
//    
//    NSLog(@"number of peaks: %i",numPeaks);
//    /*
//    if(numPeaks == 2)
//    {
//        if(self.gestureIsAlreadyRecognized == NO)
//        {
//            self.gestureIsAlreadyRecognized = YES;
//            
//            [self triggerEventNamed:kEventRecognized];
//            
//        }
//    }
//    else
//    {
//        self.gestureIsAlreadyRecognized = NO;
//        [self triggerEventNamed:kEventNotRecognized];
//    }*/
//    return numPeaks;
//    
//}

- (THFeatureSet *)featureSetFromSignals:(NSArray *)signals
{
    Signal recordedSignals[[signals count]];
    
    for (int i = 0; i < [signals count]; i++)
    {
        Signal s;
        [signals[i] getValue:&s];
        recordedSignals[i] = s;
    }
    
    
    double features[25];
    int featureCount;
    [self.featureExtractor computeAllFeaturesFromWindow:recordedSignals
                                                  count:[signals count]
                                               features:features
                                           featureCount:&featureCount];
    NSMutableArray *featureArray = [NSMutableArray array];
    for (int i = 0; i < featureCount; i++)
    {
        [featureArray addObject:@(features[i])];
    }
    THFeatureSet *featureSet = [[THFeatureSet alloc] initWithFeatures:featureArray];
    return featureSet;
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
