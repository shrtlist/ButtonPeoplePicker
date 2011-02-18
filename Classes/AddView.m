//
//  AddView.m
//
//  Created by shrtlist.com
//

#import "AddView.h"
#import <AddressBook/AddressBook.h>

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

-(void)updatePersonInfo {
	
	int count = self.group.count;
	
	NSMutableString *tempString = [NSMutableString string];
	
	for (int i = 0; i < count; i++) {
		
		NSDictionary *personDictionary = (NSDictionary *)[self.group objectAtIndex:i];
		
		ABRecordRef abPerson = (ABRecordRef)[personDictionary valueForKey:@"person"];

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