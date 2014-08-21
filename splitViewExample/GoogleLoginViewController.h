//
//  GoogleLoginViewController.h
//  splitViewExample
//
//  Created by mahesh babu on 05/08/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"
@interface GoogleLoginViewController : UIViewController
{
    IBOutlet UIWebView *webview;
    NSMutableData *receivedData;
}
-(IBAction)googleCancelButton_click:(id)sender;
@property (nonatomic, retain) IBOutlet UIWebView *webview;
@property (nonatomic, retain) NSString *isLogin;
@property (assign, nonatomic) Boolean isReader;
@property (nonatomic, retain) GTLServiceDrive *driveService;
+(GoogleLoginViewController*)getSharedInstance;

@end
