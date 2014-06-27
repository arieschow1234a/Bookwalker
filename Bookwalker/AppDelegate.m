//
//  AppDelegate.m
//  Bookwalker
//
//  Created by Aries on 5/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "Reachability.h"

@interface AppDelegate ()
{
    Reachability *reach;
}
@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupAppearance];
    
    [Parse setApplicationId:@"3USHvE8uSRF3ekzCCyslwSUtkeSjl2BFbgRwtxpW"
                  clientKey:@"s1OW5azdCV69gD999VJBJxLoulJKdQs7yIuq3KAk"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [PFFacebookUtils initializeFacebook];
    
    // Allocate a reachability object
    reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Here we set up a NSNotification observer. The Reachability that caused the notification
    // is passed in the object parameter
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    [reach startNotifier];
    
    // set Badge value 
    //UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    
    //[[[[tabBarController tabBar] items] objectAtIndex:2] setBadgeValue:@"1"];
    
    return YES;
}

// Facebook

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
      // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}






// Reachability
-(void) reachabilityChanged:(NSNotification *)notice
{
    // called after network status changes
    NetworkStatus internetStatus = [reach currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            _isInternetAvailable = NO;
            NSLog(@"The internet is down.");
            break;
        }
        case ReachableViaWiFi:
        {
            _isInternetAvailable = YES;
            NSLog(@"The internet is working via WIFI.");
            break;
        }
        case ReachableViaWWAN:
        {
            _isInternetAvailable = YES;
            NSLog(@"The internet is working via WWAN.");
            break;
        }
    }
}



// Set the navigation bar
- (void)setupAppearance
{
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    navigationBarAppearance.barTintColor = [UIColor colorWithRed:77.0/255.0 green:164.0/255.0 blue:191.0/255.0 alpha:1.0f];
    navigationBarAppearance.tintColor = [UIColor whiteColor];
    navigationBarAppearance.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[PFFacebookUtils session] close];

}


@end
