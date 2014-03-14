//
//  THFilter.m
//  TangoHapps
//
//  Created by Michael Conrads on 13/03/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THFilter.h"

#define NUMBER_OF_SAMPLES_DEFAULT 10

@interface THFilter ()
@property (nonatomic, strong, readwrite) NSMutableArray *values;
@property (nonatomic, assign, readwrite) float outputValue;
@end

@implementation THFilter

- (void)load
{
    TFProperty * propertyOut = [TFProperty propertyWithName:@"outputValue" andType:kDataTypeFloat];
    TFProperty * propertyIn = [TFProperty propertyWithName:@"inputValue" andType:kDataTypeFloat];
    
    self.properties = [NSMutableArray arrayWithObjects:propertyOut, propertyIn, nil];
    
    TFMethod *inputMethod = [TFMethod methodWithName:@"addInput"];
    inputMethod.numParams = 1;
    inputMethod.firstParamType = kDataTypeFloat;
    self.methods = [NSMutableArray arrayWithObject:inputMethod];
    
    
    TFEvent * event = [TFEvent eventNamed:kEventValueChanged];

    event.param1 = [TFPropertyInvocation invocationWithProperty:propertyOut
                                                         target:self];
    self.events = [NSMutableArray arrayWithObject:event];
    
    self.values = [NSMutableArray array];
}


- (void)addInput:(float)input
{
    float ratio = 0.3;
    
    float avg = [[self.values valueForKeyPath:@"@avg.self"] floatValue];
    self.outputValue = input * ratio + avg * (1-ratio);
    
    [self.values addObject:@(self.outputValue)];
    
    while ([self.values count] > self.numberOfSamples)
    {
        [self.values removeObjectAtIndex:0];
    }
    
    [self triggerEventNamed:kEventValueChanged];
}


#pragma mark - Archiving

- (id)init
{
    self = [super init];
    if (self)
    {
        self.numberOfSamples = NUMBER_OF_SAMPLES_DEFAULT;
        [self load];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    self.numberOfSamples = [decoder decodeIntForKey:@"numberOfSamples"];
    if(self.numberOfSamples == 0)
    {
        self.numberOfSamples = NUMBER_OF_SAMPLES_DEFAULT;
    }
    [self load];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeInt:self.numberOfSamples forKey:@"numberOfSamples"];
}

-(id)copyWithZone:(NSZone *)zone
{
    THFilter *copy = [super copyWithZone:zone];
    copy.numberOfSamples = self.numberOfSamples;
    return copy;
}

@end
