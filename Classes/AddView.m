/*
 * Copyright 2012 Marco Abundo
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

@interface AddView () // Class extension
- (void)updatePersonInfo:(NSArray *)group;
@end

@implementation AddView

@synthesize namesLabel;

#pragma mark - UIStoryboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Check the segue identifier
    if ([[segue identifier] isEqualToString:@"showButtonPeoplePicker"])
    {
        [[segue destinationViewController] setDelegate:self];
    }
}

#pragma mark - Update Person info

- (void)updatePersonInfo:(NSArray *)group
{
	ABAddressBookRef addressBook = ABAddressBookCreate();

	NSMutableString *namesString = [NSMutableString string];
	
	for (int i = 0; i < group.count; i++) {
		
		NSNumber *personID = (NSNumber *)[group objectAtIndex:i];
		
		ABRecordID abRecordID = (ABRecordID)[personID intValue];
		
		ABRecordRef abPerson = ABAddressBookGetPersonWithRecordID(addressBook, abRecordID);

		NSString *name = (__bridge_transfer NSString *)ABRecordCopyCompositeName(abPerson);
		
		if (i < (group.count - 1))
        {
			[namesString appendString:[NSString stringWithFormat:@"%@, ", name]];
		}
		else
        {
			[namesString appendString:[NSString stringWithFormat:@"%@", name]];
		}
	}

	[namesLabel setText:namesString];
	
	CFRelease(addressBook);
}

#pragma mark - ButtonPeoplePickerDelegate conformance

- (void)buttonPeoplePickerDidFinish:(ButtonPeoplePicker *)controller
{
	[self updatePersonInfo:controller.group];
	
	// Dismiss the ButtonPeoplePicker.
	[self dismissModalViewControllerAnimated:YES];
}

@end