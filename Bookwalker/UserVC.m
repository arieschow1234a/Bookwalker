//
//  UserVC.m
//  Bookwalker
//
//  Created by Aries on 9/7/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "UserVC.h"
#import "BookDetailsViewController.h"

@interface UserVC ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *releaseLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickUpLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *otherBooksLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic)NSMutableArray *holdingBooks;
@end

@implementation UserVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchUserImage];
    [self fetchUserHoldingBooks];
    self.releaseLabel.text = [[NSString alloc]initWithFormat:@"Released Books: %lu",(unsigned long)[self.user[@"releasedBooksId"] count]];
    self.pickUpLabel.text = [[NSString alloc]initWithFormat:@"Picked Up Books: %lu",(unsigned long)[self.user[@"pickedUpBooksId"] count]];
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

- (void)setHoldingBooks:(NSMutableArray *)holdingBooks
{
    _holdingBooks = holdingBooks;
    self.otherBooksLabel.text = [[NSString alloc]initWithFormat:@"%lu available books from %@:",(unsigned long)[holdingBooks count], self.user[@"name"]];
    [self setHoldingBooksImage];
}



- (void)setHoldingBooksImage
{
    // Adjust scroll view content size, set background colour and turn on paging
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.scrollView.contentSize = self.holdingBooks? CGSizeMake(100 * [self.holdingBooks count], self.scrollView.frame.size.height) : CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    
    
    //self.scrollView.backgroundColor = [UIColor grayColor];
    
    // Generate content for our scroll view using the frame height and width as the reference point
    int i = 0;
    while (i<[self.holdingBooks count]) {
        
        UIImageView *views = [[UIImageView alloc]
                              initWithFrame:CGRectMake((self.scrollView.frame.size.width/ 3) *i, 0,
                                                       (self.scrollView.frame.size.width/ 3) -10, self.scrollView.frame.size.height)];
        views.backgroundColor=[UIColor yellowColor];
        
        PFObject *holdingBook = self.holdingBooks[i];
        PFFile *imagefile = holdingBook[@"file"];
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
    [self performSegueWithIdentifier:@"Show Book Details" sender:recognizer];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Show Book Details"]){
        BookDetailsViewController *bdvc = (BookDetailsViewController *)segue.destinationViewController;
        self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        UIGestureRecognizer *recognizer = sender;
        PFObject *book = self.holdingBooks[recognizer.view.tag];
        bdvc.book = book;
    }
}


#pragma mark - Helper method

- (void)fetchUserImage
{
    PFFile *imagefile = self.user[@"file"];
    if (imagefile) {
        [imagefile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:imageData];
                self.userImageView.image = image;
            }
        }];
    }
}

- (void)fetchUserHoldingBooks
{
    NSArray *holdingBooksId = self.user[@"holdingBooksId"];
    PFQuery *query = [PFQuery queryWithClassName:@"Books"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"objectId" containedIn:holdingBooksId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }else{
            if ([objects count]) {
                self.holdingBooks = [[NSMutableArray alloc] initWithArray:objects];
            }else{
                self.otherBooksLabel.text = [[NSString alloc]initWithFormat:@"No available books from %@", self.user[@"name"]];
            }
        }
    }];
}


@end
