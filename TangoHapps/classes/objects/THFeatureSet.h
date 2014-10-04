//
//  THFeatureSet.h
//  TangoHapps
//
//  Created by Michael Conrads on 02/10/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface THFeatureSet : NSObject
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, strong, readonly) NSArray *scaledFeatures;
- (instancetype)initWithFeatures:(NSArray *)features;
- (instancetype)initWithFeatures:(NSArray *)features
                            name:(NSString *)name;
@end
