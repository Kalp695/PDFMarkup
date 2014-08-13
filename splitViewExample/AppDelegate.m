//
//  AppDelegate.m
//  splitViewExample
//
//  Created by CFA IT on 7/18/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import "AppDelegate.h"
#import <GLKit/GLKit.h>
#import "KeychainItemWrapper.h"

#define REFRESH_TOKEN_KEY   (@"T4BAPIHmmyJ4J5fXzAfwJFxe7RXeHJhe")
@interface AppDelegate ()

@property (nonatomic, readwrite, strong) KeychainItemWrapper *keychain;
- (void)boxAPITokensDidRefresh:(NSNotification *)notification;

@end

@implementation AppDelegate
@synthesize arrDropboxUserids;
@synthesize dicUserdetails;
@synthesize documentStatus;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    

    // Override point for customization after application launch.
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    splitViewController.delegate = (id)navigationController.topViewController;
    [splitViewController setValue:[NSNumber numberWithFloat:200.0] forKey:@"_masterColumnWidth"];
    
    
    NSString *dropBoxAppKey = @"axtmpnh9jmisgme";
	NSString *dropBoxAppSecret = @"wap0sdsxnldywwn";

  //  NSString *dropBoxAppKey = @"uw5h7hzofid6igu";
//	NSString *dropBoxAppSecret = @"u4x5e08gi7yqz2z";
    NSString *root = kDBRootDropbox;
	
    DBSession* session =
    [[DBSession alloc] initWithAppKey:dropBoxAppKey appSecret:dropBoxAppSecret root:root];
	session.delegate = self;
	[DBSession setSharedSession:session];
    
	[DBRequest setNetworkRequestDelegate:self];
    arrDropboxUserids = [[NSMutableArray alloc] init];
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"Dropboxuser"] !=nil) {
        
        
        dicUserdetails = [[NSUserDefaults standardUserDefaults] valueForKey:@"Dropboxuser"];
    }
    else
    {
        [[DBSession sharedSession] unlinkAll];

    }
    
    
    //setting up app name
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"appStartProperty" ofType:@"plist"];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:  @"Documents"];
    NSString *savedplistPath=[NSString stringWithFormat:@"%@/appStartProperty.plist",docsDir];
    //dictionary = [[NSDictionary alloc]initWithObjectsAndKeys:appName,@"startApp", nil];
    [dictionary writeToFile:savedplistPath atomically:YES];
    //end setting up app name

    
    
    // Box
    [BoxSDK sharedSDK].OAuth2Session.clientID = @"14yzd7a5wb17xmsdc0ti2resb5e1pvbr";
    [BoxSDK sharedSDK].OAuth2Session.clientSecret = @"RHRjNZV04vj5w0ca8BskgEkuFNrTd1Lu";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(boxAPITokensDidRefresh:)
                                                 name:BoxOAuth2SessionDidRefreshTokensNotification
                                               object:[BoxSDK sharedSDK].OAuth2Session];
    
    
    self.keychain = [[KeychainItemWrapper alloc] initWithIdentifier:REFRESH_TOKEN_KEY accessGroup:nil];
    
    id storedRefreshToken = [self.keychain objectForKey:(__bridge id)kSecValueData];
    if (storedRefreshToken)
    {
        [BoxSDK sharedSDK].OAuth2Session.refreshToken = storedRefreshToken;
    }
    
    
    return YES;
}

- (void)boxAPITokensDidRefresh:(NSNotification *)notification
{
    BoxOAuth2Session *OAuth2Session = (BoxOAuth2Session *) notification.object;
    [self setRefreshTokenInKeychain:OAuth2Session.refreshToken];
}

- (void)setRefreshTokenInKeychain:(NSString *)refreshToken
{
    [self.keychain setObject:@"PDFMarkUp" forKey: (__bridge id)kSecAttrService];
    [self.keychain setObject:refreshToken forKey:(__bridge id)kSecValueData];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
   /* NSString *query = url.query;
    if ([[url absoluteString] rangeOfString:@"cancel"].location == NSNotFound) {
        NSDictionary *urlData = [DBSession parseURLParams:query];
        NSString *uid = [urlData objectForKey:@"uid"];
        NSLog(@"uid is %@",uid);
        if (![arrDropboxUserids containsObject:uid]) {
            [arrDropboxUserids addObject:uid];
        }

        
        if ([[[DBSession sharedSession] userIds] containsObject:uid]) {
            // At this point we know the login succeeded and we have the newly linked userid
            // make a call to process the uid
            
           
            


        }
    } else {
        // user cancelled the login
        

    }*/
    
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"isDropboxLinked" object:nil]];
           
        }
        return YES;
    }
    return NO;
	
}

- (void)sessionDidReceiveAuthorizationFailure:(DBSession*)session userId:(NSString *)userId {
	relinkUserId = userId ;
	[[[UIAlertView alloc]
      initWithTitle:@"Dropbox Session Ended" message:@"Do you want to relink?" delegate:self
      cancelButtonTitle:@"Cancel" otherButtonTitles:@"Relink", nil]
     
	 show];
}




#pragma mark -
#pragma mark DBNetworkRequestDelegate methods

static int outstandingRequests;

- (void)networkRequestStarted {
	outstandingRequests++;
	if (outstandingRequests == 1) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	}
}

- (void)networkRequestStopped {
	outstandingRequests--;
	if (outstandingRequests == 0) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

+ (AppDelegate *)sharedInstance
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

@end
