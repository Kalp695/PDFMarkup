//
//  DocumentsEditViewController.h
//  splitViewExample
//
//  Created by ravi on 25/07/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MasterViewController.h"

@interface DocumentsEditViewController : UIViewController
{
    IBOutlet UIButton * uploadButton;
    IBOutlet UIButton * deleteButton;
    IBOutlet UIButton * renameButton;
    IBOutlet UIButton * createFolderButton;
    IBOutlet UIButton * mailToButton;
    IBOutlet UIButton * openInOtherFolder;

    IBOutlet UILabel * selectedLabel;

}

@property (strong, nonatomic) DetailViewController *detailViewController;

-(IBAction)action_btn:(id)sender;


@end
