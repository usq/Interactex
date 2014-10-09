//
//  THAsyncConnection.m
//  TangoHapps
//
//  Created by Michael Conrads on 11/07/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THAsyncConnection.h"
#import "GCDAsyncSocket.h"

typedef struct
{
    uint16_t length;
} Controll_MSG;

@interface THAsyncConnection ()<GCDAsyncSocketDelegate>
@property (nonatomic, strong, readwrite) GCDAsyncSocket *socket;
@end
@implementation THAsyncConnection
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self connect];

    }
    return self;
}
+ (instancetype)sharedConnection
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}
- (void)connect
{
    NSLog(@"connecting to presentation server....");
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self
                                             delegateQueue:dispatch_get_main_queue()];
    NSError *error;
    BOOL success = [self.socket connectToHost:@"192.168.178.64"
                                       onPort:1234
                                        error:&error];
    
    if(success)
    {
        NSLog(@"connected to socket");
    }
    else
    {
        NSLog(@"%@",error);
        return;
    }
}


- (void)socket:(GCDAsyncSocket *)sock
didWriteDataWithTag:(long)tag
{
    NSLog(@"i wrote data");
}

- (void)socket:(GCDAsyncSocket *)sock
didConnectToHost:(NSString *)host
          port:(uint16_t)port
{
    NSLog(@"connected to host: %@",host);
    
}

- (void)sendCommand:(NSString *)command
{
    //NSArray *components = [command componentsSeparatedByString:@"#-#"];
    NSData *d = [command dataUsingEncoding:NSUTF8StringEncoding];
    Controll_MSG msg = {};
    msg.length = d.length;
    
    NSData *msgData = [NSData dataWithBytes:&msg
                                     length:sizeof(Controll_MSG)];
    [self.socket writeData:msgData
               withTimeout:-1
                       tag:42];
    
    

    
    [self.socket writeData:d
               withTimeout:-1
                       tag:43];
}

- (IBAction)startPres:(id)sender {
    [self writeOpcode:1];
}
- (IBAction)nextSlide:(id)sender {
    [self writeOpcode:2];
}

- (IBAction)prevSlide:(id)sender {
    [self writeOpcode:3];
}

- (void)writeOpcode:(uint8_t)opcode
{
//    Controll_MSG msg;
////    msg.opcode = opcode;
//    NSData *d = [[NSData alloc] initWithBytes:&msg
//                                       length:sizeof(Controll_MSG)];
//    [self.socket writeData:d
//               withTimeout:-1
//                       tag:42];
//    
}

@end
