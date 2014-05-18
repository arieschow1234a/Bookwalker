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
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.books removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
        PFObject *book = [self.books objectAtIndex:indexPath.row];
        [book deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"Error %@ %@", error, [error userInfo]);
            }
        }];
    }
}
    





#pragma mark - Navigation

- (IBAction)addedBook:(UIStoryboardSegue *)segue
{
    if ([segue.sourceViewController isKindOfClass:[AddBookViewController class]]) {
    // Add to Core data maybe
        
    //   AddBookViewController *abvc = (AddBookViewController *)segue.sourceViewController;
      //  PFObject *addedBook = abvc.book;
       // [self.books insertObject:addedBook atIndex:0];
        [self fetchMyBook];

    }
}

#pragma mark - helper method

- (void)fetchMyBook
{
    PFRelation *booksRelation = [[PFUser currentUser] objectForKey:@"booksRelation"];
    PFQuery *query = [booksRelation query];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }else{
            self.books = [[NSMutableArray alloc] initWithArray:objects];
            
        }
    }];
    
}

@end
