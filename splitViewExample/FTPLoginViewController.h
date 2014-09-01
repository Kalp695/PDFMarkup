//
//  FTPLoginViewController.h
//  PDFMarkUP
//
//  Created by ravi on 31/08/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRRequest+_UserData.h"
#import "BRRequestLogin.h"
#import "BRRequestListDirectory.h"

@interface FTPLoginViewController : UIViewController<UITextFieldDelegate,BRRequestDelegate>
{
    BRRequestLogin *login;
   // BRRequestListDirectory *login;

}
-(IBAction)cancelClick:(id)sender;
@property(nonatomic,retain)IBOutlet UITextField * hostTextField;
@property(nonatomic,retain)IBOutlet UITextField * username;
@property(nonatomic,retain)IBOutlet UITextField * password;

@end
