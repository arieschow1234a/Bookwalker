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
#import "Notification+Parse.h"
#import "PhotoDatabaseAvailability.h"
#import "DatabaseAvailability.h"

@interface AppDelegate ()
{
    Reachability *reach;
}

//@property (nonatomic, strong) UIImage *image;
//@property (nonatomic, strong) NSURL *imageURL;
@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSManagedObjectContext *databaseContext;
@property (strong, nonatomic) NSTimer *notificationForegroundFetchTimer;
@end

// how often (in seconds) we fetch new notifications if we are in the foreground
#define FOREGROUND_NOTIFICATION_FETCH_INTERVAL (1*60)

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
    
    // Fetch Account
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self fetchFBAccount];
    }
    
    
    // Background fetch
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

    //Set up managed object context
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory
                                                     inDomains:NSUserDomainMask] firstObject];
    NSString *documentName = @"Document";
    NSURL *url = [documentsDirectory URLByAppendingPathComponent:documentName];
    self.document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [self.document openWithCompletionHandler:^(BOOL success) {
            if (success) [self documentIsReady];
            if (!success) NSLog(@"couldn’t open document at %@", url);
        }];
    } else {
        [self.document saveToURL:url forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              if (success) [self documentIsReady];
              if (!success) NSLog(@"couldn’t create document at %@", url);
          }];
    }

    // set Badge value 
    //UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    
    //[[[[tabBarController tabBar] items] objectAtIndex:2] setBadgeValue:@"1"];
    
    return YES;
}

#pragma mark - Database Context

- (void)documentIsReady
{
    if (self.document.documentState == UIDocumentStateNormal) {
        // start using document
        self.databaseContext = self.document.managedObjectContext;
        [self startNotificationFetch];
    }
}

// we do some stuff when our Photo database's context becomes available
// we kick off our foreground NSTimer so that we are fetching every once in a while in the foreground
// we post a notification to let others know the context is available

- (void)setDatabaseContext:(NSManagedObjectContext *)databaseContext
{
    _databaseContext = databaseContext;
    
    // make sure "the user" Photographer exists at all times
    //if (photoDatabaseContext) [Photographer userInManagedObjectContext:photoDatabaseContext];
    
    // every time the context changes, we'll restart our timer
    // so kill (invalidate) the current one
    // (we didn't get to this line of code in lecture, sorry!)
    
    [self.notificationForegroundFetchTimer invalidate];
    self.notificationForegroundFetchTimer = nil;
    
    if (self.databaseContext){
        NSLog(@"databasecontext available");
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Notification"];
        NSError *error;
        NSArray *matches = [self.databaseContext executeFetchRequest:request error:&error];
        for (Notification *notif in matches){
            NSLog(@"%@", notif.objectId);
           // [self.databaseContext deleteObject:notif];
            
        }
        // this timer will fire only when we are in the foreground
        self.notificationForegroundFetchTimer = [NSTimer scheduledTimerWithTimeInterval:FOREGROUND_NOTIFICATION_FETCH_INTERVAL
                                                                           target:self
                                                                               selector:@selector(startNotificationFetch:)
                                                                         userInfo:nil
                                                                          repeats:YES];
    
    
    
    
    
        // let everyone who might be interested know this context is available
        // this happens very early in the running of our application
        // it would make NO SENSE to listen to this radio station in a View Controller that was segued to, for example
        // (but that's okay because a segued-to View Controller would presumably be "prepared" by being given a context to work in)
        //NSDictionary *userInfo = self.databaseContext ? @{DatabaseAvailabilityContext : self.databaseContext} : nil;
        NSLog(@"UserInfo");
        NSDictionary *userInfo = @{DatabaseAvailabilityContext : self.databaseContext};
        [[NSNotificationCenter defaultCenter] postNotificationName:DatabaseAvailabilityNotification
                                                            object:self
                                                          userInfo:userInfo];
    
    }

}

#pragma mark - Notifcation Fetching

- (void)startNotificationFetch
{
    NSLog(@"start fetching");

    PFUser *user = [PFUser currentUser];
    if (user) {
        PFQuery *query = [PFQuery queryWithClassName:@"Notifications"];
        
        [query whereKey:@"receiverId" equalTo:user.objectId];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error){
                NSLog(@"Error %@ %@", error, [error userInfo]);
            }else{
                NSLog(@"Downloaded %lu object", (unsigned long)[objects count]);
                [self loadNotificationsFromParseArray:objects intoContext:self.databaseContext];
            }
        }];
    }
    
}

- (void)startNotificationFetch:(NSTimer *)timer
{
    [self startNotificationFetch];
}

// gets the Flickr photo dictionaries out of the url and puts them into Core Data
// this was moved here after lecture to give you an example of how to declare a method that takes a block as an argument
// and because we now do this both as part of our background session delegate handler and when background fetch happens

- (void)loadNotificationsFromParseArray:(NSArray *)results intoContext:(NSManagedObjectContext *)context
{
    if (context) {
        [context performBlock:^{
            NSLog(@"load into context");
            [Notification loadNotificationsFromParseArray:results intoManagedObjectContext:context];
            // set Badge value
            NSLog(@"Set badge value");
            NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:@"notifiBadgge"];
            if (number) {
                UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
                NSString *notifiBadge = [[NSString alloc]initWithFormat:@"%@",number];
                [[[[tabBarController tabBar] items] objectAtIndex:3] setBadgeValue:notifiBadge];
            }
        }];
    }
}

#pragma mark - Facebook

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
