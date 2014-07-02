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
#import "DatabaseAvailability.h"
#import "Notification+Parse.h"


@interface NotificationsTVC ()
@property (nonatomic, strong)NSMutableArray *notifications;
@end

@implementation NotificationsTVC

- (void)awakeFromNib
{
    NSLog(@"Testing HI");
    [[NSNotificationCenter defaultCenter] addObserverForName:DatabaseAvailabilityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      NSLog(@"%@", note.userInfo[DatabaseAvailabilityContext]);
                                                      self.managedObjectContext = note.userInfo[DatabaseAvailabilityContext];
                                                  }];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   // [self fetchNotifications];
        [self fetchDatabase];

    
    if (self.navigationController.tabBarItem.badgeValue) {
        self.navigationController.tabBarItem.badgeValue = nil;
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"notifiBadgge"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


- (void)setNotifications:(NSMutableArray *)notifications
{
    _notifications = notifications;
    [self.tableView reloadData];
}


#pragma mark - Database context
- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    NSLog(@"Notification: Set managedObjectContext");
    [self fetchDatabase];
}

- (void)fetchDatabase
{
    if (self.managedObjectContext) {
        
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Notification"];
            request.predicate = [NSPredicate predicateWithFormat:@"receiverId = %@", [PFUser currentUser].objectId];
            request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt"
                                                                      ascending:NO
                                                                       selector:@selector(localizedStandardCompare:)]];
            NSError *error;
            NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
            self.notifications = [NSMutableArray arrayWithArray:matches];
            NSLog(@"Notification: %@", matches);
    }
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
    Notification *notification = [self.notifications objectAtIndex:indexPath.row];
    [cell configureCellForNotification:notification];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:@"notification cell"]) {
        Notification *notification = [self.notifications objectAtIndex:indexPath.row];
        NSString *type = notification.type;
        NSLog(@"%@", type);
        if (type) {
            if ([type isEqualToString:@"newRequest"]) {
                [self performSegueWithIdentifier:@"Show Request" sender:cell];
                
            }else if([type isEqualToString:@"cancelRequest"] || [type isEqualToString:@"declineRequest"]){
                [self performSegueWithIdentifier:@"Show Cancelled Book" sender:cell];
                
            }
        }
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Notification *notification = [self.notifications objectAtIndex:indexPath.row];
    
    if([segue.identifier isEqualToString:@"Show Request"]){
    //    RequestTableViewController *rtvc = (RequestTableViewController *)segue.destinationViewController;
        
    }else if([segue.identifier isEqualToString:@"Show Cancelled Book"]){
        BookDetailsViewController *bdvc = (BookDetailsViewController *)segue.destinationViewController;
        bdvc.bookId = notification.bookObjectId;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    
       return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}




// Moved to App delegate 
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
