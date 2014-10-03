//
//  Classifier.m
//  AccelerometerStore
//
//  Created by Juan Haladjian on 03/02/14.
//  Copyright (c) 2014 Technical University Munich. All rights reserved.
//

#import "Classifier.h"
#import <float.h>
#import "Helper.h"

@implementation Classifier

const int kDefaultNumIterations = 10000;
const double kDefaultLearningRate = 0.01;

-(id) init{
    self = [super init];
    if(self){
        self.featuresCount = 0;
        self.numberIterations = kDefaultNumIterations;
        self.learningRate = kDefaultLearningRate;
    }
    return self;
}

-(void) nearestNeighbors {
    unsigned int correct = 0;
    
    for(unsigned int i = 0; i < self.inputCount ; ++i) {
        
        double minNorm = FLT_MAX;
        short minNormLabel;
        
        double * arrayI = input[i];
        
        for(unsigned int j = 0; j < self.inputCount ; ++j) {
            
            if(i == j) continue;
            
            double * arrayJ = input[j];
            
            double diff[self.featuresCount];
            [Helper subtractVector:arrayI fromVector:arrayJ count:self.featuresCount result:diff];
            
            double norm = [Helper norm:diff count:self.featuresCount];
            
            if(norm < minNorm) {
                minNorm = norm;
                minNormLabel = inputLabels[j];
            }
        }
        
        if(inputLabels[i] == minNormLabel) {
            ++correct;
        }
    }
    
    NSLog(@"Got %d correct out of %d ",correct,self.inputCount);
}

- (double **)scalingMatrix
{
    if(self.inputCount == 0) return nil;
    
    double ** A = [Helper emptyMatrixWithN:self.featuresCount m:self.featuresCount];
    double minmaxs[self.featuresCount][2];
    for (int i = 0 ; i < self.featuresCount; i++) {
        minmaxs[i][0] = MAXFLOAT;
        minmaxs[i][1] = -MAXFLOAT;
    }
    
    for(int i = 0 ; i < self.inputCount; i++)
    {
        
        for(int j = 0; j < self.featuresCount; j++)
        {
            
            double val = input[i][j];
            
            if(val < minmaxs[j][0])
            {
                minmaxs[j][0] = val;
            }
            
            if(val > minmaxs[j][1]) {
                minmaxs[j][1] = val;
            }
            
            NSLog(@"feature %i min %f",j,minmaxs[j][0]);
            NSLog(@"max %f",minmaxs[j][1]);
            NSLog(@"");
        }
    }
    
    
    NSLog(@"-------------------------------");
    
    [Helper identityMatrix:A n:self.featuresCount];
    
    for(int i = 0; i < self.featuresCount; ++i)
    {
        float f = (minmaxs[i][1] - minmaxs[i][0]);
        if(f == 0)
        {
            A[i][i] = 1;
        }
        else
        {
            A[i][i] = f; //was 1.0 /f
        }
        assert(fabsf(f) < 100000);
        NSLog(@"-------------- %f",f);
        
    }
  
    
    return A;
}

-(double**) scaleInputVector{
    double ** scaledInput = [Helper emptyMatrixWithN:self.inputCount m:self.featuresCount];
    
    for(int i = 0 ; i < self.inputCount ; ++i){
        [Helper multiplyMatrix:(const double**)scaleMatrix withVector:input[i] n:self.featuresCount m:self.featuresCount result:scaledInput[i]];
    }
    
    return scaledInput;
}

-(void) scaleInput{
    double ** newInput = [self scaleInputVector];
    
    for (int i = 0 ; i < self.featuresCount; i++) {
        free(input[i]);
    }
    
    free(input);
    
    input = newInput;
}

