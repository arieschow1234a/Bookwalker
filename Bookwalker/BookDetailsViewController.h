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
@property (strong, nonatomic) PFObject *book;
@property (strong, nonatomic) NSString *bookId;
@end
