//
//  AppDelegate.h
//
//  Created by shrtlist.com
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>

@interface AppDelegate : NSObject <UIApplicationDelegate> 
{
    UIWindow *window;
	UINavigationController *navController;
	
	ABAddressBookRef addressBook;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navController;
@property (nonatomic, readonly) ABAddressBookRef addressBook;

@end