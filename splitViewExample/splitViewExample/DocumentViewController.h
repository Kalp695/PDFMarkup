//
//  DocumentViewController.h
//  splitViewExample
//
//  Created by ravi on 23/07/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DocumentViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    // Code For Documents View
    
    IBOutlet UIView * documentView;
    IBOutlet UIScrollView * documentScrollView;
    NSMutableArray * documenmtsArray;

}

// Code For Documents View

-(IBAction)gridViewButton_click:(id)sender;
-(IBAction)tableViewButton_click:(id)sender;

@property(nonatomic,retain) IBOutlet UITableView * documentsTableView;
@property(nonatomic,retain) IBOutlet UIButton * documentsGridButton;


@end
