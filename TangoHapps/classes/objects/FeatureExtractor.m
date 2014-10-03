//
//  FeatureExtractor.m
//  AccelerometerStore
//
//  Created by Juan Haladjian on 05/02/14.
//  Copyright (c) 2014 Technical University Munich. All rights reserved.
//

#import "FeatureExtractor.h"

@implementation FeatureExtractor

-(double) computeMagnitudeAveragesFromWindow:(const float*) window count:(int) count{
    
    double magnitudeAvg = 0;
    for(int i = 0 ; i < count * 3 ; i+=3){
        double x = window[i];
        double y = window[i+1];
        double z = window[i+2];
        
        magnitudeAvg += sqrt(x * x + y * y + z * z);
    }
    
    return magnitudeAvg / count ;
}

- (void)computeMeansFromWindow:(Signal *)window
                         count:(int)count
                         means:(double *)means
{
    double mean1_1 = 0;
    double mean2_1 = 0;
    double mean3_1 = 0;
    
    for(int i = 0 ; i < count * 3 ; i+=3){
        mean1_1 += window[i].finger1;
        mean2_1 += window[i+1].finger1;
        mean3_1 += window[i+2].finger1;
    }
    
    means[0] = mean1_1 / (float)count;
    means[1] = mean2_1 / (float)count;
    means[2] = mean3_1 / (float)count;
    
    
    double mean1_2 = 0;
    double mean2_2 = 0;
    double mean3_2 = 0;
    
    for(int i = 0 ; i < count * 3 ; i+=3){
        mean1_2 += window[i].finger2;
        mean2_2 += window[i+1].finger2;
        mean3_2 += window[i+2].finger2;
    }
    
    means[3] = mean1_2 / (float)count;
    means[4] = mean2_2 / (float)count;
    means[5] = mean3_2 / (float)count;
}

- (void)computeDeviationsFromWindow:(Signal *)window
                              count:(int)count
                         usingMeans:(double *)means
                         deviations:(double *)deviations
{
    double deviation1_1 = 0;
    double deviation2_1 = 0;
    double deviation3_1 = 0;
    
    for(int i = 0 ; i < count * 3 ; i+=3){
        
        double diff1 = window[i].finger1 - means[0];
        double diff2 = window[i+1].finger1 - means[1];
        double diff3 = window[i+2].finger1 - means[2];
        
        deviation1_1 += diff1 * diff1;
        deviation2_1 += diff2 * diff2;
        deviation3_1 += diff3 * diff3;
    }
    
    deviations[0] = sqrt(deviation1_1 / (count-1));
    deviations[1] = sqrt(deviation2_1 / (count-1));
    deviations[2] = sqrt(deviation3_1 / (count-1));
    
    double deviation1_2 = 0;
    double deviation2_2 = 0;
    double deviation3_2 = 0;
    
    for(int i = 0 ; i < count * 3 ; i+=3){
        
        double diff1 = window[i].finger2 - means[3];
        double diff2 = window[i+1].finger2 - means[4];
        double diff3 = window[i+2].finger2 - means[5];
        
        deviation1_2 += diff1 * diff1;
        deviation2_2 += diff2 * diff2;
        deviation3_2 += diff3 * diff3;
    }
    
    deviations[3] = sqrt(deviation1_2 / (count-1));
    deviations[4] = sqrt(deviation2_2 / (count-1));
    deviations[5] = sqrt(deviation3_2 / (count-1));
}

