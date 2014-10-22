//
//  AddAccountViewController.m
//  splitViewExample
//
//  Created by ravi on 21/07/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//



#import "AddAccountViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "AppDelegate.h"
#import "GoogleLoginViewController.h"
#import "DocumentManager.h"
#import "BoxAuthorizationNavigationController.h"
#import "JSON.h"
#import "DropboxDownloadFileViewControlller.h"
#import "FTPLoginViewController.h"
#import "SugarSyncLoginViewController.h"
#import "SugarSyncConstants.h"
#import "SugarSyncHelper.h"
#import "JSON.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "KeychainItemWrapperr.h"
#import "SugarSyncXMLTemplate.h"
#import "SSHttpFetcher.h"
#import "XPathQuery.h"
#import "SSXMLLibUtil.h"
#import "SSErrorUtil.h"
#import "SSC9Log.h"
#import "KeychainItemWrapper.h"
#import "DetailViewController.h"


static NSString *const kKeychainItemName = @"Google Drive Quickstart";
static NSString *const kClientID = @"118052793139-trvujb5d8eldudv3csbupksss6amfn5b.apps.googleusercontent.com";
static NSString *const kClientSecret = @"tp1UdMtjm_ExEPnKKYGd55Al";

@interface AddAccountViewController ()<DBRestClientDelegate>

- (void)boxAPIAuthenticationDidSucceed:(NSNotification *)notification;
- (void)boxAPIAuthenticationDidFail:(NSNotification *)notification;

@end


@implementation AddAccountViewController
{
    NSMutableData * responseData;
}
@synthesize keychain;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(boxAPIAuthenticationDidSucceed:)
                                                 name:BoxOAuth2SessionDidBecomeAuthenticatedNotification
                                               object:[BoxSDK sharedSDK].OAuth2Session];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(boxAPIAuthenticationDidFail:)
                                                 name:BoxOAuth2SessionDidReceiveAuthenticationErrorNotification
                                               object:[BoxSDK sharedSDK].OAuth2Session];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}
-(void)viewDidAppear
{
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDropboxNotification:)
                                                 name:@"isDropboxLinked"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeBoxController)
                                                 name:@"googleSucces"
                                               object:nil];
    
    
}
-(IBAction)accountsButtonAction:(id)sender
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        
        UIAlertView	*alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Please check your network connectivity."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else{
        
        [AppDelegate sharedInstance].topTitle = @"Network" ;

        if ([sender tag]==1)
        {
            NSLog(@"Drop Box");
            
            // if (![[DBSession sharedSession] isLinked])
            // {
            
            for (int i =0; i<[[[AppDelegate sharedInstance] arrDropboxUserids] count]; i++) {
                
                //  [[DBSession sharedSession] unlinkUserId:[[[AppDelegate sharedInstance] arrDropboxUserids] objectAtIndex:i]];
                
                
            }
            
            [[DBSession sharedSession] linkFromController:self];
            // }
        }
        
        else if ([sender tag]==2)
        {
            NSURL *authorizationURL = [BoxSDK sharedSDK].OAuth2Session.authorizeURL;
            NSString *redirectURI = [BoxSDK sharedSDK].OAuth2Session.redirectURIString;
            BoxAuthorizationViewController *authorizationViewController = [[BoxAuthorizationViewController alloc] initWithAuthorizationURL:authorizationURL redirectURI:redirectURI];
            BoxAuthorizationNavigationController *loginNavigation = [[BoxAuthorizationNavigationController alloc] initWithRootViewController:authorizationViewController];
            authorizationViewController.delegate = loginNavigation;
            loginNavigation.modalPresentationStyle = UIModalPresentationFormSheet;
            
            [self presentViewController:loginNavigation animated:YES completion:nil];
            
        }
        else if ([sender tag]==3)
        {
            
            SugarSyncClient *sugarSyncClient = [SugarSyncClient createWithApplicationId:Sugar_createWithApplicationId accessKey:Sugar_accessKey privateAccessKey:Sugar_privateAccessKey userAgent:Sugar_userAgent];
            
            if ( !sugarSyncClient.isLoggedIn )
            {
                [sugarSyncClient displayLoginDialogWithCompletionHandler:^(SugarSyncLoginStatus aStatus, NSError *error) {
                    
                    [[SugarSyncClient sharedInstance] getUserWithCompletionHandler:^(SugarSyncUser *aUser, NSError *error) {
                        
                        
                        NSLog(@"get logged user details %@,%@",aUser.nickname,aUser.username);
                        [self sugarSyncUserDetails:aUser];

                        
                       
                    }];
                    
                }];
                
            }
            else
            {
                [[SugarSyncClient sharedInstance] getUserWithCompletionHandler:^(SugarSyncUser *aUser, NSError *error)
                {
                    
                    NSLog(@"get logged user details %@",aUser);
                    
                    [self sugarSyncUserDetails:aUser];
                }];
            }
        }
        else if ([sender tag]== 4)
        {
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            FTPLoginViewController * ftpLoginViewController = [storyboard instantiateViewControllerWithIdentifier:@"FTPLoginViewController"];
            ftpLoginViewController.modalPresentationStyle = UIModalPresentationFormSheet;
            
            [self presentViewController:ftpLoginViewController animated:YES completion:nil];
            
            
        }
        else if ([sender tag] == 5)
        {
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            GoogleLoginViewController *googleLoginViewController = [storyboard instantiateViewControllerWithIdentifier:@"GoogleLoginViewController"];
            googleLoginViewController.modalPresentationStyle = UIModalPresentationFormSheet;
            
            [self presentViewController:googleLoginViewController animated:YES completion:nil];
            //     //   [self.navigationController pushViewController:dropboxDownloadFileViewControlller animated:YES];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"isDropboxLinked" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"googleSucces" object:nil];

}

