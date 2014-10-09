//
//  THMacbook.m
//  TangoHapps
//
//  Created by Michael Conrads on 11/07/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THMacbook.h"
#import "THAsyncConnection.h"

@interface THMacbook ()
@property (nonatomic, strong, readwrite) THAsyncConnection *connection;
@end

@implementation THMacbook



//
//- (void)load
//{
//    TFMethod *arrowRightMethod = [TFMethod methodWithName:@"arrowRight"];
//    arrowRightMethod.numParams = 0;
//    self.methods = [NSMutableArray arrayWithObject:arrowRightMethod];
//}
//

- (void)load
{
    TFMethod *sendCommandMethod = [TFMethod methodWithName:@"sendCommand"];
    sendCommandMethod.numParams = 1;
    sendCommandMethod.firstParamType = kDataTypeString;
    
    
    self.methods = [NSMutableArray arrayWithObjects:sendCommandMethod, nil];
    
    
    self.connection = [THAsyncConnection sharedConnection];

}

- (void)sendCommand:(NSString *)command
{
    
    [self.connection sendCommand:command];
    
    NSLog(@"sending Command::::::::::::::::: %@",command);
}

#pragma mark - Archiving

- (id)init
{
    self = [super init];
    if (self)
    {
        [self load];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    [self load];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
}

-(id)copyWithZone:(NSZone *)zone
{
    THMacbook *copy = [super copyWithZone:zone];
    return copy;
}


@end
