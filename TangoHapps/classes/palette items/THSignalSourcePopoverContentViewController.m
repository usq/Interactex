//
//  THSignalSourcePopoverContentViewController.m
//  TangoHapps
//
//  Created by Michael Conrads on 05/03/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THSignalSourcePopoverContentViewController.h"
#import "THSignalSourcePopoverContentView.h"
#import "THSignalSource.h"
#import "THGraphView.h"

@interface THSignalSourcePopoverContentViewController ()
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (nonatomic, strong, readwrite) THSignalSourceEditable *signalSourceEditable;
@property (nonatomic, strong, readwrite) NSArray *currentData;
@property (nonatomic, assign, readwrite) float graphSize;
@property (nonatomic, strong, readwrite) THGraphView *graphView;
@property (nonatomic, assign, readwrite) BOOL savePressed;
@property (nonatomic, assign, readwrite) BOOL KVOregistered;
@end

@implementation THSignalSourcePopoverContentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
         signalSourceEditable:(THSignalSourceEditable *)signalSourceEditable
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self)
    {
        self.signalSourceEditable = signalSourceEditable;
        
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSNumber *n = change[NSKeyValueChangeNewKey];
    float num = [n floatValue];
    num -= 100; //correcting offset 130 to 282 -> 30 to 182
    float normalized = num/180.f;
    
    [self.graphView addValue1:normalized * 182.f * 0.9];
}



- (void)viewDidLoad
{
    self.savePressed = NO;
    self.graphView = [[THGraphView alloc] initWithFrame:self.view.frame maxAxisY:400 minAxisY:0];
    [self.view addSubview:self.graphView];
    
    float wLeft = 42.0;
    float spaceForDisplaying = self.graphView.frame.size.width - 2*wLeft;
    self.graphSize = spaceForDisplaying;
    
    THSignalSource *signalSource = (THSignalSource *)self.signalSourceEditable.simulableObject;
    
    if(self.signalSourceEditable.recording)
    {
        self.KVOregistered = YES;
        [signalSource addObserver:self
                       forKeyPath:@"currentOutputValue"
                          options:NSKeyValueObservingOptionNew
                          context:nil];
    }
    else
    {
        NSArray *data = signalSource.data;
        
        float largest = [[data valueForKeyPath:@"@max.floatValue"] floatValue];
        
        //TODO: this assumes the number of samples is smaller than the monitor with, so it does a linear interpolation, maybe switch to splines...
        NSMutableArray *normalizedArray = [NSMutableArray arrayWithCapacity:data.count];
        
        for (NSString *oneDataString in data)
        {
            float normalizedValue = [oneDataString floatValue]/largest;
            float h = self.graphView.frame.size.height *0.9;
            
            [normalizedArray addObject:@(normalizedValue * h)];
        }
        NSArray *reversedArray = [[normalizedArray reverseObjectEnumerator] allObjects];
        
        
        //288
        float f = (float)spaceForDisplaying/(float)[reversedArray count];
        
        for (int i = 0; i < reversedArray.count -1 ; i++)
        {
            float left = [reversedArray[i] floatValue];
            float right = [reversedArray[i+1] floatValue];
            
            float dY = right - left;
            float dSegY = dY/f;
            
            
            float acc = left;
            for (int k = 0; k < f;  k++)
            {
                acc = left + k * dSegY;
                [self.graphView addValue1:acc];
            }
        }
        [self.graphView addValue1:[[reversedArray lastObject] floatValue]];
    }
    
    [self.graphView start];
    THSignalSourcePopoverContentView *contentView = [[THSignalSourcePopoverContentView alloc] initWithFrame:self.view.frame
                                                                                             leftPercentage:self.signalSourceEditable.leftBorderPercentage
                                                                                            rightPercentage:self.signalSourceEditable.rightBorderPercentage
                                                                                                         of:self.graphSize];
    [self.view addSubview:contentView];
    
    
    self.okButton.backgroundColor = [UIColor colorWithWhite:0.200 alpha:1.000];
    [self.view bringSubviewToFront:self.okButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movedBar:) name:@"movedBar" object:nil];
}





- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"movedBar" object:nil];
    if(self.KVOregistered)
    {
        self.KVOregistered = NO;
        THSignalSource *signalSource = (THSignalSource *)self.signalSourceEditable.simulableObject;
        [signalSource removeObserver:self
                          forKeyPath:@"currentOutputValue"];

    }
}


- (void)movedBar:(NSNotification *)notification
{
    float left = [notification.userInfo[@"left"] floatValue];
    float right = [notification.userInfo[@"right"] floatValue];
    
    float wLeft = 42.0;
    float l = left - wLeft;
    
    float leftpercent =  fmax(l/self.graphSize,0);
    self.signalSourceEditable.leftBorderPercentage = leftpercent;
    
    
    float rightPercent = fmax((right - wLeft)/self.graphSize,0);
    self.signalSourceEditable.rightBorderPercentage = rightPercent;
}



- (IBAction)okButtonPressed:(id)sender
{
    if(self.savePressed == NO)
    {
        self.savePressed = YES;
        [self.signalSourceProperties didPressStop];
        [self.signalSourceEditable stopRecording];
        
    }
    else
    {
            [self.signalSourceProperties didPressSave];
                    [self.signalSourceEditable saveRecording];
            [self.currentPopoverController dismissPopoverAnimated:YES];
    }


}

- (CGSize)contentSizeForViewInPopover
{
    return self.view.frame.size;
}
@end
