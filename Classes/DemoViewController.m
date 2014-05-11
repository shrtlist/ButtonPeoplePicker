/*
 * Copyright 2014 shrtlist.com
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

#import "DemoViewController.h"
#import <AddressBook/AddressBook.h>

@interface DemoViewController () // Class extension
@property (nonatomic, weak) IBOutlet UILabel *namesLabel;
@end

@implementation DemoViewController

#pragma mark - View lifecycle

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Check the segue identifier
    if ([[segue identifier] isEqualToString:@"showButtonPeoplePicker"])
    {
        UINavigationController *navController = segue.destinationViewController;
        ButtonPeoplePicker *picker = (ButtonPeoplePicker *)navController.topViewController;
        picker.delegate = self;
    }
}

#pragma mark - Update Person info

- (void)updatePersonInfo:(NSOrderedSet *)abRecordIDs
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    NSMutableArray *namesArray = [NSMutableArray arrayWithCapacity:abRecordIDs.count];
	
	for (NSNumber *number in abRecordIDs)
    {
        ABRecordID abRecordID = [number intValue];
        
        ABRecordRef abPerson = ABAddressBookGetPersonWithRecordID(addressBook, abRecordID);

		NSString *name = (__bridge_transfer NSString *)ABRecordCopyCompositeName(abPerson);
		
		[namesArray addObject:name];
	}
    
    CFRelease(addressBook);
    
    NSString *namesString = [namesArray componentsJoinedByString:@", "];

	self.namesLabel.text = namesString;
}

#pragma mark - ButtonPeoplePickerDelegate protocol conformance

- (void)buttonPeoplePickerDidFinish:(ButtonPeoplePicker *)buttonPeoplePicker
                    withABRecordIDs:(NSOrderedSet *)abRecordIDs
{
	[self updatePersonInfo:abRecordIDs];

	[buttonPeoplePicker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)buttonPeoplePickerDidCancel:(ButtonPeoplePicker *)buttonPeoplePicker
{
	[buttonPeoplePicker dismissViewControllerAnimated:YES completion:NULL];
}

@end
