//
//  THMacbookCommandPaletteItem.m
//  TangoHapps
//
//  Created by Michael Conrads on 05/10/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THMacbookCommandPaletteItem.h"
#import "THMacbookCommandEditable.h"
@implementation THMacbookCommandPaletteItem
- (void)dropAt:(CGPoint)location
{
    THMacbookCommandEditable *editableSignalSource = [[THMacbookCommandEditable alloc] init];
    editableSignalSource.position = location;
    
    THProject *project = [THDirector sharedDirector].currentProject;
    
    [project addValue:editableSignalSource];
}

- (NSString *)description
{
    return @"Macbook Command";
}
@end
