//
//  THGestureSet.h
//  TangoHapps
//
//  Created by Michael Conrads on 03/05/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface THGestureSet : NSObject
@property (nonatomic, copy, readonly) NSArray *gestures;

+ (NSArray *)savedGestureSets;
@end
