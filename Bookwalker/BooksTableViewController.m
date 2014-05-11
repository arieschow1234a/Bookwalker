//
//  BooksTableViewController.m
//  Bookwalker
//
//  Created by Aries on 9/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "BooksTableViewController.h"
#import <Parse/Parse.h>
#import "BookDetailsViewController.h"

@interface BooksTableViewController ()

@end

@implementation BooksTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchAllBooks];

}


- (NSArray *)books
{
    if (!_books) {
        PFQuery *query = [PFQuery queryWithClassName:@"Books"];
        [query orderByDescending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error){
                NSLog(@"Error %@ %@", error, [error userInfo]);
            }else{
                _books = [[NSMutableArray alloc] initWithArray:objects];
                [self.tableView reloadData];
            }
        }];
        
    }
    return _books;
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
    return [self.books count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"books" forIndexPath:indexPath];
    
    // Configure the cell...
    PFObject *book = [self.books objectAtIndex:indexPath.row];
    cell.textLabel.text = [book objectForKey:@"title"];
    cell.detailTextLabel.text = [book objectForKey:@"author"];
    
    return cell;
}




#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"show Details"]){
        BookDetailsViewController *bdvc = (BookDetailsViewController *)segue.destinationViewController;
        // set up the vc to run here
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        PFObject *book = [self.books objectAtIndex:indexPath.row];
        
        bdvc.objectId = book.objectId;
        
        bdvc.title = [book objectForKey:@"title"];
        
        bdvc.bookTitle = [book objectForKey:@"title"];
        bdvc.author = [book objectForKey:@"author"];
        bdvc.isbn = [book objectForKey:@"isbn"];
        bdvc.note = [book objectForKey:@"note"];
        bdvc.holder= [book objectForKey:@"holderName"];
        bdvc.holderId = [book objectForKey:@"holder"];

        
    }
}


#pragma mark - helper method

- (void)fetchAllBooks
{
    PFQuery *query = [PFQuery queryWithClassName:@"Books"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }else{
            self.books = [[NSMutableArray alloc] initWithArray:objects];
            [self.tableView reloadData];
        }
    }];
}


@end
