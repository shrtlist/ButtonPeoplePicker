/*
 * Copyright 2013 shrtlist.com
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

@interface ButtonPeoplePicker () // Class extension
@property (nonatomic, weak) IBOutlet UILabel *deleteLabel;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UITableView *contactsTableView;
@property (nonatomic, weak) IBOutlet UISearchBar *searchField;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneButton;
@end

@implementation ButtonPeoplePicker
{
	ABAddressBookRef addressBook;

    NSMutableArray *filteredPeople;
    NSMutableOrderedSet *group;
    NSArray *people;
    
	UIButton *selectedButton;
}

static CGFloat const kPadding = 5.0;

#pragma mark - View lifecycle methods

// Perform additional initialization after the nib file is loaded
- (void)viewDidLoad 
{
    [super viewDidLoad];

	addressBook = ABAddressBookCreate();
	
	people = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    group = [NSMutableOrderedSet orderedSet];
	
	// Create a filtered list that will contain people for the search results table.
	filteredPeople = [NSMutableArray array];
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
    [self.searchField becomeFirstResponder];
}

#pragma mark - Respond to touch and become first responder.

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

#pragma mark - Memory management

- (void)dealloc
{
    self.delegate = nil;

    // Unregister for notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Register for keyboard notifications

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
//    CGRect aRect = self.view.frame;
//    aRect.size.height -= kbSize.height;
//    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
//        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-kbSize.height);
//        [self.scrollView setContentOffset:scrollPoint animated:YES];
//    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - Action methods

// Action receiver for the clicking of Done button
-(IBAction)doneClick:(id)sender
{
    NSArray *tmpArray = [group array];
	[self.delegate buttonPeoplePickerDidFinish:tmpArray];
}

// Action receiver for the clicking of Cancel button
- (IBAction)cancelClick:(id)sender
{
	[group removeAllObjects];
	[self.delegate buttonPeoplePickerDidCancel];
}

// Action receiver for the selecting of name button
- (void)buttonSelected:(id)sender
{
	selectedButton = (UIButton *)sender;
	
	// Clear other button states
	for (UIView *subview in self.scrollView.subviews)
    {
		if ([subview isKindOfClass:[UIButton class]] && subview != selectedButton)
        {
			((UIButton *)subview).selected = NO;
		}
	}

	if (selectedButton.selected)
    {
		selectedButton.selected = NO;
		self.deleteLabel.hidden = YES;
	}
	else
    {
		selectedButton.selected = YES;
		self.deleteLabel.hidden = NO;
	}

	[self becomeFirstResponder];
}

// Action receiver for when the searchField text changed
- (void)textFieldDidChange
{
	if (self.searchField.text.length > 0)
    {
		[self.contactsTableView setHidden:NO];
		[self filterContentForSearchText:self.searchField.text];
		[self.contactsTableView reloadData];
	}
	else
    {
		[self.contactsTableView setHidden:YES];
	}
}

#pragma mark - UIKeyInput protocol conformance

- (BOOL)hasText
{
	return NO;
}

- (void)insertText:(NSString *)text {}

- (void)deleteBackward
{	
	// Hide the delete label
	self.deleteLabel.hidden = YES;

	NSString *name = selectedButton.titleLabel.text;
	
	NSArray *personArray = (__bridge_transfer NSArray *)ABAddressBookCopyPeopleWithName(addressBook, (__bridge CFStringRef)name);
	
	ABRecordRef person = (__bridge ABRecordRef)([personArray objectAtIndex:0]);

	ABRecordID abRecordID = ABRecordGetRecordID(person);

	[self removePersonFromGroup:abRecordID];
}

#pragma mark - UITableViewDataSource protocol conformance

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// do we have search text? if yes, are there search results? if yes, return number of results, otherwise, return 1 (add email row)
	// if there are no search results, the table is empty, so return 0
	return self.searchField.text.length > 0 ? MAX( 1, filteredPeople.count ) : 0 ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
   
    cell.accessoryType = UITableViewCellAccessoryNone;
		
	// If this is the last row in filteredPeople, take special action
	if (filteredPeople.count == indexPath.row)
    {
		cell.textLabel.text	= @"Add new contact";
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

#pragma mark - UITableViewDelegate protocol conformance

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView setHidden:YES];

    // If this is the last row in filteredPeople, take special action
	if (indexPath.row == filteredPeople.count)
    {
        ABNewPersonViewController *newPersonViewController = [[ABNewPersonViewController alloc] init];
        newPersonViewController.newPersonViewDelegate = self;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:newPersonViewController];
        
        [self presentModalViewController:navController animated:YES];
	}
	else
    {
		NSNumber *personID = [filteredPeople objectAtIndex:indexPath.row];
        
        ABRecordID abRecordID = [personID intValue];
		
		[self addPersonToGroup:abRecordID];
	}

	self.searchField.text = nil;
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

#pragma mark - UISearchBarDelegate protocol conformance

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (self.searchField.text.length > 0)
    {
		[self.contactsTableView setHidden:NO];
		[self filterContentForSearchText:self.searchField.text];
		[self.contactsTableView reloadData];
	}
	else
    {
		[self.contactsTableView setHidden:YES];
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

    [group addObject:personID];
    [self layoutScrollView];
}

- (void)removePersonFromGroup:(ABRecordID)abRecordID
{
    NSNumber *personID = [NSNumber numberWithInt:abRecordID];

	[group removeObject:personID];
	[self layoutScrollView];
}

#pragma mark - Update Person info

-(void)layoutScrollView
{
	// Remove existing buttons
	for (UIView *subview in self.scrollView.subviews)
    {
		if ([subview isKindOfClass:[UIButton class]])
        {
			[subview removeFromSuperview];
		}
	}
    
	CGFloat maxWidth = self.scrollView.frame.size.width - kPadding;
	CGFloat xPosition = kPadding;
	CGFloat yPosition = kPadding;

	for (NSNumber *personID in group)
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
		[self.scrollView addSubview:button];
		
		// Calculate xPosition for the next button in the loop
		xPosition += button.frame.size.width + kPadding;
		
		// Reposition the delete label
		CGRect labelFrame = self.deleteLabel.frame;
		labelFrame.origin.y = yPosition + button.frame.size.height + kPadding;
		[self.deleteLabel setFrame:labelFrame];
	}
    
    if (group.count > 0)
    {
        [self.doneButton setEnabled:YES];
    }
    else
    {
        [self.doneButton setEnabled:NO];
    }

	// Set the content size so it can be scrollable
    CGFloat height = yPosition + 30.0;
	[self.scrollView setContentSize:CGSizeMake([self.scrollView bounds].size.width, height)];

	[self.scrollView setHidden:NO];
	[self.searchField becomeFirstResponder];
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate protocol conformance

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

#pragma mark - ABNewPersonViewControllerDelegate protocol conformance

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person
{
    if (person != NULL)
    {
        ABRecordID abRecordID = ABRecordGetRecordID(person);
        
        [self addPersonToGroup:abRecordID];
    }

	[self dismissModalViewControllerAnimated:YES];
}

@end
