
#import "THGraphView.h"
#import "THGraphTextView.h"
#import "THGraphViewHelper.h"
#import "THGraphViewSegment.h"
#import "THGraphViewSegmentGroup.h"

@interface THGraphView ()
@property (nonatomic, strong, readwrite) NSMutableArray *segmentGroups;
@property (nonatomic, strong, readwrite) NSArray *circleColors;
@end

@implementation THGraphView

float const kGraphViewLeftAxisWidth = 42.0;

- (id)initWithFrame:(CGRect)frame
           maxAxisY:(float)maxAxisY
           minAxisY:(float)minAxisY
{
    
	self = [super initWithFrame:frame];
	if (self != nil) {
        
        _maxAxisY = maxAxisY;
        _minAxisY = minAxisY;
        
		[self commonInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	self = [super initWithCoder:decoder];
	if (self != nil) {
		[self commonInit];
	}
	return self;
}

- (void)commonInit
{
    self.segmentGroups = [NSMutableArray array];
    self.circleColors = @[[UIColor blueColor],
                          [UIColor cyanColor],
                          [UIColor magentaColor],
                          [UIColor orangeColor],
                          [UIColor purpleColor],
                          [UIColor brownColor]];
    
    CGRect frame = CGRectMake(0.0, 0.0, kGraphViewLeftAxisWidth, self.frame.size.height);
	_textView = [[THGraphTextView alloc] initWithFrame:frame maxAxisY: self.maxAxisY minAxisY:self.minAxisY];
	[self addSubview:self.textView];
    
    
    //add lines 1 and 2
    [self addSegmentGroup];
    [self addSegmentGroup];
    [self stop];
}

- (void)addSegmentGroup
{
    CGRect frame = CGRectMake(kGraphViewLeftAxisWidth, 0.0, self.frame.size.width - kGraphViewLeftAxisWidth, self.frame.size.height);
    
    THGraphViewSegmentGroup *segmentGroup = [[THGraphViewSegmentGroup alloc] initWithFrame:frame
                                                                                     color:[self circledColor]];
//    segmentGroup.hidden = YES;
    [self addSubview:segmentGroup];
    [self.segmentGroups addObject:segmentGroup];
}

- (void)removeSegmentGroupFromEnd
{
    THGraphViewSegmentGroup *segementGroup = [self.segmentGroups lastObject];
    [segementGroup removeFromSuperview];
    [self.segmentGroups removeLastObject];
}


- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    frame = CGRectMake(0.0, 0.0, kGraphViewLeftAxisWidth, self.frame.size.height);
    self.textView.frame = frame;
    
    frame = CGRectMake(kGraphViewLeftAxisWidth, 0.0, self.frame.size.width - kGraphViewLeftAxisWidth, self.frame.size.height);
    
    for (THGraphViewSegmentGroup *oneSegmentGroup in self.segmentGroups)
    {
        oneSegmentGroup.frame = frame;
    }
}

- (void)setMaxAxisY:(float)maxAxisY{
    self.textView.maxAxisY = maxAxisY;
    [self.textView setNeedsDisplay];
}

-(void) setMinAxisY:(float)minAxisY{
    self.textView.minAxisY = minAxisY;
        [self.textView setNeedsDisplay];
}

- (void)addX:(float)value{
    
    [self addValue1:value];
}

- (void)addValue1:(float)valueToAdd
{
    [(THGraphViewSegmentGroup *)self.segmentGroups[0] addValue:valueToAdd];
}

- (void)addY:(float)value
{
    [self addValue2:value];
}

- (void)addValue2:(float)valueToAdd
{
    [(THGraphViewSegmentGroup *)self.segmentGroups[1] addValue:valueToAdd];
}


- (void)addValues:(NSArray *)values
{
    while ([values count] > [self.segmentGroups count])
    {
        [self addSegmentGroup];
        
    }
    
    while ([values count] < [self.segmentGroups count])
    {
        [self removeSegmentGroupFromEnd];
    }

    for (int i = 0; i < [values count]; i++)
    {
        NSNumber *n = values[i];
        THGraphViewSegmentGroup *segementGroup = self.segmentGroups[i];
        [segementGroup addValue:[n floatValue]];
    }
}

- (UIColor *)circledColor
{
    NSUInteger pos = [self.segmentGroups count] % [self.circleColors count];
    return self.circleColors[pos];
}

- (UIColor *)randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.6;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.4;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue
                      saturation:saturation
                      brightness:brightness
                           alpha:1];
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	// Fill in the background
	CGContextSetFillColorWithColor(context, graphBackgroundColor());
	CGContextFillRect(context, self.bounds);
    
    DrawHorizontalLine(context, 0.0, kGraphViewGraphOffsetY + kGraphViewAxisLabelSize.height / 2.0f , self.bounds.size.width);
	//DrawHorizontalLine(context, 0.0, self.bounds.size.height / 2.0f + kGraphViewAxisLabelSize.height / 2.0f, self.bounds.size.width);
	DrawHorizontalLine(context, 0.0, self.bounds.size.height - kGraphViewGraphOffsetY - kGraphViewAxisLabelSize.height / 2.0f, self.bounds.size.width);
    StrokeLines(context);
}

- (void)stop{
    
    for (THGraphViewSegmentGroup *oneSegementGroup in self.segmentGroups)
    {
        oneSegementGroup.hidden = YES;
    }
}

- (void)start
{
    for (THGraphViewSegmentGroup *oneSegementGroup in self.segmentGroups)
    {
        oneSegementGroup.hidden = NO;
    }
}

@end
