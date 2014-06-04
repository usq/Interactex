//
//  Classifier.h
//  AccelerometerStore
//
//  Created by Juan Haladjian on 03/02/14.
//  Copyright (c) 2014 Technical University Munich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "THTrainingsSet.h"

@interface Classifier : NSObject {
    double ** input;
    double ** scaleMatrix;
    short * inputLabels;
}

@property (nonatomic) NSInteger inputCount;
@property (nonatomic) NSInteger featuresCount;
@property (nonatomic) NSInteger numberIterations;
@property (nonatomic) double learningRate;

-(void) loadScalingMatrixFromFile:(NSString*) file;

-(void) loadTrainingDataFromFile:(NSString*) fileName;

- (void)loadTrainingDataFromTrainingsSet:(THTrainingsSet *)trainingsSet;

-(short) classifyInputVector:(double*) input ignore:(int) ignore;

-(void) scaleInput;

-(void) testFile:(NSString*) fileName;

-(void) calculateScaleMatrix;

@end
