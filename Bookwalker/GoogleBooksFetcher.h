//
//  GoogleBooksFetcher.h
//  BooksAPI
//
//  Created by Aries on 22/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoogleBooksFetcher : NSObject
+ (NSURL *)URLforbookWithISBN:(NSString *)isbn;

@end
