//
//  FolderChooseViewController.h
//  splitViewExample
//
//  Created by ravi on 30/07/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface FolderChooseViewController : UIViewController<DBRestClientDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *marrDownloadData;
    //  DBRestClient *restClient;
    NSMutableArray *arrUseraccounts;
    
}
+(FolderChooseViewController*)getSharedInstance;
//BOX
@property (nonatomic, retain) NSString * accountName;
@property (nonatomic, assign) int indexCount;
@property (nonatomic, retain) NSString *boxFolderId;
@property (nonatomic, retain) NSString *boxFolderName;

// Drive

@property(nonatomic,retain) NSMutableArray * driveFoldersList;
@property(nonatomic,retain) NSMutableArray * driveFiles;
@property(nonatomic,retain) NSString * driveFilesId;

@property (nonatomic, strong) NSString *loadData;
@property (nonatomic, strong) IBOutlet UITableView *tbDownload;
-(IBAction)chooseBarButton_click:(id)sender;
-(IBAction)uploadButton_click:(id)sender;
-(IBAction)cancelButton_click:(id)sender;



@end