-(void)receiveDropboxNotification:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"isDropboxLinked"])
    {
        
        DropboxManager *dbManager = [DropboxManager dbManager];
        [dbManager restClient].delegate = self;
        [[dbManager restClient] loadAccountInfo];
        
    }
    
}

- (void)restClient:(DBRestClient*)client loadedAccountInfo:(DBAccountInfo*)info {
    
    NSLog(@"UserID: %@ %@", [info displayName], [info userId]);
    
    NSDictionary *dicdetails = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[info displayName],[info userId],@"dropbox", nil] forKeys:[NSArray arrayWithObjects:@"username",@"userid",@"AccountType", nil]];
    [AppDelegate sharedInstance].dicUserdetails = [[NSDictionary alloc] initWithDictionary:dicdetails];
    
    
    NSMutableArray *arruseraccounts = [[NSMutableArray alloc] initWithContentsOfFile:[[DocumentManager getSharedInstance] getUserAccountpath]];
    [arruseraccounts addObject:dicdetails];
    
    [arruseraccounts writeToFile:[[DocumentManager getSharedInstance] getUserAccountpath] atomically:YES];
    [[NSUserDefaults standardUserDefaults] setValue:[AppDelegate sharedInstance].dicUserdetails forKey:@"Dropboxuser"];
    // NSLog(@"dic details %@",[AppDelegate sharedInstance].dicUserdetails);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshLefttable" object:self];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    
}



-(void)boxuserDetails:(NSString *)str_access_token :(NSString *)str_refresh_token :(NSDate *)expireDate
{
    
    NSString *str =  [NSString stringWithFormat:@"https://api.box.com/2.0/users/me?access_token=%@",str_access_token];
    
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:str]
                                                  cachePolicy:NSURLCacheStorageAllowed
                                              timeoutInterval:20];
    
    
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:request
                                          returningResponse:&response
                                                      error:&error];
    
    
    if (error == nil)
    {
        
        // Parse data here
        NSMutableArray *arruseraccounts = [[NSMutableArray alloc] initWithContentsOfFile:[[DocumentManager getSharedInstance] getUserAccountpath]];
        NSMutableDictionary *userdata = [[NSMutableDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error]];
        [userdata setObject:str_access_token forKey:@"acces_token"];
        [userdata setObject:expireDate forKey:@"expire_date"];
        [userdata setObject:str_refresh_token forKey:@"refresh_token"];
        [userdata setObject:@"box" forKey:@"AccountType"];
        
        [arruseraccounts addObject:userdata];
        
        [arruseraccounts writeToFile:[[DocumentManager getSharedInstance] getUserAccountpath] atomically:YES];
        
        NSLog(@"check %@",[self.navigationController viewControllers]);
        [self performSelector:@selector(closeBoxController) withObject:nil afterDelay:1.0];
        
    }
    
    
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    
    
}
- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    
}

-(void)closeBoxController
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshLefttable" object:self];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - Handle OAuth2 session notifications
- (void)boxAPIAuthenticationDidSucceed:(NSNotification *)notification
{
    NSLog(@"Received OAuth2 successfully authenticated notification");
    BoxOAuth2Session *session = (BoxOAuth2Session *) [notification object];
    NSLog(@"Access token  (%@) expires at %@", session.accessToken, session.accessTokenExpiration);
    
    NSLog(@"Refresh token (%@)", session.refreshToken);
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
    
    
    //[[BoxSDK sharedSDK].usersManager userInfoWithID:BoxAPIUserIDMe requestBuilder:nil success:nil failure:nil];
    
    [DropboxDownloadFileViewControlller getSharedInstance].boxAccessToken = session.accessToken;
    [DropboxDownloadFileViewControlller getSharedInstance].boxRefreshToken = session.refreshToken ;
    
    [self boxuserDetails:session.accessToken :session.refreshToken :session.accessTokenExpiration];
    
    
}

- (void)boxAPIAuthenticationDidFail:(NSNotification *)notification
{
    NSLog(@"Received OAuth2 failed authenticated notification");
    NSString *oauth2Error = [[notification userInfo] valueForKey:BoxOAuth2AuthenticationErrorKey];
    NSLog(@"Authentication error  (%@)", oauth2Error);
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

// Sugar Sync
#pragma mark SugarSYnc

-(void)sugarSyncUserDetails:(SugarSyncUser *)userDetails
{
    NSLog(@"workspaces is %@",userDetails.workspaces);
    NSMutableArray *arruseraccounts = [[NSMutableArray alloc] initWithContentsOfFile:[[DocumentManager getSharedInstance] getUserAccountpath]];
    NSMutableDictionary *userdata = [[NSMutableDictionary alloc] init];
    [userdata setObject:userDetails.nickname forKey:@"name"];
    [userdata setObject:userDetails.username forKey:@"email"];
    [userdata setObject:Sugar_accessKey forKey:@"acces_token"];
    [userdata setObject:@"sugarsync" forKey:@"AccountType"];
    [SugarSyncHelper getSharedInstance].userDetails = userDetails;
    [arruseraccounts addObject:userdata];
    NSLog(@"sugar sync details is %@",arruseraccounts);
    [arruseraccounts writeToFile:[[DocumentManager getSharedInstance] getUserAccountpath] atomically:YES];
    
    NSLog(@"check %@",[self.navigationController viewControllers]);
    [self performSelector:@selector(closeBoxController) withObject:nil afterDelay:1.0];
}

-(void)sugarSyncAccessToken
{

    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
