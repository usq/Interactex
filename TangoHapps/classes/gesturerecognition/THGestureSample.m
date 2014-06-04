//
//  THGestureSample.m
//  TangoHapps
//
//  Created by Michael Conrads on 03/05/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THGestureSample.h"

@implementation THGestureSample

+ (NSArray *)savedSamples
{
    /*
    NSMutableArray *loadedSamples = [NSMutableArray array];
    [loadedSamples addObjectsFromArray:@[@"singletick", @"doubletick", @"testinput", @"singletick_error", @"doubletick_long"]];

    lastSampleIndex = 1;
    
    while([[NSFileManager defaultManager] fileExistsAtPath:[self filePathWithIndex:self.lastSampleIndex]])
    {
        [loadedSamples addObject:[self filePathWithIndex:self.lastSampleIndex]];
        self.lastSampleIndex ++;
    }
    
    return loadedSamples;
     */
    return nil;
    
}

- (NSString *)filePathWithIndex:(NSUInteger)sampleIndex //move
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [NSString stringWithFormat:@"%@/%i_gesturerecording_v1",documentsDirectory,sampleIndex];    
}


@end
