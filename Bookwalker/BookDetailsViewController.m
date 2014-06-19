//
//  BookDetailsViewController.m
//  Bookwalker
//
//  Created by Aries on 9/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "BookDetailsViewController.h"
#import "BWHelper.h"
#import "SendRequestVC.h"

@interface BookDetailsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *isbn10Label;
@property (weak, nonatomic) IBOutlet UILabel *isbn13Label;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (weak, nonatomic) IBOutlet UILabel *holderLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *preHolderLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *bookImageView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIView *noteView;
@property (weak, nonatomic) IBOutlet UIView *infoView;

@end

@implementation BookDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.infoView.hidden = YES;
    
    self.titleLabel.text = [self.book objectForKey:@"title"];
    self.authorLabel.text = [self.book objectForKey:@"author"];
    self.statusLabel.text = [[NSString alloc]initWithFormat:@"Status: %@",[BWHelper statusOfBook:self.book]];
    self.holderLabel.text = [[NSString alloc]initWithFormat:@"Holder: %@",[self.book objectForKey:@"holderName"]];
    
    if ([self.book[@"note"] isKindOfClass:[NSString class]]){
        self.noteLabel.text = [NSString stringWithFormat:@"Note: %@",self.book[@"note"]];
    }else{
        self.noteLabel.text = @"No note from holder";
    }
    if (self.book[@"previousHolderName"]) {
        NSArray *preHolders = self.book[@"previousHolderName"];
        NSString *result = [[preHolders valueForKey:@"description"] componentsJoinedByString:@", "];
        
        self.preHolderLabel.text = [NSString stringWithFormat:@"Prev: %@", result];
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"MetaBooks"];
    [query orderByDescending:@"updatedAt"];
    [query whereKey:@"objectId" equalTo:self.book[@"bookId"]];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *metaBook, NSError *error) {
        if (error) {
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }else{
            self.descriptionTextView.text = [metaBook objectForKey:@"description"];
            self.isbn10Label.text = [NSString stringWithFormat:@"ISBN-10: %@", [metaBook objectForKey:@"isbn10"]];
            self.isbn13Label.text = [NSString stringWithFormat:@"ISBN-13: %@", [metaBook objectForKey:@"isbn13"]];
            PFFile *imagefile = [metaBook objectForKey:@"file"];
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
        }
    }];

    
}




#pragma mark - navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Request Book"]){
        UINavigationController *navigationController = segue.destinationViewController;
        SendRequestVC *srvc = (SendRequestVC *)navigationController.topViewController;
        srvc.book = self.book;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"Request Book"]) {
        PFUser *user = [PFUser currentUser];
        
        if ([user.objectId isEqualToString:self.book[@"holderId"]]) {
            [self requestOwnBookAlert];
            return NO;
            
        }else if ([self.book[@"bookStatus"] isEqual:@1]){
            [self bookClosedAlert];
            return NO;
            
        }else if ([self.book[@"requesterId"] isEqual:user.objectId]){
            [self requestedAlreadyAlert];
            return NO;
        }
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}

- (IBAction)sentRequest:(UIStoryboardSegue *)segue
{
    if ([segue.sourceViewController isKindOfClass:[SendRequestVC class]]) {
      
    }
}

#pragma mark - IBActions

- (IBAction)switchSegment:(id)sender {
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            self.noteView.hidden = NO;
            self.infoView.hidden = YES;
            break;
        case 1:
            self.infoView.hidden = NO;
            self.noteView.hidden = YES;
            break;
        default:
            self.infoView.hidden = YES;
            self.noteView.hidden = NO;
            break;
    }
}




#pragma mark - Helper methods

-(void)requestOwnBookAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!!"
                                                        message:@"You can't requested your book!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)bookClosedAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!!"
                                                        message:@"This book is closed for sharing. You may contact the holder directly!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)requestedAlreadyAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!!"
                                                        message:@"You have requested this book already! Please check Request record."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}




@end
