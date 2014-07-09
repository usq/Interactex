//
//  THSignalSource.h
//  TangoHapps
//
//  Created by Michael Conrads on 27/02/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    uint8_t value1;
    uint8_t value2;
} Signal;

extern Signal THDecodeSignal(uint32_t signal);


@interface THSignalSource : TFSimulableObject
@property (nonatomic, assign, readonly) NSInteger currentOutputValue;
@property (nonatomic, strong, readonly) NSArray *data;
@property (nonatomic, assign, readonly) float leftBorderPercentage;
@property (nonatomic, assign, readonly) float rightBorderPercentage;

+ (instancetype)sharedSignalSource;
- (void)updatedSimulation;
- (void)start;
- (void)stop;
- (void)toggle;
- (void)switchSourceFile:(NSString *)filename;
- (void)startRecording;
- (void)stopRecording;
- (void)saveRecording;
- (void)recordValue:(uint32_t)value;
- (void)cropDataToPercentages;
- (void)addDataFromGlove:(uint32_t)data;
@end
