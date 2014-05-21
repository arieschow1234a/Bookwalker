//
//  GoogleBooksFetcher.m
//  BooksAPI
//
//  Created by Aries on 22/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "GoogleBooksFetcher.h"

@implementation GoogleBooksFetcher
NSString *key = @"AIzaSyDJ90e9-d3eJ4RWQtGMuwRVy1vKhrKHeSQ";

+ (NSURL *)URLforbookWithISBN:(NSString *)isbn
{

    NSString *query = [NSString stringWithFormat:@"https://www.googleapis.com/books/v1/volumes?q=isbn:%@&key=%@", isbn, key];
    
    NSURL *url = [NSURL URLWithString:query];
    
    return url;
}

@end
