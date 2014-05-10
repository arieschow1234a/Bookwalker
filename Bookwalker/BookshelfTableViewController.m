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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Add Book"]){
        AddBookViewController *abvc = (AddBookViewController *)segue.destinationViewController;
        // set up the vc to run here
    }
}

- (IBAction)addedPhoto:(UIStoryboardSegue *)segue
{
    if ([segue.sourceViewController isKindOfClass:[AddBookViewController class]]) {
        AddBookViewController *abvc = (AddBookViewController *)segue.sourceViewController;
    }
}



@end


