//
//  THMacbookProperties.m
//  TangoHapps
//
//  Created by Michael Conrads on 11/07/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THMacbookProperties.h"
#import "THMacbookEditable.h"
#import "THMacbook.h"

@interface THMacbookProperties ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *ipTextField;

@end

@implementation THMacbookProperties

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    THMacbookEditable *editable = (THMacbookEditable *)self.editableObject;
    self.ipTextField.text = ((THMacbook *)editable.simulableObject).hostAddress;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSURL *url = [NSURL URLWithString:textField.text];
    if(url)
    {
        THMacbookEditable *editable = (THMacbookEditable *)self.editableObject;
        ((THMacbook *)editable.simulableObject).hostAddress = textField.text;
    }
    return YES;
}

@end
