//
//  THMacbookCommand.m
//  TangoHapps
//
//  Created by Michael Conrads on 05/10/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THMacbookCommand.h"

@implementation THMacbookCommand
- (void)load
{
    TFProperty * property = [TFProperty propertyWithName:@"command"
                                                 andType:kDataTypeString];
    
    self.properties = [NSMutableArray arrayWithObject:property];
}


-(id) init{
    self = [super init];
    if(self){
        [self load];
    }
    return self;
}

#pragma mark - Archiving

-(id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    
    _command = [decoder decodeObjectForKey:@"command"];
    
    [self load];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:_command forKey:@"command"];
}

-(id)copyWithZone:(NSZone *)zone {
    THMacbookCommand * copy = [super copyWithZone:zone];
    
    copy.command = self.command;
    
    return copy;
}

#pragma mark - Methods

-(NSString*) description{
    return @"MacbookCommad";
}


@end
