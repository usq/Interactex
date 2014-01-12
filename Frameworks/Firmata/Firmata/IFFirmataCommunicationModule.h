//
//  IFFirmataCommunicationModule.h
//  BLEFirmata
//
//  Created by Juan Haladjian on 10/21/13.
//  Copyright (c) 2013 TUM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IFFirmataCommunicationModule : NSObject

-(void) sendData:(uint8_t*) bytes count:(NSInteger) count;

@property (nonatomic) BOOL usesFillBytes;

@end
