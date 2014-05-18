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
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BookCell" forIndexPath:indexPath];
    
    // Configure the cell...
    PFObject *book = [self.books objectAtIndex:indexPath.row];
    [cell configureCellForBook:book];

    
    //cell.textLabel.text = [book objectForKey:@"title"];
    //cell.detailTextLabel.text = [book objectForKey:@"author"];
    
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