- (void)computeCorrelationsFromWindow:(Signal *)window
                                count:(int)count
                         correlations:(double *)correlations
{
    
    double means[6];
    double deviations[6];
    
    [self computeMeansFromWindow:window
                           count:count
                           means:means];
    [self computeDeviationsFromWindow:window
                                count:count
                           usingMeans:means
                           deviations:deviations];
    
    double corr1 = 0;
    double corr2 = 0;
    double corr3 = 0;
    
    for(int i = 0 ; i < count * 3 ; i+=3){
        
        double x = window[i].finger1;
        double y = window[i+1].finger1;
        double z = window[i+2].finger1;
        
        corr1 += (x - means[0]) * (y - means[1]);
        corr2 += (y - means[1]) * (z - means[2]);
        corr3 += (x - means[0]) * (z - means[2]);
    }
    
    double cov1 = corr1 / (count - 1);
    double cov2 = corr2 / (count - 1);
    double cov3 = corr3 / (count - 1);
    
    correlations[0] = cov1 / (deviations[0] * deviations[1]);
    correlations[1] = cov2 / (deviations[1] * deviations[2]);
    correlations[2] = cov3 / (deviations[0] * deviations[2]);
    
    /*
     double corr1 = 0;
     double corr2 = 0;
     double corr3 = 0;
     
     for(int i = 0 ; i < count * 3 ; i+=3){
     
     double x = window[i];
     double y = window[i+1];
     double z = window[i+2];
     
     corr1 += (x - means[0]) * (y - means[1]);
     corr2 += (y - means[1]) * (z - means[2]);
     corr3 += (x - means[0]) * (z - means[2]);
     }
     
     double cov1 = corr1 / (count - 1);
     double cov2 = corr2 / (count - 1);
     double cov3 = corr3 / (count - 1);
     
     correlations[0] = cov1 / (deviations[0] * deviations[1]);
     correlations[1] = cov2 / (deviations[1] * deviations[2]);
     correlations[2] = cov3 / (deviations[0] * deviations[2]);
     */
    //MC_TODO implement
}

- (void)computeMinMaxsFromValues:(float *)values
                           count:(int)count
                           peaks:(double *)minMaxs
{
    
    double min = 100000;
    double max = -100000;
    
    for(int i = 0 ; i < count; i++)
    {
        double value = values[i];
        
        if(value < min)
        {
            min = value;
        }
        if(value > max)
        {
            max = value;
        }
    }

    minMaxs[0] = min;
    minMaxs[1] = max;
}


- (void)computeMinMaxsFromWindow:(Signal *)window
                           count:(int)count
                           peaks:(double [5][2])minMaxs
{
    float finger1Window[count];
    float finger2Window[count];
    float accXWindow[count];
    float accYWindow[count];
    float accZWindow[count];
    
    [self extractValuesFromSignals:window
                             count:count
                         toFinger1:finger1Window
                         toFinger2:finger2Window
                              accX:accXWindow
                              accY:accYWindow
                              accZ:accZWindow];

    double finger1MinMax[2];
    [self computeMinMaxsFromValues:finger1Window
                             count:count
                             peaks:finger1MinMax];
    minMaxs[0][0] = finger1MinMax[0];
    minMaxs[0][1] = finger1MinMax[1];
    
    double finger2MinMax[2];
    [self computeMinMaxsFromValues:finger2Window
                             count:count
                             peaks:finger2MinMax];
    minMaxs[1][0] = finger2MinMax[0];
    minMaxs[1][1] = finger2MinMax[1];
    
    double accXMinMax[2];
    [self computeMinMaxsFromValues:accXWindow
                             count:count
                             peaks:accXMinMax];
    minMaxs[2][0] = accXMinMax[0];
    minMaxs[2][1] = accXMinMax[1];
    
    
    double accYMinMax[2];
    [self computeMinMaxsFromValues:accYWindow
                             count:count
                             peaks:accYMinMax];
    minMaxs[3][0] = accYMinMax[0];
    minMaxs[3][1] = accYMinMax[1];
    
    double accZMinMax[2];
    [self computeMinMaxsFromValues:accZWindow
                             count:count
                             peaks:accZMinMax];
    minMaxs[4][0] = accZMinMax[0];
    minMaxs[4][1] = accZMinMax[1];
}



