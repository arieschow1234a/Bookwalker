//
//  RequestTableViewController.m
//  Bookwalker
//
//  Created by Aries on 9/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "RequestTableViewController.h"
#import <Parse/Parse.h>

@interface RequestTableViewController ()
@property (strong, nonatomic) NSMutableArray *requests;
@end

@implementation RequestTableViewController

- (NSMutableArray *)requests
{
    if(!_requests){
        _requests = [[NSMutableArray alloc] init];
        
    }
    return _requests;
        
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        NSLog(@"Current User: %@", currentUser.username);
    }else{
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
    self.requests = [[NSMutableArray alloc] init];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self retrieveRequest];
    [self.navigationController.navigationBar setHidden:NO];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.requests count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"request" forIndexPath:indexPath];
    
    // Configure the cell...
    PFObject *request = [self.requests objectAtIndex:indexPath.row];
    cell.textLabel.text = [request objectForKey:@"title"];
    
    return cell;
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

#pragma mark - IBAction

- (IBAction)logout:(id)sender
{
    [PFUser logOut];
    [self performSegueWithIdentifier:@"showLogin" sender:self];
}


# pragma mark - Helper methods

- (void)retrieveRequest
{
     PFUser *user = [PFUser currentUser];
     PFRelation *relation = [user relationforKey:@"booksRelation"];
     PFQuery *query = [relation query];
    [query orderByDescending:@"updatedAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            // There was an error
        } else {
            self.requests = nil;
            for (PFObject *book in objects){
                
                PFRelation *bookRelation = [book relationforKey:@"requestsRelation"];
                [[bookRelation query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    
                    if ([objects count] >  1) {
                        NSLog(@"found");
                        [self.requests addObject:book];
                    }
                    NSLog(@"Requests: %lu", (unsigned long)[self.requests count]);
                    [self.tableView reloadData];
                }];
            }
            
        }
    }];
    
    
    /*
     PFQuery *query = [PFQuery queryWithClassName:@"User"];

    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog (@"Error: %@ %@", error, [error userInfo]);
        }else{
            // We found messages!!
            self.messages = objects;
            [self.tableView reloadData];
        }
        if ([self.refreshControl isRefreshing]) {
            [self.refreshControl endRefreshing];
        }
        
    }];
     */
     
}









@end
