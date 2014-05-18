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






@end
