
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AvailabilityMacros.h>

@class THGraphViewSegment;
@class THGraphTextView;
@class THGraphViewSegmentGroup;

@interface THGraphView : UIView {
    
}

@property (nonatomic) float maxAxisY;
@property (nonatomic) float minAxisY;

@property (nonatomic) THGraphTextView * textView;

-(id) initWithFrame:(CGRect)frame maxAxisY:(float) maxAxisY minAxisY:(float) minAxisY;

/**
 *  Adds a value to the first graph-line of the monitor.
 *  The value is added on the left hand side of the graph.
 *
 *  @param valueToAdd the graph to add
 */
- (void)addValue1:(float)valueToAdd;

/**
 *  Adds a value to the second graph-line of the monitor.
 *  The value is added on the left hand side of the graph.
 *
 *  @param valueToAdd the graph to add
 */
- (void)addValue2:(float)valueToAdd;

/**
 *
 *  @deprecated
 *  @see: -addValue1:
 *
 *  @param x the value to add to the graph
 */
-(void) addX:(float)x DEPRECATED_MSG_ATTRIBUTE("use -addValue1: instead");

/**
 *  @deprecated
 *  @see: -addValue2:
 *
 *  @param y the value to add to the graph
 */
-(void) addY:(float)y DEPRECATED_MSG_ATTRIBUTE("use -addValue2: instead");


- (void)addValues:(NSArray *)values;

-(void) start;
-(void) stop;

@end

