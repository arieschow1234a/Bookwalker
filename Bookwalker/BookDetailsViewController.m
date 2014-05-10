//
//  BookDetailsViewController.m
//  Bookwalker
//
//  Created by Aries on 9/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "BookDetailsViewController.h"

@interface BookDetailsViewController ()
@property (weak, nonatomic) IBOutlet UITextView *replyTextView;
@property (strong, nonatomic) PFObject *savedRequest;

@end

@implementation BookDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.text = [[NSString alloc]initWithFormat:@"Title: %@", self.bookTitle];
     self.authorLabel.text = [[NSString alloc]initWithFormat:@"Author: %@", self.author];
     self.isbnLabel.text = [[NSString alloc]initWithFormat:@"ISBN: %@", self.isbn];
    self.holderLabel.text = [[NSString alloc]initWithFormat:@"Holder: %@", self.holder];
    self.noteLabel.text = [[NSString alloc]initWithFormat:@"Note: %@", self.note];
    NSLog(@"%@", self.objectId);
    
}

- (IBAction)sendRequest:(id)sender {
    
    PFUser *user = [PFUser currentUser];
    
    PFObject *request = [PFObject objectWithClassName:@"Requests"];
    [request setObject:[user objectId] forKey:@"speakerId"];
    [request setObject:[user username] forKey:@"speakerName"];
    [request setObject:self.note forKey:@"comment"];
    [request setObject:self.objectId forKey:@"bookObjectId"];
    [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self retrieveRequest];
        }
    }];
    
    
    // going back
    [self.navigationController popViewControllerAnimated:YES];
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  
}

*/

# pragma mark - Helper methods

- (void)retrieveRequest
{
    // Search for the messages sent by others
    PFQuery *query = [PFQuery queryWithClassName:@"Requests"];
    [query whereKey:@"bookObjectId" equalTo:self.objectId];
    [query whereKey:@"comment" equalTo:self.note];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog (@"Error: %@ %@", error, [error userInfo]);
        }else{
            // We found request!!
            self.savedRequest = [objects objectAtIndex:0];
            NSLog(@"%@", self.savedRequest);
            
            
            PFQuery *query = [PFQuery queryWithClassName:@"Books"];
            [query getObjectInBackgroundWithId:self.objectId block:^(PFObject *book, NSError *error) {
                NSLog(@"%@", book);
                
                PFRelation *requestsRelation = [book relationForKey:@"requestsRelation"];
                [requestsRelation addObject:self.savedRequest];
                [book saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        NSLog(@"Error %@ %@", error, [error userInfo]);
                    }else{
                        NSLog(@"Saved the relation");
                    }
                }];
            }];
            
        }
       
    }];
}





@end
