//
//  AllBooksTVC.m
//  Bookwalker
//
//  Created by Aries on 15/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "AllBooksTVC.h"
#import "BookDetailsViewController.h"
#import "Reachability.h"
#import "AppDelegate.h"

@interface AllBooksTVC ()
{
    AppDelegate *appdelegate;
}

@end

@implementation AllBooksTVC

- (void)viewDidLoad
{
    //reachaibility
    appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [super viewDidLoad];
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser) {
        [self performSegueWithIdentifier:@"Show Login" sender:self];
    }
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(changeBooks) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:NO];
    [self checkInternet];
    if (self.category == nil) {
        [self fetchAllBooks];
    }else{
        [self fetchCategoryBooks];
    }

}




#pragma mark - helper method


-(void)changeBooks
{
    if (self.category == nil) {
        [self fetchAllBooks];
    }else{
        [self fetchCategoryBooks];
    }
}


- (void)fetchAllBooks
{
        PFQuery *query = [PFQuery queryWithClassName:@"Books"];
        [query orderByDescending:@"updatedAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error){
                NSLog(@"Error %@ %@", error, [error userInfo]);
            }else{
                self.books = [[NSMutableArray alloc] initWithArray:objects];
                [self.refreshControl endRefreshing];
            }
        }];
    
}

- (void)fetchCategoryBooks
{
    PFQuery *query = [PFQuery queryWithClassName:@"Books"];
    [query orderByDescending:@"updatedAt"];
    [query whereKey:@"categories" equalTo:self.category];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }else{
            self.books = [[NSMutableArray alloc] initWithArray:objects];
            [self.refreshControl endRefreshing];
        }
    }];
    
}


- (void)checkInternet
{
    if (appdelegate.isInternetAvailable == NO) {
        NSLog(@"");
    }
}



@end
