//
//  ButtonPeoplePicker.m
//
//  Created by shrtlist.com
//

#import "ButtonPeoplePicker.h"
#import "AddPersonViewController.h"
#import "AppDelegate.h"

@implementation ButtonPeoplePicker

@synthesize delegate, group, namesLabel;
@synthesize filteredPeople;

#pragma mark -
#pragma mark UIViewController lifecycle methods

// Returns a newly initialized view controller with the nib file in the specified bundle.
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
	[super initWithNibName:nibName bundle:nibBundle];
	
	self.navigationItem.title = @"Add people";
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelClick:)];
	
	self.navigationItem.leftBarButtonItem = cancelButton;
	
	[cancelButton release];
	
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneClick:)];
	
	self.navigationItem.rightBarButtonItem = doneButton;
	
	[doneButton release];
	
	return self;
}

// Perform additional initialization after the nib file is loaded
- (void)viewDidLoad 
{
    [super viewDidLoad];

	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
	people = (NSArray *)ABAddressBookCopyArrayOfAllPeople(appDelegate.addressBook);
	
	// Create a filtered list that will contain people for the search results table.
	self.filteredPeople = [NSMutableArray array];
	
	// Add a "textFieldDidChange" notification method to the text field control.
	[searchField addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
	
	[self layoutNameButtons];
}

- (void)dealloc 
{	
    [super dealloc];

	[namesLabel release];
	[deleteLabel release];
	[tView release];
	[searchField release];
	[people release];
	[filteredPeople release];
}

#pragma mark -
#pragma mark Respond to touch and become first responder.

- (BOOL)canBecomeFirstResponder {
	return YES;
}

#pragma mark -
#pragma mark Button actions

// Action receiver for the clicking of Cancel button
-(IBAction)cancelClick:(id)sender
{
	[self.group removeAllObjects];

	[self.delegate buttonPeoplePickerDidFinish:self];
}

// Action receiver for the clicking of Done button
-(IBAction)doneClick:(id)sender
{
	[self.delegate buttonPeoplePickerDidFinish:self];
}

// Action receiver for the selecting of name button
-(IBAction)buttonSelected:(id)sender {

	selectedButton = (UIButton *)sender;
	
	// Clear other button states
	for (UIView *subview in buttonView.subviews) {
		if ([subview isKindOfClass:[UIButton class]] && subview != selectedButton) {
			((UIButton *)subview).selected = NO;
		}
	}

	if (selectedButton.selected) {
		selectedButton.selected = NO;
		deleteLabel.hidden = YES;
	}
	else {
		selectedButton.selected = YES;
		deleteLabel.hidden = NO;
	}

	[self becomeFirstResponder];
}

#pragma mark -
#pragma mark UIKeyInput protocol methods

- (BOOL)hasText {
	return NO;
}

- (void)insertText:(NSString *)text {}

- (void)deleteBackward {
	
	// Hide the delete label
	deleteLabel.hidden = YES;

	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

	NSString *name = selectedButton.titleLabel.text;
	NSInteger identifier = selectedButton.tag;
	
	NSArray *personArray = (NSArray *)ABAddressBookCopyPeopleWithName(appDelegate.addressBook, (CFStringRef)name);
	
	ABRecordRef person = [personArray lastObject];
	
	NSDictionary *personDictionary = [NSDictionary dictionaryWithObjectsAndKeys:(id)person, @"person", [NSNumber numberWithInt:identifier], @"valueIdentifier", nil];

	[self removePersonFromGroup:personDictionary];
	
	[personArray release];
}

#pragma mark -
#pragma mark UITableViewDataSource protocol methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// do we have search text? if yes, are there search results? if yes, return number of results, otherwise, return 1 (add email row)
	// if there are no search results, the table is empty, so return 0
	return searchField.text.length > 0 ? MAX( 1, self.filteredPeople.count ) : 0 ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *kCellID = @"cellID";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellID] autorelease];
	}
		
	// If this is the last row in filteredPeople, take special action
	if (self.filteredPeople.count == indexPath.row) {
		// Take special action
		cell.textLabel.text	= @"Add Email";
		cell.detailTextLabel.text = searchField.text;
	}
	else {
		NSDictionary *personDictionary = [self.filteredPeople objectAtIndex:indexPath.row];
		
		ABRecordRef abPerson = [personDictionary valueForKey:@"person"];
		
		ABMultiValueIdentifier identifier = [[personDictionary valueForKey:@"valueIdentifier"] intValue];
		
		{
			NSString *string = (NSString *)ABRecordCopyCompositeName(abPerson);
			cell.textLabel.text = string;
			[string release];
		}
		
		ABMultiValueRef emailProperty = ABRecordCopyValue(abPerson, kABPersonEmailProperty);
		
		if (emailProperty) {
			CFIndex index = ABMultiValueGetIndexForIdentifier(emailProperty, identifier);
			
			if (index != -1) {
				NSString *email = (NSString *)ABMultiValueCopyValueAtIndex(emailProperty, index);
				
				cell.detailTextLabel.text = email;
				
				[email release];
			}
			else {
				cell.detailTextLabel.text = nil;
			}
		}
		
		if (emailProperty) CFRelease(emailProperty);
	}
	
	return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate protocol method

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView setHidden:YES];

	// Handle the special case
	if (indexPath.row == self.filteredPeople.count) {
		[self displayAddPersonViewController];
	}
	else {
		NSDictionary *personDictionary = [self.filteredPeople objectAtIndex:indexPath.row];
		
		[self addPersonToGroup:personDictionary];
	}

	searchField.text = nil;
}


