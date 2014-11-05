//
//  THProjectLocation.m
//  TangoHapps
//
//  Created by Michael Conrads on 05/10/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THProjectLocation.h"

static BOOL bAppRunning = NO;

@implementation THProjectLocation
+ (instancetype)sharedProjectLocation
{
    static THProjectLocation* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[THProjectLocation alloc] init];
        instance.runningOnLocation = THProjectLocationRunningOnIPad;
    });
    return instance;
}

+ (BOOL)appRunning
{
    return bAppRunning;
}

+ (void)setAppRunning:(BOOL)value
{
    bAppRunning = value;
}
@end
