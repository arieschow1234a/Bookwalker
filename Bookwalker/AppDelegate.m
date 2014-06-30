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

//@property (nonatomic, strong) UIImage *image;
//@property (nonatomic, strong) NSURL *imageURL;

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
    
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self fetchFBAccount];
    }
    
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

#pragma mark - Facebook & Image
- (void)fetchFBAccount
{
    PFUser *user = [PFUser currentUser];
    
    // Send request to Facebook
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary *result, NSError *error) {
        // handle response
        if (!error) {
            // Parse the data received
            NSDictionary *userData = (NSDictionary *)result;
            
            NSString *facebookID = userData[@"id"];
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
           
            // Do not update the pic everytime
           // self.imageURL = [NSURL URLWithString:[pictureURL absoluteString]];
            
            NSDictionary *originalData = user[@"profile"];
            NSMutableDictionary *userProfile;
            
            //Prepare origianl profile
            if (user[@"profile"]) {
                userProfile = [[NSMutableDictionary alloc]initWithDictionary:originalData];
                if (![userData isEqualToDictionary:originalData]) {
                    //Check which one is different
                    if (![userData[@"name"] isEqualToString:originalData[@"name"]]) {
                        userProfile[@"name"] = userData[@"name"];
                    }
                    if (![userData[@"email"] isEqualToString:originalData[@"email"]]) {
                        userProfile[@"email"] = userData[@"email"];
                    }
                }
                
                
            }else{
                userProfile = [[NSMutableDictionary alloc]initWithCapacity:8];
                if (facebookID) {
                    userProfile[@"facebookId"] = facebookID;
                }
                
                if (userData[@"name"]) {
                    userProfile[@"name"] = userData[@"name"];
                }
                
                if (userData[@"email"]) {
                    userProfile[@"email"] = userData[@"email"];
                }
                
                if (userData[@"gender"]) {
                    userProfile[@"gender"] = userData[@"gender"];
                }
                
                if (userData[@"location"][@"name"]) {
                    userProfile[@"location"] = userData[@"location"][@"name"];
                }
                
                if ([pictureURL absoluteString]) {
                    userProfile[@"pictureURL"] = [pictureURL absoluteString];
                }
                
                if (userData[@"birthday"]) {
                    userProfile[@"birthday"] = userData[@"birthday"];
                }
                
                if (userData[@"relationship_status"]) {
                    userProfile[@"relationship"] = userData[@"relationship_status"];
                }
            }
            [user setObject:userProfile forKey:@"profile"];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"Saved ac");
                }
            }];
            
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                    isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
        }else {
            NSLog(@"Some other error: %@", error);
        }
    }];
    
}



@end
