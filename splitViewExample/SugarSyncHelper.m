//
//  SugarSyncHelper.m
//  PDFMarkUP
//
//  Created by ravi on 01/10/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import "SugarSyncHelper.h"
static SugarSyncHelper *sharedInstance = nil;

@implementation SugarSyncHelper
@synthesize userDetails;

+(SugarSyncHelper*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
    }
    return sharedInstance;
}
@end
