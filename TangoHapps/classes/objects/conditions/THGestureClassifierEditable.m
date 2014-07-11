//
//  THGestureEditable.m
//  TangoHapps
//
//  Created by Michael Conrads on 13/03/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THGestureClassifierEditable.h"
#import "THGestureClassifier.h"
#import "THGestureClassifierProperties.h"

@implementation THGestureClassifierEditable
- (void)load
{   
    self.sprite = [CCSprite spriteWithFile:@"gesture.png"];
    [self addChild:self.sprite];
    
    self.acceptsConnections = YES;
}


- (id)init
{
    self = [super init];
    if(self)
    {
        self.simulableObject = [[THGestureClassifier alloc] init];
        [self load];
    }
    return self;
}


- (NSString *)description
{
    return @"Gesture";
}

- (void)addSignal:(float)signal
{
    [((THGestureClassifier *)self.simulableObject) addSignal:signal];
}



//- (void)setNumberOfTicksToDetect:(int)numberOfTicksToDetect
//{
//    NSLog(@"settingL %i", numberOfTicksToDetect);
//    ((THGestureClassifier *)self.simulableObject).numberOfTicksToDetect = numberOfTicksToDetect;
//}

- (int)numberOfTicksToDetect
{
    int n = ((THGestureClassifier *)self.simulableObject).numberOfTicksToDetect;
            NSLog(@"returning %i", n);
    return n;
}

- (NSUInteger)halfWindowSize
{
    return ((THGestureClassifier *)self.simulableObject).halfWindowSize;
}

- (void)setHalfWindowSize:(NSUInteger)halfWindowSize
{
    ((THGestureClassifier *)self.simulableObject).halfWindowSize = halfWindowSize;
}











#pragma mark - Property Controller

- (NSArray *)propertyControllers
{
    NSArray *controllers = [super propertyControllers];
    THGestureClassifierProperties *properties = [THGestureClassifierProperties properties];
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

- (id)copyWithZone:(NSZone *)zone
{
    THGestureClassifierEditable * copy = [super copyWithZone:zone];
    return copy;
}




@end
