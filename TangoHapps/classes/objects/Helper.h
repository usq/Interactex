//
//  Helper.h
//  AccelerometerStore
//
//  Created by Juan Haladjian on 04/02/14.
//  Copyright (c) 2014 Technical University Munich. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Helper : NSObject

+(double**) emptyMatrixWithN:(int) n m:(int) m;

/**
 *  creates a new combined matrix, you have to free the matrices yourself!
 *
 *  @param matrixToAppend   the matrix which will be pastet after matrix
 *  @param rowCountToAppend the number of rows in the new matrix
 *
 *  @param matrix           the original matrix, the new matrix will start with a copy of this matrix
 *  @param rowCount         the original rowCount
 *  @param columnCount      the original comumncount
 *
 *  @return the newly created combined matrix
 */
+ (double **)appendMatrix:(double **)matrixToAppend
             withRowCount:(int)rowCountToAppend
                 toMatrix:(double **)matrix
             withRowCount:(int)rowCount
              columnCount:(int)columnCount;

+ (short *)appendVector:(short *)vectorToAppend
              withCount:(int)countToAppend
               toVector:(short *)vector
              withCount:(int)count;


+(double) squaredNorm:(double*) v count:(unsigned int) N;

+(double) norm:(double*) v count:(int) N;

+(void) subtractVector:(const double*) v1 fromVector:(const double*) v2 count:(int) count result:(double*) result;

+(void) subtractToVector:(double*) v1 vector:(const double*) v2 count:(int) count;

+(double) dotProduct:(const double*) v1 count:(int) count;

+(void) initializeMatrixToZeros:(double**) A n:(int) n m:(int) m;

+(void) printMatrix:(double**) A n:(int) n m:(int) m;

+(void) printMatrix:(double**) A n:(int) n m:(int) m labels:(short*) labels;

+ (void)printVector:(double *)vector
              count:(int)count;


+(void) identityMatrix:(double**) A n:(int) n;

+(void) addToMatrix:(double**) A matrix:(const double**) B n:(int) n m:(int) m;

+(void) subtractToMatrix:(double**) A matrix:(const double**) B n:(int) n m:(int) m;

+(void) multiplyMatrix:(const double**) A withMatrix:(const double**) B n:(int) n result:(double**) C;

+(void) multiplyMatrix:(const double**) A withVector:(const double*) v n:(int) n m:(int) m result:(double*) c;

+(void) multiplyMatrix:(double**) A withScalar:(double) f n:(int) n m:(int) m;

+(void) multipliedMatrix:(const double**) A withScalar:(double) f n:(int) n m:(int) m result:(double**) B;

+(void) multiplyVectorWithItselfTransposed:(const double*) v  n:(int) n result:(double**) B;

+(void) copyToMatrix:(double**) A matrix:(const double**) B n:(unsigned int) n m:(unsigned int) m;

+(void) loadFeaturesFromFile:(NSString*) fileName features:(double***) features labels:(short**) labels nSamples:(int*) nSamples nFeatures:(int*) nFeatures;

+(NSInteger) loadAccelerometerDataFromFile:(NSString*) fileName accelerometerValues:(float*) accelerometerValues;

+(void) loadMatrixFromFile:(NSString*) fileName matrix:(double***) A n:(int*) n m:(int*) m;

+ (void)checkMatrix:(double **)matrix
                  n:(int)n
                  m:(int)m;

+ (void)checkVector:(double *)vector
                  n:(int)n;

+ (void)scaleFeatures:(double *)features;
@end
