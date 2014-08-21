//
//  GoogleLoginViewController.m
//  splitViewExample
//
//  Created by mahesh babu on 05/08/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import "GoogleLoginViewController.h"
#import "DocumentManager.h"
#import "JSON.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"
#import "DropboxDownloadFileViewControlller.h"
static GoogleLoginViewController *sharedInstance = nil;


NSString *client_id = @"118052793139-trvujb5d8eldudv3csbupksss6amfn5b.apps.googleusercontent.com";;
NSString *secret = @"tp1UdMtjm_ExEPnKKYGd55Al";
NSString *callbakc =  @"http://localhost";;
NSString *scope = @"https://www.googleapis.com/auth/userinfo.email+https://www.googleapis.com/auth/userinfo.profile+https://www.google.com/reader/api/0/subscription";
NSString *visibleactions = @"http://schemas.google.com/AddActivity";

static NSString *const kKeychainItemName = @"Google Drive Quickstart";



/*
NSString *client_id = @"1097593838790-s7c05tng19qomqppsskg1efm9hbar20d.apps.googleusercontent.com";
NSString *secret = @"Or56jmVPdi3umzE_3bmti0eD";
NSString *callbakc =  @"http://localhost";;
NSString *scope = @"https://www.googleapis.com/auth/userinfo.email+https://www.googleapis.com/auth/userinfo.profile+https://www.google.com/reader/api/0/subscription";
NSString *visibleactions = @"http://schemas.google.com/AddActivity";
*/


@interface GoogleLoginViewController ()

@end


@implementation GoogleLoginViewController

+(GoogleLoginViewController*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        
    }
    return sharedInstance;
}
@synthesize webview,isLogin,isReader;
@synthesize driveService;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
//- (GTLServiceDrive *)driveService {
//    static GTLServiceDrive *service = nil;
//    
//    if (!service) {
//        service = [[GTLServiceDrive alloc] init];
//        
//        // Have the service object set tickets to fetch consecutive pages
//        // of the feed so we do not need to manually fetch them.
//        service.shouldFetchNextPages = YES;
//        
//        // Have the service object set tickets to retry temporary error conditions
//        // automatically.
//        service.retryEnabled = YES;
//    }
//    return service;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.driveService = [[GTLServiceDrive alloc] init];
    self.driveService.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                                                         clientID:client_id
                                                                                     clientSecret:secret];
    
      GTMOAuth2Authentication *credentials;
     credentials = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                                        clientID:client_id
                                                                    clientSecret:secret];

    
    NSString *url = [NSString stringWithFormat:@"https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=%@&redirect_uri=%@&scope=%@&data-requestvisibleactions=%@",client_id,callbakc,scope,visibleactions];
    
    
    
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

-(IBAction)googleCancelButton_click:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];

}
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    //    [indicator startAnimating];
    if ([[[request URL] host] isEqualToString:@"localhost"]) {
        
        // Extract oauth_verifier from URL query
        NSString* verifier = nil;
        NSArray* urlParams = [[[request URL] query] componentsSeparatedByString:@"&"];
        for (NSString* param in urlParams) {
            NSArray* keyValue = [param componentsSeparatedByString:@"="];
            NSString* key = [keyValue objectAtIndex:0];
            if ([key isEqualToString:@"code"]) {
                verifier = [keyValue objectAtIndex:1];
                NSLog(@"verifier %@",verifier);
                break;
            }
        }
        
        if (verifier) {
            NSString *data = [NSString stringWithFormat:@"code=%@&client_id=%@&client_secret=%@&redirect_uri=%@&grant_type=authorization_code", verifier,client_id,secret,callbakc];
            NSString *url = [NSString stringWithFormat:@"https://accounts.google.com/o/oauth2/token"];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
            NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
            receivedData = [[NSMutableData alloc] init];
            
        } else {
            // ERROR!
        }
        
        [webView removeFromSuperview];
        
        return NO;
    }
    return YES;
}



- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data

{
    [receivedData appendData:data];
   // NSLog(@"verifier %@",receivedData);
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[NSString stringWithFormat:@"%@", error]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    NSError *myError = nil;
    NSDictionary *tokenData = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingMutableLeaves error:&myError];

    

    self.driveService.authorizer = tokenData;
    [DropboxDownloadFileViewControlller getSharedInstance].driveService.authorizer = tokenData;
    NSLog(@"Token data is %@",[DropboxDownloadFileViewControlller getSharedInstance].driveService.authorizer);

    [self getUserdetails:[tokenData objectForKey:@"access_token"] :[tokenData objectForKey:@"expires_in"] :[tokenData objectForKey:@"refresh_token"]];
     [[NSUserDefaults standardUserDefaults] setValue:[tokenData objectForKey:@"access_token"] forKey:@"google_accesstoken"];
    
}
- (BOOL)isAuthorized
{
    return [((GTMOAuth2Authentication *)self.driveService.authorizer) canAuthorize];
}
// Creates the auth controller for authorizing access to Google Drive.
- (GTMOAuth2ViewControllerTouch *)createAuthController
{
    GTMOAuth2ViewControllerTouch *authController;
    authController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeDriveFile
                                                                clientID:client_id
                                                            clientSecret:secret
                                                        keychainItemName:kKeychainItemName
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    return authController;
}

// Handle completion of the authorization process, and updates the Drive service
// with the new credentials.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error
{
    if (error != nil)
    {
        self.driveService.authorizer = nil;
    }
    else
    {
        self.driveService.authorizer = authResult;
        NSLog(@"Auth result is %@",authResult);

    }
}


-(void)getUserdetails:(NSString *)str_access_token :(NSString *)expires_in :(NSString *)refresh_token
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
    [arruseraccounts addObject:userdata];
    [arruseraccounts writeToFile:[[DocumentManager getSharedInstance] getUserAccountpath] atomically:YES];
       
    [self performSelector:@selector(closeGoogleController) withObject:nil afterDelay:1.0];

    }
    
}
-(void)closeGoogleController
{
    
    [self dismissModalViewControllerAnimated:YES];

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
