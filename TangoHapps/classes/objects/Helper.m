//
//  Helper.m
//  AccelerometerStore
//
//  Created by Juan Haladjian on 04/02/14.
//  Copyright (c) 2014 Technical University Munich. All rights reserved.
//

#import "Helper.h"

@implementation Helper

+(double**) emptyMatrixWithN:(int) n m:(int) m{
    
    double ** A = malloc(n * sizeof(double*));
    
    for (int i = 0; i < n ; ++i) {
        A[i] = malloc(m * sizeof(double));
    }
    
    return A;
}

+(double) squaredNorm:(double*) v count:(unsigned int) N{
    
    double norm = 0;
    
    for(int i = 0 ; i < N ; i++){
        norm += v[i] * v[i];
    }
    
    return norm;
}

+(double) norm:(double*) v count:(int) N{
    
    double norm = [self squaredNorm:v count:N];
    
    return sqrt(norm);
}

+(void) subtractVector:(const double*) v1 fromVector:(const double*) v2 count:(int) count result:(double*) result{
    
    for(int i = 0 ; i < count ; i++){
        result[i] = (v1[i] - v2[i]);
    }
}

+(void) subtractToVector:(double*) v1 vector:(const double*) v2 count:(int) count{
    
    for(int i = 0 ; i < count ; i++){
        v1[i] -= v2[i];
    }
}

+(double) dotProduct:(const double*) v1 count:(int) count{
    
    double result = 0.0f;
    
    for(int i = 0 ; i < count ; i++){
        result += (v1[i] * v1[i]);
    }
    
    return result;
}

+(void) initializeMatrixToZeros:(double**) A n:(int) n m:(int) m{
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < m; j++) {
            A[i][j] = 0;
        }
    }
}

+(void) printMatrix:(double**) A n:(int) n m:(int) m{
    
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < m-1; j++) {
            printf("%.6f, ",A[i][j]);
        }
        
        printf("%.6f\n",A[i][m-1]);
    }
    
    printf("\n");
}

+(void) printMatrix:(double**) A n:(int) n m:(int) m labels:(short*) labels{
    
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < m; j++) {
            printf("%.6f, ",A[i][j]);
        }
        short s = labels[i];
        printf("%d\n",s);
    }
    
    printf("\n");
}

+(void) identityMatrix:(double**) A n:(int) n{
    
    for(int i = 0 ; i < n ; i++){
        for(int j = 0 ; j < n ; j++){
            if(i == j){
                A[i][j] = 1.0f;
            } else {
                A[i][j] = 0.0f;
            }
        }
    }
}

+(void) addToMatrix:(double**) A matrix:(const double**) B n:(int) n m:(int) m{
    
    for (int i = 0 ; i < n ; i++){
        for (int j = 0 ; j < m ;j++){
            A[i][j] += B[i][j];
        }
    }
}

+(void) subtractToMatrix:(double**) A matrix:(const double**) B n:(int) n m:(int) m{
    
    for (int i = 0 ; i < n ; i++){
        for (int j = 0 ; j < m ; j++){
            A[i][j] -= B[i][j];
        }
    }
}

+(void) multiplyMatrix:(const double**) A withMatrix:(const double**) B n:(int) n result:(double**) C{
    
    for (int i = 0 ; i < n ;i++){
        for (int j = 0 ; j < n ;j++){
            C[i][j] = 0;
            for (int k = 0 ; k < n ;k++){
                C[i][j] += A[i][k] * B[k][j];
            }
        }
    }
}

+(void) multiplyMatrix:(const double**) A withVector:(const double*) v n:(int) n m:(int) m result:(double*) c{
    
    for (int i = 0 ; i < n ; i++){
        c[i] = 0;
        for (int j = 0 ; j < m ; j++){
            c[i] += A[i][j] * v[j];
        }
    }
}

+(void) multiplyMatrix:(double**) A withScalar:(double) f n:(int) n m:(int) m{
    
    for (int i = 0 ; i < n ; i++){
        for (int j = 0 ; j < m ; j++){
            A[i][j] *= f;
        }
    }
}

+(void) multipliedMatrix:(const double**) A withScalar:(double) f n:(int) n m:(int) m result:(double**) B{
    
    for (int i = 0 ; i < n ; i++){
        for (int j = 0 ; j < m ; j++){
            B[i][j] = A[i][j] * f;
        }
    }
}

+(void) multiplyVectorWithItselfTransposed:(const double*) v  n:(int) n result:(double**) B{
    
    for (int i = 0 ; i < n ; i++){
        for (int j = 0 ; j < n ; j++){
            B[i][j] += v[i] * v[j];
        }
    }
}

