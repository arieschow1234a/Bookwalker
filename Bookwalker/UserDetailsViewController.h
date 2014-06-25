//
//  UserDetailsViewController.h
//  Bookwalker
//
//  Created by Aries on 22/6/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface UserDetailsViewController : UITableViewController <NSURLConnectionDelegate>

// UITableView header view properties
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;

@property (weak, nonatomic) IBOutlet UILabel *headerNameLabel;



// UITableView row data properties
@property (nonatomic, strong) NSArray *rowTitleArray;
@property (nonatomic, strong) NSMutableArray *rowDataArray;
@property (nonatomic, strong) NSMutableData *imageData;

// UINavigationBar button touch handler
- (void)logoutButtonTouchHandler:(id)sender;

@end