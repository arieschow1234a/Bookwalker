//
//  WishListTVC.m
//  Bookwalker
//
//  Created by Aries on 21/7/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "WishListTVC.h"
#import <Parse/Parse.h>

@interface WishListTVC ()

@end

@implementation WishListTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.wishBookId){
        [self fetchWishListBooks];
    }
}



- (void)fetchWishListBooks
{
    PFQuery *query = [PFQuery queryWithClassName:@"Books"];
    [query whereKey:@"objectId" containedIn:self.wishBookId];
    [query orderByDescending:@"updatedAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }else{
            self.books = [[NSMutableArray alloc] initWithArray:objects];
        }
    }];
    
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
