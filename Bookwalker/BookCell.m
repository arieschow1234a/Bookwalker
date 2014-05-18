//
//  EntryCell.m
//  Diary
//
//  Created by Aries on 16/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "BookCell.h"

@interface BookCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bookImageView;



@end
@implementation BookCell

- (void)configureCellForBook:(PFObject *)book
{
    
    self.titleLabel.text = [book objectForKey:@"title"];
    self.authorLabel.text = [book objectForKey:@"author"];
    self.bookImageView.image = [UIImage imageNamed:@"bookcover"];

    
    /*
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, MMMM d yyyy"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:entry.date];
    
    self.dateLabel.text = [dateFormatter stringFromDate:date];
    */
    
}


/*
 + (CGFloat)heightForEntry:(DiaryEntry *)entry
 {
 const CGFloat topMargin = 35.0f;
 const CGFloat bottomMargin = 150.0f;
 const CGFloat minHeight = 106.0f;
 
 UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
 
 CGRect boundingBox = [entry.body boundingRectWithSize:CGSizeMake(202, CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName: font} context:nil];
 
 return MAX(minHeight, CGRectGetHeight(boundingBox) + topMargin + bottomMargin);
 
 }
 */


@end
























