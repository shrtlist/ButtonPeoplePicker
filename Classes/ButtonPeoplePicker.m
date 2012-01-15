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

#import "ButtonPeoplePicker.h"
#import <AddressBookUI/AddressBookUI.h>

@interface ButtonPeoplePicker () // Class extension
@property (nonatomic, weak) IBOutlet UILabel *deleteLabel;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UITableView *contactsTableView;
@property (nonatomic, weak) IBOutlet UISearchBar *searchField;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, strong) NSMutableArray *filteredPeople;
@property (nonatomic, strong) NSArray *people;

- (IBAction)cancelClick:(id)sender;
- (IBAction)doneClick:(id)sender;
- (void)layoutScrollView;
- (void)addPersonToGroup:(ABRecordID)abRecordID;
- (void)removePersonFromGroup:(ABRecordID)abRecordID;
- (void)filterContentForSearchText:(NSString*)searchText;
@end


@implementation ButtonPeoplePicker

@synthesize delegate;
@synthesize people;
// Synthesize a property named "group", but wire it to the member variable named "_group".
@synthesize group = _group;
@synthesize filteredPeople;
@synthesize deleteLabel;
@synthesize scrollView;
@synthesize contactsTableView;
@synthesize searchField;
@synthesize doneButton;

const CGFloat kPadding = 5.0;
static NSString *kSegueIdentifier = @"showAddPerson";

#pragma mark - Implement getter

- (NSArray *)group
{
    return [_group copy];
}

#pragma mark - View lifecycle methods

// Perform additional initialization after the nib file is loaded
- (void)viewDidLoad 
{
    [super viewDidLoad];

	addressBook = ABAddressBookCreate();
	
	self.people = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    _group = [NSMutableArray array];
	
	// Create a filtered list that will contain people for the search results table.
	self.filteredPeople = [NSMutableArray array];
}

- (void)viewDidUnload
{
	CFRelease(addressBook);

    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Keep the keyboard up
    [searchField becomeFirstResponder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Check the segue identifier
    if ([[segue identifier] isEqualToString:kSegueIdentifier])
    {
        // Set the destination view controller's delegate
        [[segue destinationViewController] setDelegate:self];
        
        // Set its initial text based on the searchField text
        [[segue destinationViewController] setInitialText:searchField.text];
    }
}

#pragma mark - Respond to touch and become first responder.

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

#pragma mark - Action methods

// Action receiver for the clicking of Done button
-(IBAction)doneClick:(id)sender
{
	[delegate buttonPeoplePickerDidFinish:self];
}

// Action receiver for the clicking of Cancel button
- (IBAction)cancelClick:(id)sender
{
	[_group removeAllObjects];
	[delegate buttonPeoplePickerDidFinish:self];
}

// Action receiver for the selecting of name button
- (void)buttonSelected:(id)sender {

	selectedButton = (UIButton *)sender;
	
	// Clear other button states
	for (UIView *subview in scrollView.subviews)
    {
		if ([subview isKindOfClass:[UIButton class]] && subview != selectedButton)
        {
			((UIButton *)subview).selected = NO;
		}
	}

	if (selectedButton.selected)
    {
		selectedButton.selected = NO;
		deleteLabel.hidden = YES;
	}
	else
    {
		selectedButton.selected = YES;
		deleteLabel.hidden = NO;
	}

	[self becomeFirstResponder];
}

// Action receiver for when the searchField text changed
- (void)textFieldDidChange
{
	if (searchField.text.length > 0)
    {
		[contactsTableView setHidden:NO];
		[self filterContentForSearchText:searchField.text];
		[contactsTableView reloadData];
	}
	else
    {
		[contactsTableView setHidden:YES];
	}
}

#pragma mark - UIKeyInput conformance

- (BOOL)hasText
{
	return NO;
}

- (void)insertText:(NSString *)text {}

- (void)deleteBackward
{	
	// Hide the delete label
	deleteLabel.hidden = YES;

	NSString *name = selectedButton.titleLabel.text;
	
	NSArray *personArray = (__bridge_transfer NSArray *)ABAddressBookCopyPeopleWithName(addressBook, (__bridge CFStringRef)name);
	
	ABRecordRef person = (__bridge ABRecordRef)([personArray objectAtIndex:0]);

	ABRecordID abRecordID = ABRecordGetRecordID(person);

	[self removePersonFromGroup:abRecordID];
}

#pragma mark - UITableViewDataSource conformance

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// do we have search text? if yes, are there search results? if yes, return number of results, otherwise, return 1 (add email row)
	// if there are no search results, the table is empty, so return 0
	return searchField.text.length > 0 ? MAX( 1, filteredPeople.count ) : 0 ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
   
    cell.accessoryType = UITableViewCellAccessoryNone;
		
	// If this is the last row in filteredPeople, take special action
	if (filteredPeople.count == indexPath.row)
    {
		cell.textLabel.text	= @"Add Person";
        cell.detailTextLabel.text = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else
    {
		ABRecordID abRecordID = (ABRecordID)[[filteredPeople objectAtIndex:indexPath.row] intValue];
		
		ABRecordRef abPerson = ABAddressBookGetPersonWithRecordID(addressBook, abRecordID);
		
        cell.textLabel.text = (__bridge_transfer NSString *)ABRecordCopyCompositeName(abPerson);
        cell.detailTextLabel.text = (__bridge_transfer NSString *)ABRecordCopyValue(abPerson, kABPersonOrganizationProperty);
	}
 
	return cell;
}

#pragma mark - UITableViewDelegate conformance

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView setHidden:YES];

    // Conditionally perform segue:
    // If this is the last row in filteredPeople, take special action
	if (indexPath.row == filteredPeople.count)
    {
        [self performSegueWithIdentifier:kSegueIdentifier sender:self];
	}
	else
    {
		NSNumber *personID = [filteredPeople objectAtIndex:indexPath.row];
        
        ABRecordID abRecordID = [personID intValue];
		
		[self addPersonToGroup:abRecordID];
	}

	searchField.text = nil;
}

