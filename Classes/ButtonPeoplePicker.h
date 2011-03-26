/*
 * Copyright 2010 Marco Abundo
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
#import "AddPersonViewController.h"
#import <AddressBook/AddressBook.h>

@protocol ButtonPeoplePickerDelegate;

@interface ButtonPeoplePicker : UIViewController <AddPersonViewControllerDelegate,
												  UITableViewDataSource,
												  UITableViewDelegate,
												  UIKeyInput>
{
	IBOutlet UILabel *deleteLabel;
	IBOutlet UIView *buttonView;
	IBOutlet UITableView *tView;
	IBOutlet UITextField *searchField;
	UIButton *selectedButton;
	
	NSArray *people;
	ABAddressBookRef addressBook;
}

@property (nonatomic, assign) id <ButtonPeoplePickerDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *filteredPeople;
@property (nonatomic, retain) NSMutableArray *group;

- (IBAction)cancelClick:(id)sender;
- (IBAction)doneClick:(id)sender;
- (IBAction)buttonSelected:(id)sender;

- (void)layoutNameButtons;
- (void)addPersonToGroup:(NSDictionary *)personDictionary;
- (void)removePersonFromGroup:(NSDictionary *)personDictionary;
- (void)displayAddPersonViewController;

@end

@protocol ButtonPeoplePickerDelegate
- (void)buttonPeoplePickerDidFinish:(ButtonPeoplePicker *)controller;
@end