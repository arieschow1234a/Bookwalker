//
//  NotificationCell.m
//  Bookwalker
//
//  Created by Aries on 28/6/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "NotificationCell.h"

@interface NotificationCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) UIImage *image;
@end


@implementation NotificationCell
@synthesize imageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)configureCellForNotification:(Notification *)notification
{
    NSString *type = [[NSString alloc]initWithString:notification.type];
    NSString *senderName = [[NSString alloc]initWithString:notification.senderName];
    NSString *bookTitle = [[NSString alloc]initWithString:notification.bookTitle];
    
    
    
    if ([type isEqualToString:@"newRequest"]) {
        self.contentTextView.text = [NSString stringWithFormat:@"%@ requested your book: %@.",senderName, bookTitle];
        
    }else if ([type isEqualToString:@"declineRequest"]) {
        self.contentTextView.text = [NSString stringWithFormat:@"%@ declined your request of book: %@.",senderName, bookTitle];
    
    }else if ([type isEqualToString:@"cancelRequest"]) {
        self.contentTextView.text = [NSString stringWithFormat:@"%@ cancelled requesting your book: %@.",senderName, bookTitle];
    }
    
    NSString *senderId = notification.senderId;
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:senderId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        PFFile *imagefile = object[@"file"];
        if (imagefile) {
            [imagefile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                if (!error) {
                    UIImage *image = [UIImage imageWithData:imageData];
                    self.image = image;
                }
            }];
        }
    }];
   
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Image
- (UIImage *)image
{
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    // [self.imageView sizeToFit];   // update the frame of the UIImageView
    
}



@end
