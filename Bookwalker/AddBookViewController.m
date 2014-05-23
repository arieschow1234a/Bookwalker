//
//  AddBookViewController.m
//  Bookwalker
//
//  Created by Aries on 9/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "AddBookViewController.h"
#import "GoogleBooksFetcher.h"

@interface AddBookViewController ()

@property (weak, nonatomic) IBOutlet UITextField *isbnTextField;
@property (weak, nonatomic) IBOutlet UITextView *titleTextView;
@property (weak, nonatomic) IBOutlet UITextView *authorTextView;
@property (weak, nonatomic) IBOutlet UITextField *noteField;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *imageURL;


@end

@implementation AddBookViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.book !=nil) {
        self.isbnTextField.text = [self.book objectForKey:@"isbn"];
        self.titleTextView.text = [self.book objectForKey:@"title"];
        self.authorTextView.text = [self.book objectForKey:@"author"];
        self.noteField.text = [self.book objectForKey:@"note"];
    
        PFFile *imagefile = [self.book objectForKey:@"file"];
        if (imagefile) {
            [imagefile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                if (!error) {
                    UIImage *image = [UIImage imageWithData:imageData];
                    self.image = image;
                }
            }];
        }
    }

}

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image; // does not change the frame of the UIImageView
    [self.imageView sizeToFit];   // update the frame of the UIImageView
    
}


#pragma mark - Navigation
#define UNWIND_SEGUE_IDENTIFIER @"Do Add Book"

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:UNWIND_SEGUE_IDENTIFIER]){
        if (self.book != nil) {
            [self updateBook];
        }else{
            [self createBook];

        }
    }

}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:UNWIND_SEGUE_IDENTIFIER]) {
        NSString *isbn = [self.isbnTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *title = self.titleTextView.text;
        NSString *author = self.authorTextView.text;
        NSString *note = self.noteField.text;

        //need to check if ISBN is number
        if ([isbn length] == 0 || [title length] == 0 || [author length] == 0 || [note length] == 0){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                message:@"Make sure you enter a information"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
            [alertView show];
            return NO;
        }
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}


#pragma mark - helper method

- (void)updateBook
{
    self.book[@"note"] = self.noteField.text;
    [self.book saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"updated");
        }else if (error){
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }
    }];


}

- (void)createBook
{
    // need to change ISBN to number
    NSString *isbn = [self.isbnTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    PFUser *user = [PFUser currentUser];
    
    //upload to parse
    PFObject *book = [PFObject objectWithClassName:@"Books"];
    [book setObject:isbn forKey:@"isbn"];
    [book setObject:self.titleTextView.text forKey:@"title"];
    [book setObject:self.authorTextView.text forKey:@"author"];
    [book setObject:self.noteField.text forKey:@"note"];
    [book setObject:[user objectId] forKey:@"holder"];
    [book setObject:[user username] forKey:@"holderName"];
    [book setObject:@0 forKey:@"noOfRequests"];
    
    [book saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred!"
                                                                message:@"Please try again"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
            [alertView show];
            
        }else{
            if (self.image != nil){
                [self uploadImageOfBook:book];
            }else{
                // Saved the book in Parse and then save the book in user's booksRelation
                PFRelation *booksRelation = [user relationForKey:@"booksRelation"];
                [booksRelation addObject:book];
                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        NSLog(@"Error %@ %@", error, [error userInfo]);
                    }
                }];
            }

        }
    }];

}

