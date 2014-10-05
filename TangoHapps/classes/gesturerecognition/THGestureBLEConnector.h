//
//  THGestureBLEConnector.h
//  TangoHapps
//
//  Created by Michael Conrads on 05/10/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "THSignalSource.h"

@interface THGestureBLEConnector : NSObject
+ (instancetype)sharedConnector;
- (void)registerSignalSource:(THSignalSource *)signalSource;
- (void)deregisterSignalSource:(THSignalSource *)signalSource;
- (void)start;
@end