//
//- (void)computeMinMaxDiffsFromWindow:(const float *)window
//                               count:(int)count
//                        minMaxValues:(double **)
//                               diffs:(double *)diffs
//{
//    double peaks[6];
//    [self computeMinMaxsFromWindow:window count:count peaks:peaks];
//    
//    diffs[0] = fabs(peaks[1] - peaks[0]);
//    diffs[1] = fabs(peaks[3] - peaks[2]);
//    diffs[2] = fabs(peaks[5] - peaks[4]);
//}



- (void)computeMinMaxDiffsFromMinMax:(double [5][2])minMax
                               count:(int)count
                               diffsOut:(double *)diffs
{
    for (int i = 0; i < count; i++)
    {
        diffs[i] = minMax[i][1] - minMax[i][0];
    }
}

- (NSInteger)numberOfPeaksInValues:(float *)values
                        count:(int)count
                    tolerance:(float)tolerance
                            invert:(BOOL)invert
{
    float min = 100000;
    float max = -100000;
    
    BOOL lookForMax = YES;
    NSInteger peakCount = 0;
//    NSLog(@"STARTING ");
//    if(invert)
//    {
//        for (int i = 0; i < count; i++) {
//            NSLog(@"value %f",values[i]);
//        }
//    }
//    
//    NSLog(@"ENDING");
//    
    for(int i = 0 ; i < count; i++)
    {
        double val1 = values[i];
        
        //this one is fishy
        double value = val1;
        if(invert)
        {
            value = 300 - val1;
        }
        


        
        if(value > max){
            max = value;
        }
        
        if(value < min){
            min = value;
        }
        
        
        if(lookForMax)
        {
//            NSLog(@"value %f      must be smaller than %f  ",value, max - tolerance);
            if(value < max - tolerance)
            {
//                NSLog(@"PEAK!! because value: %f  < %f", value, max-tolerance);
                min = value;
                lookForMax = NO;
                peakCount++;

            }
        } else
        {
            if(value > min + tolerance){
                max = value;
                lookForMax = YES;
            }
        }
    }
    return peakCount;
}


- (void)extractValuesFromSignals:(Signal *)window
                           count:(int)count
                        toFinger1:(float *)finger1
                        toFinger2:(float *)finger2
                        accX:(float *)accX
                        accY:(float *)accY
                        accZ:(float *)accZ
{
    for (int i = 0; i < count; i++)
    {
        Signal s = window[i];
        finger1[i] = (float)s.finger1;
        finger2[i] = (float)s.finger2;
        accX[i] = s.accX;
        accY[i] = s.accY;
        accZ[i] = s.accZ;
    }
}

- (void)computeNumPeaksFromWindow:(Signal *)window
                            count:(int)count
                        tolerance:(float)tolerance
                         numPeaks:(NSInteger *)numPeaks
{
    
    float finger1Window[count];
    float finger2Window[count];
    float accXWindow[count];
    float accYWindow[count];
    float accZWindow[count];
    
    [self extractValuesFromSignals:window
                             count:count
                         toFinger1:finger1Window
                         toFinger2:finger2Window
                              accX:accXWindow
                              accY:accYWindow
                              accZ:accZWindow];
    
    numPeaks[0] = [self numberOfPeaksInValues:finger1Window
                                        count:count
                                    tolerance:tolerance
                                       invert:YES];
    
    numPeaks[1] = [self numberOfPeaksInValues:finger2Window
                                        count:count
                                    tolerance:tolerance
                                       invert:YES];
    numPeaks[2] = [self numberOfPeaksInValues:accXWindow
                                        count:count
                                    tolerance:tolerance * 200
                                       invert:NO];
    
    numPeaks[3] = [self numberOfPeaksInValues:accYWindow
                                        count:count
                                    tolerance:tolerance * 200
                                       invert:NO];

    numPeaks[4] = [self numberOfPeaksInValues:accZWindow
                                        count:count
                                    tolerance:tolerance * 200
                                       invert:NO];
 
}

