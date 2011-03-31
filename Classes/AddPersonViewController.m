/*
 * Copyright 2011 Marco Abundo
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "AddPersonViewController.h"

@implementation AddPersonViewController

@synthesize delegate, initialText, firstName, lastName, email;

#pragma mark -
#pragma mark Lifecycle methods

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[firstNameTextField setText:initialText];
	[firstNameTextField becomeFirstResponder];
}

- (void)dealloc
{
	delegate = nil;
	[firstNameTextField release];
	[lastNameTextField release];
	[emailTextField release];

    [super dealloc];
}

#pragma mark -
#pragma mark Button actions

// Action receiver for the clicking of Add button
- (IBAction)addClick:(id)sender
{
	firstName = firstNameTextField.text;
	lastName = lastNameTextField.text;
	email = emailTextField.text;

	[delegate addPersonViewControllerDidFinish:self];
}

// Action receiver for the clicking of Cancel button
- (IBAction)cancelClick:(id)sender
{	
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

// Allow user to navigate textfields using the Next key on the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{	
	if (textField == firstNameTextField)
    {
		[lastNameTextField becomeFirstResponder];
	}
	else if (textField == lastNameTextField)
    {
		[emailTextField becomeFirstResponder];
	}

	return YES;
}

@end