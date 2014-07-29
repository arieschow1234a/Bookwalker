//
//  MyRequestVC.h
//  Bookwalker
//
//  Created by Aries on 13/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface RequestMessagesVC : UIViewController

@property (nonatomic, strong) PFObject *requestBook;
@property (nonatomic, strong) NSString *requestBookId;

@end
