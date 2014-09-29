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

-(void) computeMinMaxsFromWindow:(const float*) window count:(int) count peaks:(double*) minMaxs{
    
    double mins[3] = {10000,10000,10000};
    double maxs[3] = {-10000,-10000,-10000};
    
    for(int i = 0 ; i < count * 3 ; i+=3){
        
        double x = window[i];
        double y = window[i+1];
        double z = window[i+2];
        
        if(x < mins[0]){
            mins[0] = x;
        }
        if(x > maxs[0]){
            maxs[0] = x;
        }
        
        if(y < mins[1]){
            mins[1] = y;
        }
        if(y > maxs[1]){
            maxs[1] = y;
        }
        
        if(z < mins[2]){
            mins[2] = z;
        }
        if(z > maxs[2]){
            maxs[2] = z;
        }
    }
    
    minMaxs[0] = mins[0];
    minMaxs[1] = maxs[0];
    minMaxs[2] = mins[1];
    minMaxs[3] = maxs[1];
    minMaxs[4] = mins[2];
    minMaxs[5] = maxs[2];
}

-(void) computeMinMaxDiffsFromWindow:(const float*) window count:(int) count diffs:(double*) diffs{
    double peaks[6];
    [self computeMinMaxsFromWindow:window count:count peaks:peaks];
    
    diffs[0] = fabs(peaks[1] - peaks[0]);
    diffs[1] = fabs(peaks[3] - peaks[2]);
    diffs[2] = fabs(peaks[5] - peaks[4]);
}

- (int)computeNumPeaksFromWindow:(Signal *)window
                           count:(int)count
                       tolerance:(float)tolerance
{
    
    float min = 1000;
    float max = -1000;
    
    BOOL lookForMax = YES;
    int peakCount = 0;
    
    for(int i = 0 ; i < count * 3 ; i+=3)
    {
        
        uint16_t val1 = window[i+1].finger1;
        printf("%i ",val1);
        double value = 300 - val1;
        
        if(value > max){
            max = value;
        }
        
        if(value < min){
            min = value;
        }
        
        if(lookForMax)
        {
            if(value < max - tolerance){
                min = value;
                lookForMax = 0;
                peakCount++;
                printf(" |detected peak finger 1!| ");
            }
        } else
        {
            if(value > min + tolerance){
                max = value;
                lookForMax = 1;
            }
        }
    }
    
    //TODO: change to {peaks1,peaks2}
    min = 1000;
    max = -1000;
    
    lookForMax = YES;
    
    for(int i = 0 ; i < count * 3 ; i+=3){
        
        double value = 300 - window[i+1].finger2;
        
        if(value > max){
            max = value;
        }
        
        if(value < min){
            min = value;
        }
        
        if(lookForMax){
            if(value < max - tolerance){
                min = value;
                lookForMax = 0;
                peakCount++;
                printf(" |detected peak finger 2!| ");
            }
        } else{
            if(value > min + tolerance){
                max = value;
                lookForMax = 1;
            }
        }
    }
    
    return peakCount;
}

- (void)computeAllFeaturesFromWindow:(Signal*)window
                               count:(int)count
                            features:(double *)features{
    double means[6];
    double deviations[6];
    
    double minMaxDiffs[3];
    double correlations[3];
    NSInteger numPeaks;
    double magnitude;
    
    [self computeMeansFromWindow:window
                           count:count
                           means:means];
    
    [self computeDeviationsFromWindow:window
                                count:count
                           usingMeans:means
                           deviations:deviations];
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
