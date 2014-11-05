//
//  THProjectLocation.h
//  TangoHapps
//
//  Created by Michael Conrads on 05/10/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, THProjectLocationRunningOn)
{
    THProjectLocationRunningOnIPhone,
    THProjectLocationRunningOnIPad
};

@interface THProjectLocation : NSObject
@property (nonatomic, assign, readwrite) THProjectLocationRunningOn runningOnLocation;
+ (instancetype)sharedProjectLocation;
+ (BOOL)appRunning;
+ (void)setAppRunning:(BOOL)value;
@end
