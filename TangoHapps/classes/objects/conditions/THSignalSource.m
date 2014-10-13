//
//  THSignalSource.m
//  TangoHapps
//
//  Created by Michael Conrads on 27/02/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THSignalSource.h"
#import "THGestureRecognizer.h"
#import "THProjectLocation.h"
#import "THGestureBLEConnector.h"

#define RECORDED_MAXCOUNT 500


uint16_t uint16FromBytes(uint8_t high, uint8_t low)
{
    uint16_t s = high;
    s <<= 8;
    s |= low;
    return s;
}

int16_t int16FromBytes(uint8_t high, uint8_t low)
{
    int16_t s = high;
    s <<= 8;
    s |= low;
    return s;
}


Signal THDecodeSignal(uint8_t *input)
{
    Signal s = {};
    s.finger1 = uint16FromBytes(input[0], input[1]);
    s.finger2 = uint16FromBytes(input[2], input[3]);
    s.accX = int16FromBytes(input[4], input[5]);
    s.accY = int16FromBytes(input[6], input[7]);
    s.accZ = int16FromBytes(input[8], input[9]);
    
    return s;
}


@interface THSignalSource ()

@property (nonatomic, assign, readwrite) Signal currentOutputValue;
@property (nonatomic, strong, readwrite) NSArray *data;
@property (nonatomic, strong, readwrite) NSMutableArray *recordedData;
@property (nonatomic, assign, readwrite) BOOL sendingData;

@property (nonatomic, assign, readwrite) NSUInteger index;
@property (nonatomic, assign, readwrite) NSUInteger leftIndex;
@property (nonatomic, assign, readwrite) NSUInteger rightIndex;

@property (nonatomic, assign, readwrite) float leftBorderPercentage;
@property (nonatomic, assign, readwrite) float rightBorderPercentage;
@property (nonatomic, copy, readwrite) NSString *currentFilePath;
@property (nonatomic, assign, readwrite) int16_t lastX;
@property (nonatomic, assign, readwrite) int16_t lastY;
@property (nonatomic, assign, readwrite) int16_t lastZ;
@end

static THSignalSource* instance;
NSString * const kSignalSourceEditableLeftPercentage = @"kSignalSourceEditableLeftPercentage";
NSString * const kSignalSourceEditableRightPercentage = @"kSignalSourceEditableRightPercentage";
NSString * const kSignalSourceCurrentFilePath = @"kSignalSourceCurrentFilePath";

@implementation THSignalSource

+ (instancetype)sharedSignalSource
{
    if(instance == nil)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[self alloc] init];
        });
    }
    return instance;
}

- (void)load
{
//    assert(instance == nil);
//    instance = self;
    self.lastX = self.lastY = self.lastZ = 0;
    
    TFProperty * property = [TFProperty propertyWithName:@"currentOutputValue" andType:kDataTypeInteger];
    self.properties = [NSMutableArray arrayWithObject:property];
    
    TFMethod *startMethod = [TFMethod methodWithName:@"start"];
    TFMethod *stopMethod = [TFMethod methodWithName:@"stop"];
    TFMethod *toggleMethod = [TFMethod methodWithName:@"toggle"];
    
    self.methods = [NSMutableArray arrayWithObjects:startMethod, stopMethod, toggleMethod, nil];
    
    TFEvent *event = [TFEvent eventNamed:kEventValueChanged];
    event.param1 = [TFPropertyInvocation invocationWithProperty:property
                                                         target:self];
    self.events = [NSMutableArray arrayWithObject:event];
    
    if(self.currentFilePath == nil)
    {
        self.currentFilePath = @"singletick";
    }
    if(self.data == nil)
    {
       // [self switchSourceFile:self.currentFilePath];
    }
    
    if(self.simulating)
    {
        
    }
    
    if([THProjectLocation sharedProjectLocation].runningOnLocation == THProjectLocationRunningOnIPhone)
    {
        [[THGestureBLEConnector sharedConnector] registerSignalSource:self];
        [[THGestureBLEConnector sharedConnector] start];
    }
}


- (void)updateIndizes
{
    self.leftIndex = floor((float)([self.data count] -1) * self.leftBorderPercentage) - 1;
    self.rightIndex = floor((float)([self.data count] -1) * self.rightBorderPercentage);
    if (self.rightIndex == 0)
    {
        self.rightIndex = [self.data count]-1;
    }
    self.index = self.leftIndex;
}

- (void)setLeftBorderPercentage:(float)leftBorderPercentage
{
    _leftBorderPercentage = leftBorderPercentage;
    [self updateIndizes];
}

- (void)setRightBorderPercentage:(float)rightBorderPercentage
{
    _rightBorderPercentage = rightBorderPercentage;
    [self updateIndizes];
}

- (void)startRecording
{
    self.recordedData = [NSMutableArray array];
}

- (void)stopRecording
{
    //TODO: saveRecorded data
    self.data = [self.recordedData copy];
}

