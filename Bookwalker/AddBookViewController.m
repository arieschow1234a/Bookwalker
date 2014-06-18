//
//  AddBookViewController.m
//  Bookwalker
//
//  Created by Aries on 9/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "AddBookViewController.h"
#import "BWHelper.h"

@interface AddBookViewController ()

@property (nonatomic, strong) NSNumber *bookStatus;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *isbn10;
@property (nonatomic, strong) NSString *isbn13;
@property (nonatomic, strong) NSString *publisher;
@property (nonatomic, strong) NSString *publishDate;


@property (nonatomic) BOOL metaBookExist;
@property (nonatomic, strong) PFObject *metaBook;

@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UITextField *isbnTextField;
@property (weak, nonatomic) IBOutlet UITextView *titleTextView;
@property (weak, nonatomic) IBOutlet UITextView *authorTextView;
@property (weak, nonatomic) IBOutlet UITextField *noteField;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *imageURL;

@property (weak, nonatomic) IBOutlet UIView *editView;
@property (weak, nonatomic) IBOutlet UISwitch *statusSwitch;

@end

@implementation AddBookViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isbnTextField.placeholder = @"ISBN";
    
    if (self.book !=nil) {
        self.isbnTextField.hidden = YES;
        self.searchButton.hidden = YES;
        self.titleTextView.text = [self.book objectForKey:@"title"];
        self.authorTextView.text = [self.book objectForKey:@"author"];
        self.editView.hidden = NO;
        self.bookStatus = [self.book objectForKey:@"bookStatus"];
        
        if ([self.book[@"note"] isKindOfClass:[NSString class]]){
            self.noteField.text  = [NSString stringWithFormat:@"%@",self.book[@"note"]];
        }else{
             self.noteField.text = @"No note from holder";
        }

        [self setInitialStatusSwitch];
        
        // Get meta book info
        PFQuery *query = [PFQuery queryWithClassName:@"MetaBooks"];
        [query orderByDescending:@"updatedAt"];
        [query whereKey:@"objectId" equalTo:self.book[@"bookId"]];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *metaBook, NSError *error) {
            if (error){
                NSLog(@"Error %@ %@", error, [error userInfo]);
            }else{
                PFFile *imagefile = [metaBook objectForKey:@"file"];
                if (imagefile) {
                    [imagefile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                        if (!error) {
                            UIImage *image = [UIImage imageWithData:imageData];
                            self.image = image;
                        }
                    }];
                }
            }
        }];
    }

}

- (NSNumber *)bookStatus
{
    if (!_bookStatus) {
        _bookStatus = [[NSNumber alloc] init];
    }
    return _bookStatus;
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
   // [self.imageView sizeToFit];   // update the frame of the UIImageView
    
}


#pragma mark - Navigation
#define UNWIND_SEGUE_IDENTIFIER @"Do Add Book"

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:UNWIND_SEGUE_IDENTIFIER]){
        if (self.book != nil) {
            [self updateCopy];
        }else{
            if (self.metaBookExist) {
                [self createBook];
            }else{
                [self createMetaBook];
            }
        }
    }

}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:UNWIND_SEGUE_IDENTIFIER]) {
        NSString *note = self.noteField.text;
        NSString *title = self.titleTextView.text;
        NSString *author = self.authorTextView.text;
        
        if ([note length] == 0 ||[title length] == 0 || [author length] == 0 ){
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


#pragma mark - database

- (void)updateCopy
{
    self.book[@"note"] = self.noteField.text;
    self.book[@"bookStatus"] = self.bookStatus;
    [self.book saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
        }else if (error){
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }
    }];


}

- (void)createMetaBook
{
    
    //upload to parse
    PFObject *metaBook = [PFObject objectWithClassName:@"MetaBooks"];
    [metaBook setObject:self.titleTextView.text forKey:@"title"];
    [metaBook setObject:self.authorTextView.text forKey:@"author"];
    
    if (self.description) {
        [metaBook setObject:self.description forKey:@"description"];
    }
    if (self.isbn10) {
        [metaBook setObject:self.isbn10 forKey:@"isbn10"];
    }
    if (self.isbn13) {
        [metaBook setObject:self.isbn13 forKey:@"isbn13"];
    }
    if (self.publishDate) {
        [metaBook setObject:self.publishDate forKey:@"publishDate"];
    }
    if (self.publisher) {
        [metaBook setObject:self.publisher forKey:@"publisher"];
    }
    
    [metaBook saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            [self tryAgainAlert];
        }else{
            self.metaBook = metaBook;
            if (self.image != nil){
                [self uploadImageOfBook:metaBook];
            }else{
                [self createBook];
            }

        }
    }];

}

