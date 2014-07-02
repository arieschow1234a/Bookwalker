//
//  Notification+Parse.h
//  Bookwalker
//
//  Created by Aries on 1/7/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "Notification.h"
#import <Parse/Parse.h>
@interface Notification (Parse)

+ (Notification *)notificationWithParseObject:(PFObject *)parseObject
                       inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)loadNotificationsFromParseArray:(NSArray *)objects
               intoManagedObjectContext:(NSManagedObjectContext *)context;

@end
