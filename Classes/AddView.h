//
//  AddView.h
//
//  Created by shrtlist.com
//

#import "ButtonPeoplePicker.h"
#import "AppDelegate.h"

@interface AddView : UIViewController <UINavigationControllerDelegate, AddPeopleViewControllerDelegate> 
{
	NSMutableArray *group;
	
	UIImage *personImage;
	NSString *personFullName;
	
	// For address book
	IBOutlet UILabel *fullname;
	
	UIImageView *personImageView;
	UIImageView *personImageBorderView;
	
	AppDelegate *appDelegate;
}

@property (nonatomic, retain) NSMutableArray *group;

-(IBAction)addPeopleClick:(id)sender;

-(void)updatePersonInfo;

@end