//
//  THMacbookCommand.h
//  TangoHapps
//
//  Created by Michael Conrads on 05/10/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFSimulableObject.h"

@interface THMacbookCommand : TFSimulableObject
@property (nonatomic, strong, readwrite) NSString *command;
@end
