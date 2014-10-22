//
//  DocumentManager.m
//  splitViewExample
//
//  Created by mahesh babu on 06/08/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import "DocumentManager.h"

static DocumentManager *sharedInstance = nil;

@implementation DocumentManager


+(DocumentManager*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        
    }
    return sharedInstance;
}


-(NSString *)getUserAccountpath
{
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"UserAccounts.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path])
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"UserAccounts" ofType:@"plist"];
        
        [fileManager copyItemAtPath:bundle toPath: path error:&error];
    }
    
    return path;
}
@end
