//
//  BookDetailsViewController.h
//  Bookwalker
//
//  Created by Aries on 9/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface BookDetailsViewController : UIViewController
@property (strong, nonatomic) NSString *bookTitle;
@property (strong, nonatomic) NSString *author;
@property (strong, nonatomic) NSString *isbn;
@property (strong, nonatomic) NSString *note;
@property (strong, nonatomic) NSString *holder;
@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) NSString *holderId;


@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *isbnLabel;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (weak, nonatomic) IBOutlet UILabel *holderLabel;




@end
