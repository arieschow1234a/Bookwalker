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
#import "UserVC.h"

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

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic)NSMutableArray *previousHolder;
@property (weak, nonatomic) IBOutlet UIImageView *holderImageView;
@property (strong, nonatomic)PFUser *holder;
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
    [self fetchHolderImage];
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
    }
    if ([self.book[@"previousHolderId"] count]) {
        self.preHolderLabel.text = [NSString stringWithFormat:@"Previous reader:%lu", (unsigned long)[self.book[@"previousHolderId"] count]];
        PFQuery *query = [PFUser query];
        [query whereKey:@"objectId" containedIn:self.book[@"previousHolderId"]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                self.previousHolder = [[NSMutableArray alloc]initWithArray:objects];
            }
        }];
    }
    
    // Wish Button
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
- (void)fetchHolderImage
{
    NSString *holderId = self.book[@"holderId"];
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:holderId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *user, NSError *error) {
        self.holder = (PFUser *) user;
        PFFile *imagefile = self.holder[@"file"];
        if (imagefile) {
            [imagefile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                if (!error) {
                    UIImage *image = [UIImage imageWithData:imageData];
                    self.holderImageView.image = image;
                }
            }];
        }else{
            self.holderImageView.backgroundColor = [UIColor yellowColor];
        }
        [self.holderImageView setTag:1000000];
        [self.holderImageView setUserInteractionEnabled:YES];
        UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapping:)];
        [singleTap setNumberOfTapsRequired:1];
        [self.holderImageView addGestureRecognizer:singleTap];
    }];
}

#pragma mark - scroll view
- (void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    
    // next three lines are necessary for zooming
    //_scrollView.minimumZoomScale = 0.2;
    //_scrollView.maximumZoomScale = 2.0;
    //_scrollView.delegate = self;
    
    // next line is necessary in case self.image gets set before self.scrollView does
    // for example, prepareForSegue:sender: is called before outlet-setting phase
    //self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
}

- (void)setPreviousHolder:(NSMutableArray *)previousHolder
{
    _previousHolder = previousHolder;
    [self setJourneyImage];
}

- (void)setJourneyImage
{
    // Adjust scroll view content size, set background colour and turn on paging
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.scrollView.contentSize = self.previousHolder? CGSizeMake(60 * [self.previousHolder count], self.scrollView.frame.size.height) : CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    //self.scrollView.pagingEnabled=YES;
    //self.scrollView.backgroundColor = [UIColor grayColor];

    // Generate content for our scroll view using the frame height and width as the reference point
    int i = 0;
    while (i<[self.previousHolder count]) {
        
        UIImageView *views = [[UIImageView alloc]
                         initWithFrame:CGRectMake((self.scrollView.frame.size.width/ 3) *i, 0,
                                                  (self.scrollView.frame.size.width/ 3) -10, self.scrollView.frame.size.height)];
        views.backgroundColor=[UIColor yellowColor];
        PFObject *preHolder = self.previousHolder[i];
            PFFile *imagefile = preHolder[@"file"];
            if (imagefile) {
                [imagefile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                    if (!error) {
                        UIImage *image = [UIImage imageWithData:imageData];
                        views.image = image;
                        [views setTag:i];
                        [views setUserInteractionEnabled:YES];
                        UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapping:)];
                        [singleTap setNumberOfTapsRequired:1];
                        [views addGestureRecognizer:singleTap];
                        [self.scrollView addSubview:views];
                        
                    }
                }];
            }else{
                //Now assume all use FB log in so everyone gets a image else, use the next line.
                //views.image = [UIImage imageNamed:@"bookcover"];
                [views setTag:i];
                [views setUserInteractionEnabled:YES];
                UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapping:)];
                [singleTap setNumberOfTapsRequired:1];
                [views addGestureRecognizer:singleTap];
                [self.scrollView addSubview:views];
            }
    i++;
    }
}
-(void)singleTapping:(UIGestureRecognizer *)recognizer
{
    [self performSegueWithIdentifier:@"Show Holder" sender:recognizer];
}

/*
 - (void) buttonClicked: (id)sender
 {
 NSLog( @"Button clicked." );
 }
 Now modify the code creating the button and add the following code:
 [button addTarget: self
 action: @selector(buttonClicked:)
 forControlEvents: UIControlEventTouchDown];
*/

#pragma mark - navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    if([segue.identifier isEqualToString:@"Request Book"]){
        UINavigationController *navigationController = segue.destinationViewController;
        SendRequestVC *srvc = (SendRequestVC *)navigationController.topViewController;
        srvc.book = self.book;
        
    }else if([segue.identifier isEqualToString:@"Show Holder"]){
        UserVC *uvc = segue.destinationViewController;
        UIGestureRecognizer *recognizer = sender;
        
        if (recognizer.view.tag == 1000000) {
            uvc.user = self.holder;
            uvc.title = self.holder[@"name"];
        }else{
            PFUser *prevHolder = self.previousHolder[recognizer.view.tag];
            uvc.user = prevHolder;
            uvc.title = prevHolder[@"name"];
        }
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
        [user addObjectsFromArray:wishes forKey:@"interestedBook"];
        [user addObject:self.book.objectId forKey:@"wishBookId"];
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
               // NSLog(@"add wish");
            }
        }];
    }else{
        [self.wishButton setTitle:@"Wishlist" forState:UIControlStateNormal];
        [user removeObject:self.book[@"title"] forKey:@"interestedBook"];
        [user removeObject:self.book.objectId forKey:@"wishBookId"];
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
              //  NSLog(@"remove wish");
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
