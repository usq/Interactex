//
//  THGesturePaletteItem.m
//  TangoHapps
//
//  Created by Michael Conrads on 13/03/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THGestureClassifierPaletteItem.h"
#import "THGestureClassifierEditable.h"

@implementation THGestureClassifierPaletteItem

- (void)dropAt:(CGPoint)location
{
    THGestureClassifierEditable *editableSignalSource = [[THGestureClassifierEditable alloc] init];
    editableSignalSource.position = location;
    
    THProject *project = [THDirector sharedDirector].currentProject;
    
    [project addValue:editableSignalSource];
}

@end