-(double**) neighborhoodComponentsAnalysisWithInitialMatrix:(const double**) initialMatrix {
    
    int N = self.inputCount;
    int D = self.featuresCount;
    
    double ** A = [Helper emptyMatrixWithN:D m:D];
    [Helper checkMatrix:A n:D m:D];
    [Helper copyToMatrix:A matrix:initialMatrix n:D m:D];
    [Helper checkMatrix:A n:D m:D];
    
    double ** firstTerm = [Helper emptyMatrixWithN:D m:D];
    double ** secondTerm = [Helper emptyMatrixWithN:D m:D];
    double ** term = [Helper emptyMatrixWithN:D m:D];
    
    
    for(unsigned int it = 0; it < self.numberIterations; ++it) {
        unsigned int i = it % N;
        
        double softmaxNormalization = 0.0;
        for(unsigned int k = 0; k < N; ++k) {
            if(k == i) continue;
            
            double vector1[D];
            double vector2[D];
            [Helper checkMatrix:A n:D m:D];
            [Helper multiplyMatrix:(const double**)A withVector:input[i] n:D m:D result:vector1];
            [Helper checkMatrix:A n:D m:D];
            [Helper multiplyMatrix:(const double**)A withVector:input[k] n:D m:D result:vector2];
            [Helper checkMatrix:A n:D m:D];
            [Helper subtractToVector:vector1 vector:vector2 count:D];
            
            double squaredNorm = [Helper squaredNorm:vector1 count:D];
            
            softmaxNormalization += exp(-squaredNorm);
        }
        
        
        double softmax[N];
        
        for(unsigned int k = 0; k < N; ++k) {
            
            if(k == i) {
                
                softmax[k] = 0.0;
                
            } else {
                
                double vector1[D];
                double vector2[D];
                
                [Helper checkMatrix:A n:D m:D];
                [Helper multiplyMatrix:(const double**)A withVector:input[i] n:D m:D result:vector1];
                [Helper checkMatrix:A n:D m:D];
                [Helper multiplyMatrix:(const double**)A withVector:input[k] n:D m:D result:vector2];
                [Helper checkMatrix:A n:D m:D];
                [Helper subtractToVector:vector1 vector:vector2 count:D];
                double squaredNorm = [Helper squaredNorm:vector1 count:D];
                
                if(softmaxNormalization == 0)
                {
                    softmaxNormalization = 0.0000001;
                }
                
                softmax[k] = exp(-squaredNorm) / softmaxNormalization;
            }
        }
        
        //[self printVector:softmax length:N];
        
        double p = 0.0;
        
        for(unsigned int k = 0; k < N; ++k) {
            if(inputLabels[k] == inputLabels[i]){
                p += softmax[k];
            }
        }
        
        [Helper initializeMatrixToZeros:firstTerm n:D m:D];
        [Helper initializeMatrixToZeros:secondTerm n:D m:D];
        [Helper checkMatrix:secondTerm n:D m:D];
        [Helper checkMatrix:firstTerm n:D m:D];
        
        for(unsigned int k = 0; k < N; ++k) {
            if(k == i) continue;
            
            double xik[D];
            [Helper subtractVector:input[i] fromVector:input[k] count:D result:xik];
            
            [Helper initializeMatrixToZeros:term n:D m:D];
            [Helper checkMatrix:term n:D m:D];
            [Helper multiplyVectorWithItselfTransposed:xik n:D result:term];
            
            
            [Helper checkVector:softmax n:N];
            [Helper checkMatrix:term n:D m:D];
            [Helper multiplyMatrix:term withScalar:softmax[k] n:D m:D];
            [Helper checkMatrix:term n:D m:D];
            
            [Helper checkMatrix:firstTerm n:D m:D];
            [Helper addToMatrix:firstTerm matrix:(const double**)term n:D m:D];
            [Helper checkMatrix:firstTerm n:D m:D];
            
            if(inputLabels[k] == inputLabels[i]){
                [Helper checkMatrix:secondTerm n:D m:D];
                [Helper addToMatrix:secondTerm matrix:(const double**)term n:D m:D];
                [Helper checkMatrix:secondTerm n:D m:D];
            }
        }
        
        [Helper checkMatrix:firstTerm n:D m:D];
        [Helper multiplyMatrix:firstTerm withScalar:p n:D m:D];
        [Helper checkMatrix:firstTerm n:D m:D];
        [Helper checkMatrix:secondTerm n:D m:D];
        
        [Helper subtractToMatrix:firstTerm matrix:(const double**)secondTerm n:D m:D];
        [Helper multiplyMatrix:(const double**)A withMatrix:(const double**)firstTerm n:D result:term];
        [Helper multiplyMatrix:term withScalar:self.learningRate n:D m:D];

        [Helper checkMatrix:A n:D m:D];
            [Helper checkMatrix:firstTerm n:D m:D];
                    [Helper checkMatrix:term n:D m:D];
        [Helper addToMatrix:A matrix:(const double**)term n:D m:D];
    }
    
    
    free(term);
    free(firstTerm);
    free(secondTerm);
    return A;
}

- (short)classifyInputVector:(double*)inputVector
                      ignore:(int)ignore
{
    
    
    double inputScaled[self.featuresCount];
    
//    NSLog(@"------------------------------------------------------------------------------------");
    NSLog(@"before:");
    [Helper printVector:inputVector
                  count:self.featuresCount];
    [Helper multiplyMatrix:(const double**)scaleMatrix withVector:inputVector n:self.featuresCount m:self.featuresCount result:inputScaled];
    
    NSLog(@"after:");
    [Helper printVector:inputScaled
                  count:self.featuresCount];
    
    
    double minNorm = FLT_MAX;
    
    short minNormLabel;
    
    double diff[self.featuresCount];
    
    for(unsigned int j = 0; j < self.inputCount ; ++j) {
        
        if(j == ignore) continue;
        
        [Helper subtractVector:inputScaled fromVector:input[j] count:self.featuresCount result:diff];
        
        double norm = [Helper norm:diff count:self.featuresCount];

        NSLog(@"label: %i \t\t norm: %f", inputLabels[j],norm);
        
        if(norm < minNorm)
        {
            minNorm = norm;
            minNormLabel = inputLabels[j];
//            NSLog(@"minnorm: %f", minNorm);
//            NSLog(@"found smaller norm for label: %i",inputLabels[j]);
        }
    }
    
    NSLog(@"");
//    NSLog(@"------------------------------------------------------------------------------------");
    return minNormLabel;
}

