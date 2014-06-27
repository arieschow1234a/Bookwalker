//
//  EditAccountVC.m
//  Bookwalker
//
//  Created by Aries on 26/6/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "EditAccountVC.h"
#import <Parse/Parse.h>

@interface EditAccountVC ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@end

@implementation EditAccountVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.nicknameTextField.text = self.nickname;
    self.emailTextField.text = self.email;
    self.imageView.image = self.image;
    self.imageView.layer.cornerRadius = 5.0f;
    self.imageView.layer.masksToBounds = YES;
}

- (void)setNickname:(NSString *)nickname
{
    _nickname = nickname;
    self.nicknameTextField.text = nickname;
}

- (void)setEmail:(NSString *)email
{
    _email = email;
    self.emailTextField.text = email;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.imageView.image = image;
    self.imageView.layer.cornerRadius = 5.0f;
    self.imageView.layer.masksToBounds = YES;
}

#pragma mark - Navigation

- (IBAction)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma mark - Navigation
#define UNWIND_SEGUE_IDENTIFIER @"Do Edit Account"

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:UNWIND_SEGUE_IDENTIFIER]){
        [self updateAccount];
    }
    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:UNWIND_SEGUE_IDENTIFIER]) {
        NSString *nickname = self.nicknameTextField.text;
        NSString *email = self.emailTextField.text;
        
        if ([nickname length] == 0 ||[email length] == 0){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                message:@"Make sure you enter all information"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
            [alertView show];
            return NO;
        }
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}

#pragma mark - Helper Method

- (void)updateAccount
{
    PFUser *user = [PFUser currentUser];
    [user setObject:self.nicknameTextField.text forKey:@"name"];
    [user setObject:self.emailTextField.text forKey:@"email"];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"OK");
        }
    }];

}


@end
