//
//  THGesture.m
//  TangoHapps
//
//  Created by Michael Conrads on 13/03/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THGestureClassifier.h"
#import "THGestureRecognizer.h"
#import "THSignalSource.h"

#import "THProjectLocation.h"

NSString * kGestureClassifierShouldDeleteTraining = @"kGestureClassifierShouldDeleteTraining";

//#define WINDOW_SIZE (HALF_WINDOW_SIZE*2)

@interface THGestureClassifier()
@property (nonatomic, assign, readwrite) NSUInteger numberOfPeaks;
//@property (nonatomic, assign, readwrite) NSUInteger numberOfTicksToDetect;
@property (nonatomic, assign, readwrite) NSUInteger index;
@property (nonatomic, assign, readwrite) BOOL gestureIsAlreadyRecognized;
@property (nonatomic, strong, readwrite) THGestureRecognizer *recognizer;
@property (nonatomic, assign, readwrite) BOOL *relaysInput;
@property (nonatomic, strong, readwrite) NSArray *recordedValues;


@property (nonatomic, strong, readwrite) NSMutableArray *trainedFeatureSets;
@property (nonatomic, assign, readwrite) short label;
@end

@implementation THGestureClassifier

- (void)load
{
    self.hasAlreadyBeenRecognized = YES;
    if(self.trainedFeatureSets == nil)
    {
        self.trainedFeatureSets = [NSMutableArray array];
    }
    
    TFMethod *inputMethod = [TFMethod methodWithName:@"addSignal"];
    inputMethod.numParams = 1;
    inputMethod.firstParamType = kDataTypeFloat;
    self.methods = [NSMutableArray arrayWithObject:inputMethod];

    TFEvent * eventRecongnized = [TFEvent eventNamed:kEventRecognized];
    TFEvent * eventNotRecognized = [TFEvent eventNamed:kEventNotRecognized];

    self.events = [NSMutableArray arrayWithObjects:eventRecongnized, eventNotRecognized,nil];
    
    
    self.label = [[THGestureRecognizer sharedRecognizer] registerGesture:self];
    NSLog(@".............................................registered gesture with label:%i",self.label);
    NSLog(@"self.simulating: %i",self.simulating);
    self.relaysInput =  self.label == 1;
    
    self.recognizer = [THGestureRecognizer sharedRecognizer];
    self.index = 0;
    if(self.name== nil || [self.name isEqualToString:@""])
    {
        self.name = @"Gesture";
    }

    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changedStuff:)
                                                 name:kEventValueChanged
                                               object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(changedStuff:)
//                                                 name:@"singletonSignalChanged"
//                                               object:nil];
//    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(shouldDeleteTrainingNotification:)
                                                 name:kGestureClassifierShouldDeleteTraining
                                               object:nil];
    
    if([THProjectLocation sharedProjectLocation].runningOnLocation == THProjectLocationRunningOnIPhone)
    {
       // [[THSignalSource sharedSignalSource] connectBLE];
    }
}

- (void)willStartSimulating
{
    NSLog(@"will start simulating");
}


- (void)shouldDeleteTrainingNotification:(NSNotification *)notification
{
    NSUInteger index = [notification.userInfo[@"index"] unsignedIntegerValue];
    [self.trainedFeatureSets removeObjectAtIndex:index];
    [self.recognizer removeTrainingAtIndex:index
                                 withLabel:self.label
                                forGesture:self];
}

- (void)prepareToDie
{
    [[THGestureRecognizer sharedRecognizer] deregisterGesture:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[THSignalSource sharedSignalSource] prepareToDie];
}


- (void)recognized
{
    self.hasAlreadyBeenRecognized = YES;
    NSLog(@"\n\nRECOGNIZED!!!!!!!!!!!!!!!\n");
    [self triggerEventNamed:kEventRecognized
           ignoreSimulating:YES];
}

- (void)notRecognized
{
    
}

- (void)changedStuff:(NSNotification *)obj
{
    THSignalSource *src = obj.object;
    [self addSignal:src.currentOutputValue];
}

- (void)addSignal:(Signal)signal
{
    self.currentSignal = signal;
    if(self.relaysInput || TRUE)
    {
        [self.recognizer observeSignal:signal];
    }
}

- (void)setHalfWindowSize:(NSUInteger)halfWindowSize
{
    self.recognizer.halfWindowSize = halfWindowSize;
}


//extract features and save in gesture
- (void)finishedGesture:(NSArray *)gestureData
{
    //extract features
    NSString *featureName = [NSString stringWithFormat:@"Training %i", [self.trainedFeatureSets count] + 1];
    THFeatureSet *featureSet = [self.recognizer featureSetFromSignals:gestureData
                                name:featureName];
    
    __block NSUInteger numPeaks = 0;
    [featureSet.scaledFeatures enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSNumber *peakCount = (NSNumber *)obj;
        NSLog(@"adding peakcount%@",peakCount);
        numPeaks += [peakCount unsignedIntegerValue];
    }];
    self.numberOfPeaks = numPeaks;
    
        NSParameterAssert(self.numberOfPeaks < 1000);
    //add feature set to saved features
    [self.trainedFeatureSets addObject:featureSet];
    
    //retrain kNN
    [self.recognizer trainRecognizerWithGesture:self
                                addedFeatureSet:featureSet];
}

#pragma mark - Archiving

- (id)init
{
    self = [super init];
    if (self)
    {
        self.recognizer.halfWindowSize = HALF_WINDOW_SIZE_DEFAULT;
        [self load];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    self.recognizer.halfWindowSize = [decoder decodeIntForKey:@"halfWindowSize"];
    self.trainedFeatureSets = [decoder decodeObjectForKey:@"trainedFeatureSets"];
    self.label = [[decoder decodeObjectForKey:@"label"] shortValue];
    self.name = [decoder decodeObjectForKey:@"name"];
    self.numberOfPeaks = [[decoder decodeObjectForKey:@"mc_numberOfPeaks"] unsignedIntegerValue];
    
    NSParameterAssert(self.numberOfPeaks < 1000);
    if(self.recognizer.halfWindowSize == 0)
    {
        self.recognizer.halfWindowSize = HALF_WINDOW_SIZE_DEFAULT;
    }
    [self load];
    [self.recognizer trainRecognizerWithGesture:self];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeInt:self.halfWindowSize
              forKey:@"halfWindowSize"];
    [coder encodeObject:self.trainedFeatureSets
                 forKey:@"trainedFeatureSets"];
    [coder encodeObject:@(self.label)
                 forKey:@"label"];
    [coder encodeObject:self.name
                 forKey:@"name"];
    
    NSParameterAssert(self.numberOfPeaks < 1000);
    [coder encodeObject:[NSNumber numberWithUnsignedInteger:self.numberOfPeaks]
                 forKey:@"mc_numberOfPeaks"];
}

-(id)copyWithZone:(NSZone *)zone
{
    THGestureClassifier *copy = [super copyWithZone:zone];
    copy.trainedFeatureSets = self.trainedFeatureSets;
    copy.label = self.label;
    copy.name = self.name;
    copy.numberOfPeaks = self.numberOfPeaks;

    return copy;
}

- (void)printRecording
{
    NSLog(@"--------------------");
    for (NSNumber *n in self.recordedValues)
    {
        uint32_t value = [n unsignedIntegerValue];
        Signal s = THDecodeSignal(value);
        printf("%i ",s.finger1);
    }
    printf("\n");
    NSLog(@"--------------------");
}
@end
