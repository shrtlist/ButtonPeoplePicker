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

#import "AddView.h"
#import <AddressBook/AddressBook.h>

@interface AddView () // Private methods

- (void)updatePersonInfo:(NSArray *)group;

@end

@implementation AddView

#pragma mark -
#pragma mark Lifecycle methods

- (void)dealloc 
{
	[namesLabel release];
    [super dealloc];
}


#pragma mark -
#pragma mark Button actions

// Action receiver for the clicking of 'Show ButtonPeoplePicker' button
-(IBAction)showButtonPeoplePicker:(id)sender
{
	ButtonPeoplePicker *buttonPeoplePicker = [[ButtonPeoplePicker alloc] init];
    [buttonPeoplePicker setDelegate:self];
    [self presentModalViewController:buttonPeoplePicker animated:YES];
	[buttonPeoplePicker release];
}

#pragma mark -
#pragma mark Update Person info

- (void)updatePersonInfo:(NSArray *)group
{
	ABAddressBookRef addressBook = ABAddressBookCreate();
	
	NSMutableString *tempString = [NSMutableString string];
	
	for (int i = 0; i < group.count; i++) {
		
		NSDictionary *personDictionary = (NSDictionary *)[group objectAtIndex:i];
		
		ABRecordID abRecordID = (ABRecordID)[[personDictionary valueForKey:@"abRecordID"] intValue];
		
		ABRecordRef abPerson = ABAddressBookGetPersonWithRecordID(addressBook, abRecordID);

		NSString *name = (NSString *)ABRecordCopyCompositeName(abPerson);
		
		if (i < (group.count - 1))
        {
			[tempString appendString:[NSString stringWithFormat:@"%@, ", name]];
		}
		else
        {
			[tempString appendString:[NSString stringWithFormat:@"%@", name]];
		}
		
		[name release];
	}

	[namesLabel setText:tempString];
	
	CFRelease(addressBook);
}


#pragma mark -
#pragma mark ButtonPeoplePickerDelegate protocol method

- (void)buttonPeoplePickerDidFinish:(ButtonPeoplePicker *)controller
{
	[self updatePersonInfo:controller.group];
	
	// Dismiss the ButtonPeoplePicker.
	[self dismissModalViewControllerAnimated:YES];
}

@end