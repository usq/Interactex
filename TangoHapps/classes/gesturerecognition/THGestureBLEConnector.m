//
//  THGestureBLEConnector.m
//  TangoHapps
//
//  Created by Michael Conrads on 05/10/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THGestureBLEConnector.h"

#import "BLE.h"
#import "THProjectLocation.h"

@interface THGestureBLEConnector ()<BLEDiscoveryDelegate, BLEServiceDelegate, BLEServiceDataDelegate>
@property (nonatomic, weak, readwrite) THSignalSource *registeredSignalSource;
@property (nonatomic, assign, readwrite) BOOL scanning;
@end

@implementation THGestureBLEConnector
+ (instancetype)sharedConnector
{
    static THGestureBLEConnector *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[THGestureBLEConnector alloc] init];
        instance.scanning = NO;
    });
    return instance;
}

- (void)registerSignalSource:(THSignalSource *)signalSource
{
    if(self.registeredSignalSource == nil)
    {
        self.registeredSignalSource = signalSource;
    }
}

- (void)deregisterSignalSource:(THSignalSource *)signalSource
{
    if([BLEDiscovery sharedInstance].discoveryDelegate == self)
    {
        [BLEDiscovery sharedInstance].discoveryDelegate = nil;
        [BLEDiscovery sharedInstance].peripheralDelegate = nil;
        self.registeredSignalSource = nil;
    }
}

- (void)start
{
//    if([THProjectLocation appRunning] == NO)
//    {
//        return;
//    }
//    
    NSLog(@"-------------------------%i",self.scanning);
    if([BLEDiscovery sharedInstance].currentPeripheral == nil)
    {
        NSLog(@"%s",__PRETTY_FUNCTION__);
//        [[BLEDiscovery sharedInstance] stopScanning];
        //[[BLEDiscovery sharedInstance] disconnectCurrentPeripheral];
        [BLEDiscovery sharedInstance].discoveryDelegate = self;
        [BLEDiscovery sharedInstance].peripheralDelegate = self;
        
        if([[BLEDiscovery sharedInstance].foundPeripherals count] > 0)
        {
            [[BLEDiscovery sharedInstance] connectPeripheral:[BLEDiscovery sharedInstance].foundPeripherals[0]];
        }
        else
        {
            [[BLEDiscovery sharedInstance] startScanningForUUIDString:@"713d0000-503e-4c75-ba94-3148f18d941e"];
        }

        self.scanning = YES;
    }
    else
    {
        [BLEDiscovery sharedInstance].discoveryDelegate = self;
        [BLEDiscovery sharedInstance].peripheralDelegate = self;
    }
}

- (void)discoveryDidRefresh
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    NSLog(@"%@",[BLEDiscovery sharedInstance].currentPeripheral);
    NSLog(@"%@",[BLEDiscovery sharedInstance].foundPeripherals);
    NSLog(@"");
    if([BLEDiscovery sharedInstance].currentPeripheral == nil &&
       [BLEDiscovery sharedInstance].foundPeripherals.count == 0)
    {
        [[BLEDiscovery sharedInstance] startScanningForUUIDString:@"713d0000-503e-4c75-ba94-3148f18d941e"];
    }
    else if ([[BLEDiscovery sharedInstance].foundPeripherals count] > 1)
    {
        CBPeripheral *p = [[BLEDiscovery sharedInstance].foundPeripherals firstObject];
        [[BLEDiscovery sharedInstance] connectPeripheral:p];
    }

    
    
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)bleServiceDidConnect:(BLEService *)service
{
    self.scanning = NO;
    NSLog(@"%s",__PRETTY_FUNCTION__);
    service.delegate = self;
    service.shouldUseCRC = NO;
    service.shouldUseTurnBasedCommunication = NO;

}
- (void)bleServiceDidDisconnect:(BLEService *)service
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    if(self.registeredSignalSource)
    {
        NSLog(@"\n\n\nSKIPPING restart \n\n\n");
     // [self start];
    }
}

- (void)bleServiceIsReady:(BLEService *)service
{
    service.dataDelegate = self;
}

- (void)peripheralDiscovered:(CBPeripheral *)peripheral
{

    [[BLEDiscovery sharedInstance] connectPeripheral:peripheral];
}

- (void)dealloc
{
    [self deregisterSignalSource:nil];
}

- (void)didReceiveData:(uint8_t *)buffer
                lenght:(NSInteger)originalLength
{
    assert(originalLength == 10);
    Signal s = THDecodeSignal(buffer);
    if(abs(s.accX) < 2000)
    {
        s.accX = 0;
    }
    if(abs(s.accY) < 2000)
    {
        s.accY = 0;
    }
    if(abs(s.accZ) < 2000)
    {
        s.accZ = 0;
    }
    [self.registeredSignalSource recordValue:s];
    
}

@end
