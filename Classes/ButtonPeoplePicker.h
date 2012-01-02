/*
 * Copyright 2011 Marco Abundo
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

#import "AddPersonViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@protocol ButtonPeoplePickerDelegate;

@interface ButtonPeoplePicker : UIViewController <AddPersonViewControllerDelegate,
                                                  ABPeoplePickerNavigationControllerDelegate,
                                                  UISearchBarDelegate,
												  UITableViewDataSource,
												  UITableViewDelegate,
												  UIKeyInput>
{
	UIButton *selectedButton;
	ABAddressBookRef addressBook;
}

@property (nonatomic, weak) id <ButtonPeoplePickerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *group;

@property (nonatomic, strong) IBOutlet UILabel *deleteLabel;
@property (nonatomic, strong) IBOutlet UIView *buttonView;
@property (nonatomic, strong) IBOutlet UITableView *contactsTableView;
@property (nonatomic, strong) IBOutlet UISearchBar *searchField;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;

- (IBAction)cancelClick:(id)sender;
- (IBAction)doneClick:(id)sender;

@end

@protocol ButtonPeoplePickerDelegate
- (void)buttonPeoplePickerDidFinish:(ButtonPeoplePicker *)controller;
@end