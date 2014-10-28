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
@property(atomic,assign,readwrite) BOOL sugarDownload;


// Upload
@property(atomic,assign,readwrite) BOOL dropBoxUpload;
@property(atomic,assign,readwrite) BOOL boxUpload;

@property(atomic,assign,readwrite) BOOL ftpUpload;
@property(atomic,assign,readwrite) BOOL sugarUpload;

//Sugarsync
@property(atomic,retain) NSArray * sugarSyncClassFiles;
@property(atomic,assign,readwrite) int sugarSyncIndex;

@end
