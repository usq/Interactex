//
//  THGesturePaletteItem.m
//  TangoHapps
//
//  Created by Michael Conrads on 13/03/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THGesturePaletteItem.h"
#import "THGestureEditable.h"

@implementation THGesturePaletteItem

- (void)dropAt:(CGPoint)location
{
    THGestureEditable *editableSignalSource = [[THGestureEditable alloc] init];
    editableSignalSource.position = location;
    
    THProject *project = [THDirector sharedDirector].currentProject;
    
    [project addValue:editableSignalSource];
}

@end
