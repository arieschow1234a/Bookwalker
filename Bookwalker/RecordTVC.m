//
//  RecordTVC.m
//  Bookwalker
//
//  Created by Aries on 8/6/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "RecordTVC.h"
#import <Parse/Parse.h>
#import "RecordCell.h"

@interface RecordTVC ()
@property (strong, nonatomic) NSMutableArray *records;
@end

@implementation RecordTVC

- (void)setRecords:(NSMutableArray *)records
{
    _records = records;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    [self retrieveRecord];
    [self.navigationController.navigationBar setHidden:NO];
    
    
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
    return [self.records count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *book = [self.records objectAtIndex:indexPath.row];
    // Configure the cell...
    static NSString *CellIdentifier = @"record";
    RecordCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[RecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell configureCellForBook:book];
    
    return cell;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
 
}



# pragma mark - Helper methods

- (void)retrieveRecord
{
    // My requests of others' books
    PFUser *user = [PFUser currentUser];
    PFQuery *giver = [PFQuery queryWithClassName:@"Records"];
    [giver whereKey:@"giverId" equalTo:user.objectId];
    
    PFQuery *receiver = [PFQuery queryWithClassName:@"Records"];
    [receiver whereKey:@"receiverId" equalTo:user.objectId];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[giver,receiver]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }else{
            self.records = [[NSMutableArray alloc] initWithArray:objects];
            [self.tableView reloadData];
            NSLog(@"%@", self.records);
        }
    }];
}






@end
