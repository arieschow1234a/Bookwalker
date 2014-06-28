//
//  NotificationCell.m
//  Bookwalker
//
//  Created by Aries on 28/6/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "NotificationCell.h"

@implementation NotificationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)configureCellForNotification:(PFObject *)notification
{
    NSString *type = [[NSString alloc]initWithString:notification[@"type"]];
    NSString *senderName = [[NSString alloc]initWithString:notification[@"senderName"]];
    NSString *bookTitle = [[NSString alloc]initWithString:notification[@"bookTitle"]];
    
    if ([type isEqualToString:@"newRequest"]) {
        self.contentTextView.text = [NSString stringWithFormat:@"%@ requested your book: %@.",senderName, bookTitle];
        
    }else if ([type isEqualToString:@"declineRequest"]) {
        self.contentTextView.text = [NSString stringWithFormat:@"%@ declined your request on book: %@.",senderName, bookTitle];
    
    }else if ([type isEqualToString:@"cancelRequest"]) {
        self.contentTextView.text = [NSString stringWithFormat:@"%@ cancelled requesting your book: %@.",senderName, bookTitle];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
