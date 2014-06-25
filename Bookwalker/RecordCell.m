//
//  RecordCell.m
//  Bookwalker
//
//  Created by Aries on 8/6/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "RecordCell.h"

@implementation RecordCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)configureCellForBook:(PFObject *)book
{
    PFUser *user = [PFUser currentUser];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    if ([book[@"giverId"] isEqualToString:user.objectId]) {
        self.recordTextView.text = [NSString stringWithFormat:@"You shared %@ with %@", book[@"bookTitle"], book[@"receiverName"]];
    }else if ([book[@"receiverId"] isEqualToString:user.objectId]){
       self.recordTextView.text = [NSString stringWithFormat:@"%@ shared %@ with you", book[@"giverName"], book[@"bookTitle"]];
    }

}


/*
+ (CGFloat)heightForBook:(PFObject *)book
{
 const CGFloat topMargin = 35.0f;
 const CGFloat bottomMargin = 150.0f;
 const CGFloat minHeight = 106.0f;
 
 UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
 
 CGRect boundingBox = [ boundingRectWithSize:CGSizeMake(202, CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName: font} context:nil];
 
 return MAX(minHeight, CGRectGetHeight(boundingBox) + topMargin + bottomMargin);
 
}
*/

@end
