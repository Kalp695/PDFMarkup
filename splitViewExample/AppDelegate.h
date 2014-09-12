//
//  AppDelegate.h
//  splitViewExample
//
//  Created by CFA IT on 7/18/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import <BoxSDK/BoxSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,DBSessionDelegate,DBNetworkRequestDelegate>
{
    NSString *relinkUserId;
    
}
@property (strong,nonatomic)  NSString *documentStatus;
@property (strong,nonatomic)  NSString *appdelRefreshToken;

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic)  NSMutableArray *arrDropboxUserids;
@property (strong,nonatomic) NSDictionary *dicUserdetails;
@property (strong,nonatomic) NSDictionary *dicgoogleUserdetails;

@property (strong,nonatomic)  NSMutableArray *boxSelectedFiles;
@property (assign, nonatomic)  int accountIndex;
@property (strong,nonatomic)  NSString *ftpDownloadpath;

// downloading check
@property (strong,nonatomic)  NSString * bgRunningStatus;

- (void)setRefreshTokenInKeychain:(NSString *)refreshToken;

+ (AppDelegate *)sharedInstance;


@end