- (void)uploadImageOfBook:(PFObject *)book
{
    NSData *fileData;
    NSString *fileName;
    NSString *fileType;

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
                    
                    // Upload copy
                    [self createBook];
                    
                }
            }];
            
        }
    }];
}


- (void)createBook
{
    
    PFUser *user = [PFUser currentUser];
    PFObject *book = [PFObject objectWithClassName:@"Books"];
    [book setObject:[user objectId] forKey:@"holderId"];
    [book setObject:[user username] forKey:@"holderName"];
    [book setObject:@0 forKey:@"noOfRequests"];
    [book setObject:@0 forKey:@"bookStatus"];
    [book setObject:self.noteField.text forKey:@"note"];
    [book setObject:self.metaBook.objectId forKey:@"bookId"];
    [book setObject:self.titleTextView.text forKey:@"title"];
    [book setObject:self.authorTextView.text forKey:@"author"];
    if (self.isbn10) {
        [book setObject:self.isbn10 forKey:@"isbn10"];
    }
    if (self.isbn13) {
        [book setObject:self.isbn13 forKey:@"isbn13"];
    }
    [book saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
        }
    }];
    
}

#pragma mark - IBAction

- (IBAction)cancel:(id)sender {
 [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    
}

- (IBAction)updateBookStatus:(id)sender
{
    if (self.statusSwitch.on == YES) {
        self.bookStatus = @0;
    }else{
        self.bookStatus = @1;
    }
}

- (IBAction)SeachBook
{
    [self.isbnTextField resignFirstResponder];
    [self.noteField resignFirstResponder];
    
    NSString *isbn = [self.isbnTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if ([isbn length] == 11 || [isbn length] == 12 || [isbn length] < 10 || [isbn length] > 13 ){
        [self invalidISBNAlert];
    }else{
        [self fetchMetabook];
    }
}


#pragma mark - Fetchers

- (void)fetchMetabook
{
    NSString *isbn = [self.isbnTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"isbn13 = %@ OR isbn10 = %@", isbn, isbn];
    PFQuery *query = [PFQuery queryWithClassName:@"MetaBooks" predicate:predicate];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *metaBook, NSError *error) {
        if (error) {
            [self fetchAnobii];
        }else{
           // NSLog(@"fetch metabook");
            self.metaBookExist = YES;
            self.metaBook = metaBook;
            self.titleTextView.text = metaBook[@"title"];
            self.authorTextView.text = metaBook[@"author"];
            PFFile *imagefile = [metaBook objectForKey:@"file"];
            if (imagefile) {
                [imagefile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                    if (!error) {
                        UIImage *image = [UIImage imageWithData:imageData];
                        self.image = image;
                    }
                }];
            }
        }
    }];
    
}




