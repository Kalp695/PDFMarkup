//
//  GoogleDriveLoginViewController.m
//  PDFMarkUP
//
//  Created by mahesh babu on 24/08/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import "GoogleLoginViewController.h"
#import "DriveHelperClass.h"
#import "DocumentManager.h"
#import "DriveConstants.h"
NSString *callbakc =  @"http://localhost";
NSString *scope = @"https://www.googleapis.com/auth/userinfo.email+https://www.googleapis.com/auth/userinfo.profile+https://www.google.com/reader/api/0/subscription";
NSString *visibleactions = @"http://schemas.google.com/AddActivity";


@interface GoogleLoginViewController ()

@end

@implementation GoogleLoginViewController

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
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [DriveHelperClass getSharedInstance].driveService = [[GTLServiceDrive alloc] init];
    [DriveHelperClass getSharedInstance].driveService.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeyChainItemName
                                                                                                                         clientID:kClientID
                                                                                                                     clientSecret:kClientSecret];

}
-(void)viewWillAppear:(BOOL)animated
{
    
        // Not yet authorized, request authorization and push the login UI onto the navigation stack.
      //  [self presentModalViewController:[self createAuthController]
      //                          animated:YES];
        [self createAuthController];
    

    
}
- (BOOL)isAuthorized
{
    return [((GTMOAuth2Authentication *)[DriveHelperClass getSharedInstance].driveService.authorizer) canAuthorize];
}

// Creates the auth controller for authorizing access to Googel Drive.
- (GTMOAuth2ViewControllerTouch *)createAuthController
{
    
    GTMOAuth2ViewControllerTouch *authController;
    authController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeDrive
                                                                clientID:kClientID
                                                            clientSecret:kClientSecret
                                                        keychainItemName:kKeyChainItemName
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    [authController.view setFrame:CGRectMake(-20,35,500,600)];

    [self.view addSubview:authController.view];

    return authController;
}
-(IBAction)cancelClick:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];

}
// Handle completion of the authorization process, and updates the Drive service
// with the new credentials.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error
{
    if (error != nil)
    {
        [DriveHelperClass getSharedInstance].driveService.authorizer = nil;
    }
    else
    {
        NSLog(@"auth result is %@",authResult);
        [DriveHelperClass getSharedInstance].driveService.authorizer = authResult;
//        NSString * accessToken = authResult.accessToken;
//        NSString * refreshT = authResult.refreshToken;
//        NSString * expire = [NSString stringWithFormat:@"%@",authResult.expirationDate];
        
        
        [self getUserdetails:authResult.accessToken :[NSString stringWithFormat:@"%@",authResult.expirationDate] :authResult.refreshToken :authResult.code];
        [self dismissModalViewControllerAnimated:YES];
    }
}

-(void)getUserdetails:(NSString *)str_access_token :(NSString *)expires_in :(NSString *)refresh_token :(NSString *)code
{
    
    //  https://www.googleapis.com/oauth2/v1/userinfo?alt=json&access_token=ya29.WABjxDd0eWUD3RsAAABKxUt_bVWN2VsWX2l8VavY_FsJxUuqQfptWY1UMYYiww
    
    NSString *str =  [NSString stringWithFormat:@"https://www.googleapis.com/oauth2/v1/userinfo?alt=json&access_token=%@",str_access_token];
    
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:str]
                                                  cachePolicy:NSURLCacheStorageAllowed
                                              timeoutInterval:20];
    NSURLResponse *response;
    NSError *error;
    
    NSData * data = [NSURLConnection sendSynchronousRequest:request
                                          returningResponse:&response
                                                      error:&error];
    NSMutableArray *arruseraccounts = [[NSMutableArray alloc] initWithContentsOfFile:[[DocumentManager getSharedInstance] getUserAccountpath]];
    
    NSMutableDictionary *userdata = [[NSMutableDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error]];
    if (error == nil)
    {
        NSLog(@"userdata is %@",userdata);
        [userdata setObject:@"google" forKey:@"AccountType"];
        [userdata setObject:str_access_token forKey:@"acces_token"];
        [userdata setObject:expires_in forKey:@"expire_date"];
        [userdata setObject:refresh_token forKey:@"refresh_token"];
        [userdata setObject:code forKey:@"code"];

        [arruseraccounts addObject:userdata];
        [arruseraccounts writeToFile:[[DocumentManager getSharedInstance] getUserAccountpath] atomically:YES];
        
        [self performSelector:@selector(closeGoogleController) withObject:nil afterDelay:1.0];
        
    }
    
}
-(void)closeGoogleController
{
    
   // [self dismissModalViewControllerAnimated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"googleSucces" object:self];
    
    // [self.navigationController popViewControllerAnimated:YES];
    
    
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
