//
//  BookDetailsViewController.m
//  Bookwalker
//
//  Created by Aries on 9/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "BookDetailsViewController.h"
#import "BWHelper.h"

@interface BookDetailsViewController ()
@property (weak, nonatomic) IBOutlet UITextView *replyTextView;
@property (strong, nonatomic) PFObject *savedNote;
@property (strong, nonatomic) PFObject *savedRequest;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *isbnLabel;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (weak, nonatomic) IBOutlet UILabel *holderLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;


@property (weak, nonatomic) IBOutlet UIImageView *bookImageView;

@end

@implementation BookDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text = [self.book objectForKey:@"title"];
    self.authorLabel.text = [self.book objectForKey:@"author"];
    self.isbnLabel.text = [self.book objectForKey:@"isbn"];
    self.statusLabel.text = [[NSString alloc]initWithFormat:@"Status: %@",[BWHelper statusOfBook:self.book]];
    self.holderLabel.text = [[NSString alloc]initWithFormat:@"Holder: %@",[self.book objectForKey:@"holderName"]];
    self.noteLabel.text = [[NSString alloc]initWithFormat:@"Note: %@",[self.book objectForKey:@"note"]];

    PFFile *imagefile = [self.book objectForKey:@"file"];
    if (imagefile) {
        [imagefile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:imageData];
                self.bookImageView.image = image;
            }
        }];
    }else{
        self.bookImageView.image = [UIImage imageNamed:@"bookcover"];
    }

    
    
    
    [self.replyTextView.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [self.replyTextView.layer setBorderWidth:1.0f];
    self.replyTextView.editable = YES;
    
}

- (IBAction)sendRequest:(id)sender {
    
    PFUser *user = [PFUser currentUser];
    
    PFObject *note = [PFObject objectWithClassName:@"Requests"];
    [note setObject:self.book[@"holder"] forKey:@"speakerId"];
    [note setObject:self.book[@"holderName"] forKey:@"speakerName"];
    [note setObject:self.book[@"note"] forKey:@"comment"];
    [note setObject:self.book.objectId forKey:@"bookObjectId"];
    [note saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            PFObject *request = [PFObject objectWithClassName:@"Requests"];
            [request setObject:user.objectId forKey:@"speakerId"];
            [request setObject:user.username forKey:@"speakerName"];
            [request setObject:self.replyTextView.text forKey:@"comment"];
            [request setObject:self.book.objectId forKey:@"bookObjectId"];
            [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [self getSavedRequestAndSaveInParse];
                }
            }];
            
            
            
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

#pragma mark - Helper methods

- (void)getSavedRequestAndSaveInParse
{
    // Search for the messages sent by others
    PFQuery *query = [PFQuery queryWithClassName:@"Requests"];
    [query whereKey:@"bookObjectId" equalTo:self.book.objectId];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog (@"Error: %@ %@", error, [error userInfo]);
        }else{
            // We found request!!
            
           self.savedNote = objects[0];
            self.savedRequest = objects[1];
            
            PFQuery *query = [PFQuery queryWithClassName:@"Books"];
            [query getObjectInBackgroundWithId:self.book.objectId block:^(PFObject *book, NSError *error) {
                
                PFRelation *requestsRelation = [book relationForKey:@"requestsRelation"];
                [requestsRelation addObject:self.savedNote];
                [requestsRelation addObject:self.savedRequest];
                // Get the NSNumber into int
                NSNumber *number = [book objectForKey:@"noOfRequest"];
                int value = [number intValue];
                number = [NSNumber numberWithInt:value + 2];
                [book setObject:number forKey:@"noOfRequests"];
                
                [book setObject:[PFUser currentUser].objectId forKey:@"requesterId"];

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
