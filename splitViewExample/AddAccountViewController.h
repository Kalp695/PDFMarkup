//
//  AddAccountViewController.h
//  splitViewExample
//
//  Created by ravi on 21/07/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "DropboxManager.h"
#import <GLKit/GLKit.h>
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"

@class DBRestClient;

@interface AddAccountViewController : UIViewController
{
    AddAccountViewController * addAccount;
    
}


-(IBAction)accountsButtonAction:(id)sender;
@end
