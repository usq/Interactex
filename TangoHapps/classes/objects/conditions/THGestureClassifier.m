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



//#define WINDOW_SIZE (HALF_WINDOW_SIZE*2)

@interface THGestureClassifier()
@property (nonatomic, assign, readwrite) Signal *signalWindow;
@property (nonatomic, assign, readwrite) NSUInteger index;
@property (nonatomic, assign, readwrite) BOOL gestureIsAlreadyRecognized;
@property (nonatomic, strong, readwrite) THGestureRecognizer *recognizer;
@property (nonatomic, assign, readwrite) BOOL *relaysInput;

@end

@implementation THGestureClassifier

- (void)load
{
    TFMethod *inputMethod = [TFMethod methodWithName:@"addSignal"];
    inputMethod.numParams = 1;
    inputMethod.firstParamType = kDataTypeFloat;
    self.methods = [NSMutableArray arrayWithObject:inputMethod];

    TFEvent * eventRecongnized = [TFEvent eventNamed:kEventRecognized];
    TFEvent * eventNotRecognized = [TFEvent eventNamed:kEventNotRecognized];

    self.events = [NSMutableArray arrayWithObjects:eventRecongnized, eventNotRecognized,nil];
    
    self.relaysInput = [[THGestureRecognizer sharedRecognizer] registerGesture:self];
    
    self.index = 0;
}

- (void)addSignal:(uint32_t)signal
{
    Signal s = THDecodeSignal(signal);
    //signal = 300 -signal;
    if(self.relaysInput)
    {
        [self.recognizer observeSignal:s];
    }
}

- (void)setHalfWindowSize:(NSUInteger)halfWindowSize
{
    
    self.recognizer.halfWindowSize = halfWindowSize;
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
    [coder encodeInt:self.numberOfTicksToDetect forKey:@"numberOfTicks"];
    [coder encodeInt:self.halfWindowSize forKey:@"halfWindowSize"];
}

-(id)copyWithZone:(NSZone *)zone
{
    
    THGestureClassifier *copy = [super copyWithZone:zone];
    copy.numberOfTicksToDetect = self.numberOfTicksToDetect;
//    copy.halfWindowSize = self.halfWindowSize;
    return copy;
}

@end
