//
//  SendRequestVC.m
//  Bookwalker
//
//  Created by Aries on 9/6/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "SendRequestVC.h"
#import "BookDetailsViewController.h"

@interface SendRequestVC ()
@property (weak, nonatomic) IBOutlet UITextView *replyTextView;
@property (weak, nonatomic) IBOutlet UITextView *noteTextView;
@property (weak, nonatomic) IBOutlet UILabel *holderLabel;
@property (strong, nonatomic) PFObject *savedNote;
@property (strong, nonatomic) PFObject *savedRequest;

@end

@implementation SendRequestVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(hideKeyBoard)];
    
    [self.view addGestureRecognizer:tapGesture];
    
    [self.replyTextView.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [self.replyTextView.layer setBorderWidth:1.0f];
    self.replyTextView.editable = YES;
    self.holderLabel.text = [NSString stringWithFormat:@"Holder: %@",self.book[@"holderName"]];
    if ([self.book[@"note"] isKindOfClass:[NSString class]]){
        self.noteTextView.text = [NSString stringWithFormat:@"Note: %@",self.book[@"note"]];
    }else{
        self.noteTextView.text = @"No note from holder";
    }
}

-(void)hideKeyBoard {
    [self.view endEditing:YES];
}

#pragma mark - Navigation

- (IBAction)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    
}

#define UNWIND_SEGUE_IDENTIFIER @"Do Send Request"

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:UNWIND_SEGUE_IDENTIFIER]) {
        
        if ([self.replyTextView.text length] == 0 ){
            [self noInputAlert];
            return NO;
        }
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PFUser *user = [PFUser currentUser];

    if ([segue.identifier isEqualToString:UNWIND_SEGUE_IDENTIFIER]){
        
        PFObject *note = [PFObject objectWithClassName:@"Requests"];
        [note setObject:self.book[@"holderId"] forKey:@"speakerId"];
        [note setObject:self.book[@"holderName"] forKey:@"speakerName"];
        [note setObject:self.book.objectId forKey:@"bookObjectId"];
        [note addObject:self.book[@"holderId"] forKey:@"participants"];
        [note addObject:user.objectId forKey:@"participants"];
        if ([self.book[@"note"] isKindOfClass:[NSString class]]) {
            [note setObject:self.book[@"note"] forKey:@"comment"];
        }else{
            [note setObject:@"No note from holder" forKey:@"comment"];
        }
        [note saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                PFObject *request = [PFObject objectWithClassName:@"Requests"];
                [request setObject:user.objectId forKey:@"speakerId"];
                [request setObject:user[@"name"] forKey:@"speakerName"];
                [request setObject:self.replyTextView.text forKey:@"comment"];
                [request setObject:self.book.objectId forKey:@"bookObjectId"];
                [request addObject:self.book[@"holderId"] forKey:@"participants"];
                [request addObject:user.objectId forKey:@"participants"];
                [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        // saved the note& request into self.book's relation on cloud
                        [self updateBook];
                    }
                }];
            }
        }];
        // going back
        [self.navigationController popViewControllerAnimated:YES];
        BookDetailsViewController *bdvc = segue.destinationViewController;
        bdvc.book[@"requesterId"] = user.objectId;
    }
}



// Saved the coversation into requestsRelation
- (void)updateBook
{
    
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Books"];
    [query getObjectInBackgroundWithId:self.book.objectId block:^(PFObject *book, NSError *error) {
        // Get the NSNumber into int
            NSNumber *number = [book objectForKey:@"noOfRequests"];
            int value = [number intValue];
            number = [NSNumber numberWithInt:value + 1];
            [book setObject:number forKey:@"noOfRequests"];
            
            [book setObject:user.objectId forKey:@"requesterId"];
            [book setObject:user[@"name"] forKey:@"requesterName"];
            [book saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    NSLog(@"Error %@ %@", error, [error userInfo]);
                }else{
                    [self saveNotificationWithBook:book];
                }
            }];
    }];
}

- (void)saveNotificationWithBook:(PFObject *)book
{
    PFUser *user = [PFUser currentUser];
    PFObject *notification = [PFObject objectWithClassName:@"Notifications"];

    [notification setObject:@"newRequest" forKey:@"type"];
    [notification setObject:book[@"holderId"] forKey:@"receiverId"];
    [notification setObject:book[@"holderName"] forKey:@"receiverName"];
    [notification setObject:user.objectId forKey:@"senderId"];
    [notification setObject:user[@"name"] forKey:@"senderName"];
    [notification setObject:book.objectId forKey:@"bookObjectId"];
    [notification setObject:book[@"title"] forKey:@"bookTitle"];
    notification[@"parent"] = book;
    [notification saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"saved Notification");
        }
    }];

}




#pragma mark - Helper methods
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