- (void)uploadImageOfBook:(PFObject *)book
{
    NSData *fileData;
    NSString *fileName;
    NSString *fileType;
    PFUser *user = [PFUser currentUser];
    
    // if image, shrink it
    //  UIImage *newImage = [self resizeImage:self.image toWidth:320.0f andHeight:480.0f]; // of iphone
    // Upload the file itself
    fileData = UIImagePNGRepresentation(self.image);
    fileName = @"image.png";
    fileType = @"image";
    
    PFFile *file = [PFFile fileWithName:fileName data:fileData];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred!"
                                                                message:@"Please try again"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
            [alertView show];
            
        }else{
            [book setObject:file forKey:@"file"];
            [book setObject:fileType forKey:@"fileType"];
            
            [book saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    NSLog(@"Error %@ %@", error, [error userInfo]);
                }else{
                    self.image = nil;
                    // Saved the book in Parse and then save the book in user's booksRelation
                    PFRelation *booksRelation = [user relationForKey:@"booksRelation"];
                    [booksRelation addObject:book];
                    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (error) {
                            NSLog(@"Error %@ %@", error, [error userInfo]);
                        }
                    }];
                }
            }];
            
        }
    }];
}

- (UIImage *)resizeImage:(UIImage *)image toWidth:(float)width andHeight:(float)height
{
    CGSize newSize = CGSizeMake(width, height);
    CGRect newRectangle = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext(newSize);
    [self.image drawInRect:newRectangle];
    UIImage *resizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizeImage;
}

#pragma mark - IBAction

- (IBAction)cancel:(id)sender {
 [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    
}



- (IBAction)SeachBook
{
    [self.isbnTextField resignFirstResponder];
    
    NSString *isbn = self.isbnTextField.text;
    
  // for testing  NSString *isbn = @"9789867406392";
    NSURLRequest *request = [NSURLRequest requestWithURL:[GoogleBooksFetcher URLforbookWithISBN:isbn]];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    
    // create the session without specifying a queue to run completion handler on (thus, not main queue)
    // we also don't specify a delegate (since completion handler is all we need)
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                    completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
        // this handler is not executing on the main queue, so we can't do UI directly here
        if (error){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred!"
                                                                message:@"Please enter valid ISBN!"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
            [alertView show];
        }else{
            NSData *jsonResults = [NSData dataWithContentsOfURL:localfile];
            // convert it to a Property List (NSArray and NSDictionary)
            NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                                options:0
                                                                                  error:NULL];
            NSDictionary *item = [propertyListResults valueForKey:@"items"][0];
            NSDictionary *volumeInfo = [item valueForKey:@"volumeInfo"];
            NSString *author = [[volumeInfo valueForKey:@"authors"] objectAtIndex:0];
            NSString *title = [volumeInfo valueForKey:@"title"];
            NSString *thumbnail = [volumeInfo valueForKeyPath:@"imageLinks.thumbnail"];
            // so we must dispatch this back to the main queue
            dispatch_async(dispatch_get_main_queue(), ^{
                self.titleTextView.text = title;
                self.authorTextView.text = author;
               self.imageURL = [NSURL URLWithString:thumbnail];
            });
        }
    }];
    [task resume]; // don't forget that all NSURLSession tasks start out suspended!
    
    
    
}

#pragma mark - Setting the Image from the Image's URL

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    //    self.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.imageURL]]; // blocks main queue!
    [self startDownloadingImage];
}

- (void)startDownloadingImage
{
    self.image = nil;
    
    if (self.imageURL)
    {
        
        NSURLRequest *request = [NSURLRequest requestWithURL:self.imageURL];
        
        // another configuration option is backgroundSessionConfiguration (multitasking API required though)
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        
        // create the session without specifying a queue to run completion handler on (thus, not main queue)
        // we also don't specify a delegate (since completion handler is all we need)
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                        completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
                                                            // this handler is not executing on the main queue, so we can't do UI directly here
                                                            if (!error) {
                                                                if ([request.URL isEqual:self.imageURL]) {
                                                                    // UIImage is an exception to the "can't do UI here"
                                                                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localfile]];
                                                                    // but calling "self.image =" is definitely not an exception to that!
                                                                    // so we must dispatch this back to the main queue
                                                                    dispatch_async(dispatch_get_main_queue(), ^{ self.image = image; });
                                                                }
                                                            }
                                                        }];
        [task resume]; // don't forget that all NSURLSession tasks start out suspended!
    }
}






@end
