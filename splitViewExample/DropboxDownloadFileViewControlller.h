//
//  DropboxDownloadFileViewControlller.h
//  DropboxIntegration
//
//  Created by TheAppGuruz-iOS-101 on 26/04/14.
//  Copyright (c) 2014 TheAppGuruz-iOS-101. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface DropboxDownloadFileViewControlller : UIViewController<DBRestClientDelegate>
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
}
+(DropboxDownloadFileViewControlller*)getSharedInstance;
@property (nonatomic, strong) NSString *accountStatus;

@property(nonatomic,strong) NSMutableArray *filePathsArray;
@property(nonatomic,strong) NSMutableArray *boxFilePathsArray;

-(NSString*)getDropBoxDirectoryPath:(NSString*)path withfilename:(NSString *)filename;
-(void)upload:(id)sender;

-(IBAction)btnDownloadPress:(id)sender;
-(IBAction)back:(id)sender;


@property (nonatomic, strong) IBOutlet UITableView *tbDownload;
//@property (nonatomic, readonly) DBRestClient *restClient;
@property (nonatomic, strong) NSString *loadData;
@property (nonatomic, strong)     NSMutableArray * folderPath;

// BOX
@property (nonatomic, retain) NSString *boxAccessToken;
@property (nonatomic, retain) NSString *boxRefreshToken;

@property (nonatomic, assign) int index;
@property (nonatomic, retain) NSString *boxFolderId;
@property (nonatomic, retain) NSString *boxFolderName;


@end
