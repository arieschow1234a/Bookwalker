//
//  BookDetailsViewController.m
//  Bookwalker
//
//  Created by Aries on 9/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "BookDetailsViewController.h"

@interface BookDetailsViewController ()


@end

@implementation BookDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text = [[NSString alloc]initWithFormat:@"Title: %@", self.bookTitle];
     self.authorLabel.text = [[NSString alloc]initWithFormat:@"Author: %@", self.author];
     self.isbnLabel.text = [[NSString alloc]initWithFormat:@"ISBN: %@", self.isbn];
    self.holderLabel.text = [[NSString alloc]initWithFormat:@"Holder: %@", self.holder];
    self.noteLabel.text = [[NSString alloc]initWithFormat:@"Note: %@", self.note];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
