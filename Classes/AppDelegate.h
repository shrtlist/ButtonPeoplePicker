//
//  AppDelegate.h
//
//  Created by shrtlist.com
//

@interface AppDelegate : NSObject <UIApplicationDelegate> 
{
    UIWindow *window;
	UINavigationController *navController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navController;

@end