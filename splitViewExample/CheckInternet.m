//
//  harpWebServices.m
//  Harp
//
//  Created by Sunil on 1/18/14.
//  Copyright (c) 2014 Sunil. All rights reserved.
//

#import "Reachability.h"
#import "CheckInternet.h"

static CheckInternet *sharedInstance = nil;

@implementation CheckInternet


+(CheckInternet *)sharedInstance
{
     if (sharedInstance==Nil) {
        sharedInstance=[[CheckInternet alloc]init];
    }
    return sharedInstance;
    /**/
}


#pragma mark check Internet Connectivity
-(BOOL)internetIsAvailable
{
    Reachability *reachibility=[Reachability reachabilityForInternetConnection];
	if([reachibility currentReachabilityStatus]==NotReachable)
	{
		//show an alertView stating that internet connection is unavailable
        //ShowAlert(@"iRant", @"Internet connection unavailable", @"OK");
		
		//raise a notification to stop all the activity indicators(all HUD classes should implement this)
        //[[NSNotificationCenter defaultCenter]postNotificationName:@"InternetConnectionUnavailable" object:nil];
		return FALSE;
	}
	return TRUE;
}

-(BOOL)checkForInternetConnectivity
{
    Reachability *reachibility=[Reachability reachabilityForInternetConnection];
	if([reachibility currentReachabilityStatus]==NotReachable)
	{
       
		return FALSE;
	}
	return TRUE;
}




@end
