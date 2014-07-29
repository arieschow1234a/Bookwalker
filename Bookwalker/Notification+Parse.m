//
//  Notification+Parse.m
//  Bookwalker
//
//  Created by Aries on 1/7/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "Notification+Parse.h"


@implementation Notification (Parse)

+ (Notification *)notificationWithParseObject:(PFObject *)parseObject
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    Notification *notification = nil;
    
    NSString *objectId = parseObject.objectId;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Notification"];
    request.predicate = [NSPredicate predicateWithFormat:@"objectId = %@", objectId];

    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!matches || error || ([matches count] > 1)) {
        NSLog(@"Notification+Parse: error, do not insert into contest");
        // handle error
    } else if ([matches count]) {
        notification = [matches firstObject];
        NSLog(@"Notification+Parse: already exist");
    } else {
        if ([parseObject[@"type"] length]) {
            NSLog(@"Notification+Parse: insert the notification");
            
            NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:@"notifiBadgge"];
            if (number == nil) {
                number = [NSNumber numberWithInt:0];
            }
            int value = [number intValue];
            number = [NSNumber numberWithInt:value + 1];
            [[NSUserDefaults standardUserDefaults] setValue:number forKey:@"notifiBadgge"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
            notification = [NSEntityDescription insertNewObjectForEntityForName:@"Notification"
                                                         inManagedObjectContext:context];
            notification.objectId = parseObject.objectId;
            notification.updatedAt = parseObject.updatedAt;
            notification.createdAt = parseObject.createdAt;
            notification.senderId = parseObject[@"senderId"];
            notification.senderName = parseObject[@"senderName"];
            notification.receiverId = parseObject[@"receiverId"];
            notification.receicerName = parseObject[@"receicerName"];
            notification.type = parseObject[@"type"];
            notification.bookTitle = parseObject[@"bookTitle"];
            notification.bookObjectId = parseObject[@"bookObjectId"];

        }
    }
    
    return notification;
}

+ (void)loadNotificationsFromParseArray:(NSArray *)objects
         intoManagedObjectContext:(NSManagedObjectContext *)context
{
    // check all the objects at once by their id and return a list and use that list to insert into context
    
    
    for (PFObject *notification in objects) {
        [self notificationWithParseObject:notification inManagedObjectContext:context];
    }

}

@end
