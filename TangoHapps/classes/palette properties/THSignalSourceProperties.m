//
//  THSignalSourceProperties.m
//  TangoHapps
//
//  Created by Michael Conrads on 28/02/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THSignalSourceProperties.h"
#import "THSignalSourceEditable.h"
#import "THSignalSourcePopoverContentViewController.h"

@interface THSignalSourceProperties ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *addRecordingButton;
@property (weak, nonatomic) IBOutlet UILabel *headline;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong, readwrite) NSArray *gestures;
@property (nonatomic, strong, readwrite) UIPopoverController *popoverViewController;
@end

@implementation THSignalSourceProperties

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self) {
        self.gestures = @[@"singletick", @"doubletick", @"testinput", @"singletick_error", @"doubletick_long"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self updateHeadlineWithFileName:self.gestures[0]];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)title
{
    return @"Signal Source";
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.gestures.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"THSignalSourcePropertiesTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = self.gestures[indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSString *fileName = self.gestures[indexPath.row];
    THSignalSourceEditable *signalSourceEditable = (THSignalSourceEditable *)self.editableObject;
    [signalSourceEditable switchSourceFile:fileName];
    [self updateHeadlineWithFileName:fileName];
    THSignalSourcePopoverContentViewController *contentViewController = [[THSignalSourcePopoverContentViewController alloc] initWithNibName:@"THSignalSourcePopoverContentViewController"
                                                                                                                                     bundle:[NSBundle mainBundle]
                                                                                                                       signalSourceEditable:signalSourceEditable];
    
    
    self.popoverViewController = [[UIPopoverController alloc] initWithContentViewController:contentViewController];
    self.popoverViewController.backgroundColor = [UIColor colorWithRed:0.321 green:0.402 blue:0.341 alpha:1.000];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    CCDirector *director = [CCDirector sharedDirector];
    
    CGRect rect = [cell convertRect:cell.contentView.frame toView:director.view];
    contentViewController.currentPopoverController = self.popoverViewController;
    
    [self.popoverViewController presentPopoverFromRect:rect
                                                inView:director.view
                              permittedArrowDirections:UIPopoverArrowDirectionLeft
                                              animated:YES];
    
}
- (IBAction)addRecordingPressed:(UIButton *)sender
{
    
}

- (void)updateHeadlineWithFileName:(NSString *)fileName
{
    self.headline.text = [NSString stringWithFormat:@"current: %@",fileName];
}

@end
