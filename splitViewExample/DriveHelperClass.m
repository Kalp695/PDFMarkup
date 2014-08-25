//
//  DriveHelperClass.m
//  GD
//
//  Created by ravi on 23/08/14.
//  Copyright (c) 2014 Teapoy Infotech. All rights reserved.
//

#import "DriveHelperClass.h"

static DriveHelperClass *sharedInstance = nil;

@implementation DriveHelperClass
{
    
}
+(DriveHelperClass*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
    }
    return sharedInstance;
}
@synthesize driveService;

@end
