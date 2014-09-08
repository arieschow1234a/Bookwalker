//
//  LoginViewController.m
//  Ribbit
//
//  Created by Aries on 5/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import "AllBooksTVC.h"
#import "RequestTableViewController.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *imageURL;
@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // hide the nav bar
    [self.navigationController.navigationBar setHidden:YES];

    //if ([UIScreen mainScreen].bounds.size.height == 568 ) {
    //    self.backgroundImageView.image = [UIImage imageNamed:@"loginBackground-568h"];
   // }
    
    // Check if user is cached and linked to Facebook, if so, bypass login
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


#pragma mark - normal Login
- (IBAction)login:(id)sender
{
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([username length] == 0 || [password length] == 0 ){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:@"Make sure you enter a username & passoword"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }else{
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                                    message:[error userInfo][@"error"]
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil, nil];
                [alertView show];
            }else{
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }];
    }
}


#pragma mark - Login with FB


- (IBAction)loginButtonTouchHandler:(id)sender  {
    
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"email", @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    [_activityIndicator startAnimating]; // Show loading indicator until login is finished
    self.scrollView.hidden = YES;
    
    // Login PFUser using facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [_activityIndicator stopAnimating]; // Hide loading indicator
        
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Uh oh. The user cancelled the Facebook login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
                self.scrollView.hidden = NO;
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        } else if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
            [self.navigationController popToRootViewControllerAnimated:YES];
            [self fetchFBAccount];
            
        } else {
            NSLog(@"User with facebook logged in!");
           // [self.navigationController pushViewController:[[RequestTableViewController alloc] init] animated:NO];
            [self.navigationController popToRootViewControllerAnimated:YES];
            [self fetchFBAccount];
        }
    }];
    
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
           // NSLog(@"%@", result);
            
            NSString *facebookID = userData[@"id"];
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            self.imageURL = [NSURL URLWithString:[pictureURL absoluteString]];
            
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

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    [self startDownloadingImage];
}

- (void)startDownloadingImage
{
    self.image = nil;
    
    if (self.imageURL)
    {
        
        NSURLRequest *request = [NSURLRequest requestWithURL:self.imageURL];
        
        // another configuration option is backgroundSessionConfiguration (multitasking API required though)
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        
        // create the session without specifying a queue to run completion handler on (thus, not main queue)
        // we also don't specify a delegate (since completion handler is all we need)
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                        completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
                                                            // this handler is not executing on the main queue, so we can't do UI directly here
                                                            if (!error) {
                                                                if ([request.URL isEqual:self.imageURL]) {
                                                                    // UIImage is an exception to the "can't do UI here"
                                                                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localfile]];
                                                                    // but calling "self.image =" is definitely not an exception to that!
                                                                    // so we must dispatch this back to the main queue
                                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                                        self.image = image;
                                                                        [self uploadImage];
                                                                    });
                                                                }
                                                            }
                                                        }];
        [task resume]; // don't forget that all NSURLSession tasks start out suspended!
    }
}


- (void)uploadImage
{
    NSData *fileData;
    NSString *fileName;
    NSString *fileType;
    
    // if image, shrink it
    //  UIImage *newImage = [self resizeImage:self.image toWidth:320.0f andHeight:480.0f]; // of iphone
    // Upload the file itself
    fileData = UIImageJPEGRepresentation(self.image, 1.0);
    fileName = @"profilePic.jpg";
    fileType = @"image";
    
    //Do not know how to check if it is the same, so upload it anyway
    PFFile *file = [PFFile fileWithName:fileName data:fileData];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }else{
            [[PFUser currentUser] setObject:file forKey:@"file"];
            [[PFUser currentUser] setObject:fileType forKey:@"fileType"];
            
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    NSLog(@"Error %@ %@", error, [error userInfo]);
                }else{
                    NSLog(@"Uploaded image");
                }
            }];
        }
    }];}




@end
