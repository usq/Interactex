//
//  THGestureClassifierPopoverContentViewController.m
//  TangoHapps
//
//  Created by Michael Conrads on 10/07/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THGestureClassifierPopoverContentViewController.h"

#import "THGestureClassifierEditable.h"
#import "THGestureClassifier.h"
#import "THGraphView.h"
#import "THSignalSource.h"
#import "THGestureClassifierPopoverGraphView.h"



@interface THGestureClassifierPopoverContentViewController ()
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (nonatomic, weak, readwrite) THGestureClassifierEditable *gestureClassifierEditable;
@property (nonatomic, weak, readwrite) THGestureClassifier *gestureClassifier;
@property (nonatomic, weak, readwrite) THGestureClassifierProperties *gestureClassifierProperties;

@property (nonatomic, assign, readwrite) float graphSize;
@property (nonatomic, strong, readwrite) THGraphView *graphView;
@property (nonatomic, assign, readwrite) BOOL savePressed;
@property (nonatomic, assign, readwrite) BOOL KVOregistered;
@property (nonatomic, weak, readwrite) THSignalSource *signalSource;
@property (nonatomic, strong, readwrite) NSMutableArray *visibleValues;
@property (nonatomic, assign, readwrite) float leftPercentage;
@property (nonatomic, assign, readwrite) float rightPercentage;
@end

@implementation THGestureClassifierPopoverContentViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
              gestureClassifierProperties:(THGestureClassifierProperties *)gestureClassifierProperties
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self) {
        self.leftPercentage = 0;
        self.rightPercentage = 1;
        self.gestureClassifierProperties = gestureClassifierProperties;
        self.gestureClassifierEditable = (THGestureClassifierEditable *)self.gestureClassifierProperties.editableObject;
        self.gestureClassifier = (THGestureClassifier *)self.gestureClassifierEditable.simulableObject;
        self.signalSource = [THSignalSource sharedSignalSource];
        self.visibleValues = [NSMutableArray array];
    }
    return self;
}



- (IBAction)okPressed:(id)sender
{
    if(self.savePressed == NO)
    {
        self.savePressed = YES;
        [self removeKVO];
    }
    else
    {
        [self cropVisibleValues];
        [self.gestureClassifier finishedGesture:self.visibleValues];
        
        [self.currentPopoverController dismissPopoverAnimated:YES];
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSValue *n = change[NSKeyValueChangeNewKey];
    
    
    [self.visibleValues addObject:n];
    while([self.visibleValues count] > 300)
    {
        [self.visibleValues removeLastObject];
    }
    
    Signal s;
    [n getValue:&s];
    
    float n1 = s.finger1;
    float n2 = s.finger2;
    float accX = s.accX;
    
    accX = fmaxf(accX, -15000);
    accX = fminf(accX, 15000);
    
    float faccx = (accX + 15000)/30000;
    
    NSLog(@"value1:%i value2: %i",s.finger1,s.finger2);
    n1 -= 100; //correcting offset 130 to 282 -> 30 to 182
    n2 -= 100; //correcting offset 130 to 282 -> 30 to 182
    faccx *= 200;
    
    float normalized1 = n1/180.f;
    float normalized2 = n2/180.f;
    
    //holds ca 300
    [self.graphView addValue1:normalized1 * 182.f * 0.9];
//    [self.graphView addValue2:normalized2 * 182.f * 0.9];
    [self.graphView addValue2:faccx];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.savePressed = NO;
    self.graphView = [[THGraphView alloc] initWithFrame:self.view.frame maxAxisY:400 minAxisY:0];
    [self.view addSubview:self.graphView];
    
    float wLeft = 42.0;
    float spaceForDisplaying = self.graphView.frame.size.width - 2*wLeft;
    self.graphSize = spaceForDisplaying;
    
    if(self.KVOregistered == NO)
    {
        self.KVOregistered = YES;
        [self.signalSource addObserver:self
                            forKeyPath:@"currentOutputValue"
                               options:NSKeyValueObservingOptionNew
                               context:nil];
    }
    else
    {
        assert(false);
    }
    
    [self.graphView start];
    THGestureClassifierPopoverGraphView *contentView = [[THGestureClassifierPopoverGraphView alloc] initWithFrame:self.view.frame
                                                                                                leftPercentage:0
                                                                                               rightPercentage:1
                                                                                                            of:self.graphSize];
    [self.view addSubview:contentView];
    
    
    self.okButton.backgroundColor = [UIColor colorWithWhite:0.200 alpha:1.000];
    [self.view bringSubviewToFront:self.okButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movedBar:)
                                                 name:@"gestureMovedBar"
                                               object:nil];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"gestureMovedBar"
                                                  object:nil];
    [self removeKVO];
}

- (void)removeKVO
{
    if(self.KVOregistered)
    {
        self.KVOregistered = NO;
        
        [self.signalSource removeObserver:self
                               forKeyPath:@"currentOutputValue"];
        
    }
}


- (void)movedBar:(NSNotification *)notification
{
    float left = [notification.userInfo[@"left"] floatValue];
    float right = [notification.userInfo[@"right"] floatValue];
    
    float wLeft = 42.0;
    float l = left - wLeft;
    
    self.leftPercentage =  fmax(l/self.graphSize,0);
    self.rightPercentage = fmax((right - wLeft)/self.graphSize,0);
}

- (void)cropVisibleValues
{
    NSUInteger leftIndex = floorf([self.visibleValues count] * self.leftPercentage);
    NSUInteger rightIndex = ceilf([self.visibleValues count] * self.rightPercentage);
    NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(leftIndex, rightIndex - leftIndex + 1)];
    self.visibleValues = [[self.visibleValues objectsAtIndexes:set] mutableCopy];
}



- (CGSize)contentSizeForViewInPopover
{
    return self.view.frame.size;
}
@end
