//
//  FTP.h
//  PDFMarkUP
//
//  Created by ravi on 31/08/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRRequestListDirectory.h"
#import "BRRequestCreateDirectory.h"
#import "BRRequestUpload.h"
#import "BRRequestDownload.h"
#import "BRRequestDelete.h"
#import "BRRequest+_UserData.h"

@interface FTP : NSObject<BRRequestDelegate>
{
    BRRequestCreateDirectory *createDir;
    BRRequestDelete * deleteDir;
    BRRequestListDirectory *listDir;
    
    BRRequestDownload * downloadFile;
    BRRequestUpload *uploadFile;
    BRRequestDelete *deleteFile;
    
    
    NSMutableData *downloadData;
    NSData *uploadData;

}
@property(nonatomic,retain)NSString * hostName;
@property(nonatomic,retain)NSString * userName;
@property(nonatomic,retain)NSString * password;
-(void)listDirectory:(id)sender;

@end
