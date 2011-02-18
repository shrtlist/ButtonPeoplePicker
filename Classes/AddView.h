//
//  AddView.h
//
//  Created by shrtlist.com
//

#import "ButtonPeoplePicker.h"

@interface AddView : UIViewController <ButtonPeoplePickerDelegate> 
{
	NSMutableArray *group;
	
	IBOutlet UILabel *fullname;
}

@property (nonatomic, retain) NSMutableArray *group;

-(IBAction)addPeopleClick:(id)sender;

-(void)updatePersonInfo;

@end