- (void)fetchGoogle
{
    NSString *isbn = [self.isbnTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //NSString *isbn = @"9789867406392";
    NSURLRequest *request = [NSURLRequest requestWithURL:[BWHelper GoogleURLforbookWithISBN:isbn]];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    
    // create the session without specifying a queue to run completion handler on (thus, not main queue)
    // we also don't specify a delegate (since completion handler is all we need)
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                    completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
                                                        // this handler is not executing on the main queue, so we can't do UI directly here
        if (error){
            [self invalidISBNAlert];
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

- (void)fetchAnobii
{
    NSString *isbn = [self.isbnTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //NSString *isbn = @"9570329521";
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[BWHelper AnobiiSearchURLforbookWithISBN:isbn]];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                    completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
         
            if (error) {
                [self fetchGoogle];
            }else if (!error) {
                
                NSString *html = [NSString stringWithContentsOfURL:localfile encoding:NSUTF8StringEncoding error:NULL];
                if ([self fetchHTML:html LineContainwords:@"無效的ISBN"]) {
                    [self invalidISBNAlert];
                }else{
                    NSString *siteLine = [self fetchHTML:html LineContainwords:@"cover_image"];
                    
                    // Get site
                    NSString *site = [siteLine stringByReplacingOccurrencesOfString:@"<a class=\"cover_image\" href=\"" withString:@""];
                    site = [site stringByReplacingOccurrencesOfString:@"\">" withString:@""];
                    NSString *trimmedSite = [site stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    NSURL *siteURL = [BWHelper AnobiiSiteURLforbookWithSite:trimmedSite];
                    
                    [self fetchAnobiiSite:siteURL];
                    
                    //Get bookid, image, title from site
                    NSArray *str = [site componentsSeparatedByString:@"/"];
                    NSString *aBookId = str[4];
                    NSString *title = str[2];
                    NSRange underscore = [title rangeOfString:@"_"];
                    if (underscore.location) {
                        title = [title stringByReplacingOccurrencesOfString:@"_" withString:@" "];
                    }
                    //Author
                    NSString *authorLine = [self fetchHTML:html LineContainwords:@"作者為"];
                    NSString *author = [authorLine stringByReplacingOccurrencesOfString:@"</li>" withString:@""];
                    author = [author stringByReplacingOccurrencesOfString:@"作者為" withString:@""];
                    author = [author stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.titleTextView.text = title;
                        self.imageURL = [BWHelper AnobiiImageURLforbookWithId:aBookId];
                        self.authorTextView.text = author;
                    });
                }
        }
    }];
    [task resume]; // don't forget that all NSURLSession tasks start out suspended!
    
}

- (void)fetchAnobiiSite:(NSURL *)siteURL
{
    NSURLRequest *request = [NSURLRequest requestWithURL:siteURL];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                    completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
        if (!error) {
            
            
            NSString *html = [NSString stringWithContentsOfURL:localfile encoding:NSUTF8StringEncoding error:NULL];
            
            // NSLog(@"%@", html);
            
            //ISBN10, 13, publisher, publishDate
            NSRange AStart = [html lineRangeForRange:[html rangeOfString:@"ISBN-10:"]];
            NSRange AEnd = [html rangeOfString:@"</div><!-- end of book detail -->"];
            NSString *detail = [html substringWithRange:NSMakeRange(AStart.location+AStart.length, AEnd.location-AStart.location-AStart.length)];
          
            detail = [detail stringByReplacingOccurrencesOfString:@"</li>" withString:@" "];
            detail = [detail stringByReplacingOccurrencesOfString:@"</ul>" withString:@" "];
            detail = [detail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSArray *details = [[NSArray alloc] initWithArray:[detail componentsSeparatedByString:@"</strong>"]];
            NSMutableArray *detailsArray = [[NSMutableArray alloc]init];
            for (NSString *string in details) {
                if ([string length]) {
                    NSRange start = [string rangeOfString:@"<strong>"];
                    NSString *shortString = [string substringWithRange:NSMakeRange(start.location+start.length, [string length]-start.length-start.location)];
                    [detailsArray addObject:shortString];
                }
            }
            self.isbn10 = detailsArray[0];
            self.isbn13 = detailsArray[1];
            self.publisher = detailsArray[2];
            self.publishDate = detailsArray[3];
            
            // Desciption
            NSRange start = [html lineRangeForRange:[html rangeOfString:@"description_full"]];
            NSRange end = [html rangeOfString:@"<!-- end of description -->"];
            NSString *shortString = [html substringWithRange:NSMakeRange(start.location+start.length, end.location-start.location-start.length)];
            
            NSString *description = [shortString stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
            description = [description stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
            description = [description stringByReplacingOccurrencesOfString:@"<div>" withString:@""];
            description = [description stringByReplacingOccurrencesOfString:@"</div>" withString:@""];
            description = [description stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
            description = [description stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
            NSString *trimmedDescription = [description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            self.description = trimmedDescription;
            //Category
            
            
            
            
        }
    }];
    [task resume];
    
}

- (NSString *)fetchHTML:(NSString *)html LineContainwords:(NSString *)words
{
    NSRange range = [html lineRangeForRange:[html rangeOfString:words]];
    NSString *line = [NSString stringWithFormat:@"%@",[html substringWithRange:range]];
    return line;
}




#pragma mark - Setting the Image from the Image's URL

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
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


# pragma mark - Helper method

- (void)invalidISBNAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred!"
                                                        message:@"Please enter valid ISBN!"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView show];
    
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

- (void)setInitialStatusSwitch
{
    if ([self.bookStatus isEqualToNumber:@1]) {
        self.statusSwitch.on = NO;
    }else if ([self.bookStatus isEqualToNumber:@0]){
        self.statusSwitch.on = YES;
    }
}

- (void)tryAgainAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred!"
                                                        message:@"Please try again"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}


@end
