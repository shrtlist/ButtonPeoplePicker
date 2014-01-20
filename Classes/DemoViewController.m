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
{
    ABAddressBookRef _addressBook;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Check the segue identifier
    if ([[segue identifier] isEqualToString:@"showButtonPeoplePicker"])
    {
        [[segue destinationViewController] setAddressBook:_addressBook];
        [[segue destinationViewController] setDelegate:self];
    }
}

#pragma mark - Memory management

- (void)dealloc
{
    CFRelease(_addressBook);
}

#pragma mark - Update Person info

- (void)updatePersonInfo:(NSArray *)abPersonRefs
{
	NSMutableString *namesString = [NSMutableString string];
	
	for (NSUInteger i = 0; i < abPersonRefs.count; i++) {
		
		ABRecordRef abPerson = (__bridge ABRecordRef)[abPersonRefs objectAtIndex:i];

		NSString *name = (__bridge_transfer NSString *)ABRecordCopyCompositeName(abPerson);
		
		if (i < (abPersonRefs.count - 1))
        {
			[namesString appendString:[NSString stringWithFormat:@"%@, ", name]];
		}
		else
        {
			[namesString appendString:[NSString stringWithFormat:@"%@", name]];
		}
	}

	[self.namesLabel setText:namesString];
}

#pragma mark - ButtonPeoplePickerDelegate protocol conformance

- (void)buttonPeoplePickerDidFinish:(ButtonPeoplePicker *)buttonPeoplePicker
                   withABPersonRefs:(NSArray *)abPersonRefs
{
	[self updatePersonInfo:abPersonRefs];

	[buttonPeoplePicker dismissModalViewControllerAnimated:YES];
}

- (void)buttonPeoplePickerDidCancel:(ButtonPeoplePicker *)buttonPeoplePicker
{
	[buttonPeoplePicker dismissModalViewControllerAnimated:YES];
}

@end
