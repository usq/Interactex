//
//  THMSignalSource.h
//  TangoHapps
//
//  Created by Michael Conrads on 13/06/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 The signal source is responsible for providing signals from either a device or a sourcefile (playback)
 This class can be seen as an input stream for signal values
 */
@interface THMSignalSource : TFSimulableObject
@property (nonatomic, assign, readonly) NSInteger currentSignalValue;
@property (nonatomic, strong, readonly) NSArray *signalValues;
- (void)startProvidingSignals;
- (void)stopProvidingSignals;
- (void)switchSourceToFile:(NSString *)filename;
- (void)switchSourceToDevice;
@end
