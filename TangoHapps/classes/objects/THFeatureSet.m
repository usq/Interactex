//
//  THFeatureSet.m
//  TangoHapps
//
//  Created by Michael Conrads on 02/10/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THFeatureSet.h"
#import "FeatureExtractor.h"

@interface THFeatureSet ()
@property (nonatomic, strong, readwrite) NSArray *features;
@end

@implementation THFeatureSet

- (instancetype)initWithFeatures:(NSArray *)features
{
    self = [super init];
    if (self)
    {
        self.features = features;
    }
    return self;
}


//
//
//- (void)fillPrimitivesFeatures:(double ***)features
//                        labels:(short **)labels
//                      nSamples:(int *)nSamples
//                     nFeatures:(int *)nFeatures
//{
//    NSParameterAssert([self.allInputs count] > 0);                      //we have at lease one input
//    NSParameterAssert([self.labels count] == [self.allInputs count]);   //every input has a label
//    NSParameterAssert([[self.allInputs firstObject] count] > 0);        //we have at least one feature per input
//    
//    NSInteger inputCount = [self.allInputs count];
//    NSInteger featuresCount = [[self.allInputs firstObject] count];
//    
//    *nSamples = inputCount;
//    *nFeatures = featuresCount;
//    
//    *features = [Helper emptyMatrixWithN:inputCount m:featuresCount];
//    *labels = malloc(inputCount * sizeof(short));
//    
//    
//    for (int n = 0; n < [self.allInputs count]; n++)
//    {
//        NSArray *inputVector = self.allInputs[n];
//        
//        NSParameterAssert([inputVector count] == featuresCount);           //every input has same number of features
//        
//        for (int i = 0; i < [inputVector count]; i++)
//        {
//            (*features)[n][i] = [inputVector[i] doubleValue];
//        }
//        
//        (*labels)[n] = [self.labels[n] integerValue];
//    }
//}
//
//

@end
