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
        self.shouldConnect = YES;
    }
    return self;
}

- (void)startConnection
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    NSLog(@"initializing GKSession");

    self.session = [[GKSession alloc] initWithSessionID:@"flexSession"
                                            displayName:nil
                                            sessionMode:GKSessionModeClient];
    
    self.session.delegate = self;
    self.session.available = YES;
}

- (void)stopConnection
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    self.shouldConnect = NO;
    self.sessionReady = NO;
    self.session.delegate = nil;
    [self.session disconnectFromAllPeers];
    self.session.available = NO;
    
    if([BLEDiscovery sharedInstance].peripheralDelegate == self)
    {
        [[BLEDiscovery sharedInstance] disconnectCurrentPeripheral];
        [BLEDiscovery sharedInstance].discoveryDelegate = nil;
        [BLEDiscovery sharedInstance].peripheralDelegate = nil;
    }
    else
    {
        NSLog(@"!______________________________________________________________________________________");
    }
    
    self.session = nil;
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
            NSLog(@"%s",__PRETTY_FUNCTION__);
            NSLog(@"session available, connecting to peer");
            [self.session connectToPeer:peerID
                            withTimeout:4];
        }
            break;
            
        case GKPeerStateDisconnected:
        {
            NSLog(@"SESSION DISCONNECTED");
            self.sessionReady = NO;
        }
            break;
            
        case GKPeerStateConnected:
        {
            
            //[[BLEDiscovery sharedInstance] stopScanning];
            //[[BLEDiscovery sharedInstance] disconnectCurrentPeripheral];
            [BLEDiscovery sharedInstance].discoveryDelegate = self;
            [BLEDiscovery sharedInstance].peripheralDelegate = self;

            
            NSLog(@"connected gamekit session");
            self.shouldConnect = YES;
            if([BLEDiscovery sharedInstance].currentPeripheral.state == CBPeripheralStateConnected)
            {
                NSLog(@"---%@",[BLEDiscovery sharedInstance].connectedService);
            }
            else if([[BLEDiscovery sharedInstance].foundPeripherals count] == 1)
            {
                NSLog(@"connect known peripheral");
                [[BLEDiscovery sharedInstance] connectPeripheral:[[BLEDiscovery sharedInstance].foundPeripherals firstObject]];
            }
            else
            {
                NSLog(@"scanning for ble...");
                [[BLEDiscovery sharedInstance] startScanningForUUIDString:@"713d0000-503e-4c75-ba94-3148f18d941e"];
            }

  
            self.connectedPeer = peerID;
            self.sessionReady = YES;
            
        }
            break;
            
        default:
            NSLog(@"--- session changed state to %i",state);
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


#warning this message is not clean

- (void)didReceiveData:(uint8_t *)buffer
                lenght:(NSInteger)originalLength
{
    if(self.sessionReady)
    {
        
        @try {
            NSData *dataToSend = [NSData dataWithBytes:buffer
                                                length:originalLength];
            NSError *e;
            if(self.session && dataToSend.length > 0)
            {
                [self.session sendData:dataToSend
                               toPeers:@[self.connectedPeer]
                          withDataMode:GKSendDataReliable
                                 error:&e];
                if(e)
                {
                    NSLog(@"%@",e);
                }
            }
            
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception);
        }
        @finally {
            
        }
       
    }
    else
    {
        [[BLEDiscovery sharedInstance] disconnectCurrentPeripheral];
        NSLog(@"gksession not connected");
    }
}
@end
