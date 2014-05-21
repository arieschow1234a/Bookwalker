//
//  MyRequestVC.m
//  Bookwalker
//
//  Created by Aries on 13/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "RequestDetailsVC.h"

@interface RequestDetailsVC () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic)NSArray *conversations;
@property (weak, nonatomic) IBOutlet UITextView *replyTextView;


@end

@implementation RequestDetailsVC



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.replyTextView.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [self.replyTextView.layer setBorderWidth:1.0f];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self retrieveRequestOfABook];
    
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
            // Get the NSNumber into int
            NSNumber *number = [self.requestBook objectForKey:@"noOfRequest"];
            int value = [number intValue];
            number = [NSNumber numberWithInt:value + 1];
            [self.requestBook setObject:number forKey:@"noOfRequests"];
            [self.requestBook saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [self retrieveRequestOfABook];
                }else{
                    NSLog(@"Error %@ %@", error, [error userInfo]);
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



@end