- (void)saveRecording
{
    
    NSMutableArray *a = [NSMutableArray array];
    
    int i = [self.data count] *_rightBorderPercentage;
    int m = [self.data count] * fmin(fmax((1 - _leftBorderPercentage),0),1);
    
    for ( ; i < m; i++)
    {
        [a addObject:self.data[i]];
    }
    
    [[THGestureRecognizer sharedRecognizer] printFeaturesForWindow:self.data];
}


- (void)recordValue:(Signal)value
{
    while([self.recordedData count] > RECORDED_MAXCOUNT)
    {
        [self.recordedData removeObjectAtIndex:0];
    }
    
    float f = 0.3;

    value.accX = value.accX * f + self.lastX * (1-f);
    value.accY = value.accY * f + self.lastY * (1-f);
    value.accZ = value.accZ * f + self.lastZ * (1-f);
    
    self.lastX = value.accX;
    self.lastY = value.accY;
    self.lastZ = value.accZ;
    
    
    NSData *v = [NSData dataWithBytes:&value length:sizeof(Signal)];
    [self.recordedData addObject:v];
    
    
    THGestureRecognizer *r = [THGestureRecognizer sharedRecognizer];
    assert(r);
    assert([r isKindOfClass:[THGestureRecognizer class]]);
    
    [r observeSignal:value];
    
    self.currentOutputValue = value;
    //
    [self triggerEventNamed:kEventValueChanged
           ignoreSimulating:YES];
    
//    [self triggerEventNamed:kEventValueChanged];
}

#pragma mark - Methods

- (void)didStartSimulating
{
    [super didStartSimulating];
}

- (NSString *)description
{
    return @"SignalSource";
}

- (void)start
{
    self.index = self.leftIndex;
    self.sendingData = YES;
}

- (void)stop
{
    self.sendingData = NO;
}

- (void)toggle
{
    self.sendingData = !self.sendingData;
}

- (void)updatedSimulation
{
    [self sendSignalValues];
}

- (void)sendSignalValues
{
    if(self.sendingData)
    {
        if(self.index > [self.data count] -1)
        {
            self.index = 0;
        }
        
        Signal s;
        NSValue *wrappedSignal = self.data[self.index];
        
        [wrappedSignal getValue:&s];
        self.currentOutputValue = s;
        [self triggerEventNamed:kEventValueChanged];
        
        self.index ++;
        if(self.index > self.rightIndex)
        {
            
            self.index = self.leftIndex;
        }
    }
}


- (void)cropDataToPercentages
{
//    NSParameterAssert(indexRange.location >= 0 && [self.data count] <= indexRange.location + indexRange.length);
    
//    self.data = [self.data objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:indexRange]];
    _leftBorderPercentage = 0;
    _rightBorderPercentage = 1;
    
    [self updateIndizes];
}



#pragma mark - Archiving

- (id)init
{
    if(instance)
    {
        return instance;
    }
    else
    {
        self = [super init];
        if (self) {
            _leftBorderPercentage = 0;
            _rightBorderPercentage = 1;
            [self load];
        }
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];

    self.currentFilePath = [decoder decodeObjectForKey:kSignalSourceCurrentFilePath];
    
    _leftBorderPercentage = fmin([decoder decodeFloatForKey:kSignalSourceEditableLeftPercentage],1);
    _rightBorderPercentage = fmin([decoder decodeFloatForKey:kSignalSourceEditableRightPercentage],1);
    if(_rightBorderPercentage == 0)
    {
        _rightBorderPercentage = 1;
    }
    [self load];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeFloat:self.leftBorderPercentage forKey:kSignalSourceEditableLeftPercentage];
    [coder encodeFloat:self.rightBorderPercentage forKey:kSignalSourceEditableRightPercentage];
    [coder encodeObject:self.currentFilePath forKey:kSignalSourceCurrentFilePath];
}

- (id)copyWithZone:(NSZone *)zone
{
    THSignalSource *copy = [super copyWithZone:zone];
    copy.leftBorderPercentage = self.leftBorderPercentage;
    copy.rightBorderPercentage = self.leftBorderPercentage;
    return copy;
}

- (void)switchSourceFile:(NSString *)filename
{
    self.currentFilePath = filename;
    NSData *d = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.currentFilePath
                                                                               ofType:@"txt"]];
    assert(d != nil);
    
    NSString *content = [[NSString alloc] initWithData:d
                                              encoding:NSUTF8StringEncoding];
    
    self.data = [content componentsSeparatedByString:@"\n"];
    [self updateIndizes];

}

- (void)addDataFromGlove:(uint8_t *)data
                  length:(uint8_t)length
{
    TFEvent * event = [self.events firstObject];
    
    Signal s = THDecodeSignal(data);
    self.currentOutputValue = s;

    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:event.name
                                                        object:self];

//    [self triggerEventNamed:kEventValueChanged];
}
@end
