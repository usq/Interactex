//
//  FeatureExtractor.h
//  AccelerometerStore
//
//  Created by Juan Haladjian on 05/02/14.
//  Copyright (c) 2014 Technical University Munich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "THSignalSource.h"

@interface FeatureExtractor : NSObject

-(double) computeMagnitudeAveragesFromWindow:(const float*) window count:(int) count;

- (void)computeMeansFromWindow:(Signal *)window
                         count:(int)count
                         means:(double*)means;

- (void)computeDeviationsFromWindow:(Signal *)window
                              count:(int)count
                         usingMeans:(double *)means
                         deviations:(double *)deviations;


- (void)computeCorrelationsFromWindow:(Signal *)window
                                count:(int)count
                         correlations:(double *)correlations;


-(void) computeMinMaxsFromWindow:(const float*) window count:(int) count peaks:(double*) minMaxs;

-(void) computeMinMaxDiffsFromWindow:(const float*) window count:(int) count diffs:(double*) diffs;

-(int) computeNumPeaksFromWindow:(Signal *) window count:(int) count tolerance:(float) tolerance;

-(void) computeAllFeaturesFromWindow:(Signal*)window
                               count:(int) count
                            features:(double *)features;

@property (nonatomic) float peakDetectionTolerance;

@end
