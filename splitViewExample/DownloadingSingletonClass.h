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
@property(atomic,retain) NSString * activityViewStatus;


@property(atomic,assign,readwrite) BOOL ftpDownload;

// Upload
@property(atomic,assign,readwrite) BOOL dropBoxUpload;
@property(atomic,assign,readwrite) BOOL boxUpload;

@property(atomic,assign,readwrite) BOOL ftpUpload;

@end