+(void) copyToMatrix:(double**) A matrix:(const double**) B n:(unsigned int) n m:(unsigned int) m{
    
    for (int i = 0 ; i < n ; i++){
        for (int j = 0 ; j < m ; j++){
            A[i][j] = B[i][j];
        }
    }
}

+(void) loadMatrixFromFile:(NSString*) fileName matrix:(double***) A n:(int*) n m:(int*) m{
    
    NSString* path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    
    NSCharacterSet * endLineCharacter = [NSCharacterSet characterSetWithCharactersInString:@"\n"];
    NSCharacterSet * separatorsCharacter = [NSCharacterSet characterSetWithCharactersInString:@","];
    
    NSArray * lines = [content componentsSeparatedByCharactersInSet:endLineCharacter];
    
    NSString * firstLine = [lines objectAtIndex:0];
    NSArray * firstLineStrings = [firstLine componentsSeparatedByCharactersInSet:separatorsCharacter];
    
    *n = lines.count;
    *m = firstLineStrings.count - 1;
    
    *A = [Helper emptyMatrixWithN:*n m:*m];
    
    NSInteger count = 0;
    for (NSString * line in lines) {
        
        NSArray* lineStrings = [line componentsSeparatedByCharactersInSet:separatorsCharacter];
        
        for(int i = 0; i < lineStrings.count -1; i++){
            NSString * valueString = [lineStrings objectAtIndex:i];
            double f = [valueString doubleValue];
            (*A)[count][i] = f;
        }
        
        count++;
    }
}

+(void) loadFeaturesFromFile:(NSString*) fileName features:(double***) features labels:(short**) labels nSamples:(int*) nSamples nFeatures:(int*) nFeatures
{
    
    NSInteger inputCount;
    NSInteger featuresCount;
    
    NSString* path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    
    NSCharacterSet * endLineCharacter = [NSCharacterSet characterSetWithCharactersInString:@"\n"];
    NSCharacterSet * separatorsCharacter = [NSCharacterSet characterSetWithCharactersInString:@","];
    
    NSArray * lines = [content componentsSeparatedByCharactersInSet:endLineCharacter];
    
    NSString * firstLine = [lines objectAtIndex:0];
    NSArray * firstLineStrings = [firstLine componentsSeparatedByCharactersInSet:separatorsCharacter];
    
    inputCount = lines.count;
    featuresCount = firstLineStrings.count - 1;
    
    *features = [Helper emptyMatrixWithN:inputCount m:featuresCount];
    *labels = malloc(inputCount * sizeof(short));
    
    NSInteger n = 0;
    for (NSString * line in lines) {
        
        NSArray* lineStrings = [line componentsSeparatedByCharactersInSet:separatorsCharacter];
        
        for(int i = 0; i < lineStrings.count -1; i++)
        {
            NSString * valueString = [lineStrings objectAtIndex:i];
            double f = [valueString doubleValue];
            (*features)[n][i] = f;
        }
        
        NSString * label = [lineStrings objectAtIndex:lineStrings.count-1];
        (*labels)[n] = [label integerValue];
        
        n++;
    }
    
    *nSamples = inputCount;
    *nFeatures = featuresCount;
}


/*
+(void) saveMatrix:(double**) input n:(int) n m:(int) m toFile:(NSString*) fileName{
    NSString * content = @"";
    
    for (int i = 0 ; i < n; i++) {
        for (int j = 0 ; j < m; j++) {
            NSString * newStr = [NSString stringWithFormat:@"%f ",input[i][j]];
            content = [content stringByAppendingString: newStr];
        }
        content = [content stringByAppendingString:@"\n"];
    }
    
    NSString* path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
    
    [content writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}*/

+(NSInteger) loadAccelerometerDataFromFile:(NSString*) fileName accelerometerValues:(float*) accelerometerValues{
    
    NSString* path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
    
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    
    NSCharacterSet * separators = [NSCharacterSet characterSetWithCharactersInString:@";, []=\n"];
    
    NSArray* singleStrs = [content componentsSeparatedByCharactersInSet:separators];
    
    NSInteger count = 0;
    
    int state = -1;
    for (NSString * s in singleStrs) {
        if([s isEqualToString:@"y1"] || [s isEqualToString:@"y2"] || [s isEqualToString:@"y3"]){
            state++;
            count = 0;
        } else {
            if(!([s isEqualToString:@" "] || [s isEqualToString:@""] || [s isEqualToString:@"\n"])){
                float value = [s floatValue];
                accelerometerValues[count*3+state] = value;
                count++;
            }
        }
    }
    return count;
    
    /*
     printf("\n");
     for(int i = 0 ; i < loadedAccelerometerValuesCount * 3 ; i+=3){
     printf("%f, ",loadedAccelerometerValues[i+2]);
     
     }
     printf("\n");*/
}

@end