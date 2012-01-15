/*
 * Copyright 2012 Marco Abundo
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

@protocol AddPersonViewControllerDelegate;

@interface AddPersonViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, weak) id <AddPersonViewControllerDelegate> delegate;
@property (nonatomic, strong, readonly) NSString *firstName;
@property (nonatomic, strong, readonly) NSString *lastName;
@property (nonatomic, strong, readonly) NSString *email;
@property (nonatomic, copy) NSString *initialText;

@end

@protocol AddPersonViewControllerDelegate
- (void)addPersonViewControllerDidFinish:(AddPersonViewController *)controller;
@end