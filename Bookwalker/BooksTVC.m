//
//  BooksTVC.m
//  Bookwalker
//
//  Created by Aries on 15/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "BooksTVC.h"
#import "BookCell.h"
#import <Parse/Parse.h>
#import "BookDetailsViewController.h"


@interface BooksTVC ()

@end

@implementation BooksTVC
{
    NSArray *searchResults;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)setBooks:(NSMutableArray *)books
{
    _books = books;
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

    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
    } else {
        return [self.books count];
    }

    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BookCell";
    BookCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[BookCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    // Configure the cell...
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        PFObject *book = [searchResults objectAtIndex:indexPath.row];
        [cell configureCellForBook:book];
    } else {
        PFObject *book = [self.books objectAtIndex:indexPath.row];
        [cell configureCellForBook:book];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.searchDisplayController.active) {
        
        [self performSegueWithIdentifier:@"Show Details" sender:self];
    }
}


- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    PFQuery *queryTitle = [PFQuery queryWithClassName:@"Books"];
    [queryTitle whereKey:@"title" matchesRegex:searchText modifiers:@"i"];
    
    PFQuery *queryAuthor = [PFQuery queryWithClassName:@"Books"];
    [queryAuthor whereKey:@"author" matchesRegex:searchText modifiers:@"i"];
    
    PFQuery *queryISBN10 = [PFQuery queryWithClassName:@"Books"];
    [queryISBN10 whereKey:@"isbn10" equalTo:searchText];
    
    PFQuery *queryISBN13 = [PFQuery queryWithClassName:@"Books"];
    [queryISBN13 whereKey:@"isbn13" equalTo:searchText];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[queryTitle, queryAuthor, queryISBN10, queryISBN13]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if (error) {
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }else{
            searchResults = results;
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
    }];
}


-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Show Details"]){
        BookDetailsViewController *bdvc = (BookDetailsViewController *)segue.destinationViewController;
        self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        NSIndexPath *indexPath = nil;
        PFObject *book = nil;
        
        // set up the vc to run here
        if (self.searchDisplayController.active) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            book = [searchResults objectAtIndex:indexPath.row];
        }else{
            indexPath = [self.tableView indexPathForCell:sender];
            book = [self.books objectAtIndex:indexPath.row];
        }
        bdvc.book = book;
    }
}

@end
