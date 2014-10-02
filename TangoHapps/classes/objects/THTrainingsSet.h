//
//  THTrainingsSet.h
//  TangoHapps
//
//  Created by Michael Conrads on 01/05/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "THFeatureSet.h"
@interface THTrainingsSet : NSObject
//+ (instancetype)trainingsSetWithFilepaths:(NSArray *)filePaths;

//- (void)fillPrimitivesFeatures:(double ***)features
//                        labels:(short **)labels
//                      nSamples:(int *)nSamples
//                     nFeatures:(int *)nFeatures;


@property (nonatomic, strong, readwrite) NSArray *featureSets;

- (void)addFeatureSet:(THFeatureSet *)featureSet;
@end
