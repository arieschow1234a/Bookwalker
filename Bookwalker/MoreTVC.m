//
//  MoreTVC.m
//  Bookwalker
//
//  Created by Aries on 8/7/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "MoreTVC.h"
#import <Parse/Parse.h>
@interface MoreTVC ()
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation MoreTVC



- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:NO];
    if (![self.nameLabel.text isEqualToString:[PFUser currentUser][@"name"] ]) {
        [self fetchNameAndUserImageView];
    }
}



#pragma mark - Table view data source


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    if([segue.identifier isEqualToString:@"Show Login"]){
        [PFUser logOut];
    }
}

#pragma mark - helper method

- (void)fetchNameAndUserImageView
{
    PFUser *user = [PFUser currentUser];
    self.nameLabel.text = user[@"name"];
    PFFile *imagefile = user[@"file"];
    if (imagefile) {
        [imagefile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:imageData];
                self.userImageView.image = image;
            }
        }];
    }else{
        self.userImageView.image = nil;
    }
}


@end
