//
//  CategoriesTVC.m
//  Bookwalker
//
//  Created by Aries on 26/6/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "CategoriesTVC.h"
#import <Parse/Parse.h>
#import "AllBooksTVC.h"

@interface CategoriesTVC ()

@end

@implementation CategoriesTVC


- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchCategory];
    
}

- (void)setCategories:(NSArray *)categories
{
    _categories = categories;
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
    return [self.categories count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"categoryCell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *cat = [self.categories objectAtIndex:indexPath.row];
    cell.textLabel.text = cat;
    return cell;
}

#pragma mark - helper method

- (void)fetchCategory
{
    [PFCloud callFunctionInBackground:@"categories"
                       withParameters:@{}
                                block:^(NSDictionary *result, NSError *error) {
                                    self.categories = [[NSArray alloc] initWithArray:[result allKeys]];
                                }];
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Show Books in Category"]){
        self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        AllBooksTVC *abtvc = (AllBooksTVC *)segue.destinationViewController;
        // set up the vc to run here
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSString *category = [self.categories objectAtIndex:indexPath.row];
        abtvc.category = category;
        abtvc.title = category;
        abtvc.navigationItem.rightBarButtonItem = nil;
    }
}
@end













