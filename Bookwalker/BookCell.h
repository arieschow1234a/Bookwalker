//
//  EntryCell.h
//  Diary
//
//  Created by Aries on 16/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface BookCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet UIImageView *bookImageView;

//+ (CGFloat)heightForBook:(DiaryEntry *)entry;
- (void)configureCellForBook:(PFObject *)book;
@end
