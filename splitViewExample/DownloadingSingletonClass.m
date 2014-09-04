//
//  DownloadingSingletonClass.m
//  PDFMarkUP
//
//  Created by ravi on 04/09/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import "DownloadingSingletonClass.h"
static DownloadingSingletonClass *sharedInstance = nil;

@implementation DownloadingSingletonClass
{
    
}
@synthesize dropBoxDownload;

+(DownloadingSingletonClass*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        
    }
    return sharedInstance;
}
@end
