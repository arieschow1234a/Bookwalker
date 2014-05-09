//
//  AddBookViewController.m
//  Bookwalker
//
//  Created by Aries on 9/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "AddBookViewController.h"
#import <Parse/Parse.h>

@interface AddBookViewController ()

@end

@implementation AddBookViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



#pragma mark - Navigation
#define UNWIND_SEGUE_IDENTIFIER @"Do Add Book"

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:UNWIND_SEGUE_IDENTIFIER]){
        // need to change ISBN to number
        NSString *isbn = [self.isbnField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *title = self.titleField.text;
        NSString *author = self.authorField.text;
        NSString *note = self.noteField.text;
        PFUser *user = [PFUser currentUser];
        
        //need to check if ISBN is number
        if ([isbn length] == 0 || [title length] == 0 || [author length] == 0 || [note length] == 0){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                message:@"Make sure you enter a information"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
            [alertView show];
        }else{
            //upload to parse
            PFObject *book = [PFObject objectWithClassName:@"Books"];
            [book setObject:isbn forKey:@"isbn"];
            [book setObject:title forKey:@"title"];
            [book setObject:author forKey:@"author"];
            [book setObject:note forKey:@"note"];
            [book setObject:[user objectId] forKey:@"holder"];
            [book setObject:[user username] forKey:@"holderName"];
            [book saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred!"
                                                                        message:@"Please try again"
                                                                       delegate:self
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil, nil];
                    [alertView show];
                    
                }else{
                    // Everything was successful!
                    PFRelation *booksRelation = [user relationForKey:@"booksRelation"];
                    [booksRelation addObject:book];
                    NSLog(@"Done!!!");
                    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (error) {
                            NSLog(@"Error %@ %@", error, [error userInfo]);
                        }
                    }];

                    
                    
                }
            }];

            
            
            
        }
    
    }
}






- (IBAction)cancel:(id)sender {
 [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    
}
@end
