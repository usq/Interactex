//
//  THSignalSourceEditable.m
//  TangoHapps
//
//  Created by Michael Conrads on 28/02/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//
#import "THSignalSourceProperties.h"
#import "THSignalSourceEditable.h"
#import "THSignalSource.h"
#import <GameKit/GameKit.h>

@interface THSignalSource ()
@property (nonatomic, assign, readwrite) float leftBorderPercentage;
@property (nonatomic, assign, readwrite) float rightBorderPercentage;
@end


@interface THSignalSourceEditable ()<GKSessionDelegate>
@property (nonatomic, strong, readwrite) GKSession *session;
@property (nonatomic, assign, readwrite) BOOL recording;
@end


@implementation THSignalSourceEditable

- (void)load
{
    
    self.sprite = [CCSprite spriteWithFile:@"signalsource.png"];
    [self addChild:self.sprite];
    
    self.acceptsConnections = YES;
}

- (id)init
{
    self = [super init];
    if(self){
        self.simulableObject = [[THSignalSource alloc] init];
        [self load];
    }
    return self;
}

- (void)update
{
    THSignalSource *source = (THSignalSource *)self.simulableObject;
    [source updatedSimulation];
}

- (void)start
{
    [(THSignalSource *)self.simulableObject start];
}

- (void)stop
{
    [(THSignalSource *)self.simulableObject stop];
}

- (void)toggle
{
    [(THSignalSource *)self.simulableObject toggle];
}


- (NSString *)description
{
    return @"SignalSource";
}

- (void)setLeftBorderPercentage:(float)leftBorderPercentage
{
    ((THSignalSource *)self.simulableObject).leftBorderPercentage = leftBorderPercentage;
}

- (void)setRightBorderPercentage:(float)rightBorderPercentage
{
    ((THSignalSource *)self.simulableObject).rightBorderPercentage = rightBorderPercentage;
}

- (float)leftBorderPercentage
{
    return ((THSignalSource *)self.simulableObject).leftBorderPercentage;
}

- (float)rightBorderPercentage
{
    return ((THSignalSource *)self.simulableObject).rightBorderPercentage;
}

- (void)switchSourceFile:(NSString *)filename
{
    THSignalSource *source = (THSignalSource *)self.simulableObject;
    [source switchSourceFile:filename];
}


- (void)recordeNewGesture
{
    self.recording = YES;
    THSignalSource *source = (THSignalSource *)self.simulableObject;
    [source startRecording];
    [self establishConnection];
}

- (void)stopRecording
{
    self.recording = NO;
   THSignalSource *source = (THSignalSource *)self.simulableObject;
    [source stopRecording];
    [self.session disconnectFromAllPeers];
}

- (void)saveRecording
{
    THSignalSource *source = (THSignalSource *)self.simulableObject;
    [source saveRecording];
}

- (void)establishConnection
{
    self.session = [[GKSession alloc] initWithSessionID:@"flexSession"
                                            displayName:nil
                                            sessionMode:GKSessionModeServer];
    self.session.delegate = self;
    self.session.available = YES;
}

- (NSArray *)recordedData
{
    THSignalSource *source = (THSignalSource *)self.simulableObject;
    return source.data;
}

-(void)session:(GKSession *)aSession
didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    NSError *error;
    [self.session setDataReceiveHandler:self withContext:nil];
    [self.session acceptConnectionFromPeer:peerID error:&error];
}


- (void)session:(GKSession *)session
           peer:(NSString *)peerID
 didChangeState:(GKPeerConnectionState)state
{
    NSLog(@"%i",state);
}

- (void)receiveData:(NSData *)data
           fromPeer:(NSString *)peer
          inSession:(GKSession *)session
            context:(void *)context
{
    if(self.recording)
    {

        uint32_t signalValue = *(uint32_t *)[data bytes];
        
        uint32_t backup = signalValue;
        uint16_t value2 = (uint16_t)backup;
        backup >>= 8;
        uint16_t value1 = (uint16_t)backup;
        
        NSLog(@"value1: %i   value2:  %i", value1, value2);
        
        //const uint8_t *data = ((uint8_t *)[data bytes]);
        
        
        
//        uint16_t signalValue = *(uint16_t *)[data bytes];
        THSignalSource *source = (THSignalSource *)self.simulableObject;
        
        
        
        [source recordValue:signalValue];
    }
}


#pragma mark - Property Controller

- (NSArray *)propertyControllers
{
    NSArray *controllers = [super propertyControllers];
    THSignalSourceProperties *properties = [THSignalSourceProperties properties];
    //add property-controllers here

    return [controllers arrayByAddingObject:properties];
}


#pragma mark - Archiving

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if(self){
        [self load];
      
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
}

- (id)copyWithZone:(NSZone *)zone {
    THSignalSourceEditable * copy = [super copyWithZone:zone];
    return copy;
}



@end