#pragma mark -
#pragma mark Update the filteredPeople array based on the search text.

- (void)filterContentForSearchText:(NSString*)searchText {

	// First clear the filtered array.
	[self.filteredPeople removeAllObjects];

	// beginswith[cd] predicate
	NSPredicate *beginsPredicate = [NSPredicate predicateWithFormat:@"(SELF beginswith[cd] %@)", searchText];

	/*
	 Search the main list for people whose firstname OR lastname OR organization matches searchText; add items that match to the filtered array.
	 */
	
	for (id person in people) {
		
		// Access the person's email addresses (an ABMultiValueRef)
		ABMultiValueRef emailsProperty = ABRecordCopyValue(person, kABPersonEmailProperty);
		
		if (emailsProperty) {
			
			// Iterate through the email address multivalue
			for (CFIndex index = 0; index < ABMultiValueGetCount(emailsProperty); index++) {
					
				NSString *firstName = (NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
				NSString *lastName = (NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
				NSString *organization = (NSString *)ABRecordCopyValue(person, kABPersonOrganizationProperty);
				NSString *emailString = (NSString *)ABMultiValueCopyValueAtIndex(emailsProperty, index);
				
				// Match by firstName, lastName, organization or email address
				if ([beginsPredicate evaluateWithObject:firstName] ||
					[beginsPredicate evaluateWithObject:lastName] ||
					[beginsPredicate evaluateWithObject:organization] ||
					[beginsPredicate evaluateWithObject:emailString]) {

					// Get the address identifier for this address
					ABMultiValueIdentifier identifier = ABMultiValueGetIdentifierAtIndex(emailsProperty, index);
					
					NSDictionary *personDictionary = [NSDictionary dictionaryWithObjectsAndKeys:(id)person, @"person", [NSNumber numberWithInt:identifier], @"valueIdentifier", nil];

					// Add each personDictionary to filteredPeople
					[self.filteredPeople addObject:personDictionary];
				}

				[firstName release];
				[lastName release];
				[organization release];
				[emailString release];
			 }
			
			 CFRelease(emailsProperty);
		}
	}
}

#pragma mark -
#pragma mark textFieldDidChange notification method to the searchField control.

- (void)textFieldDidChange {
	
	if (searchField.text.length > 0) {
		[tView setHidden:NO];
		
		[self filterContentForSearchText:searchField.text];
		
		[tView reloadData];
	}
	else {
		[tView setHidden:YES];
	}
}

#pragma mark -
#pragma mark Add and remove a person to/from the group

- (void)addPersonToGroup:(NSDictionary *)personDictionary {
	
	if (self.group == nil) {
		self.group = [NSMutableArray array];
	}
	
	[self.group addObject:personDictionary];
	
	[self layoutNameButtons];
}

- (void)removePersonFromGroup:(NSDictionary *)personDictionary {
	
	[self.group removeObject:personDictionary];
	
	[self layoutNameButtons];
}

#pragma mark -
#pragma mark Update Person info

-(void)layoutNameButtons {

	// Remove existing buttons
	for (UIView *subview in buttonView.subviews) {
		if ([subview isKindOfClass:[UIButton class]]) {
			[subview removeFromSuperview];
		}
	}
	
	CGFloat PADDING = 5.0;
	
	CGFloat maxWidth = buttonView.frame.size.width - PADDING;
	
	CGFloat xPosition = PADDING;
	CGFloat yPosition = PADDING;

	for (int i = 0; i < self.group.count; i++) {
		
		NSDictionary *personDictionary = (NSDictionary *)[self.group objectAtIndex:i];

		ABRecordRef abPerson = (ABRecordRef)[personDictionary valueForKey:@"person"];
		NSString *name = (NSString *)ABRecordCopyCompositeName(abPerson);
		
		ABMultiValueIdentifier identifier = [[personDictionary valueForKey:@"valueIdentifier"] intValue];
		
		// Create the button image
		UIImage *image = [UIImage imageNamed:@"ButtonCorners.png"];
		image = [image stretchableImageWithLeftCapWidth:3.5 topCapHeight:3.5];
		
		UIImage *image2 = [UIImage imageNamed:@"bottom-button-bg.png"];
		image2 = [image2 stretchableImageWithLeftCapWidth:3.5 topCapHeight:3.5];

		// Create the button
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button setTitle:name forState:UIControlStateNormal];
		
		// Use the identifier as a tag for future reference
		[button setTag:identifier];
		[button.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
		[button setBackgroundImage:image forState:UIControlStateNormal];
		[button setBackgroundImage:image2 forState:UIControlStateSelected];
		[button addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];

		// Get the width and height of the name string given a font size
		CGSize nameSize = [name sizeWithFont:[UIFont systemFontOfSize:16.0]];

		if ((xPosition + nameSize.width + PADDING) > maxWidth) {
			// Reset horizontal position to left edge of superview's frame
			xPosition = PADDING;
			
			// Set vertical position to a new 'line'
			yPosition += nameSize.height + PADDING;
		}
		
		// Create the button's frame
		CGRect buttonFrame = CGRectMake(xPosition, yPosition, nameSize.width + (PADDING * 2), nameSize.height);
		
		[button setFrame:buttonFrame];

		[buttonView addSubview:button];
		
		// Calculate xPosition for the next button in the loop
		xPosition += button.frame.size.width + PADDING;
		
		// Calculate the y origin for the delete label
		CGRect labelFrame = deleteLabel.frame;
		labelFrame.origin.y = yPosition + button.frame.size.height + PADDING;
		[deleteLabel setFrame:labelFrame];
		
		[name release];
	}
	
	[buttonView setHidden:NO];
	
	[searchField becomeFirstResponder];
}

#pragma mark -
#pragma mark display the AddPersonViewController modally

-(void)displayAddPersonViewController {
	
	AddPersonViewController *apvc = [[AddPersonViewController alloc] init];
	apvc.initialText = searchField.text;
	apvc.delegate = self;
	
	[self.navigationController presentModalViewController:apvc animated:YES];

	[apvc release];
}

#pragma mark -
#pragma mark AddPersonViewControllerDelegate method

- (void)addPersonViewControllerDidFinish:(AddPersonViewController *)controller {
	
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
	NSString *firstName = controller.firstNameTextField.text;
	NSString *lastName = controller.lastNameTextField.text;
	NSString *email = controller.emailTextField.text;
	
	ABRecordRef personRef = ABPersonCreate();

	ABRecordSetValue(personRef, kABPersonFirstNameProperty, firstName, nil);
	
	if (lastName) {
		ABRecordSetValue(personRef, kABPersonLastNameProperty, lastName, nil);
	}
	
	ABMutableMultiValueRef emailProperty = ABMultiValueCreateMutable(kABPersonEmailProperty);
	
	ABMultiValueAddValueAndLabel(emailProperty, email, kABHomeLabel, nil);
	
	ABRecordSetValue(personRef, kABPersonEmailProperty, emailProperty, nil);
	
	CFRelease(emailProperty);
		
	// Add the person to the address book
	ABAddressBookAddRecord(appDelegate.addressBook, personRef, nil);
	
	// Save changes to the address book
	ABAddressBookSave(appDelegate.addressBook, nil);
	
	NSDictionary *personDictionary = [NSDictionary dictionaryWithObjectsAndKeys:(id)personRef, @"person", [NSNumber numberWithInt:0], @"valueIdentifier", nil];
	
	CFRelease(personRef);
	
	[self addPersonToGroup:personDictionary];
	
	[self dismissModalViewControllerAnimated:YES];
}

@end