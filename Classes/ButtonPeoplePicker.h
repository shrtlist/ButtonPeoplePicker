//
//  ButtonPeoplePicker.h
//
//  Created by shrtlist.com
//

#import "ButtonPeoplePicker.h"
#import "AddPersonViewController.h"

@protocol AddPeopleViewControllerDelegate;

@interface ButtonPeoplePicker : UIViewController <AddPersonViewControllerDelegate,
													   UITableViewDataSource,
													   UITableViewDelegate,
													   UIKeyInput>
{
	id <AddPeopleViewControllerDelegate> delegate;

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
@property (nonatomic, assign) id <AddPeopleViewControllerDelegate> delegate;
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

@protocol AddPeopleViewControllerDelegate
- (void)addPeopleViewControllerDidFinish:(ButtonPeoplePicker *)controller;
@end