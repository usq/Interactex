//
//  THMRecordedSignal.h
//  TangoHapps
//
//  Created by Michael Conrads on 13/06/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface THMRecordedSignal : NSObject
- (void)saveRecordingUnderName:(NSString *)recordingName;
- (THMRecordedSignal *)loadRecordedSignalWithName:(NSString *)recordingName;
@end
