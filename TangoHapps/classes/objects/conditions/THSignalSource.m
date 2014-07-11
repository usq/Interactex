//
//  THSignalSource.m
//  TangoHapps
//
//  Created by Michael Conrads on 27/02/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THSignalSource.h"
#import "THGestureRecognizer.h"

#define RECORDED_MAXCOUNT 500


Signal THDecodeSignal(uint32_t input)
{
    uint16_t value1 = ntohs((uint16_t)input);
    input >>= 16;
    uint16_t value2 = ntohs((uint16_t)input);
    //NSLog(@"value1: %i",value1);
    Signal s = {};
    s.value1 = value1;
    s.value2 = value2;
    
    return s;
}

@interface THSignalSource ()

@property (nonatomic, assign, readwrite) uint32_t currentOutputValue;
@property (nonatomic, strong, readwrite) NSArray *data;
@property (nonatomic, strong, readwrite) NSMutableArray *recordedData;
@property (nonatomic, assign, readwrite) BOOL sendingData;

@property (nonatomic, assign, readwrite) NSUInteger index;
@property (nonatomic, assign, readwrite) NSUInteger leftIndex;
@property (nonatomic, assign, readwrite) NSUInteger rightIndex;

@property (nonatomic, assign, readwrite) float leftBorderPercentage;
@property (nonatomic, assign, readwrite) float rightBorderPercentage;
@property (nonatomic, copy, readwrite) NSString *currentFilePath;
@end


NSString * const kSignalSourceEditableLeftPercentage = @"kSignalSourceEditableLeftPercentage";
NSString * const kSignalSourceEditableRightPercentage = @"kSignalSourceEditableRightPercentage";
NSString * const kSignalSourceCurrentFilePath = @"kSignalSourceCurrentFilePath";
    static id instance;
@implementation THSignalSource

+ (instancetype)sharedSignalSource
{
    assert(instance != nil);
    return instance;
}

- (void)load
{

    instance = self;
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


- (void)recordValue:(uint32_t)value
{
    while([self.recordedData count] > RECORDED_MAXCOUNT)
    {
        [self.recordedData removeObjectAtIndex:0];
    }
    [self.recordedData addObject:@(value)];
    
    Signal signal = THDecodeSignal(value);
    [[THGestureRecognizer sharedRecognizer] observeSignal:signal];
    
    self.currentOutputValue = value;
    [self triggerEventNamed:kEventValueChanged];
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
        
        self.currentOutputValue = [self.data[self.index] integerValue];
        [self triggerEventNamed:kEventValueChanged];
//        [self triggerEventNamed:kEventValueChanged];
        
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
    self = [super init];
    if (self) {
        _leftBorderPercentage = 0;
        _rightBorderPercentage = 1;
        [self load];
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

- (void)addDataFromGlove:(uint32_t)data
{
    TFEvent * event = [self.events firstObject];
    self.currentOutputValue = data;
    [[NSNotificationCenter defaultCenter] postNotificationName:event.name
                                                        object:self];

//    [self triggerEventNamed:kEventValueChanged];
}
@end
