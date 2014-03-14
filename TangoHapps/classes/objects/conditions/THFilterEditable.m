//
//  THFilterEditable.m
//  TangoHapps
//
//  Created by Michael Conrads on 13/03/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THFilterEditable.h"
#import "THFilter.h"
#import "THFilterProperties.h"

@implementation THFilterEditable
- (void)load
{
    
    self.sprite = [CCSprite spriteWithFile:@"filter.png"];
    [self addChild:self.sprite];
    
    self.acceptsConnections = YES;
}


- (id)init
{
    self = [super init];
    if(self){
        self.simulableObject = [[THFilter alloc] init];
        [self load];
    }
    return self;
}


- (void)addInput:(float)input
{
    [(THFilter *)self.simulableObject addInput:input];
}

- (NSString *)description
{
    return @"Filter";
}

- (void)setNumberOfSamples:(NSUInteger)numberOfSamples
{
    ((THFilter *)self.simulableObject).numberOfSamples = numberOfSamples;
}

- (NSUInteger)numberOfSamples
{
    return ((THFilter *)self.simulableObject).numberOfSamples;
}


#pragma mark - Property Controller

- (NSArray *)propertyControllers
{
    NSArray *controllers = [super propertyControllers];
    THFilterProperties *properties = [THFilterProperties properties];
    properties.editableObject = self;
    //add property-controllers here
    return [controllers arrayByAddingObject:properties];
}



#pragma mark - Archiving

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if(self){
        [self load];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
}

- (id)copyWithZone:(NSZone *)zone {
    THFilterEditable * copy = [super copyWithZone:zone];
    return copy;
}



@end
