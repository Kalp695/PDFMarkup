//
//  SugarSyncHelper.h
//  PDFMarkUP
//
//  Created by ravi on 01/10/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SugarSyncConstants.h"
#import "SugarSyncLoginViewController.h"

@interface SugarSyncHelper : NSObject
{
    
}

@property (nonatomic, retain) SugarSyncUser * userDetails;


+(SugarSyncHelper *)getSharedInstance;

@end
