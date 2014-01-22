/*
 * Copyright 2014 shrtlist.com
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

#import <AddressBookUI/AddressBookUI.h>

@protocol ButtonPeoplePickerDelegate;

@interface ButtonPeoplePicker : UIViewController <ABPeoplePickerNavigationControllerDelegate,
                                                  ABNewPersonViewControllerDelegate,
                                                  UISearchBarDelegate,
												  UITableViewDataSource,
												  UITableViewDelegate,
												  UIKeyInput,
                                                  UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<ButtonPeoplePickerDelegate> delegate;

// The Address Book to browse. All contacts returned will be from that ABAddressBook instance.
// If not set, a new ABAddressBookRef will be created the first time the property is accessed.
@property (nonatomic, readwrite) ABAddressBookRef addressBook;

// Color of tokens. Default is blueColor
@property (nonatomic, strong) UIColor *tokenColor;

// Color of selected token. Default is blackColor.
@property (nonatomic, strong) UIColor *selectedTokenColor;

@end

@protocol ButtonPeoplePickerDelegate <NSObject>

// Called after the user has pressed Done.
// The delegate is responsible for dismissing the buttonPeoplePicker.
// abRecordIDs - array of NSNumbers representing ABRecordIDs selected
- (void)buttonPeoplePickerDidFinish:(ButtonPeoplePicker *)buttonPeoplePicker
                   withABRecordIDs:(NSArray *)abRecordIDs;

// Called after the user has pressed Cancel.
// The delegate is responsible for dismissing the ButtonPeoplePicker.
- (void)buttonPeoplePickerDidCancel:(ButtonPeoplePicker *)buttonPeoplePicker;

@end
