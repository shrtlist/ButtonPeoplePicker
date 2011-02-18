//
//  AddView.m
//  Boomerang
//
//  Created by Keegan Flanigan on 5/13/09.
//  Copyright 2009 MirageBox. All rights reserved.
//

#import "AddView.h"

@implementation AddView

@synthesize group;

#pragma mark -
#pragma mark Lifecycle methods

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
	[super initWithNibName:nibName bundle:nibBundle];
	
	appDelegate = [[UIApplication sharedApplication] delegate];
	
	personFullName = nil;
	personImage = nil;
	
	return self;
}

- (void)viewDidLoad 
{
	[super viewDidLoad];
	
	self.title = @"Group Expense";
	fullname.text = @"Add people...";

	CGRect personPortrait = { 8.0f, 8.0f, 53.0f, 53.0f };
	
	personImageView = [[UIImageView alloc] init];
	personImageView.frame = personPortrait;
	[self.view addSubview:personImageView];
	
	personImageBorderView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"person-photo-cover.png"]];
	personImageBorderView.frame = personPortrait;
	[self.view addSubview:personImageBorderView];
}

- (void)dealloc 
{
	[personImageView release];
	[personImageBorderView release];
	
	if(personFullName != nil)
	{
		[personFullName release];
	}
	
	if(personImage != nil)
	{
		[personImage release];
	}

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
		
		if (abPerson != nil && ABPersonHasImageData(abPerson))
		{
			NSData *personImgData = (NSData *)ABPersonCopyImageData(abPerson);
			personImageView.image = [UIImage imageWithData:personImgData];
			[personImgData release];
		}
		else
		{
			personImageView.image = [UIImage imageNamed: @"icon-default-person.png"];
		}

		NSString *name = (NSString *)ABRecordCopyCompositeName(abPerson);
		
		if (i < (count - 1)) {
			[tempString appendString:[NSString stringWithFormat:@"%@, ", name]];
		}
		else if (count > 2) {
			[tempString appendString:[NSString stringWithFormat:@"and %i others", count]];
		}
		else {
			[tempString appendString:[NSString stringWithFormat:@"%@", name]];
		}
		
		[name release];
	}
	
	fullname.text = tempString;
}


#pragma mark -
#pragma mark AddPeopleViewControllerDelegate protocol method

- (void)addPeopleViewControllerDidFinish:(ButtonPeoplePicker *)controller {
    
	self.group = controller.group;
	
	if (controller.groupName.text.length > 0) {
		fullname.text = controller.groupName.text;
	}
	else {
		[self updatePersonInfo];
	}
	
	// Dismiss the ButtonPeoplePicker.
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

@end