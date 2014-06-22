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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self checkInternet];
    [self fetchAllBooks];    
}




#pragma mark - helper method

- (void)fetchAllBooks
{
        PFQuery *query = [PFQuery queryWithClassName:@"Books"];
        [query orderByDescending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error){
                NSLog(@"Error %@ %@", error, [error userInfo]);
            }else{
                self.books = [[NSMutableArray alloc] initWithArray:objects];
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
