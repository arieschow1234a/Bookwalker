//
//  Notification.h
//  Bookwalker
//
//  Created by Aries on 1/7/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Notification : NSManagedObject

@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * receiverId;
@property (nonatomic, retain) NSString * receicerName;
@property (nonatomic, retain) NSString * bookObjectId;
@property (nonatomic, retain) NSString * bookTitle;
@property (nonatomic, retain) NSString * senderId;
@property (nonatomic, retain) NSString * senderName;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * content;

@end
