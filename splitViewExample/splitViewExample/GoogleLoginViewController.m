//
//  GoogleLoginViewController.m
//  splitViewExample
//
//  Created by mahesh babu on 05/08/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import "GoogleLoginViewController.h"
#import "DocumentManager.h"

NSString *client_id = @"118052793139-trvujb5d8eldudv3csbupksss6amfn5b.apps.googleusercontent.com";;
NSString *secret = @"tp1UdMtjm_ExEPnKKYGd55Al";
NSString *callbakc =  @"http://localhost";;
NSString *scope = @"https://www.googleapis.com/auth/userinfo.email+https://www.googleapis.com/auth/userinfo.profile+https://www.google.com/reader/api/0/subscription";
NSString *visibleactions = @"http://schemas.google.com/AddActivity";


@interface GoogleLoginViewController ()

@end


@implementation GoogleLoginViewController

@synthesize webview,isLogin,isReader;


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
    
    NSString *url = [NSString stringWithFormat:@"https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=%@&redirect_uri=%@&scope=%@&data-requestvisibleactions=%@",client_id,callbakc,scope,visibleactions];
    
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
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

   // NSString *response = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
   // SBJsonParser *jResponse = [[SBJsonParser alloc]init];
   // NSDictionary *tokenData = [jResponse objectWithString:response];
    //  WebServiceSocket *dconnection = [[WebServiceSocket alloc] init];
    //   dconnection.delegate = self;
    
   
    [self getUserdetails:[tokenData objectForKey:@"access_token"]];
     [[NSUserDefaults standardUserDefaults] setValue:[tokenData objectForKey:@"access_token"] forKey:@"google_accesstoken"];
    //  NSString *pdata = [NSString stringWithFormat:@"type=3&token=%@&secret=123&login=%@",[tokenData accessToken.secret,self.isLogin];
    //  [dconnection fetch:1 withPostdata:pdata withGetData:@"" isSilent:NO];
    
    
//    [self.navigationController popToRootViewControllerAnimated:YES];
 
}


-(void)getUserdetails:(NSString *)str_access_token
{
    
  //  https://www.googleapis.com/oauth2/v1/userinfo?alt=json&access_token=ya29.WABjxDd0eWUD3RsAAABKxUt_bVWN2VsWX2l8VavY_FsJxUuqQfptWY1UMYYiww
    NSString *str =  [NSString stringWithFormat:@"https://www.googleapis.com/oauth2/v1/userinfo?alt=json&access_token=%@",str_access_token];
    
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:str]
                                                  cachePolicy:NSURLCacheStorageAllowed
                                              timeoutInterval:20];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                               
                               if ([data length] >0 && error == nil) {
                                   
                                 
                                   
                                    NSError *myError = nil;
                                   
                                   NSMutableArray *arruseraccounts = [[NSMutableArray alloc] initWithContentsOfFile:[[DocumentManager getSharedInstance] getUserAccountpath]];
                                   NSMutableDictionary *userdata = [[NSMutableDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&myError]];
                                   [userdata setObject:@"google" forKey:@"AccountType"];
                                   
                                   [arruseraccounts addObject:userdata];
                                   [arruseraccounts writeToFile:[[DocumentManager getSharedInstance] getUserAccountpath] atomically:YES];
                                   
                                   NSLog(@"check %@",[self.navigationController viewControllers]);
                                   [self performSelector:@selector(closeController) withObject:nil afterDelay:1.0];
                               } else if ([data length] == 0 && error == nil) {
                                   
                                   NSLog(@"Nothing was downloaded.");
                                   
                               } else if (error != nil) {
                                  
                                   NSLog(@"Error = %@", error);
                               }
                           }];

}

-(void)closeController
{
    [self.navigationController popToRootViewControllerAnimated:YES];

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
