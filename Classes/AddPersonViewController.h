//
//  AddPersonViewController.h
//  Boomerang
//
//  Created by Administrator on 1/20/11.
//  Copyright 2011 throwaboomerang.com. All rights reserved.
//

@protocol AddPersonViewControllerDelegate;

@interface AddPersonViewController : UIViewController <UITextFieldDelegate> {
	
	id <AddPersonViewControllerDelegate> delegate;

	UITextField *firstNameTextField;
	UITextField *lastNameTextField;
	UITextField *emailTextField;
	
	NSString *initialText;
}

@property (nonatomic, assign) id <AddPersonViewControllerDelegate> delegate;
@property (nonatomic, retain) NSString *initialText;
@property (nonatomic, readonly) IBOutlet UITextField *firstNameTextField;
@property (nonatomic, readonly) IBOutlet UITextField *lastNameTextField;
@property (nonatomic, readonly) IBOutlet UITextField *emailTextField;

- (IBAction)cancelClick:(id)sender;
- (IBAction)addClick:(id)sender;

@end

@protocol AddPersonViewControllerDelegate
- (void)addPersonViewControllerDidFinish:(AddPersonViewController *)controller;
@end