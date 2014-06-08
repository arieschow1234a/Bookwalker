//
//  RecordCell.h
//  Bookwalker
//
//  Created by Aries on 8/6/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface RecordCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *recordTextView;

//+ (CGFloat)heightForBook:(PFObject *)book;
- (void)configureCellForBook:(PFObject *)book;

@end
