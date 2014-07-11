//
//  THMacbookEditable.m
//  TangoHapps
//
//  Created by Michael Conrads on 11/07/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THMacbookEditable.h"

@implementation THMacbookEditable


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
