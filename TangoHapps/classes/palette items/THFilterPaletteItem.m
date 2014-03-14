//
//  THFilterPaletteItem.m
//  TangoHapps
//
//  Created by Michael Conrads on 13/03/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THFilterPaletteItem.h"
#import "THFilterEditable.h"
@implementation THFilterPaletteItem

- (void)dropAt:(CGPoint)location
{
    THFilterEditable *editableSignalSource = [[THFilterEditable alloc] init];
    editableSignalSource.position = location;
    
    THProject *project = [THDirector sharedDirector].currentProject;
    
    [project addValue:editableSignalSource];
}

@end
