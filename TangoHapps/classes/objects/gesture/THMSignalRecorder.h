//
//  THMSignalRecorder.h
//  TangoHapps
//
//  Created by Michael Conrads on 13/06/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "THMSignalSource.h"
#import "THMRecordedSignal.h"

/*
 The SignalRecorder is responsible for recording values provided by a signal source
 
 */
@interface THMSignalRecorder : NSObject
+ (instancetype)signalRecorderWithSignalSource:(THMSignalSource *)signalSource;
- (void)startRecording;
- (THMRecordedSignal *)stopRecording;
@end
