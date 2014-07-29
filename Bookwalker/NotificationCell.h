//
//  NotificationCell.h
//  Bookwalker
//
//  Created by Aries on 28/6/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Notification+Parse.h"

@interface NotificationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

- (void)configureCellForNotification:(Notification *)notification;

@end
