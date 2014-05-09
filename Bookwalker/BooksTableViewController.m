//
//  BooksTableViewController.m
//  Bookwalker
//
//  Created by Aries on 9/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "BooksTableViewController.h"
#import <Parse/Parse.h>

@interface BooksTableViewController ()

@end

@implementation BooksTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
