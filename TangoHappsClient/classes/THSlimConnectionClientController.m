//
//  THSlimConnectionController.m
//  TangoHapps
//
//  Created by Michael Conrads on 25/03/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THSlimConnectionClientController.h"
#import <GameKit/GameKit.h>
@interface THSlimConnectionClientController()<GKSessionDelegate, BLEDiscoveryDelegate, BLEServiceDelegate, BLEServiceDataDelegate>
@property (nonatomic, strong, readwrite) GKSession *session;
@property (nonatomic, strong, readwrite) IFFirmata *firmataController;
@property (nonatomic, assign, readwrite) BOOL sessionReady;
@property (nonatomic, assign, readwrite) NSString *connectedPeer;
@end
@implementation THSlimConnectionClientController
- (void)startConnection
{
    [BLEDiscovery sharedInstance].discoveryDelegate = self;
    [BLEDiscovery sharedInstance].peripheralDelegate = self;
    
    [[BLEDiscovery sharedInstance] startScanningForSupportedUUIDs];
    
    self.session = [[GKSession alloc] initWithSessionID:@"flexSession"
                                                  displayName:nil
                                                  sessionMode:GKSessionModeClient];
    
    self.session.delegate = self;
    self.session.available = YES;
}

- (void)session:(GKSession *)session
           peer:(NSString *)peerID
 didChangeState:(GKPeerConnectionState)state
{
    if(state == GKPeerStateAvailable)
    {
        [self.session connectToPeer:peerID withTimeout:10];
    }
    if(state == GKPeerStateConnected)
    {
        self.connectedPeer = peerID;
        self.sessionReady = YES;
    }
    else
    {
        self.sessionReady = NO;
    }
}

- (void)discoveryDidRefresh
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)bleServiceDidDisconnect:(BLEService *)service
{
    [[BLEDiscovery sharedInstance] startScanningForSupportedUUIDs];
}

- (void)discoveryStatePoweredOff
{
        NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)peripheralDiscovered:(CBPeripheral *)peripheral
{
    [[BLEDiscovery sharedInstance] connectPeripheral:peripheral];
}
- (void)bleServiceDidConnect:(BLEService *)service
{
        NSLog(@"%s",__PRETTY_FUNCTION__);
    
    service.delegate = self;
    service.shouldUseCRC = NO;
    service.shouldUseTurnBasedCommunication = NO;
}

- (void)bleServiceIsReady:(BLEService *)service
{
    service.dataDelegate = self;
}

- (void)didReceiveData:(uint8_t *)buffer
                lenght:(NSInteger)originalLength
{
    
    uint16_t k = buffer[14];
    k<<=8;
    k = k | buffer[15];
    if(self.sessionReady)
    {
        NSData *dataToSend = [NSData dataWithBytes:&k length:sizeof(uint16_t)];
        NSError *e;
        [self.session sendData:dataToSend
                       toPeers:@[self.connectedPeer]
                  withDataMode:GKSendDataReliable
                         error:&e];
        if(e)
        {
            NSLog(@"%@",e);
        }
    }
    else
    {
        NSLog(@"gksession not connected");
    }
}
@end