- (void)computeAllFeaturesFromWindow:(Signal*)window
                               count:(int)count
                            features:(double *)features
                        featureCount:(int *)featureCount

{
    
//    double means[6];
//    double deviations[6];
//    
//    double minMaxDiffs[3];
//    double correlations[3];
//    double magnitude;
    
    NSInteger numpeaks[5];
    [self computeNumPeaksFromWindow:window
                              count:count
                          tolerance:20
                           numPeaks:numpeaks];
    

    
    
    features[0] = numpeaks[0]; //feature 1 contains numPeak finger 1
    features[1] = numpeaks[1]; //feature 2 contains numPeak finger 2
    features[2] = numpeaks[2]; //feature 3 contains numPeak accX
    features[3] = numpeaks[3]; //feature 4 contains numPeak accY
    features[4] = numpeaks[4]; //feature 5 contains numPeak accZ
    
    
    
    
    double minMaxs[5][2];
    [self computeMinMaxsFromWindow:window
                             count:count
                             peaks:minMaxs];
    
    features[5]  = minMaxs[0][0]; //feature 6 contains min finger 1
    features[6]  = minMaxs[0][1]; //feature 7 contains max finger 1
    
    features[7]  = minMaxs[1][0]; //feature 8 contains min finger 2
    features[8]  = minMaxs[1][1]; //feature 9 contains max finger 2
    
    features[9]  = minMaxs[2][0]; //feature 10 contains min accX
    features[10] = minMaxs[2][1]; //feature 11 contains max accX
    
    features[11] = minMaxs[3][0]; //feature 12 contains min accY
    features[12] = minMaxs[3][1]; //feature 13 contains max accY
    
    features[13] = minMaxs[4][0]; //feature 14 contains min accZ
    features[14] = minMaxs[4][1]; //feature 15 contains max accZ
    
    double minMaxDiffs[5];
    [self computeMinMaxDiffsFromMinMax:minMaxs
                                 count:5
                              diffsOut:minMaxDiffs];
    
    
    features[15] = minMaxDiffs[0]; //feature 16 contains minMaxDiff finger1
    features[16] = minMaxDiffs[1]; //feature 17 contains minMaxDiff finger2
    features[17] = minMaxDiffs[2]; //feature 18 contains minMaxDiff accX
    features[18] = minMaxDiffs[3]; //feature 19 contains minMaxDiff accY
    features[19] = minMaxDiffs[4]; //feature 20 contains minMaxDiff accZ

    *featureCount = 5;
    
    
    

    //
    //    [self computeMeansFromWindow:window
    //                           count:count
    //                           means:means];
    //
    //    [self computeDeviationsFromWindow:window
    //                                count:count
    //                           usingMeans:means
    //                           deviations:deviations];
    //
    //
    //    features[0] = means[1];
    ////    features[1] = magnitude;
    //    features[2] = deviations[1];
    //    features[3] = minMaxDiffs[1];
    ////    features[4] = numPeaks;
    //    features[5] = correlations[0];
    //    features[6] = correlations[1];
    //    features[7] = correlations[2];
    
    
    //MC_TODO: implement
    /*
     [self computeMinMaxDiffsFromWindow:window count:count diffs:minMaxDiffs];
     numPeaks = [self computeNumPeaksFromWindow:window count:count  tolerance:self.peakDetectionTolerance];
     [self computeCorrelationsFromWindow:window count:count correlations:correlations];
     magnitude = [self computeMagnitudeAveragesFromWindow:window count:count];
     
     features[0] = means[1];
     features[1] = magnitude;
     features[2] = deviations[1];
     features[3] = minMaxDiffs[1];
     features[4] = numPeaks;
     features[5] = correlations[0];
     features[6] = correlations[1];
     features[7] = correlations[2];
     */
}

@end