#pragma mark - Update the filteredPeople array based on the search text.

- (void)filterContentForSearchText:(NSString*)searchText
{
	// First clear the filtered array.
	[filteredPeople removeAllObjects];

	// beginswith[cd] predicate
	NSPredicate *beginsPredicate = [NSPredicate predicateWithFormat:@"(SELF beginswith[cd] %@)", searchText];

	/*
	 Search the main list for people whose name OR organization matches searchText;
     add items that match to the filtered array.
	 */
	
	for (id record in people)
    {
        ABRecordRef person = (__bridge ABRecordRef)record;

        NSString *compositeName = (__bridge_transfer NSString *)ABRecordCopyCompositeName(person);
        NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
        NSString *organization = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonOrganizationProperty);
        
        // Match by name or organization
        if ([beginsPredicate evaluateWithObject:compositeName] ||
            [beginsPredicate evaluateWithObject:firstName] ||
            [beginsPredicate evaluateWithObject:lastName] ||
            [beginsPredicate evaluateWithObject:organization])
        {
            ABRecordID abRecordID = ABRecordGetRecordID(person);

            // Add the matching abRecordID to filteredPeople
            [filteredPeople addObject:[NSNumber numberWithInt:abRecordID]];
        }
	}
}

#pragma mark - UISearchBarDelegate conformance

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchField.text.length > 0)
    {
		[contactsTableView setHidden:NO];
		[self filterContentForSearchText:searchField.text];
		[contactsTableView reloadData];
	}
	else
    {
		[contactsTableView setHidden:YES];
	}
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
	// Create the people picker
	ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
	peoplePicker.peoplePickerDelegate = self;
	
	// Show the people picker modally
	[self presentModalViewController:peoplePicker animated:YES];
}

#pragma mark - Add and remove a person to/from the group

- (void)addPersonToGroup:(ABRecordID)abRecordID
{
    NSNumber *personID = [NSNumber numberWithInt:abRecordID];

    // Check for an existing entry for this person
    if (![_group containsObject:personID])
    {
        [_group addObject:personID];
        [self layoutScrollView];
    }
}

- (void)removePersonFromGroup:(ABRecordID)abRecordID
{
    NSNumber *personID = [NSNumber numberWithInt:abRecordID];

	[_group removeObject:personID];
	[self layoutScrollView];
}

#pragma mark - Update Person info

