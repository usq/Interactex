//
//  THAsyncConnection.h
//  TangoHapps
//
//  Created by Michael Conrads on 11/07/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface THAsyncConnection : NSObject
+ (instancetype)sharedConnection;
- (IBAction)nextSlide:(id)sender;
- (void)sendCommand:(NSString *)command;
@end
