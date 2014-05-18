//
//  AllBooksTVC.m
//  Bookwalker
//
//  Created by Aries on 15/5/14.
//  Copyright (c) 2014年 Aries. All rights reserved.
//

#import "AllBooksTVC.h"
#import "BookDetailsViewController.h"


@interface AllBooksTVC ()

@end

@implementation AllBooksTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchAllBooks];
    
}



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"show Details"]){
        BookDetailsViewController *bdvc = (BookDetailsViewController *)segue.destinationViewController;
        // set up the vc to run here
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        PFObject *book = [self.books objectAtIndex:indexPath.row];
        
        bdvc.objectId = book.objectId;
        
        bdvc.title = [book objectForKey:@"title"];
        
        bdvc.bookTitle = [book objectForKey:@"title"];
        bdvc.author = [book objectForKey:@"author"];
        bdvc.isbn = [book objectForKey:@"isbn"];
        bdvc.note = [book objectForKey:@"note"];
        bdvc.holder= [book objectForKey:@"holderName"];
        bdvc.holderId = [book objectForKey:@"holder"];
        
        
    }
}


#pragma mark - helper method

- (void)fetchAllBooks
{
    PFQuery *query = [PFQuery queryWithClassName:@"Books"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }else{
            self.books = [[NSMutableArray alloc] initWithArray:objects];
        }
    }];
}

@end
