//
//  NotificationsTVC.m
//  Bookwalker
//
//  Created by Aries on 27/6/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "NotificationsTVC.h"
#import <Parse/Parse.h>
#import "RequestTableViewController.h"
#import "NotificationCell.h"
#import "BookDetailsViewController.h"

@interface NotificationsTVC ()
@property (nonatomic, strong)NSMutableArray *notifications;
@end

@implementation NotificationsTVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self fetchNotifications];
    [self.navigationController.tabBarItem setBadgeValue:@"1"];
}


- (void)setNotifications:(NSMutableArray *)notifications
{
    _notifications = notifications;
    [self.tableView reloadData];
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
    return [self.notifications count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notification cell" forIndexPath:indexPath];
    
    // Configure the cell...
    PFObject *notification = [self.notifications objectAtIndex:indexPath.row];
    [cell configureCellForNotification:notification];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:@"notification cell"]) {
        PFObject *notification = [self.notifications objectAtIndex:indexPath.row];
        NSString *type = notification[@"type"];
        if ([type isEqualToString:@"newRequest"]) {
            [self performSegueWithIdentifier:@"Show Request" sender:cell];
        
        }else if([type isEqualToString:@"cancelRequest"] || [type isEqualToString:@"declineRequest"]){
            [self performSegueWithIdentifier:@"Show Cancelled Book" sender:cell];

        }
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    PFObject *notification = [self.notifications objectAtIndex:indexPath.row];
    
    if([segue.identifier isEqualToString:@"Show Request"]){
    //    RequestTableViewController *rtvc = (RequestTableViewController *)segue.destinationViewController;
        
    }else if([segue.identifier isEqualToString:@"Show Cancelled Book"]){
        BookDetailsViewController *bdvc = (BookDetailsViewController *)segue.destinationViewController;
        bdvc.bookId = notification[@"bookObjectId"];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    
       return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}



#pragma mark - Helper method
- (void)fetchNotifications
{
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Notifications"];
    [query whereKey:@"receiverId" equalTo:user.objectId];
    query.limit = 20;
    
    NSMutableArray *objectIds = [[NSMutableArray alloc] init];
    if (self.notifications) {
        for (PFObject *oldNotif in self.notifications) {
            [objectIds addObject:oldNotif.objectId];
        }
        [query whereKey:@"objectId" notContainedIn:objectIds];
        [query orderByAscending:@"createdAt"];

    }else{
        [query orderByDescending:@"createdAt"];
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }else{
           // NSLog(@"%lu", (unsigned long)[objects count]);
            if (self.notifications) {
                for (PFObject *newNotif in objects) {
                    [self.notifications insertObject:newNotif atIndex:0];
                }
                [self.tableView reloadData];
            }else{
                self.notifications = [[NSMutableArray alloc] initWithArray:objects];
            }
        }
    }];
}


@end
