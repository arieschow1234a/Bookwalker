//
//  EntryCell.m
//  Diary
//
//  Created by Aries on 16/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "BookCell.h"

@interface BookCell ()



@end
@implementation BookCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _bookImageView = [[UIImageView alloc] initWithFrame:(CGRectMake(20, 5, 60, 75))];
        
        _titleLabel = [[UILabel alloc] initWithFrame:(CGRectMake(88, 14, 218, 21))];
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textAlignment = NSTextAlignmentNatural;
        
        _authorLabel = [[UILabel alloc] initWithFrame:(CGRectMake(88, 43, 218, 21))];
        _authorLabel.font = [UIFont systemFontOfSize:15];
        _authorLabel.textAlignment = NSTextAlignmentNatural;
        
        [self.contentView addSubview:_bookImageView];
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_authorLabel];
    }
    
    return self;
}



- (void)configureCellForBook:(PFObject *)book
{
    
    self.titleLabel.text = [book objectForKey:@"title"];
    self.authorLabel.text = [book objectForKey:@"author"];

    PFFile *imagefile = [book objectForKey:@"file"];
    if (imagefile) {
        [imagefile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:imageData];
                self.bookImageView.image = image;
            }
        }];
    }else{
        self.bookImageView.image = [UIImage imageNamed:@"bookcover"];
    }
    

    
    
    
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
























