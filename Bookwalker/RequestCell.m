//
//  RequestCell.m
//  Bookwalker
//
//  Created by Aries on 11/6/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "RequestCell.h"

@implementation RequestCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)configureCellForReply:(PFObject *)reply
{
    self.speakerLabel.text = [NSString stringWithFormat:@"%@:", [reply objectForKey:@"speakerName"]];
    self.replyTextView.text = [NSString stringWithFormat: @"%@", [reply objectForKey:@"comment"]];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}



+ (CGFloat)heightForReplyText:(NSString *)replyText
 {
 const CGFloat topMargin = 5.0f;
 const CGFloat bottomMargin = 5.0f;
 const CGFloat minHeight = 40.0f;
 UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
 
 CGRect boundingBox = [replyText boundingRectWithSize:CGSizeMake(207, CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName: font} context:nil];
 
 return MAX(minHeight, CGRectGetHeight(boundingBox) + topMargin + bottomMargin);
 
 }
 


@end
