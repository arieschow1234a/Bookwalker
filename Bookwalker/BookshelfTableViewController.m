//
//  BookshelfTableViewController.m
//  Bookwalker
//
//  Created by Aries on 9/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "BookshelfTableViewController.h"
#import "AddBookViewController.h"

@interface BookshelfTableViewController ()

@end

@implementation BookshelfTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (PFRelation *)booksRelation
{
    if (!_booksRelation) {
        _booksRelation = [[PFUser currentUser] objectForKey:@"booksRelation"];
    }
    return _booksRelation;
}

- (NSArray *)books
{
    if (!_books) {
        PFQuery *query = [self.booksRelation query];
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


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
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
/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Add Book"]){
        AddBookViewController *abvc = (AddBookViewController *)segue.destinationViewController;
        // set up the vc to run here
    }
}

*/
// this is called when AddBookViewController unwinds back to us

- (IBAction)addedPhoto:(UIStoryboardSegue *)segue
{
    if ([segue.sourceViewController isKindOfClass:[AddBookViewController class]]) {
        AddBookViewController *abvc = (AddBookViewController *)segue.sourceViewController;
        PFObject *addedBook = abvc.book;
        [self.books insertObject:addedBook atIndex:0];
        [self.tableView reloadData];
    }
}



@end


