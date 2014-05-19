//
//  RequestTableViewController.m
//  Bookwalker
//
//  Created by Aries on 9/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "RequestTableViewController.h"
#import "MyRequestVC.h"
#import <Parse/Parse.h>

@interface RequestTableViewController ()
@property (strong, nonatomic) NSArray *requests;
@end

@implementation RequestTableViewController

- (NSArray *)requests
{
    if(!_requests){
        _requests = [[NSArray alloc] init];
    }
    return _requests;
        
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser) {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
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
    //cell.textLabel.text = [NSString stringWithFormat:@"For %@, %@ sent you a request", request[@"title"], request[@""] ];
    
    
    return cell;
}




#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"My request"]){
        
        MyRequestVC *mrvc = (MyRequestVC *)segue.destinationViewController;
        // set up the vc to run here
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        PFObject *myRequestBook = [self.requests objectAtIndex:indexPath.row];
        
        mrvc.myRequestBook = myRequestBook;
        mrvc.title = [myRequestBook objectForKey:@"title"];
        
    }
}

#pragma mark - IBAction

- (IBAction)logout:(id)sender
{
    [PFUser logOut];
    [self performSegueWithIdentifier:@"showLogin" sender:self];
}


# pragma mark - Helper methods

- (void)retrieveRequest
{
    // My requests of others' books
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Books"];
    [query whereKey:@"requesterId" equalTo:user.objectId];
    [query orderByDescending:@"updatedAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }else{
           self.requests = objects;
            [self.tableView reloadData];

        }
    }];

    
    //May be useful when fetching the request from other people
    /*
     PFUser *user = [PFUser currentUser];
     PFRelation *relation = [user relationforKey:@"booksRelation"];
    
    PFQuery *query = [relation query];
    [query orderByDescending:@"updatedAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            // There was an error
        } else {
            self.requests = nil;
            NSArray *books = [[NSArray alloc] initWithArray:objects];
            for (PFObject *book in books){
                NSNumber *number = [book objectForKey:@"noOfRequests"];
                NSLog(@"%@", number);
                int value = [number intValue];
                if(value > 1) {
                    NSLog(@"found");
                    [self.requests addObject:book];
                }
            }
            [self.tableView reloadData];
        }
    }];
     */
    
}









@end
