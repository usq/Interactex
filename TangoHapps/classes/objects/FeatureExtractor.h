//
//  FeatureExtractor.h
//  AccelerometerStore
//
//  Created by Juan Haladjian on 05/02/14.
//  Copyright (c) 2014 Technical University Munich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeatureExtractor : NSObject

-(double) computeMagnitudeAveragesFromWindow:(const float*) window count:(int) count;

-(void) computeMeansFromWindow:(const float*) window count:(int) count means:(double*) means;

-(void) computeDeviationsFromWindow:(const float*) window count:(int) count usingMeans:(double*) means deviations:(double*) deviations ;

-(void) computeCorrelationsFromWindow:(const float*) window count:(int) count correlations:(double*) correlations;


-(void) computeMinMaxsFromWindow:(const float*) window count:(int) count peaks:(double*) minMaxs;

-(void) computeMinMaxDiffsFromWindow:(const float*) window count:(int) count diffs:(double*) diffs;

-(int) computeNumPeaksFromWindow:(const float*) window count:(int) count tolerance:(float) tolerance;

-(void) computeAllFeaturesFromWindow:(const float*) window count:(int) count features:(double*) features;

@property (nonatomic) float peakDetectionTolerance;

@end
