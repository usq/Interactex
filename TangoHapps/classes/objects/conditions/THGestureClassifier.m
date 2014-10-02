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
#import "THAsyncConnection.h"



//#define WINDOW_SIZE (HALF_WINDOW_SIZE*2)

@interface THGestureClassifier()
@property (nonatomic, assign, readwrite) NSUInteger numberOfTicksToDetect;
@property (nonatomic, assign, readwrite) NSUInteger index;
@property (nonatomic, assign, readwrite) BOOL gestureIsAlreadyRecognized;
@property (nonatomic, strong, readwrite) THGestureRecognizer *recognizer;
@property (nonatomic, assign, readwrite) BOOL *relaysInput;
@property (nonatomic, strong, readwrite) NSArray *recordedValues;
@property (nonatomic, strong, readwrite) THAsyncConnection *connection;

@property (nonatomic, strong, readwrite) NSMutableArray *trainedFeatureSets;
@property (nonatomic, assign, readwrite) short label;
@end

@implementation THGestureClassifier

- (void)load
{
    self.hasAlreadyBeenRecognized = YES;
    self.trainedFeatureSets = [NSMutableArray array];
    
    TFMethod *inputMethod = [TFMethod methodWithName:@"addSignal"];
    inputMethod.numParams = 1;
    inputMethod.firstParamType = kDataTypeFloat;
    self.methods = [NSMutableArray arrayWithObject:inputMethod];

    TFEvent * eventRecongnized = [TFEvent eventNamed:kEventRecognized];
    TFEvent * eventNotRecognized = [TFEvent eventNamed:kEventNotRecognized];

    self.events = [NSMutableArray arrayWithObjects:eventRecongnized, eventNotRecognized,nil];
    
    
    self.label = [[THGestureRecognizer sharedRecognizer] registerGesture:self];
    self.relaysInput =  self.label == 1;
    
    self.recognizer = [THGestureRecognizer sharedRecognizer];
    self.index = 0;
    self.connection = [THAsyncConnection sharedConnection];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changedStuff:)
                                                 name:kEventValueChanged
                                               object:nil];
}

- (void)recognized
{
    NSLog(@"\n\nRECOGNIZED!!!!!!!!!!!!!!!\n");
    //gesture has been recognized
    [self.connection nextSlide:nil];
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
    THFeatureSet *featureSet = [self.recognizer featureSetFromSignals:gestureData];
    
    //add feature set to saved features
    [self.trainedFeatureSets addObject:featureSet];
    
    //retrain kNN
    [self.recognizer trainRecognizerWithGesture:self];
    
//    self.recordedValues = gestureData;
  
    //self.numberOfTicksToDetect = [self.recognizer peaksInWindow:self.recordedValues];
//    NSLog(@"Number of Peaks: %i",self.numberOfTicksToDetect);
}

#pragma mark - Archiving

- (id)init
{
    self = [super init];
    if (self)
    {
        self.numberOfTicksToDetect = 1;
        self.recognizer.halfWindowSize = HALF_WINDOW_SIZE_DEFAULT;
        [self load];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    self.numberOfTicksToDetect = [decoder decodeIntForKey:@"numberOfTicks"];
    self.recognizer.halfWindowSize = [decoder decodeIntForKey:@"halfWindowSize"];
    if(self.recognizer.halfWindowSize == 0)
    {
        self.recognizer.halfWindowSize = HALF_WINDOW_SIZE_DEFAULT;
    }
    [self load];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeInt:self.numberOfTicksToDetect
              forKey:@"numberOfTicks"];
    [coder encodeInt:self.halfWindowSize
              forKey:@"halfWindowSize"];
}

-(id)copyWithZone:(NSZone *)zone
{
    THGestureClassifier *copy = [super copyWithZone:zone];
    copy.numberOfTicksToDetect = self.numberOfTicksToDetect;
//    copy.halfWindowSize = self.halfWindowSize;
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
