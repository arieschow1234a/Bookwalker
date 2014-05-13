//
//  MyRequestVC.m
//  Bookwalker
//
//  Created by Aries on 13/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "MyRequestVC.h"

@interface MyRequestVC () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic)NSArray *conversations;


@end

@implementation MyRequestVC



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self retrieveRequestOfABook];
}


- (PFObject *)myquest
{
    if (!_myquest) {
        _myquest = [[PFObject alloc] init];
    }
    return _myquest;
}

- (NSArray *)conversations
{
    if (!_conversations) _conversations = [[NSArray alloc] init];
    return _conversations;
        
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.conversations count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"comment"];
    
    
    PFObject *reply = [self.conversations objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat: @"%@: %@",[reply objectForKey:@"speakerName"], [reply objectForKey:@"comment"]];
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


# pragma mark - Helper methods

- (void)retrieveRequestOfABook
{

     PFRelation *relation = [self.myquest relationforKey:@"requestsRelation"];
     PFQuery *query = [relation query];
     [query orderByAscending:@"createdAt"];
     [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
         if (error) {
         // There was an error
         } else {
             self.conversations = objects;
             [self.tableView reloadData];
         }
     }];
    
    
}



@end
