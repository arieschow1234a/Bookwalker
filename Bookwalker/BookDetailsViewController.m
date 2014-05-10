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
@property (strong, nonatomic) PFObject *savedNote;
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
    
    PFObject *note = [PFObject objectWithClassName:@"Requests"];
    [note setObject:self.holderId forKey:@"speakerId"];
    [note setObject:self.holder forKey:@"speakerName"];
    [note setObject:self.note forKey:@"comment"];
    [note setObject:self.objectId forKey:@"bookObjectId"];
    [note saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            PFObject *request = [PFObject objectWithClassName:@"Requests"];
            [request setObject:user.objectId forKey:@"speakerId"];
            [request setObject:user.username forKey:@"speakerName"];
            [request setObject:self.replyTextView.text forKey:@"comment"];
            [request setObject:self.objectId forKey:@"bookObjectId"];
            [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"Done");
                    [self retrieveRequest];
                }
            }];
            
            
            
            //[self retrieveRequest];
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
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog (@"Error: %@ %@", error, [error userInfo]);
        }else{
            // We found request!!
            
           self.savedNote = objects[0];
            self.savedRequest = objects[1];
            
            
            PFQuery *query = [PFQuery queryWithClassName:@"Books"];
            [query getObjectInBackgroundWithId:self.objectId block:^(PFObject *book, NSError *error) {
                
                PFRelation *requestsRelation = [book relationForKey:@"requestsRelation"];
                [requestsRelation addObject:self.savedNote];
                [requestsRelation addObject:self.savedRequest];
                [book saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        NSLog(@"Error %@ %@", error, [error userInfo]);
                    }
                }];
            }];
        
        }
       
    }];
}





@end
