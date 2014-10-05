//
//  THMacbookCommandProperties.m
//  TangoHapps
//
//  Created by Michael Conrads on 05/10/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THMacbookCommandProperties.h"
#import "THMacbookCommandEditable.h"
#import "THMacbookCommand.h"
@interface THMacbookCommandProperties ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *appTextfield;
@property (weak, nonatomic) IBOutlet UITextField *keyTextfield;

@end

@implementation THMacbookCommandProperties

- (void)viewDidLoad {
    [super viewDidLoad];
    THMacbookCommand *command = (THMacbookCommand *)((THMacbookCommandEditable *)self.editableObject).simulableObject;
    
    NSString *strcommand = command.command;
    
    NSArray *c = [strcommand componentsSeparatedByString:@"#-#"];
    if(c)
    {
        NSString *app = [c firstObject];
        NSString *key = [c lastObject];
        self.appTextfield.text = app;
        self.keyTextfield.text = key;
    }

    self.appTextfield.delegate = self;
    self.keyTextfield.delegate = self;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString *combined = [@[self.appTextfield.text, self.keyTextfield.text] componentsJoinedByString:@"#-#"];
    THMacbookCommand *command = (THMacbookCommand *)((THMacbookCommandEditable *)self.editableObject).simulableObject;
    
    command.command = combined;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}



@end
