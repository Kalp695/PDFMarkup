//
//  NetworkMenuController.h
//  splitViewExample
//
//  Created by mahesh babu on 22/07/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"
@interface NetworkMenuController : UIViewController
{
    IBOutlet UIButton * downloadButton;
    IBOutlet UIButton * deleteButton;
    IBOutlet UIButton * renameButton;
    IBOutlet UIButton * createFolderButton;
    IBOutlet UILabel * selectedLabel;
}

@property (strong, nonatomic) DetailViewController *detailViewController;

-(IBAction)action_download:(id)sender;
@end
