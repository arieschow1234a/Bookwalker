//
//  AccountVC.m
//  Bookwalker
//
//  Created by Aries on 22/6/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "AccountVC.h"
#import <Parse/Parse.h>
#import "EditAccountVC.h"

@interface AccountVC ()
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@property (nonatomic, strong) NSMutableData *imageData;
@end

@implementation AccountVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self retrieveImage];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    PFUser *user = [PFUser currentUser];
    self.nicknameLabel.text = user[@"name"];
    self.emailLabel.text = user[@"email"];
    NSLog(@"%@", user[@"email"]);

}

#pragma mark - NSURLConnectionDataDelegate

/* Callback delegate methods used for downloading the user's profile picture */

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // As chuncks of the image are received, we build our data file
    [self.imageData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // All data has been downloaded, now we can set the image in the header image view
    self.headerImageView.image = [UIImage imageWithData:self.imageData];
    
    // Add a nice corner radius to the image
    self.headerImageView.layer.cornerRadius = 5.0f;
    self.headerImageView.layer.masksToBounds = YES;
}

- (void)retrieveImage
{
    
    // Download the user's facebook profile picture
    self.imageData = [[NSMutableData alloc] init]; // the data will be loaded in here
    
    if ([[PFUser currentUser] objectForKey:@"profile"][@"pictureURL"]) {
        NSURL *pictureURL = [NSURL URLWithString:[[PFUser currentUser] objectForKey:@"profile"][@"pictureURL"]];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:pictureURL
                                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                              timeoutInterval:2.0f];
        // Run network request asynchronously
        NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
        if (!urlConnection) {
            NSLog(@"Failed to download picture");
        }
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Edit Account"]){
        UINavigationController *navigationController = segue.destinationViewController;
        EditAccountVC *eavc = (EditAccountVC *)navigationController.topViewController;
        eavc.image = self.headerImageView.image;
        eavc.nickname = self.nicknameLabel.text;
        eavc.email = self.emailLabel.text;
    }
}

- (IBAction)editedAccount:(UIStoryboardSegue *)segue
{
    if ([segue.sourceViewController isKindOfClass:[EditAccountVC class]]) {

    }
}

@end
