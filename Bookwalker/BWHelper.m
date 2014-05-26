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

+ (NSURL *)URLforbookWithISBN:(NSString *)isbn
{

    NSString *query = [NSString stringWithFormat:@"https://www.googleapis.com/books/v1/volumes?q=isbn:%@&key=%@", isbn, GoogleKey];
    
    NSURL *url = [NSURL URLWithString:query];
    
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
