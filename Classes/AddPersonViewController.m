//
//  AddPersonViewController.m
//  Boomerang
//
//  Created by Administrator on 1/20/11.
//  Copyright 2011 throwaboomerang.com. All rights reserved.
//

#import "AddPersonViewController.h"

@implementation AddPersonViewController

@synthesize delegate, initialText, firstNameTextField, lastNameTextField, emailTextField;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	firstNameTextField.text = initialText;
	
	[firstNameTextField becomeFirstResponder];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Button actions

// Action receiver for the clicking of Cancel button
-(IBAction)cancelClick:(id)sender
{	
	[self dismissModalViewControllerAnimated:YES];
}

// Action receiver for the clicking of Add button
-(IBAction)addClick:(id)sender
{
	[self.delegate addPersonViewControllerDidFinish:self];
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

// Allow user to navigate textfields using the Next key on the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	if (textField == self.firstNameTextField) {
		[self.lastNameTextField becomeFirstResponder];
	}
	else if (textField == self.lastNameTextField) {
		[self.emailTextField becomeFirstResponder];
	}

	return YES;
}

@end