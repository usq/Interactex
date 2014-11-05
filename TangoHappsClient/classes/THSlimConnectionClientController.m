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
@property (nonatomic, strong, readwrite) NSString *connectedPeer;
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

        self.session = [[GKSession alloc] initWithSessionID:@"flexSession"
                                                displayName:@"TangoHapps Client"
                                                sessionMode:GKSessionModeClient];
        
        self.session.delegate = self;
        self.session.disconnectTimeout = 5;
        self.session.available = YES;

    }
    return self;
}

- (void)startConnection
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    NSLog(@"initializing GKSession");

    self.session.available = YES;
}

- (void)stopConnection
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    self.shouldConnect = NO;
    self.sessionReady = NO;
    [self.session disconnectFromAllPeers];

    
    if([BLEDiscovery sharedInstance].peripheralDelegate == self)
    {
        NSLog(@"disconnecting peripheral");
        [[BLEDiscovery sharedInstance] disconnectCurrentPeripheral];
        [BLEDiscovery sharedInstance].discoveryDelegate = nil;
        [BLEDiscovery sharedInstance].peripheralDelegate = nil;
    }
    else
    {
        NSLog(@"I'm not the delegate, %@ is, SlimConnection is not touching BLEDiscovery",[BLEDiscovery sharedInstance].peripheralDelegate);
    }
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
            NSLog(@"session available, connecting to peer");
            [self.session connectToPeer:peerID
                            withTimeout:4];
        }
            break;
            
        case GKPeerStateDisconnected:
        {
            self.sessionReady = NO;
        }
            break;
            
        case GKPeerStateConnected:
        {
            self.session.available = NO;
            self.connectedPeer = peerID;
            self.sessionReady = YES;
            
            [BLEDiscovery sharedInstance].discoveryDelegate = self;
            [BLEDiscovery sharedInstance].peripheralDelegate = self;
            
            NSLog(@"connected gamekit session");
            self.shouldConnect = YES;
            if([BLEDiscovery sharedInstance].currentPeripheral.state == CBPeripheralStateConnected)
            {
                NSLog(@"Has already connected peripheral, doing strange things...");
                [[BLEDiscovery sharedInstance] connectPeripheral:[BLEDiscovery sharedInstance].currentPeripheral];
            }
            else if([[BLEDiscovery sharedInstance].foundPeripherals count] == 1)
            {
                NSLog(@"Connect to known peripheral");
                [[BLEDiscovery sharedInstance] connectPeripheral:[[BLEDiscovery sharedInstance].foundPeripherals firstObject]];
            }
            else
            {
                NSLog(@"scanning for ble...");
                [[BLEDiscovery sharedInstance] startScanningForUUIDString:[self uuidString]];
            }

        }
            break;
            
        default:
        {
            NSLog(@"--- session changed state to %i",state);
            self.sessionReady = NO;
        }
            break;
    }
}

- (NSString *)uuidString
{
    return @"713d0000-503e-4c75-ba94-3148f18d941e";
}

- (void)session:(GKSession *)session
connectionWithPeerFailed:(NSString *)peerID
      withError:(NSError *)error
{
    NSLog(@"%s : %@, retrying",__PRETTY_FUNCTION__,error);
    
}

- (void)session:(GKSession *)session
didFailWithError:(NSError *)error
{
    NSLog(@"%s failed with error: %@",__PRETTY_FUNCTION__, error);
    session.available = YES;
}

- (void)discoveryDidRefresh
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    NSLog(@"%@",[BLEDiscovery sharedInstance].currentPeripheral);
    NSLog(@"%@",[BLEDiscovery sharedInstance].foundPeripherals);
    NSLog(@"");
    if([BLEDiscovery sharedInstance].currentPeripheral == nil &&
       [BLEDiscovery sharedInstance].foundPeripherals.count == 0 &&
       self.shouldConnect)
    {
        [[BLEDiscovery sharedInstance] startScanningForUUIDString:[self uuidString]];
    }
    else if ([[BLEDiscovery sharedInstance].foundPeripherals count] > 1)
    {
        CBPeripheral *p = [[BLEDiscovery sharedInstance].foundPeripherals firstObject];
        [[BLEDiscovery sharedInstance] connectPeripheral:p];
    }
       
}

- (void)bleServiceDidDisconnect:(BLEService *)service
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    if(self.shouldConnect && self.sessionReady)
    {
        NSLog(@"rescanning");
        [[BLEDiscovery sharedInstance] startScanningForUUIDString:[self uuidString]];
    }
}

- (void)discoveryStatePoweredOff
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)peripheralDiscovered:(CBPeripheral *)peripheral
{
    if(self.shouldConnect && self.sessionReady)
    {
        [[BLEDiscovery sharedInstance] connectPeripheral:peripheral];
    }
}

- (void)bleServiceDidConnect:(BLEService *)service
{
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

        if(self.session && dataToSend.length > 0)
        {
            NSError *e;
            [self.session sendData:dataToSend
                           toPeers:@[self.connectedPeer]
                      withDataMode:GKSendDataReliable
                             error:&e];
            if(e)
            {
                NSLog(@"error sensing data: %@",e);
            }
        }
        
    }
    else
    {
        self.session.available = YES;
        NSLog(@"gksession not ready, session available: %@ ",self.session.available?@"YES":@"NO");
        [[BLEDiscovery sharedInstance] disconnectCurrentPeripheral];

    }
}
@end
