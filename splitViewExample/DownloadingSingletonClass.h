//
//  DownloadingSingletonClass.h
//  PDFMarkUP
//
//  Created by ravi on 04/09/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadingSingletonClass : NSObject
{
    
}
+(DownloadingSingletonClass*)getSharedInstance;

@property(atomic,assign,readwrite) BOOL dropBoxDownload;
@property(atomic,assign,readwrite) BOOL activityView;

@end
