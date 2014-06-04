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

-(double**) scalingMatrix {
    
    if(self.inputCount == 0) return nil;
    
    double ** A = [Helper emptyMatrixWithN:self.featuresCount m:self.featuresCount];
    
    double minmaxs[self.inputCount][2];
    for (int i = 0 ; i < self.inputCount; i++) {
        minmaxs[i][0] = FLT_MAX;
        minmaxs[i][1] = -FLT_MAX;
    }
    
    for(int i = 0 ; i < self.inputCount ; ++i){
        for(int j = 0; j < self.featuresCount; ++j) {
            
            double val = input[i][j];
            
            if(val < minmaxs[j][0]) {
                minmaxs[j][0] = val;
            }
            
            if(val > minmaxs[j][1]) {
                minmaxs[j][1] = val;
            }
        }
    }
    
    [Helper identityMatrix:A n:self.featuresCount];
    
    for(int i = 0; i < self.featuresCount; ++i) {
        A[i][i] = 1.0/(minmaxs[i][1] - minmaxs[i][0]);
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
    
    [Helper copyToMatrix:A matrix:initialMatrix n:D m:D];
    
    
    double ** firstTerm = malloc(D * sizeof(double*));
    double ** secondTerm = malloc(D * sizeof(double*));
    double ** term = malloc(D * sizeof(double*));
    
    for (int i = 0; i < D ; ++i) {
        firstTerm[i] = malloc(D * sizeof(double));
        secondTerm[i] = malloc(D * sizeof(double));
        term[i] = malloc(D * sizeof(double));
    }
    
    for(unsigned int it = 0; it < self.numberIterations; ++it) {
        unsigned int i = it % N;
        
        double softmaxNormalization = 0.0;
        for(unsigned int k = 0; k < N; ++k) {
            if(k == i) continue;
            
            double vector1[D];
            double vector2[D];
            
            [Helper multiplyMatrix:(const double**)A withVector:input[i] n:D m:D result:vector1];
            [Helper multiplyMatrix:(const double**)A withVector:input[k] n:D m:D result:vector2];
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
                
                [Helper multiplyMatrix:(const double**)A withVector:input[i] n:D m:D result:vector1];
                [Helper multiplyMatrix:(const double**)A withVector:input[k] n:D m:D result:vector2];
                [Helper subtractToVector:vector1 vector:vector2 count:D];
                double squaredNorm = [Helper squaredNorm:vector1 count:D];

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
        
        for(unsigned int k = 0; k < N; ++k) {
            if(k == i) continue;
            
            double xik[D];
            [Helper subtractVector:input[i] fromVector:input[k] count:D result:xik];
            
            [Helper initializeMatrixToZeros:term n:D m:D];
            
            [Helper multiplyVectorWithItselfTransposed:xik n:D result:term];
            [Helper multiplyMatrix:term withScalar:softmax[k] n:D m:D];
            
            [Helper addToMatrix:firstTerm matrix:(const double**)term n:D m:D];
            
            if(inputLabels[k] == inputLabels[i]){
                [Helper addToMatrix:secondTerm matrix:(const double**)term n:D m:D];
            }
        }
        
        [Helper multiplyMatrix:firstTerm withScalar:p n:D m:D];
        
        [Helper subtractToMatrix:firstTerm matrix:(const double**)secondTerm n:D m:D];
        [Helper multiplyMatrix:(const double**)A withMatrix:(const double**)firstTerm n:D result:term];
        [Helper multiplyMatrix:term withScalar:self.learningRate n:D m:D];
        [Helper addToMatrix:A matrix:(const double**)term n:D m:D];
    }
    
    return A;
}

-(short) classifyInputVector:(double*) inputVector ignore:(int) ignore{
    
    double inputScaled[self.featuresCount];
    
    [Helper multiplyMatrix:(const double**)scaleMatrix withVector:inputVector n:self.featuresCount m:self.featuresCount result:inputScaled];
    
    double minNorm = FLT_MAX;
    
    short minNormLabel;
    
    double diff[self.featuresCount];
    
    for(unsigned int j = 0; j < self.inputCount ; ++j) {
        
        if(j == ignore) continue;
        
        [Helper subtractVector:inputScaled fromVector:input[j] count:self.featuresCount result:diff];
        
        double norm = [Helper norm:diff count:self.featuresCount];
        
        if(norm < minNorm) {
            minNorm = norm;
            minNormLabel = inputLabels[j];
        }
    }
    
    return minNormLabel;
}

-(void) loadTrainingDataFromFile:(NSString*) fileName{

    int inputCount,featuresCount;
    
    [Helper loadFeaturesFromFile:fileName features:&input labels:&inputLabels nSamples:&inputCount nFeatures:&featuresCount];
    
    self.inputCount = inputCount;
    self.featuresCount = featuresCount;
}

- (void)loadTrainingDataFromTrainingsSet:(THTrainingsSet *)trainingsSet
{
    int inputCount,featuresCount;
    
    [trainingsSet fillPrimitivesFeatures:&input
                                  labels:&inputLabels
                                nSamples:&inputCount
                               nFeatures:&featuresCount];
    
    self.inputCount = inputCount;
    self.featuresCount = featuresCount;
}

-(void) loadScalingMatrixFromFile:(NSString*) fileName{
    
    NSString* path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    
    NSCharacterSet * endLineCharacter = [NSCharacterSet characterSetWithCharactersInString:@"\n"];
    NSCharacterSet * separatorsCharacter = [NSCharacterSet characterSetWithCharactersInString:@" "];
    
    NSArray * lines = [content componentsSeparatedByCharactersInSet:endLineCharacter];
    
    self.featuresCount = lines.count ;
    scaleMatrix = [Helper emptyMatrixWithN:self.featuresCount m:self.featuresCount];
    
    NSInteger n = 0;
    for (NSString * line in lines) {
        
        NSArray* lineStrings = [line componentsSeparatedByCharactersInSet:separatorsCharacter];
        
        for(int i = 0; i < lineStrings.count; i++){
            NSString * valueString = [lineStrings objectAtIndex:i];
            double f = [valueString doubleValue];
            scaleMatrix[n][i] = f;
        }
        n++;
    }
}

-(void) calculateScaleMatrix{
    
    double ** scalingMatrixTest = [self scalingMatrix];
    
    scaleMatrix = [self neighborhoodComponentsAnalysisWithInitialMatrix:(const double**)scalingMatrixTest];
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
    
    for (int i = 0 ; i < self.inputCount; i++) {
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
