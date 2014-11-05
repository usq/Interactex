//
//  THSignalSource.h
//  TangoHapps
//
//  Created by Michael Conrads on 27/02/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    uint16_t finger1;
    uint16_t finger2;
    int16_t accX;
    int16_t accY;
    int16_t accZ;
} Signal;

extern Signal THDecodeSignal(uint8_t *signal);


@interface THSignalSource : TFSimulableObject
@property (nonatomic, assign, readonly) Signal currentOutputValue;
@property (nonatomic, strong, readonly) NSArray *data;
@property (nonatomic, assign, readonly) float leftBorderPercentage;
@property (nonatomic, assign, readonly) float rightBorderPercentage;

+ (instancetype)sharedSignalSource;
- (void)connectBLE;

- (void)updatedSimulation;
- (void)start;
- (void)stop;
- (void)toggle;
- (void)switchSourceFile:(NSString *)filename;
- (void)startRecording;
- (void)stopRecording;
- (void)saveRecording;
- (void)recordValue:(Signal)value;
- (void)cropDataToPercentages;
- (void)addDataFromGlove:(uint8_t *)data
                  length:(uint8_t)length;
@end
