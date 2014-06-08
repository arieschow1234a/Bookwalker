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
@property (weak, nonatomic) IBOutlet UILabel *preHolderLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;


@property (weak, nonatomic) IBOutlet UIImageView *bookImageView;

@end

@implementation BookDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text = [self.book objectForKey:@"title"];
    self.authorLabel.text = [self.book objectForKey:@"author"];
    self.statusLabel.text = [[NSString alloc]initWithFormat:@"Status: %@",[BWHelper statusOfBook:self.book]];
    self.holderLabel.text = [[NSString alloc]initWithFormat:@"Holder: %@",[self.book objectForKey:@"holderName"]];
    
    if ([self.book[@"note"] isKindOfClass:[NSString class]]){
        self.noteLabel.text = [NSString stringWithFormat:@"Note: %@",self.book[@"note"]];
    }else{
        self.noteLabel.text = @"No note from holder";
    }
    if (self.book[@"previousHolderName"]) {
        NSArray *preHolders = self.book[@"previousHolderName"];
        NSString *result = [[preHolders valueForKey:@"description"] componentsJoinedByString:@", "];
        
        self.preHolderLabel.text = [NSString stringWithFormat:@"Prev: %@", result];
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"MetaBooks"];
    [query orderByDescending:@"updatedAt"];
    [query whereKey:@"objectId" equalTo:self.book[@"bookId"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }else{
            PFObject *metaBook = objects[0];
            
            self.descriptionTextView.text = [metaBook objectForKey:@"description"];
            self.isbnLabel.text = [metaBook objectForKey:@"isbn"];

            PFFile *imagefile = [metaBook objectForKey:@"file"];
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
        }
    }];
    
    [self.replyTextView.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [self.replyTextView.layer setBorderWidth:1.0f];
    self.replyTextView.editable = YES;
    
}

- (IBAction)sendRequest:(id)sender {
    
    PFUser *user = [PFUser currentUser];
        
    if ([user.objectId isEqualToString:self.book[@"holderId"]]) {
        [self requestOwnBookAlert];
      
    }else if ([self.book[@"bookStatus"] isEqual:@1]){
        [self bookClosedAlert];
    
    }else if ([self.book[@"requesterId"] isEqual:user.objectId]){
        [self requestedAlreadyAlert];
    }else if ([self.replyTextView.text length]){
        
        NSNull *null = [NSNull null];
        PFObject *note = [PFObject objectWithClassName:@"Requests"];
        [note setObject:self.book[@"holderId"] forKey:@"speakerId"];
        [note setObject:self.book[@"holderName"] forKey:@"speakerName"];
        [note setObject:self.book.objectId forKey:@"bookObjectId"];
        if ([self.book[@"note"] isKindOfClass:[NSString class]]) {
            [note setObject:self.book[@"note"] forKey:@"comment"];
        }else{
            [note setObject:null forKey:@"comment"];
        }
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
        
    }else{
        [self noInputAlert];

    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  
}

*/

// Saved the coversation into requestsRelation
- (void)getSavedRequestAndSaveInParse
{
    PFUser *user = [PFUser currentUser];
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
                NSNumber *number = [book objectForKey:@"noOfRequests"];
                int value = [number intValue];
                number = [NSNumber numberWithInt:value + 1];
                [book setObject:number forKey:@"noOfRequests"];
                
                [book setObject:user.objectId forKey:@"requesterId"];
                [book setObject:user.username forKey:@"requesterName"];


                [book saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        NSLog(@"Error %@ %@", error, [error userInfo]);
                    }
                }];
            }];
        
        }
       
    }];
}

#pragma mark - Helper methods

-(void)requestOwnBookAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!!"
                                                        message:@"You can't requested your book!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)bookClosedAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!!"
                                                        message:@"This book is closed for sharing. You may contact the holder directly!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)requestedAlreadyAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!!"
                                                        message:@"You have requested this book already! Please check Request record."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)noInputAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!!"
                                                        message:@"Please write your request!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}




@end
