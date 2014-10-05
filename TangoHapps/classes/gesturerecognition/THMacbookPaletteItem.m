//
//  THMacbookPaletteItem.m
//  TangoHapps
//
//  Created by Michael Conrads on 11/07/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THMacbookPaletteItem.h"
#import "THMacbookEditable.h"

@implementation THMacbookPaletteItem
- (void)dropAt:(CGPoint)location
{
    THMacbookEditable *editable = [[THMacbookEditable alloc] init];
    editable.position = location;
    
    THProject *project = [THDirector sharedDirector].currentProject;
    
    [project addValue:editable];
}

@end
