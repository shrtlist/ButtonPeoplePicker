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

#import "AppDelegate.h"
#import "AddView.h"

@implementation AppDelegate

@synthesize window;

#pragma mark - UIApplicationDelegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    AddView *viewController = [[AddView alloc] initWithNibName:@"AddView" bundle:nil];
    
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:viewController];
    
    // Set the navigationBar title
    navController.navigationBar.topItem.title = @"ButtonPeoplePicker Demo";
    
    [window setRootViewController:navController];
    [window makeKeyAndVisible];

    return YES;
}


@end