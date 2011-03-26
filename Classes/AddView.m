/*
 * Copyright 2010 Marco Abundo
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

- (void)updatePersonInfo;

@end

@implementation AddView

@synthesize group;

#pragma mark -
#pragma mark Lifecycle methods

- (void)viewDidLoad 
{
	[super viewDidLoad];
	
	self.title = @"ButtonPeoplePicker Demo";
	fullname.text = @"Add people...";
}

- (void)dealloc 
{
	[fullname release];
    [group release];

    [super dealloc];
}


#pragma mark -
#pragma mark Button actions

// Action receiver for the clicking of 'plus' button
-(IBAction)addPeopleClick:(id)sender
{
	ButtonPeoplePicker *addPeopleViewController = [[ButtonPeoplePicker alloc] init];
	
	addPeopleViewController.delegate = self;
	
	addPeopleViewController.group = self.group;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:addPeopleViewController];
	
	[addPeopleViewController release];
	
	[self presentModalViewController:navController animated:YES];
	
	[navController release];
}

#pragma mark -
#pragma mark Update Person info

- (void)updatePersonInfo
{
	ABAddressBookRef addressBook = ABAddressBookCreate();

	int count = self.group.count;
	
	NSMutableString *tempString = [NSMutableString string];
	
	for (int i = 0; i < count; i++) {
		
		NSDictionary *personDictionary = (NSDictionary *)[self.group objectAtIndex:i];
		
		ABRecordID abRecordID = (ABRecordID)[[personDictionary valueForKey:@"abRecordID"] intValue];
		
		ABRecordRef abPerson = ABAddressBookGetPersonWithRecordID(addressBook, abRecordID);

		NSString *name = (NSString *)ABRecordCopyCompositeName(abPerson);
		
		if (i < (count - 1)) {
			[tempString appendString:[NSString stringWithFormat:@"%@, ", name]];
		}
		else {
			[tempString appendString:[NSString stringWithFormat:@"%@", name]];
		}
		
		[name release];
	}
	
	fullname.text = tempString;
	
	CFRelease(addressBook);
}


#pragma mark -
#pragma mark ButtonPeoplePickerDelegate protocol method

- (void)buttonPeoplePickerDidFinish:(ButtonPeoplePicker *)controller {
    
	self.group = controller.group;
	
	[self updatePersonInfo];
	
	// Dismiss the ButtonPeoplePicker.
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

@end