- (void)loadTrainingDataFromFile:(NSString*) fileName{
    
    int inputCount,featuresCount;
    
    [Helper loadFeaturesFromFile:fileName features:&input labels:&inputLabels nSamples:&inputCount nFeatures:&featuresCount];
    
    self.inputCount = inputCount;
    self.featuresCount = featuresCount;
}



- (void)appendFeatureSets:(NSArray *)featureSets
                 forLabel:(short)label
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    NSParameterAssert([featureSets count] > 0);
    
    THFeatureSet *featureSet1 = [featureSets firstObject];
    if(self.featuresCount == 0)
    {
        self.featuresCount = [featureSet1.scaledFeatures count];
    }
    else
    {
        NSParameterAssert(self.featuresCount == [featureSet1.scaledFeatures count]);
    }
    
    
    double **newFeatures = [Helper emptyMatrixWithN:[featureSets count]
                                                  m:self.featuresCount];
    
    for (int i = 0; i < [featureSets count]; i++)
    {
        THFeatureSet *oneFeatureSet = featureSets[i];
        for (int k = 0; k < [oneFeatureSet.scaledFeatures count]; k++)
        {
            float feature = [oneFeatureSet.scaledFeatures[k] floatValue];
            newFeatures[i][k] = feature;
        }
    }
    
    
    short *newLabels = malloc(sizeof(short) * [featureSets count]);
    for (int i = 0; i < [featureSets count]; i++)
    {
        newLabels[i] = label;
    }
    
    
    if(self.inputCount == 0) //first time, no feature rows
    {
        self.inputCount = [featureSets count];
        
        input = newFeatures;
        inputLabels = newLabels;
        
    }
    else //append features
    {
        double **newInput = [Helper appendMatrix:newFeatures
                                    withRowCount:[featureSets count]
                                        toMatrix:input
                                    withRowCount:self.inputCount
                                     columnCount:self.featuresCount];
        
        
        
        
        //cleanup
        free(input);
        free(newFeatures);
        input = newInput;
        
        short *newAppendedLabels = [Helper appendVector:newLabels
                                              withCount:[featureSets count]
                                               toVector:inputLabels
                                              withCount:self.inputCount];
        
        //cleanup
        free(inputLabels);
        free(newLabels);
        inputLabels = newAppendedLabels;
        
        self.inputCount += [featureSets count];
        
    }
    
    [Helper printMatrix:input
                      n:self.inputCount
                      m:self.featuresCount
                 labels:inputLabels];
    
    [self calculateScaleMatrix];
    
  
}


-(void) calculateScaleMatrix{
    
    double ** scalingMatrixTest = [self scalingMatrix];
    [Helper printMatrix:scalingMatrixTest
                      n:self.featuresCount
                      m:self.featuresCount];
    if(scaleMatrix)
    {
        free(scaleMatrix);
    }
    scaleMatrix = [self neighborhoodComponentsAnalysisWithInitialMatrix:(const double**)scalingMatrixTest];
    [Helper printMatrix:scaleMatrix
                      n:self.featuresCount
                      m:self.featuresCount];
}

-(void) testFile:(NSString*) fileName{
    
    [self loadTrainingDataFromFile:fileName];
    
    [self calculateScaleMatrix];
    
    [Helper printMatrix:scaleMatrix n:self.featuresCount m:self.featuresCount];
    
    double ** ncaInputTest = [self scaleInputVector];
    
    [Helper printMatrix:ncaInputTest n:self.inputCount m:self.featuresCount labels:inputLabels];
    
    
    NSLog(@"NN on raw data: ");
    [self nearestNeighbors];
    
    double ** scalingMatrixTest = [self scalingMatrix];
    
    [Helper copyToMatrix:scaleMatrix matrix:(const double**)scalingMatrixTest n:self.featuresCount m:self.featuresCount];
    
    double ** scaledScaling = [self scaleInputVector];
    [Helper copyToMatrix:input matrix:(const double**)scaledScaling n:self.inputCount m:self.featuresCount];
    
    NSLog(@"NN on scaled data: ");
    [self nearestNeighbors];
    
    [Helper copyToMatrix:input matrix:(const double**)ncaInputTest n:self.inputCount m:self.featuresCount];
    
    NSLog(@"NN on bca data: ");
    [self nearestNeighbors];
    
    for (int i = 0 ; i < self.inputCount; i++)
    {
        free(ncaInputTest[i]);
        free(scaledScaling[i]);
    }
    
    for (int i = 0 ; i < self.featuresCount; i++) {
        free(scalingMatrixTest[i]);
        free(scaleMatrix[i]);
    }
    
    free(scaledScaling);
    free(scalingMatrixTest);
    free(ncaInputTest);
    free(scaleMatrix);
}

@end
