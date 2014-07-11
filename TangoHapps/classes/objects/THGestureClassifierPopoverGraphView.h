//
//  THGestureClassifierPopoverGraphView.h
//  TangoHapps
//
//  Created by Michael Conrads on 10/07/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface THGestureClassifierPopoverGraphView : UIView
- (id)initWithFrame:(CGRect)frame
     leftPercentage:(float)leftPercentage
    rightPercentage:(float)rightPercentage
                 of:(float)graphSpacing;
@end
