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
@property (nonatomic, assign, readwrite) BOOL sessionReady;
@property (nonatomic, assign, readwrite) NSString *connectedPeer;
@property (nonatomic, assign, readwrite) BOOL shouldConnect;
@end
@implementation THSlimConnectionClientController

+ (instancetype)sharedSlimConnectionController
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[THSlimConnectionClientController alloc] init];
    });
    return instance;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.shouldConnect = YES;
    }
    return self;
}

- (void)startConnection
{
    NSLog(@"initializing GKSession");
    self.shouldConnect = YES;
    [BLEDiscovery sharedInstance].discoveryDelegate = self;
    [BLEDiscovery sharedInstance].peripheralDelegate = self;
    
    
    
    self.session = [[GKSession alloc] initWithSessionID:@"flexSession"
                                            displayName:nil
                                            sessionMode:GKSessionModeClient];
    
    self.session.delegate = self;
    self.session.available = YES;
}

- (void)stopConnection
{
    self.shouldConnect = NO;
    [self.session disconnectFromAllPeers];
    self.session.available = NO;
    [[BLEDiscovery sharedInstance] disconnectCurrentPeripheral];
}

- (void)session:(GKSession *)session
           peer:(NSString *)peerID
 didChangeState:(GKPeerConnectionState)state
{
    
    
    //    GKPeerStateAvailable,    // not connected to session, but available for connectToPeer:withTimeout:
    //    GKPeerStateUnavailable,  // no longer available
    //    GKPeerStateConnected,    // connected to the session
    //    GKPeerStateDisconnected, // disconnected from the session
    //    GKPeerStateConnecting,   // waiting for accept, or deny response
    
    switch (state)
    {
        case GKPeerStateAvailable:
        {
            [self.session connectToPeer:peerID
                            withTimeout:4];
        }
            
            break;
            
        case GKPeerStateConnected:
        {
            
            [[BLEDiscovery sharedInstance] disconnectCurrentPeripheral];
            NSLog(@"connected gamekit session, scanning for ble...");
            [[BLEDiscovery sharedInstance] startScanningForUUIDString:@"713d0000-503e-4c75-ba94-3148f18d941e"];
            self.connectedPeer = peerID;
            self.sessionReady = YES;
            
        }
            break;
            
        default:
            self.sessionReady = NO;
            break;
    }
}



- (void)session:(GKSession *)session
didFailWithError:(NSError *)error
{
    NSLog(@"%@",error);
    session.available = YES;
}

- (void)discoveryDidRefresh
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)bleServiceDidDisconnect:(BLEService *)service
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    if(self.shouldConnect)
    {
        [[BLEDiscovery sharedInstance] startScanningForSupportedUUIDs];
    }
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
    if(self.sessionReady)
    {
        NSData *dataToSend = [NSData dataWithBytes:buffer
                                            length:originalLength];
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
