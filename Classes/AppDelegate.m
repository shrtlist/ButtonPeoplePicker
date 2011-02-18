//
//  AppDelegate.m
//
//  Created by shrtlist.com
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window;
@synthesize navController;

#pragma mark -
#pragma mark UIApplicationDelegate methods

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{	
	[window addSubview:navController.view];
    [window makeKeyAndVisible];
}

- (void)dealloc 
{
	[navController release];
    [window release];
    [super dealloc];
}

@end