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

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    //if ([UIScreen mainScreen].bounds.size.height == 568 ) {
    //    self.backgroundImageView.image = [UIImage imageNamed:@"loginBackground-568h"];
   // }

    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // hide the nav bar
    [self.navigationController.navigationBar setHidden:YES];

}



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






@end