-(void)layoutScrollView
{
	// Remove existing buttons
	for (UIView *subview in scrollView.subviews)
    {
		if ([subview isKindOfClass:[UIButton class]])
        {
			[subview removeFromSuperview];
		}
	}
    
	CGFloat maxWidth = scrollView.frame.size.width - kPadding;
	CGFloat xPosition = kPadding;
	CGFloat yPosition = kPadding;

	for (NSNumber *personID in _group)
    {
		ABRecordID abRecordID = (ABRecordID)[personID intValue];

        // Get the person record for abRecordID
		ABRecordRef abPerson = ABAddressBookGetPersonWithRecordID(addressBook, abRecordID);

        // Copy the name associated with this person record
		NSString *name = (__bridge_transfer NSString *)ABRecordCopyCompositeName(abPerson);

		// Create the button background images
		UIImage *normalBackgroundImage = [UIImage imageNamed:@"ButtonCorners.png"];
		normalBackgroundImage = [normalBackgroundImage stretchableImageWithLeftCapWidth:3.5 
                                                                           topCapHeight:3.5];
		
		UIImage *selectedBackgroundImage = [UIImage imageNamed:@"bottom-button-bg.png"];
		selectedBackgroundImage = [selectedBackgroundImage stretchableImageWithLeftCapWidth:3.5 
                                                                               topCapHeight:3.5];

		// Create the button
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button setTitle:name forState:UIControlStateNormal];
		
		// Use the identifier as a tag for future reference
		//[button setTag:identifier];
		[button.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
		[button setBackgroundImage:normalBackgroundImage forState:UIControlStateNormal];
		[button setBackgroundImage:selectedBackgroundImage forState:UIControlStateSelected];
		[button addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];

		// Get the width and height of the name string given a font size
        CGSize nameSize = [name sizeWithFont:[UIFont systemFontOfSize:16.0]];

		if ((xPosition + nameSize.width + kPadding) > maxWidth)
        {
			// Reset horizontal position to left edge of superview's frame
			xPosition = kPadding;
			
			// Set vertical position to a new 'line'
			yPosition += nameSize.height + kPadding;
		}
		
		// Create the button's frame
		CGRect buttonFrame = CGRectMake(xPosition, yPosition, nameSize.width + (kPadding * 2), nameSize.height);
		[button setFrame:buttonFrame];
        
        // Add the button to its superview
		[scrollView addSubview:button];
		
		// Calculate xPosition for the next button in the loop
		xPosition += button.frame.size.width + kPadding;
		
		// Reposition the delete label
		CGRect labelFrame = deleteLabel.frame;
		labelFrame.origin.y = yPosition + button.frame.size.height + kPadding;
		[deleteLabel setFrame:labelFrame];
	}
    
    if (_group.count > 0)
    {
        [doneButton setEnabled:YES];
    }
    else
    {
        [doneButton setEnabled:NO];
    }

	// Set the content size so it can be scrollable
    CGFloat height = yPosition + 30.0;
	[scrollView setContentSize:CGSizeMake([scrollView bounds].size.width, height)];

	[scrollView setHidden:NO];
	[searchField becomeFirstResponder];
}

#pragma mark - AddPersonViewControllerDelegate conformance

- (void)addPersonViewControllerDidFinish:(AddPersonViewController *)controller
{
    // Copy firstName, lastName and email strings from AddPersonViewController
	NSString *firstName = [NSString stringWithString:controller.firstName];
	NSString *lastName = [NSString stringWithString:controller.lastName];
	NSString *email = [NSString stringWithString:controller.email];

    // Create a new person record
	ABRecordRef personRef = ABPersonCreate();

    // Set the first name on the new person record
	ABRecordSetValue(personRef, kABPersonFirstNameProperty, (__bridge CFTypeRef)firstName, nil);

    // If there's a last name, set it on the new person record
	if (lastName && (lastName.length > 0))
    {
		ABRecordSetValue(personRef, kABPersonLastNameProperty, (__bridge CFTypeRef)lastName, nil);
	}

    // If there's an email, set it on the new person record
	if (email && (email.length > 0))
	{
		ABMutableMultiValueRef emailProperty = ABMultiValueCreateMutable(kABPersonEmailProperty);
		ABMultiValueAddValueAndLabel(emailProperty, (__bridge CFTypeRef)email, kABHomeLabel, nil);
		ABRecordSetValue(personRef, kABPersonEmailProperty, emailProperty, nil);
		CFRelease(emailProperty);
	}
		
	// Add the new person record to the address book
	ABAddressBookAddRecord(addressBook, personRef, nil);
	
	// Save changes to the address book
	ABAddressBookSave(addressBook, nil);

    // Get the new person record ID
	ABRecordID abRecordID = ABRecordGetRecordID(personRef);

	CFRelease(personRef);
	
	[self addPersonToGroup:abRecordID];

    // We're done, dismiss the controller
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate methods

// Displays the information of a selected person
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)picker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
	[self addPersonToGroup:ABRecordGetRecordID(person)];
    
	// Dismiss the people picker
	[self dismissModalViewControllerAnimated:YES];
	
	// Dismiss the underlying search display controller
	self.searchDisplayController.active = NO;

    return NO;
}

// This should never get called since we dismiss the picker in the above method.
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{	
	return NO;
}

// Dismisses the people picker and shows the application when users tap Cancel. 
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
	// Dismiss the people picker
	[self dismissModalViewControllerAnimated:YES];
	
	// Dismiss the underlying search display controller
	self.searchDisplayController.active = NO;
}

@end