//
//  RequestCell.h
//  Bookwalker
//
//  Created by Aries on 11/6/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface RequestCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *speakerLabel;
@property (weak, nonatomic) IBOutlet UITextView *replyTextView;

- (void)configureCellForReply:(PFObject *)reply;
+ (CGFloat)heightForReplyText:(NSString *)replyText;

@end
