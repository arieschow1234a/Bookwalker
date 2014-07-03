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
@property (weak, nonatomic) IBOutlet UITextView *noteTextView;
@property (weak, nonatomic) IBOutlet UILabel *holderLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *preHolderLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *bookImageView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIView *noteView;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIButton *wishButton;

@end

@implementation BookDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.infoView.hidden = YES;

    //If it is from notifications
    if (!self.book) {
        if (self.bookId) {
            PFQuery *query = [PFQuery queryWithClassName:@"Books"];
            [query getObjectInBackgroundWithId:self.bookId block:^(PFObject *object, NSError *error) {
                if (error){
                    NSLog(@"Error %@ %@", error, [error userInfo]);
                }else{
                    self.book = object;
                    [self bookSetting];
                }
            }];
        }
    }else{
        [self bookSetting];
    }
    
}

- (void)bookSetting
{
    self.titleLabel.text = [self.book objectForKey:@"title"];
    self.authorLabel.text = [self.book objectForKey:@"author"];
    self.statusLabel.text = [[NSString alloc]initWithFormat:@"Status: %@",[BWHelper statusOfBook:self.book]];
    self.holderLabel.text = [[NSString alloc]initWithFormat:@"%@",[self.book objectForKey:@"holderName"]];
    
    if ([self.book[@"note"] isKindOfClass:[NSString class]]){
        self.noteTextView.text = [NSString stringWithFormat:@"%@",self.book[@"note"]];
    }else{
        self.noteTextView.text = @"No note from holder";
    }
    if (self.book[@"previousHolderName"]) {
        NSArray *preHolders = self.book[@"previousHolderName"];
        NSString *result = [[preHolders valueForKey:@"description"] componentsJoinedByString:@", "];
        
        self.preHolderLabel.text = [NSString stringWithFormat:@"Journey:%@", result];
    }
    PFUser *user = [PFUser currentUser];
        if ([user[@"wishBookId"] containsObject:self.book.objectId]) {
        [self.wishButton setTitle:@"Remove" forState:UIControlStateNormal];
    }else{
        [self.wishButton setTitle:@"Wishlist" forState:UIControlStateNormal];
    }
    
    PFFile *imagefile = [self.book objectForKey:@"file"];
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
        }else if ([self.book[@"requesterId"] isKindOfClass:[NSString class]]){
            [self someoneRequestedAlert];
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

- (IBAction)addWishlist:(id)sender {
    PFUser *user = [PFUser currentUser];
    NSArray *wishes = @[self.book[@"title"], self.book[@"author"]];
    if ([self.wishButton.currentTitle isEqualToString:@"Wishlist"]){
        [self.wishButton setTitle:@"Remove" forState:UIControlStateNormal];
        [user addObjectsFromArray:wishes forKey:@"wishlist"];
        [user addObject:self.book.objectId forKey:@"wishBookId"];
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"add wish");
            }
        }];
    }else{
        [self.wishButton setTitle:@"Wishlist" forState:UIControlStateNormal];
        [user removeObject:self.book[@"title"] forKey:@"wishlist"];
        [user removeObject:self.book.objectId forKey:@"wishBookId"];
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"remove wish");
            }
        }];
    }
}



#pragma mark - Helper methods

-(void)requestOwnBookAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                        message:@"You can't request your own books!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)bookClosedAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                        message:@"This book is closed for sharing. You may contact the holder directly!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)requestedAlreadyAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"You have requested this book already! Please check Request."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)someoneRequestedAlert
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                                message:@"Someone have requested this book but we can notify you when the book is available."
                                                               delegate:nil
                                                      cancelButtonTitle:@"Put into Wishlist"
                                                      otherButtonTitles:@"Cancel", nil];
            [alertView show];
        }


@end
