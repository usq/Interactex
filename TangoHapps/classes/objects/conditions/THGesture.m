//
//  THGesture.m
//  TangoHapps
//
//  Created by Michael Conrads on 13/03/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THGesture.h"
#define HALF_WINDOW_SIZE_DEFAULT 30
//#define WINDOW_SIZE (HALF_WINDOW_SIZE*2)

@interface THGesture()
@property (nonatomic, assign, readwrite) float *signalWindow;
@property (nonatomic, assign, readwrite) NSUInteger index;
@property (nonatomic, assign, readwrite) BOOL gestureIsAlreadyRecognized;

@end

@implementation THGesture

- (void)load
{
//    TFProperty * propertyOut = [TFProperty propertyWithName:@"outputValue" andType:kDataTypeFloat];
//    TFProperty * propertyIn = [TFProperty propertyWithName:@"inputValue" andType:kDataTypeFloat];
//    
//    self.properties = [NSMutableArray arrayWithObjects:propertyOut, propertyIn, nil];
//    
    TFMethod *inputMethod = [TFMethod methodWithName:@"addSignal"];
    inputMethod.numParams = 1;
    inputMethod.firstParamType = kDataTypeFloat;
    self.methods = [NSMutableArray arrayWithObject:inputMethod];

    TFEvent * eventRecongnized = [TFEvent eventNamed:kEventRecognized];
    TFEvent * eventNotRecognized = [TFEvent eventNamed:kEventNotRecognized];
//    event.param1 = [TFPropertyInvocation invocationWithProperty:propertyOut
//                                                         target:self];
    self.events = [NSMutableArray arrayWithObjects:eventRecongnized, eventNotRecognized,nil];

    self.index = 0;
    self.gestureIsAlreadyRecognized = NO;
    if(self.numberOfTicksToDetect == 0)
    {
        self.numberOfTicksToDetect = 1;
    }
    self.signalWindow = calloc(self.halfWindowSize * 2, sizeof(float));
}

- (void)addSignal:(float)signal
{
    signal = 300 -signal;
    
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
        
        [self checkWindow];
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
    
    self.signalWindow = calloc(_halfWindowSize * 2, sizeof(float));
    self.index = 0;
}

- (void)checkWindow
{
    NSLog(@"checking window %i", self.halfWindowSize);
    
    int numPeaks = [self computeNumPeaksFromWindow:self.signalWindow
                                             count:self.halfWindowSize * 2
                                         tolerance:100];
    
    NSLog(@"number of peaks: %i",numPeaks);
    if(numPeaks == self.numberOfTicksToDetect)
    {
        if(self.gestureIsAlreadyRecognized == NO)
        {
            self.gestureIsAlreadyRecognized = YES;

            [self triggerEventNamed:kEventRecognized];
            
        }
    }
    else
    {
        self.gestureIsAlreadyRecognized = NO;
        [self triggerEventNamed:kEventNotRecognized];
    }
}

-(int) computeNumPeaksFromWindow:(const float*) window count:(int) count tolerance:(float) tolerance{
    
    float min = NSIntegerMax;
    float max = NSIntegerMin;
    
    BOOL lookForMax = YES;
    int peakCount = 0;
    
    for(int i = 0 ; i < count; i++){
        
        double value = window[i];
        
        if(value > max){
            max = value;
        }
        
        if(value < min){
            min = value;
        }
        
        if(lookForMax)
        {
            if(value < max - tolerance){
                min = value;
                lookForMax = 0;
                peakCount++;
            }
        } else{
            if(value > min + tolerance){
                max = value;
                lookForMax = 1;
            }
        }
    }
    
    return peakCount;
}

- (void)dealloc
{
    free((void *)self.signalWindow);
}

-(void) computeAllFeaturesFromWindow:(const float*) window count:(int) count features:(double*) features
{
//    
//    double means[3];
//    double deviations[3];
//    double minMaxDiffs[3];
//    double correlations[3];
//    NSInteger numPeaks;
//    double magnitude;
//    
//    numPeaks = [self computeNumPeaksFromWindow:window count:count  tolerance:self.peakDetectionTolerance];

    //magnitude = [self computeMagnitudeAveragesFromWindow:window count:count];
    
//    features[0] = means[1];
//    features[1] = magnitude;
//    features[2] = deviations[1];
//    features[3] = minMaxDiffs[1];
//    features[4] = numPeaks;
//    features[5] = correlations[0];
//    features[6] = correlations[1];
//    features[7] = correlations[2];
}



#pragma mark - Archiving

- (id)init
{
    self = [super init];
    if (self)
    {
        self.numberOfTicksToDetect = 1;
        self.halfWindowSize = HALF_WINDOW_SIZE_DEFAULT;
        NSLog(@"!!!!!!!!!!!!!!!!!! numberOfTicksToDetect is 1");
        [self load];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    self.numberOfTicksToDetect = [decoder decodeIntForKey:@"numberOfTicks"];
    self.halfWindowSize = [decoder decodeIntForKey:@"halfWindowSize"];
    if(self.halfWindowSize == 0)
    {
        self.halfWindowSize = HALF_WINDOW_SIZE_DEFAULT;
    }
    [self load];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeInt:self.numberOfTicksToDetect forKey:@"numberOfTicks"];
    [coder encodeInt:self.halfWindowSize forKey:@"halfWindowSize"];
}

-(id)copyWithZone:(NSZone *)zone
{
    THGesture *copy = [super copyWithZone:zone];
    copy.numberOfTicksToDetect = self.numberOfTicksToDetect;
    copy.halfWindowSize = self.halfWindowSize;
    return copy;
}

@end
