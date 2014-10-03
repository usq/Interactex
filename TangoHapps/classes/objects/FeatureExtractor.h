//
//  FeatureExtractor.h
//  AccelerometerStore
//
//  Created by Juan Haladjian on 05/02/14.
//  Copyright (c) 2014 Technical University Munich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "THSignalSource.h"

#define FEATURE_COUNT 20

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



- (void)computeMinMaxDiffsFromWindow:(const float*) window count:(int) count diffs:(double*) diffs;




- (void)computeMinMaxsFromWindow:(Signal *)window
                           count:(int)count
                           peaks:(double [5][2])minMaxs;



- (void)computeNumPeaksFromWindow:(Signal *)window
                            count:(int)count
                        tolerance:(float)tolerance
                         numPeaks:(NSInteger *)numPeaks;


- (void)computeAllFeaturesFromWindow:(Signal*)window
                               count:(int)count
                            features:(double *)features
                        featureCount:(int *)featureCount;



@property (nonatomic) float peakDetectionTolerance;

@end
