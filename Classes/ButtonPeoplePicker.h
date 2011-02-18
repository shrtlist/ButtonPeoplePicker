//
//  ButtonPeoplePicker.h
//
//  Created by shrtlist.com
//

#import "ButtonPeoplePicker.h"
#import "AddPersonViewController.h"

@protocol ButtonPeoplePickerDelegate;

@interface ButtonPeoplePicker : UIViewController <AddPersonViewControllerDelegate,
													   UITableViewDataSource,
													   UITableViewDelegate,
													   UIKeyInput>
{
	id <ButtonPeoplePickerDelegate> delegate;

	UILabel *namesLabel;
	IBOutlet UILabel *deleteLabel;
	UITextField *groupName;
	UIButton *selectedButton;
	IBOutlet UIView *buttonView;
	IBOutlet UITableView *tView;
	IBOutlet UITextField *searchField;
	
	NSArray *people;
	NSMutableArray *filteredPeople;	// The content filtered as a result of a search.
	NSMutableArray *group;
}

@property (nonatomic, retain) IBOutlet UILabel *namesLabel;
@property (nonatomic, retain) IBOutlet UITextField *groupName;
@property (nonatomic, assign) id <ButtonPeoplePickerDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *filteredPeople;
@property (nonatomic, retain) NSMutableArray *group;

-(IBAction)cancelClick:(id)sender;
-(IBAction)doneClick:(id)sender;
-(IBAction)buttonSelected:(id)sender;

-(void)layoutNameButtons;
-(void)addPersonToGroup:(NSDictionary *)personDictionary;
-(void)removePersonFromGroup:(NSDictionary *)personDictionary;
-(void)displayAddPersonViewController;

@end

@protocol ButtonPeoplePickerDelegate
- (void)buttonPeoplePickerDidFinish:(ButtonPeoplePicker *)controller;
@end