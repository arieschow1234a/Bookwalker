//
//  GoogleBooksFetcher.m
//  BooksAPI
//
//  Created by Aries on 22/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "BWHelper.h"



@implementation BWHelper
NSString *GoogleKey = @"AIzaSyDJ90e9-d3eJ4RWQtGMuwRVy1vKhrKHeSQ";

+ (NSURL *)GoogleURLforbookWithISBN:(NSString *)isbn
{

    NSString *query = [NSString stringWithFormat:@"https://www.googleapis.com/books/v1/volumes?q=isbn:%@&key=%@", isbn, GoogleKey];
    
    NSURL *url = [NSURL URLWithString:query];
    
    return url;
}

#pragma mark - Anobii fetcher

+ (NSURL *)AnobiiSearchURLforbookWithISBN:(NSString *)isbn
{
    
    NSString *query = [NSString stringWithFormat:@"http://www.anobii.com/search?s=1&keyword=%@", isbn];
    
    NSURL *url = [NSURL URLWithString:query];
    
    return url;
}


+ (NSURL *)AnobiiImageURLforbookWithId:(NSString *)bookId
{
    
    NSString *query = [NSString stringWithFormat:@"http://image.anobii.com/anobi/image_book.php?&item_id=%@", bookId];
    
    NSURL *url = [NSURL URLWithString:query];
    
    return url;
}

+ (NSURL *)AnobiiSiteURLforbookWithSite:(NSString *)site
{
    NSString *query = [NSString stringWithFormat:@"http://www.anobii.com%@", site];
    NSString *queryWithUnicode = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:queryWithUnicode];
    
    return url;
}


+ (NSString *)statusOfBook:(PFObject *)book
{
    NSNumber *statusNo = [[NSNumber alloc] init];
    statusNo = [book objectForKey:@"bookStatus"];
    NSString *bookStatus = [[NSString alloc] init];

    if ([statusNo  isEqual:@1]){
        bookStatus = @"Closed";
    }else if([statusNo isEqual:@2]){
        bookStatus = @"Pending";
    }else{
        bookStatus = @"Open";
    }
    return bookStatus;
}



@end
