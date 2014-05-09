//
//  AddBookViewController.h
//  Bookwalker
//
//  Created by Aries on 9/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface AddBookViewController : UIViewController
- (IBAction)cancel:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *isbnField;
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextField *authorField;
@property (weak, nonatomic) IBOutlet UITextField *noteField;
@property (strong, nonatomic) PFObject *book;

@end
