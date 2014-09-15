//
//  MasterViewController.h
//  splitViewExample
//
//  Created by CFA IT on 7/18/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeftTableViewCell.h"
@class DetailViewController;

@interface MasterViewController : UITableViewController
{
    CGRect activityIndicatorframe;
    NSMutableArray * bgProcessArray;
}
@property (strong, nonatomic) DetailViewController *detailViewController;
@property(nonatomic,assign) BOOL popStatus;
@property (strong, nonatomic)  NSMutableArray *_objects;
@property (strong, nonatomic) NSMutableArray * leftArrayTitles;
@property (strong, nonatomic) NSMutableArray * leftImagesArray;
@property (strong, nonatomic) NSMutableArray * accountsArray;
@property (strong, nonatomic) NSMutableArray *arrUseraccounts;
@property (strong, nonatomic) NSMutableArray * accountsImagesArray;

-(void)insertNewSection:(id)sender;
+ (MasterViewController *) sharedInstance;
@end
