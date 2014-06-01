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
    return [self.books count];
    /*
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
    } else {
        return [self.books count];
    }

    */
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
    PFObject *book = [self.books objectAtIndex:indexPath.row];
    [cell configureCellForBook:book];

    
    /*
    // Configure the cell...
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        PFObject *book = [searchResults objectAtIndex:indexPath.row];
        [cell configureCellForBook:book];
    } else {
        PFObject *book = [self.books objectAtIndex:indexPath.row];
        [cell configureCellForBook:book];
    }
   
   
        */
    return cell;
}



/*
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    PFQuery *query = [PFQuery queryWithClassName:@"Books"];
    [query orderByDescending:@"updatedAt"];
    [query whereKey:@"title" containsString:searchText];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }else{
            searchResults = objects;
            NSLog(@"found %@", searchResults);
        }
    }];
}
 
 

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

*/
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
