//
//  RequestTableViewController.m
//  Bookwalker
//
//  Created by Aries on 9/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "RequestTableViewController.h"
#import "RequestMessagesVC.h"
#import <Parse/Parse.h>

@interface RequestTableViewController ()
@property (strong, nonatomic) NSMutableArray *allRequests;
@property (strong, nonatomic) NSMutableArray *myRequests;
@property (strong, nonatomic) NSMutableArray *requestsFromOthers;
@end

@implementation RequestTableViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser) {
        [self performSegueWithIdentifier:@"Show Login" sender:self];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    [self retrieveMyRequests];
    [self retrieveRequestsFromOthers];
    [self.navigationController.navigationBar setHidden:NO];

    
}

- (NSMutableArray *)allRequests
{
    if (!_allRequests) {
        
        _allRequests = [[NSMutableArray alloc] init];
    }
    return _allRequests;
}

- (void)setMyRequests:(NSMutableArray *)myRequests
{
    _myRequests = myRequests;
    if (![self.allRequests count]) {
        [self.allRequests addObject:myRequests];
    }else if ([self.requestsFromOthers count] && [self.allRequests count] == 1){
        [self.allRequests insertObject:myRequests atIndex:0];
    }else if ([self.allRequests count] == 2){
        [self.allRequests replaceObjectAtIndex:0 withObject:myRequests];
    }else{
        [self.allRequests replaceObjectAtIndex:0 withObject:myRequests];
    }
    [self.tableView reloadData];
}

- (void)setRequestsFromOthers:(NSMutableArray *)requestsFromOthers
{
    _requestsFromOthers = requestsFromOthers;
    
    if (![self.allRequests count]) {
        [self.allRequests addObject:requestsFromOthers];
    }else if ([self.myRequests count] && [self.allRequests count] == 1){
        [self.allRequests addObject:requestsFromOthers];
    }else if ([self.allRequests count] == 2){
        [self.allRequests replaceObjectAtIndex:1 withObject:requestsFromOthers];
    }else{
        [self.allRequests replaceObjectAtIndex:0 withObject:requestsFromOthers];
        
    }
    
    [self.tableView reloadData];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.allRequests count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.allRequests objectAtIndex:section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"request" forIndexPath:indexPath];
    
    // Configure the cell...
    PFObject *requestBook = [[self.allRequests objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    //cell.textLabel.text = [NSString stringWithFormat:@"For %@, %@ sent you a request", request[@"title"], request[@""] ];
    cell.textLabel.text = requestBook[@"title"];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
   
    if ([self.allRequests objectAtIndex:section] == self.myRequests){
        return @"My Requests";
    }else{
        return @"Requests from others";
    }
    
}





#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Show Request"]){
        self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        RequestMessagesVC *rdvc = (RequestMessagesVC *)segue.destinationViewController;
        // set up the vc to run here
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        PFObject *requestBook = [[self.allRequests objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        rdvc.requestBook = requestBook;
        rdvc.title = [requestBook objectForKey:@"title"];
        
    }
}

#pragma mark - IBAction

- (IBAction)logout:(id)sender
{
    [PFUser logOut];
    [self performSegueWithIdentifier:@"Show Login" sender:self];
}


# pragma mark - Helper methods

- (void)retrieveMyRequests
{
    // My requests of others' books
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Books"];
    [query orderByDescending:@"updatedAt"];
    [query whereKey:@"requesterId" equalTo:user.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }else{
           self.myRequests = [[NSMutableArray alloc] initWithArray:objects];
        }
    }];
    
}

- (void)retrieveRequestsFromOthers
{
    NSNull *null = [NSNull null];
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Books"];
    [query orderByDescending:@"updatedAt"];
    [query whereKey:@"holderId" equalTo:user.objectId];
    [query whereKeyExists:@"requesterId"];
    [query whereKey:@"requesterId" notEqualTo:null];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }else{
            self.requestsFromOthers = [[NSMutableArray alloc] initWithArray:objects];
        }
    }];
}







@end
