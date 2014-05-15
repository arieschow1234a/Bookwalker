//
//  AddBookViewController.m
//  Bookwalker
//
//  Created by Aries on 9/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "AddBookViewController.h"

@interface AddBookViewController ()
@property (weak, nonatomic) IBOutlet UITextField *isbnField;
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextField *authorField;
@property (weak, nonatomic) IBOutlet UITextField *noteField;
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

        //upload to parse
        PFObject *book = [PFObject objectWithClassName:@"Books"];
        [book setObject:isbn forKey:@"isbn"];
        [book setObject:title forKey:@"title"];
        [book setObject:author forKey:@"author"];
        [book setObject:note forKey:@"note"];
        [book setObject:[user objectId] forKey:@"holder"];
        [book setObject:[user username] forKey:@"holderName"];
        [book setObject:@0 forKey:@"noOfRequests"];
        
        self.book = book;
        [book saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred!"
                                                                    message:@"Please try again"
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil, nil];
                [alertView show];
                
            }else{
                // Saved the book in Parse and then save the book in user's booksRelation
                PFRelation *booksRelation = [user relationForKey:@"booksRelation"];
                [booksRelation addObject:book];
                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        NSLog(@"Error %@ %@", error, [error userInfo]);
                    }
                }];
            }
        }];
    }

}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:UNWIND_SEGUE_IDENTIFIER]) {
        NSString *isbn = [self.isbnField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *title = self.titleField.text;
        NSString *author = self.authorField.text;
        NSString *note = self.noteField.text;

        //need to check if ISBN is number
        if ([isbn length] == 0 || [title length] == 0 || [author length] == 0 || [note length] == 0){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                message:@"Make sure you enter a information"
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


- (IBAction)cancel:(id)sender {
 [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    
}




@end
