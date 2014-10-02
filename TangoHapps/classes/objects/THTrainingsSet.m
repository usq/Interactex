//
//  THTrainingsSet.m
//  TangoHapps
//
//  Created by Michael Conrads on 01/05/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THTrainingsSet.h"
#import "Helper.h"

@interface THTrainingsSet ()
@property (nonatomic, strong, readwrite) NSMutableArray *allInputs;
@property (nonatomic, strong, readwrite) NSMutableArray *labels;
@end

@implementation THTrainingsSet

+ (instancetype)trainingsSetWithFilepaths:(NSArray *)filePaths
{
    THTrainingsSet *trainingsSet = [[self alloc] init];
    
}

- (void)addFeatureSet:(THFeatureSet *)featureSet
{
    self.
}

- (void)fillPrimitivesFeatures:(double ***)features
                        labels:(short **)labels
                      nSamples:(int *)nSamples
                     nFeatures:(int *)nFeatures
{
    NSParameterAssert([self.allInputs count] > 0);                      //we have at lease one input
    NSParameterAssert([self.labels count] == [self.allInputs count]);   //every input has a label
    NSParameterAssert([[self.allInputs firstObject] count] > 0);        //we have at least one feature per input
    
    NSInteger inputCount = [self.allInputs count];
    NSInteger featuresCount = [[self.allInputs firstObject] count];
    
    *nSamples = inputCount;
    *nFeatures = featuresCount;
    
    *features = [Helper emptyMatrixWithN:inputCount m:featuresCount];
    *labels = malloc(inputCount * sizeof(short));

    
    for (int n = 0; n < [self.allInputs count]; n++)
    {
        NSArray *inputVector = self.allInputs[n];
     
        NSParameterAssert([inputVector count] == featuresCount);           //every input has same number of features
        
        for (int i = 0; i < [inputVector count]; i++)
        {
            (*features)[n][i] = [inputVector[i] doubleValue];
        }
        
        (*labels)[n] = [self.labels[n] integerValue];
    }
}





@end
