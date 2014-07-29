//
//  TestingCDTVC.m
//  Bookwalker
//
//  Created by Aries on 1/7/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "TestingCDTVC.h"
#import "Notification.h"
#import "DatabaseAvailability.h"

@interface TestingCDTVC ()

@end

@implementation TestingCDTVC

- (void)awakeFromNib
{
    NSLog(@"Testing HI");
    [[NSNotificationCenter defaultCenter] addObserverForName:DatabaseAvailabilityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      NSLog(@"note HI");
                                                      NSLog(@"%@", note.userInfo[DatabaseAvailabilityContext]);
                                                      self.managedObjectContext = note.userInfo[DatabaseAvailabilityContext];
                                                  }];
      
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    NSLog(@"Set managedObjectContext at testing");
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Notification"];
    request.predicate = nil;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt"
                                                              ascending:YES
                                                               selector:@selector(localizedStandardCompare:)]];
    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    NSLog(@"self.fetchResultController %@", self.fetchedResultsController);
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Notification Cell"];
    
    Notification *notification = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSLog(@"%@", notification);
    cell.textLabel.text = notification.type;
    cell.detailTextLabel.text = notification.bookTitle;
    
    return cell;
}

@end
