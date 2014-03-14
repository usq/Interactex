//
//  THSignalSource.h
//  TangoHapps
//
//  Created by Michael Conrads on 27/02/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface THSignalSource : TFSimulableObject
@property (nonatomic, assign, readonly) NSInteger currentOutputValue;
@property (nonatomic, strong, readonly) NSArray *data;
@property (nonatomic, assign, readonly) float leftBorderPercentage;
@property (nonatomic, assign, readonly) float rightBorderPercentage;

- (void)updatedSimulation;
- (void)start;
- (void)stop;
- (void)toggle;
- (void)switchSourceFile:(NSString *)filename;
@end
