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
+ (NSString *)statusOfBook:(PFObject *)book;
+ (NSURL *)GoogleURLforbookWithISBN:(NSString *)isbn;
+ (NSURL *)AnobiiSearchURLforbookWithISBN:(NSString *)isbn;
+ (NSURL *)AnobiiImageURLforbookWithId:(NSString *)bookId;
+ (NSURL *)AnobiiSiteURLforbookWithSite:(NSString *)site;

@end
