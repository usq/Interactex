//
//  THTrainingsSet.h
//  TangoHapps
//
//  Created by Michael Conrads on 01/05/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface THTrainingsSet : NSObject
+ (instancetype)trainingsSetWithFilepaths:(NSArray *)filePaths;

- (void)fillPrimitivesFeatures:(double ***)features
                        labels:(short **)labels
                      nSamples:(int *)nSamples
                     nFeatures:(int *)nFeatures;
@end
