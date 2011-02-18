//
//  AppDelegate.m
//
//  Created by shrtlist.com
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window;
@synthesize navController;
@synthesize addressBook;

#pragma mark -
#pragma mark UIApplicationDelegate methods

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
	addressBook = ABAddressBookCreate();
	
	[window addSubview:navController.view];
    [window makeKeyAndVisible];
}

- (void)dealloc 
{
	CFRelease(addressBook);
	
    [window release];
    [super dealloc];
}

@end