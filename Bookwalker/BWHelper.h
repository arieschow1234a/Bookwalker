//
//  GoogleBooksFetcher.h
//  BooksAPI
//
//  Created by Aries on 22/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface BWHelper : NSObject
+ (NSURL *)URLforbookWithISBN:(NSString *)isbn;
+ (NSString *)statusOfBook:(PFObject *)book;

@end
