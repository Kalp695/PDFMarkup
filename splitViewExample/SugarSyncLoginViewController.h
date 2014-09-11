//
//  SugarSyncLoginWindowController.h
//
//  Created by Bill Culp on 8/26/12.
//  Copyright (c) 2012 Cloud9. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.

#import <UIKit/UIKit.h>
#import "SugarSyncClient.h"

/*
 *  SugarSyncLoginViewController display a modal login dialog to all the user to login to 
 *  SugarSync with userName and password credentials
 */
@interface SugarSyncLoginViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic, assign) IBOutlet UITextField *userNameField;
@property (nonatomic, assign) IBOutlet UITextField *passwordField;
@property (nonatomic, assign) IBOutlet UIButton *loginButton;
@property (nonatomic, assign) IBOutlet UILabel *error;
@property (nonatomic, assign) SugarSyncClient *client;

//typedef void (^completionHandler)(SugarSyncLoginStatus, NSError*);
//@property (nonatomic, copy) completionHandler completionHandler;

@property (nonatomic, copy) void (^completionHandler)(SugarSyncLoginStatus, NSError*);

-(IBAction)cancelClick:(id)sender;
-(IBAction)loginClick:(id)sender;


@end
