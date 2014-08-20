//
//  BoxHelperClass.m
//  PDFMarkUP
//
//  Created by ravi on 20/08/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import "BoxHelperClass.h"
#import "DocumentManager.h"
#import "AppDelegate.h"
#import "JSON.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"

static BoxHelperClass *sharedInstance = nil;

@implementation BoxHelperClass
{
    NSMutableArray * arrUseraccounts;
}
+(BoxHelperClass*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        
    }
    return sharedInstance;
}

-(BOOL)checkExpiredBoxToken
{
    arrUseraccounts = [[NSMutableArray alloc] initWithContentsOfFile:[[DocumentManager getSharedInstance] getUserAccountpath]];

    NSInteger secRemaining ;
    
    NSDate* date1 = [[arrUseraccounts objectAtIndex:[AppDelegate sharedInstance].accountIndex] objectForKey:@"expire_date"];
    NSDate* date2 = [NSDate date];
    NSTimeInterval distanceBetweenDates = [date1 timeIntervalSinceDate:date2];
    double secondsInAnHour = 60;
    secRemaining = distanceBetweenDates / secondsInAnHour;
    
    NSLog(@"access token expires in %d mins",secRemaining);
    [self createNewAccesToken];

    return secRemaining;
}

-(void)createNewAccesToken
{
    
    /*
     
     curl https://www.box.com/api/oauth2/token
     -d 'grant_type=refresh_token&refresh_token={valid refresh token}&client_id={your_client_id}&client_secret={your_client_secret}'
     -X POST
     
     */
    
    
    NSString* refresh =[NSString stringWithFormat:@"%@",[[arrUseraccounts objectAtIndex:[AppDelegate sharedInstance].accountIndex] objectForKey:@"refresh_token"]];
    
    
    NSString* clientId =[NSString stringWithFormat:@"%@",[BoxSDK sharedSDK].OAuth2Session.clientID];
    NSString* clientSecret =[NSString stringWithFormat:@"%@", [BoxSDK sharedSDK].OAuth2Session.clientSecret];
    
    ASIFormDataRequest *postParams = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"https://www.box.com/api/oauth2/token?"]];
    
    [postParams setRequestMethod:@"POST"];
    
    [postParams setPostValue:@"refresh_token" forKey:@"grant_type"];
    [postParams setPostValue:refresh forKey:@"refresh_token"];
    [postParams setPostValue:clientId forKey:@"client_id"];
    [postParams setPostValue:clientSecret forKey:@"client_secret"];
    
    [postParams startAsynchronous];
    postParams.delegate = self ;
    postParams.userInfo = [NSDictionary dictionaryWithObject:@"accessToken" forKey:@"id"];
    
    NSLog(@"Url is ---> %@",postParams.url);
    NSLog(@"response string is-----> %@",postParams.responseString);
    
}
#pragma mark - ASIHTTP Delegate

- (void)requestFinished:(ASIHTTPRequest *)request
{
if ([[request.userInfo objectForKey:@"id"] isEqualToString:@"accessToken"])
{
    
    NSLog(@"response is %@",request.responseString);
    NSMutableArray *arrJson= [[NSMutableArray alloc]initWithObjects:[request.responseString JSONValue],nil];
    NSLog(@"%@",[request.responseString JSONValue] );
    
    NSLog(@"old access token is  -> %@", [[arrUseraccounts objectAtIndex:[AppDelegate sharedInstance].accountIndex] objectForKey:@"acces_token"]);
    
    NSLog(@"new access token is  -> %@", [[arrJson objectAtIndex:0]objectForKey:@"access_token"]);
    
    
    NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
    NSDictionary *oldDict = (NSDictionary *)[arrUseraccounts objectAtIndex:[AppDelegate sharedInstance].accountIndex];
    [newDict addEntriesFromDictionary:oldDict];
    [newDict setObject:[[arrJson objectAtIndex:0]objectForKey:@"access_token"] forKey:@"acces_token"];
    [newDict setObject:[[arrJson objectAtIndex:0]objectForKey:@"refresh_token"] forKey:@"refresh_token"];
    
    NSDate *datePlusOneMinute = [[NSDate date] dateByAddingTimeInterval:[[[arrJson objectAtIndex:0]objectForKey:@"expires_in"]integerValue]];
    [newDict setObject:[[arrJson objectAtIndex:0]objectForKey:@"expires_in"] forKey:@"request_time"];
    [newDict setObject:datePlusOneMinute forKey:@"expire_date"];
    
    [newDict setObject:@"updated" forKey:@"tokenStatus"];
    
    [arrUseraccounts replaceObjectAtIndex:[AppDelegate sharedInstance].accountIndex withObject:newDict];
    
    [arrUseraccounts writeToFile:[[DocumentManager getSharedInstance] getUserAccountpath] atomically:YES];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"accessTokenSuccess" object:nil];
}
}

@end
