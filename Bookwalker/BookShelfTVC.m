//
//  BooksShelfTVC.m
//  Bookwalker
//
//  Created by Aries on 15/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "BookShelfTVC.h"
#import "AddBookViewController.h"

@interface BookShelfTVC ()

@end

@implementation BookShelfTVC

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
    [self fetchMyBook];
}

#pragma mark - tableview delegate

// Use the swipe to delete the entry

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *book = [self.books objectAtIndex:indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([self.books count] == 1) {
            self.books = nil;
            [self.tableView reloadData];
        }else{
            [self.books removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
        }
        [book deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"Error %@ %@", error, [error userInfo]);
            }
        }];
    }
}
    





#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Edit"]){
        UITableViewCell *cell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        UINavigationController *navigationController = segue.destinationViewController;
        AddBookViewController *abvc = (AddBookViewController *)navigationController.topViewController;
        abvc.book = [self.books objectAtIndex:indexPath.row];
    }
}



- (IBAction)addedBook:(UIStoryboardSegue *)segue
{
    if ([segue.sourceViewController isKindOfClass:[AddBookViewController class]]) {
    // Add to Core data maybe
        [self fetchMyBook];

    }
}

#pragma mark - helper method

- (void)fetchMyBook
{
    PFQuery *query = [PFQuery queryWithClassName:@"Books"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"holderId" equalTo:[PFUser currentUser].objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }else{
            self.books = [[NSMutableArray alloc] initWithArray:objects];
        }
    }];
    
}

@end
