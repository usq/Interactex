//
//  THMacbookCommandEditable.m
//  TangoHapps
//
//  Created by Michael Conrads on 05/10/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THMacbookCommandEditable.h"
#import "THMacbookCommand.h"
#import "THMacbookCommandProperties.h"
@implementation THMacbookCommandEditable
- (void)load
{
    
    self.sprite = [CCSprite spriteWithFile:@"macbookCommand.png"];
    [self addChild:self.sprite];
    
    self.acceptsConnections = YES;
}
- (id)init
{
    self = [super init];
    if(self){
        self.simulableObject = [[THMacbookCommand alloc] init];
        [self load];
    }
    return self;
}


- (NSString *)description
{
    return @"MacbookCommand";
}


#pragma mark - Property Controller

- (NSArray *)propertyControllers
{
    NSArray *controllers = [super propertyControllers];
    THMacbookCommandProperties *properties = [THMacbookCommandProperties properties];
    properties.editableObject = self;
    //add property-controllers here
    return [controllers arrayByAddingObject:properties];
}



#pragma mark - Archiving

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if(self)
    {
        [self load];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
}

- (id)copyWithZone:(NSZone *)zone {
    THMacbookCommandEditable * copy = [super copyWithZone:zone];
    return copy;
}


@end
