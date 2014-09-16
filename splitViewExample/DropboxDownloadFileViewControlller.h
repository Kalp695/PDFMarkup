//
//  DropboxDownloadFileViewControlller.h
//  DropboxIntegration
//
//  Created by TheAppGuruz-iOS-101 on 26/04/14.
//  Copyright (c) 2014 TheAppGuruz-iOS-101. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "GTLDrive.h"
#import "ASIHTTPRequest.h"

#import "BRRequestListDirectory.h"
#import "BRRequestCreateDirectory.h"
#import "BRRequestUpload.h"
#import "BRRequestDownload.h"
#import "BRRequestDelete.h"
#import "BRRequest+_UserData.h"

@interface DropboxDownloadFileViewControlller : UIViewController<DBRestClientDelegate,ASIHTTPRequestDelegate,BRRequestDelegate>
{
    NSMutableArray *marrDownloadData;
    NSMutableArray *arrmetadata;
    // DBRestClient *restClient;
    IBOutlet UIButton * downloadingButton;
    NSMutableArray * filePathsArray;
    
    IBOutlet UIBarButtonItem *editBarButton;
    
    NSMutableArray * sqliteRowsArray;
    
    NSMutableArray * sqliteFilesArray;
    NSString *hash;
    NSString *folder_file;
    DBMetadata* currentChild;
    
    NSString * tempString;
    NSMutableArray *arrdownlaodfiels;
    NSTimer *timer;
    NSMutableArray *arrtimers;
    BOOL bisprocessing;
    NSString *strrootpath;
    NSMutableDictionary *arrLocalFilepaths;
    NSString * refreshToken ;
    
    //FTP
    
    BRRequestCreateDirectory *createDir;
    BRRequestDelete * deleteDir;
    BRRequestListDirectory *listDir;
    BRRequestDownload * downloadFile;
    BRRequestDelete *deleteFile;
    
    NSMutableData *downloadData;
    NSData *uploadData;
    NSMutableArray * ftpListArray;
    
    
    // NSOperation Queue
    
    NSOperationQueue * boxOperationQueue;
    NSOperationQueue * driveOperationQueue;
    NSOperationQueue * dropBoxOperationQueue;
    NSOperationQueue * ftpOperationQueue;

    // Asynch

   // BOOL dropBoxDownload;
    BOOL dbEditing;
    
    //
    BOOL boxDownloadProcess;
    
}
- (BOOL)connected;

+(DropboxDownloadFileViewControlller*)getSharedInstance;
@property (atomic, strong) NSString *accountStatus;

@property(atomic,strong) NSMutableArray *filePathsArray;
@property(atomic,strong) NSMutableArray *boxFilePathsArray;

-(NSString*)getDropBoxDirectoryPath:(NSString*)path withfilename:(NSString *)filename;
-(void)upload:(id)sender;

-(IBAction)btnDownloadPress:(id)sender;
-(IBAction)back:(id)sender;


@property (nonatomic, weak) IBOutlet UITableView *tbDownload;
//@property (nonatomic, readonly) DBRestClient *restClient;
@property (nonatomic, strong) NSString *loadData;
@property (nonatomic, strong)     NSMutableArray * folderPath;

// BOX
@property (nonatomic, retain) NSString *boxAccessToken;
@property (nonatomic, retain) NSString *boxRefreshToken;
-(BOOL)checkExpiredBoxToken;
@property (nonatomic, assign) int index;
@property (nonatomic, retain) NSString *boxFolderId;
@property (nonatomic, retain) NSString *boxFolderName;


// GDrive
@property (retain) NSMutableArray *driveFiles;
@property(nonatomic,retain)NSMutableArray * driveFilesArray;
@property(nonatomic,retain) NSString * driveFilesId;
@property(nonatomic,retain)NSMutableArray * driveFilePathsArray;

//FTP
@property(nonatomic,retain) NSString * ftpFolderName;
@property(nonatomic,retain) NSString * ftpFolderPath;

@property(nonatomic,retain)NSMutableArray * ftpFilePathsArray;
@property(nonatomic,retain)NSString * ftpStatus;
@property(nonatomic,retain)NSString * downloadingName;



@end
