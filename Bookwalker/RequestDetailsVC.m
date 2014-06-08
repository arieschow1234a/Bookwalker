//
//  MyRequestVC.m
//  Bookwalker
//
//  Created by Aries on 13/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "RequestDetailsVC.h"

@interface RequestDetailsVC () <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic)NSArray *conversations;
@property (weak, nonatomic) IBOutlet UITextView *replyTextView;
@property (weak, nonatomic) IBOutlet UIButton *confirmGivingButton;

@property (nonatomic, strong) NSString *requesterId;

@end

@implementation RequestDetailsVC



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.replyTextView.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [self.replyTextView.layer setBorderWidth:1.0f];
    
    //If the user is the requester
    PFUser *user = [PFUser currentUser];
    if ([self.requestBook[@"holderId"] isEqualToString:user.objectId]) {
        self.confirmGivingButton.hidden = NO;
    }else{
        self.confirmGivingButton.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self retrieveRequestOfABook];
    
}

- (NSString *)requesterId
{
    if (!_requesterId) {
        _requesterId = [[NSString alloc]initWithString:self.requestBook[@"requesterId"]];
    }
    return _requesterId;
}

- (void)setConversations:(NSArray *)conversations
{
    _conversations = conversations;
    [self.tableView reloadData];
}



#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.conversations count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"comment"];
    
    
    PFObject *reply = [self.conversations objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat: @"%@: %@",[reply objectForKey:@"speakerName"], [reply objectForKey:@"comment"]];
    return cell;
    
}


- (IBAction)sendReply:(id)sender
{
    //save the reply into requests class and save it into books requestsRelation
    PFUser *user = [PFUser currentUser];
    PFObject *reply= [PFObject objectWithClassName:@"Requests"];
    [reply setObject:user.objectId forKey:@"speakerId"];
    [reply setObject:user.username forKey:@"speakerName"];
    [reply setObject:self.replyTextView.text forKey:@"comment"];
    [reply setObject:self.requestBook.objectId forKey:@"bookObjectId"];
    [reply saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self.replyTextView resignFirstResponder];
            self.replyTextView.text = nil;
            PFRelation *requestsRelation = [self.requestBook relationForKey:@"requestsRelation"];
            [requestsRelation addObject:reply];
            [self.requestBook saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"replied");
                    [self retrieveRequestOfABook];
                }
            }];
            
        }else{
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



# pragma mark - IBAction

- (IBAction)confirmGivingButtonPressed:(id)sender {
    
    UIAlertView *confrimAlertView = [[UIAlertView alloc] initWithTitle:@"Warning!!"
                                                               message:@"Please do it after giving out the book!"
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                     otherButtonTitles:@"Yes, I did", nil];
    
    confrimAlertView.tag = 2;

    [confrimAlertView show];
    
}

- (IBAction)cancelRequestButtonPressed:(id)sender {
    
    UIAlertView *cancelAlert = [[UIAlertView alloc] initWithTitle:@"Warning!!"
                                                              message:@"It will cancel the request! Are you sure?"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:@"Yes", nil];
    
    cancelAlert.tag = 1;
    [cancelAlert show];
}





# pragma mark - Helper methods

- (void)retrieveRequestOfABook
{
    PFRelation *relation = [self.requestBook relationforKey:@"requestsRelation"];
    PFQuery *query = [relation query];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            // There was an error
        } else {
            self.conversations = objects;
        }
    }];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            [self cancelRequest];
        }
    }else if (alertView.tag == 2){
        if (buttonIndex == 1) {
            [self confirmGiving];
        }
    }
}

- (void)cancelRequest
{
    
    NSNull *null = [NSNull null];
    
    [self.requestBook setObject:null forKey:@"requesterId"];
    [self.requestBook setObject:null forKey:@"requesterName"];
    [self.requestBook saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }else{
            // going back
            [self.navigationController popViewControllerAnimated:YES];
            [self removeRequestConversation];
        }
        
    }];
 
}


- (void)confirmGiving
{
    //After confirming,
    //1. create record
    //2. update the info of book
    //3. delete converstaion
    NSString *requesterId = self.requestBook[@"requesterId"];
    NSString *requesterName = self.requestBook[@"requesterName"];
    NSString *holderId = self.requestBook[@"holderId"];
    NSString *holderName = self.requestBook[@"holderName"];
    
    PFObject *record = [PFObject objectWithClassName:@"Records"];
    [record setObject:holderId forKey:@"giverId"];
    [record setObject:holderName forKey:@"giverName"];
    [record setObject:requesterId forKey:@"receiverId"];
    [record setObject:requesterName forKey:@"receiverName"];
    [record setObject:self.requestBook.objectId forKey:@"bookObjectId"];
    [record setObject:self.requestBook[@"title"] forKey:@"bookTitle"];
    [record saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }else{
            [self updateBookInfo];
        }
    }];


}

- (void)updateBookInfo
{
    NSNull *null = [NSNull null];
    NSString *requesterId = self.requestBook[@"requesterId"];
    NSString *requesterName = self.requestBook[@"requesterName"];
    NSString *holderId = self.requestBook[@"holderId"];
    NSString *holderName = self.requestBook[@"holderName"];
    
    [self.requestBook setObject:requesterId forKey:@"holderId"];
    [self.requestBook setObject:requesterName forKey:@"holderName"];
    [self.requestBook addObject:holderId forKey:@"previousHolderId"];
    [self.requestBook addObject:holderName forKey:@"previousHolderName"];
    [self.requestBook setObject:null forKey:@"note"];
    [self.requestBook setObject:null forKey:@"requesterId"];
    [self.requestBook setObject:null forKey:@"requesterName"];
    
    NSNumber *number = [self.requestBook objectForKey:@"noOfTransfer"];
    int value = [number intValue];
    number = [NSNumber numberWithInt:value + 1];
    [self.requestBook setObject:number forKey:@"noOfTransfer"];
    
    [self.requestBook saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }else{
            [self.navigationController popViewControllerAnimated:YES];
            [self removeRequestConversation];
        }
    }];

    
}



- (void)removeRequestConversation
{
    PFQuery *query = [PFQuery queryWithClassName:@"Requests"];
    [query whereKey:@"bookObjectId" equalTo:self.requestBook.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }else{
            if (objects) {
                for (PFObject *request in objects) {
                    [request deleteInBackground];
                }
            }
        }
    }];
}




@end
