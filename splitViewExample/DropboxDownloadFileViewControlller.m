//
//  DropboxDownloadFileViewControlller.m
//  DropboxIntegration
//
//  Created by TheAppGuruz-iOS-101 on 26/04/14.
//  Copyright (c) 2014 TheAppGuruz-iOS-101. All rights reserved.
//


NSString * folderDocpath;
#import "DropboxDownloadFileViewControlller.h"
#import "MBProgressHUD.h"
#import "FileItemTableCell.h"
#import "AppDelegate.h"
#import "DropboxManager.h"
#import "DocumentManager.h"
#import "JSON.h"
#import "FolderChooseViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "BoxHelperClass.h"
#import "GTLDrive.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GoogleLoginViewController.h"
#import "KeychainItemWrapper.h"
#import "DriveHelperClass.h"
#import "DriveConstants.h"
#import "FTPMainViewController.h"
#import "PDFThumbnail.h"
#import "DetailViewController.h"
#import "DownloadingSingletonClass.h"

static DropboxDownloadFileViewControlller *sharedInstance = nil;



@interface FolderItem : NSObject

@property (retain, nonatomic) NSString *title;

@property (retain, nonatomic) UIImage *image;

@property (assign, nonatomic) BOOL isChecked;

@end

@implementation FolderItem

@end


@interface DropboxDownloadFileViewControlller ()

@end

@implementation DropboxDownloadFileViewControlller
{
    int filesCount;
    int pdfCount;
    int itemCount;
    
    NSMutableString  * pdfFileNames;
    NSString * documentFolder;
    
    int pdfValue;
    
    NSMutableArray *columns;
    
    UIBarButtonItem *editButton;
    
    NSMutableArray *arrUseraccounts;
    
    
    // BOX
    NSMutableArray * folderItemsArray;
    NSMutableArray * boxFilesItemsArray;
    NSString * boxFolderPath;
    NSString * boxDownloadingType;
    NSMutableArray * boxInsideFolderArray;
    NSString * root;
    NSString * boxFilePath;
    NSMutableArray * boxSelectedFilesArray;
    BOOL fetching;
    
    //Drive
    BOOL fileFetchStatusFailure;
    int count;
    NSMutableArray * fileNames;
}

+(DropboxDownloadFileViewControlller*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        
    }
    return sharedInstance;
}

@synthesize tbDownload;
@synthesize loadData;
@synthesize folderPath;
@synthesize accountStatus;
NSString *wastepath = nil;

// Box
@synthesize boxAccessToken;
@synthesize boxRefreshToken;
@synthesize filePathsArray;
@synthesize boxFilePathsArray;
@synthesize boxFolderId,boxFolderName,index;

// Drive
@synthesize driveFiles;
@synthesize driveFilesArray,driveFilesId,driveFilePathsArray;

// FTP
@synthesize ftpFolderName;
@synthesize ftpFolderPath,ftpFilePathsArray;
@synthesize ftpStatus;
@synthesize downloadingName;

-(void)viewWillAppear:(BOOL)animated
{
    
    // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(multipleFileDownload:) name:@"DownloadClick" object:nil];
    
    // });
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(createFolder)
                                                 name:@"CreateFolderClick"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DeleteClick) name:@"DeleteClick" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renameFolder) name:@"RenameClick" object:nil];
    
    arrUseraccounts = [[NSMutableArray alloc] initWithContentsOfFile:[[DocumentManager getSharedInstance] getUserAccountpath]];
    
    if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"dropbox"])
    {
    }
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"box"])
    {
        NSLog(@"Box");
        self.title = [[arrUseraccounts objectAtIndex:[DropboxDownloadFileViewControlller getSharedInstance].index] objectForKey:@"name"];
        
        
        folderItemsArray = [[NSMutableArray alloc]init];
        boxInsideFolderArray = [[NSMutableArray alloc]init];
        if (!boxFolderId) {
            boxFolderId = BoxAPIFolderIDRoot;
            boxFolderName =@"All Files";
        }
        refreshToken = [BoxSDK sharedSDK].OAuth2Session.refreshToken;
        fetching = YES;
        [self checkExpiredBoxToken];
    }
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"google"])
    {
        self.driveFiles = [[NSMutableArray alloc]init];
        driveFilesArray = [[NSMutableArray alloc]init];
        driveFilePathsArray = [[NSMutableArray alloc]init];
        NSLog(@"google Drive");
        if (!driveFilesId)
        {
            driveFilesId = @"root";
        }
        [self loadDriveFiles:driveFilesId];
        // [[self class ]retrieveAllFilesWithService:[DropboxDownloadFileViewControlller getSharedInstance].driveService completionBlock:nil];
    }
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"ftp"])
    {
        NSLog(@"folder path is %@",ftpFolderPath);
        
        if (!ftpFolderName)
        {
            ftpFolderName = @"";
        }
        if (!ftpFolderPath) {
            ftpFolderPath = @"";
            
        }
        
        ftpListArray = [[NSMutableArray alloc]init];
        
        [self listDirectory:[arrUseraccounts objectAtIndex:[DropboxDownloadFileViewControlller getSharedInstance].index]];
        
    }
}
#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"dropbox"])
    {
        if (!loadData)
        {
            loadData = @"";
        }
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dbEditing = YES;
        
        [self performSelector:@selector(fetchAllDropboxData) withObject:nil afterDelay:.1];
        self.title = [[[AppDelegate sharedInstance] dicUserdetails] objectForKey:@"username"];
    }
    
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"box"])
    {
        
        NSLog(@"refresh token is %@",[[AppDelegate sharedInstance ] appdelRefreshToken]);
        NSLog(@"Box name");
        boxFilesItemsArray = [[NSMutableArray alloc]init];
        root = @"";
        boxFilePath =@"";
    }
    
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"google"])
    {
        boxFilesItemsArray = [[NSMutableArray alloc]init];
    }
    
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"ftp"])
    {
        ftpListArray = [[NSMutableArray alloc]init];
        ftpFilePathsArray = [[NSMutableArray alloc]init];
        boxFilesItemsArray = [[NSMutableArray alloc]init];
    }
    
    pdfValue = 0;
    filesCount = 0;
    pdfCount = 0;
    itemCount = 0;
    marrDownloadData = [[NSMutableArray alloc] init];
    arrmetadata = [[NSMutableArray alloc] init];
    self.filePathsArray = [[NSMutableArray alloc ]init];
    boxFilePathsArray = [[NSMutableArray alloc]init];
    arrtimers = [[NSMutableArray alloc] init];
    
    
    
    columns = [[NSMutableArray alloc] init];
    sqliteFilesArray = [[NSMutableArray alloc]init];
    sqliteRowsArray = [[NSMutableArray alloc ]init];
    folderPath =  [[NSMutableArray alloc ]init] ;
    
    arrLocalFilepaths = [[NSMutableDictionary alloc] init];
    
    
    self.tbDownload.allowsSelectionDuringEditing=YES;
    
    
    editButton = [[UIBarButtonItem alloc]
                  initWithTitle:@"Edit"
                  style:UIBarButtonItemStyleBordered
                  target:self
                  action:@selector(editBarButton_clickk:)];
    editBarButton.title = @"Edit";
    self.navigationItem.rightBarButtonItem = editButton;
    
}

-(BOOL)checkExpiredBoxToken
{
    
    NSInteger secRemaining ;
    
    NSDate* date1 = [[arrUseraccounts objectAtIndex:[DropboxDownloadFileViewControlller getSharedInstance].index] objectForKey:@"expire_date"];
    NSDate* date2 = [NSDate date];
    NSTimeInterval distanceBetweenDates = [date1 timeIntervalSinceDate:date2];
    double secondsInAnHour = 60;
    secRemaining = distanceBetweenDates / secondsInAnHour;
    
    NSLog(@"access token expires in %d mins",secRemaining);
    
    if (secRemaining <2)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSLog(@"Time to create new access token");
        [self createNewAccesToken];
    }
    else
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [self fetchFolderItemsWithFolderID:boxFolderId name:boxFolderName];
        
    }
    return secRemaining;
}
-(void)createNewAccesToken
{
    
    /*
     
     curl https://www.box.com/api/oauth2/token
     -d 'grant_type=refresh_token&refresh_token={valid refresh token}&client_id={your_client_id}&client_secret={your_client_secret}'
     -X POST
     
     */
    
    
    NSString* refresh =[NSString stringWithFormat:@"%@",[[arrUseraccounts objectAtIndex:[DropboxDownloadFileViewControlller getSharedInstance].index] objectForKey:@"refresh_token"]];
    
    
    NSString* clientId =[NSString stringWithFormat:@"%@",[BoxSDK sharedSDK].OAuth2Session.clientID];
    NSString* clientSecret =[NSString stringWithFormat:@"%@", [BoxSDK sharedSDK].OAuth2Session.clientSecret];
    
    ASIFormDataRequest *postParams = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"https://www.box.com/api/oauth2/token?"]];
    
    [postParams setRequestMethod:@"POST"];
    
    [postParams setPostValue:@"refresh_token" forKey:@"grant_type"];
    [postParams setPostValue:refresh forKey:@"refresh_token"];
    [postParams setPostValue:clientId forKey:@"client_id"];
    [postParams setPostValue:clientSecret forKey:@"client_secret"];
    
    [postParams startAsynchronous];
    postParams.delegate = self ;
    postParams.userInfo = [NSDictionary dictionaryWithObject:@"accessToken" forKey:@"id"];
    
    NSLog(@"Url is ---> %@",postParams.url);
    NSLog(@"response string is-----> %@",postParams.responseString);
    
    
    
}
#pragma mark FTP Methods

-(void)listDirectory:(id)sender
{
    NSLog(@"sender is %@",sender);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    listDir = [[BRRequestListDirectory alloc] initWithDelegate:self];
    listDir.hostname = [sender objectForKey:@"host"];
    listDir.path = ftpFolderName;
    listDir.username = [sender objectForKey:@"name"];
    listDir.password = [sender objectForKey:@"password"];
    [listDir start];
    
}

- (void) requestDataAvailable: (BRRequestDownload *) request;
{
    [downloadData appendData: request.receivedData];
}





//-----
//
//				percentCompleted
//
// synopsis:	[self percentCompleted:request];
//					BRRequest *request	-
//
// description:	percentCompleted is designed to
//
// errors:		none
//
// returns:		none
//

- (void) percentCompleted: (BRRequest *) request
{
    NSLog(@"%f completed...", request.percentCompleted);
    NSLog(@"%ld bytes this iteration", request.bytesSent);
    NSLog(@"%ld total bytes", request.totalBytesSent);
}



//-----
//
//				requestDataSendSize
//
// synopsis:	retval = [self requestDataSendSize:request];
//					long retval             	-
//					BRRequestUpload *request	-
//
// description:	requestDataSendSize is designed to
//
// important:   This is an optional method when uploading. It is purely used
//              to help calculate the percent completed.
//
//              If this method is missing, then the send size defaults to LONG_MAX
//              or about 2 gig.
//
// errors:		none
//
// returns:		Variable of type long
//

- (long) requestDataSendSize: (BRRequestUpload *) request
{
    //----- user returns the total size of data to send. Used ONLY for percentComplete
    return [uploadData length];
}



//-----
//
//				requestDataToSend
//
// synopsis:	retval = [self requestDataToSend:request];
//					NSData *retval          	-
//					BRRequestUpload *request	-
//
// description:	requestDataToSend is designed to hand off the BR the next block
//              of data to upload to the FTP server. It continues to call this
//              method for more data until nil is returned.
//
// important:   This is a required method for uploading data to an FTP server.
//              If this method is missing, it you will get a runtime error indicating
//              this method is missing.
//
// errors:		none
//
// returns:		Variable of type NSData *
//

- (NSData *) requestDataToSend: (BRRequestUpload *) request
{
    //----- returns data object or nil when complete
    //----- basically, first time we return the pointer to the NSData.
    //----- and BR will upload the data.
    //----- Second time we return nil which means no more data to send
    NSData *temp = uploadData;                                                  // this is a shallow copy of the pointer, not a deep copy
    
    uploadData = nil;                                                           // next time around, return nil...
    
    return temp;
}



//-----
//
//				requestCompleted
//
// synopsis:	[self requestCompleted:request];
//					BRRequest *request	-
//
// description:	requestCompleted is designed to
//
// errors:		none
//
// returns:		none
//

-(void) requestCompleted: (BRRequest *) request
{
    
    
    if (request == createDir)
    {
        NSLog(@"%@ completed!", request);
        
        createDir = nil;
        [self viewWillAppear:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DropboxCreateFolderSuccess" object:self userInfo:nil];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        
    }
    
    if (request == deleteDir)
    {
        NSLog(@"%@ completed!", request);
        
        deleteDir = nil;
        // [tbDownload reloadData];
        [self viewWillAppear:YES];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
    }
    
    if (request == listDir)
    {
        //called after 'request' is completed successfully
        NSLog(@"%@ completed!", request);
        if ([ftpStatus isEqualToString:@"Downloading"])
        {
            for (NSDictionary *file in listDir.filesInfo)
            {
                NSString * name = [file objectForKey:(id)kCFFTPResourceName];
                
                if ([[name pathExtension] isEqualToString:@""])
                {
                    
                    NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
                    [dic setObject:name forKey:@"folderName"];
                    [dic setObject:@"folder" forKey:@"type"];
                    [dic setObject:[NSString stringWithFormat:@"%@/",root] forKey:@"path"];
                    [boxFilesItemsArray addObject: dic];
                    
                }
                else
                {
                    NSString * ext = @"pdf";
                    if ([[[file objectForKey:(id)kCFFTPResourceName] pathExtension ]isEqualToString:@""]||[[[[file objectForKey:(id)kCFFTPResourceName]lowercaseString]pathExtension]isEqualToString:ext])
                    {
                        NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
                        [dic setObject:name forKey:@"folderName"];
                        [dic setObject:@"file" forKey:@"type"];
                        [dic setObject:[NSString stringWithFormat:@"%@/",root] forKey:@"path"];
                        [boxFilesItemsArray addObject: dic];
                    }
                }
            }
            
            if ([ftpFilePathsArray count]>0) {
                
                [ftpFilePathsArray removeObjectAtIndex:0];
                root = @"";
                
            }
            if ([ftpFilePathsArray count]>0) {
                [self downloadFromFTPServer];
                
            }
            else
            {
                [self performSelector:@selector(closeFtpControllerr) withObject:nil afterDelay:0];
                
            }
            
            
        }
        else
        {
            //we print each of the files name
            for (NSDictionary *file in listDir.filesInfo)
            {
                NSLog(@"%@", [file objectForKey:(id)kCFFTPResourceName]);
                NSString * ext = @"pdf";
                if ([[[file objectForKey:(id)kCFFTPResourceName] pathExtension ]isEqualToString:@""]||[[[[file objectForKey:(id)kCFFTPResourceName]lowercaseString]pathExtension]isEqualToString:ext])
                {
                    [ftpListArray addObject:[file objectForKey:(id)kCFFTPResourceName]];
                    
                }
                FolderItem *item = [[FolderItem alloc] init];
                item.isChecked = NO;
                [arrmetadata addObject:item];
            }
            [tbDownload reloadData];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            listDir = nil;
            [self performSelector:@selector(postNoftifier) withObject:self afterDelay:0.5 ];
            
        }
        
        
        
    }
    if (request == downloadFile)
    {
        //called after 'request' is completed successfully
        NSLog(@"%@ completed!", request);
        
        NSError *error;
        
        
        if ([ftpStatus isEqualToString:@"Downloading"])
        {
            
            NSString *filePath;
            
            filePath  = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",root,downloadingName]];
            [downloadData writeToFile:filePath atomically:YES];
            
            downloadData = nil;
            downloadFile = nil;
            [[NSNotificationCenter defaultCenter]postNotificationName:@"BGDownloadSuccess" object:nil];
            
            if ([ftpFilePathsArray count]>0) {
                
                [self pdfThumbnail:filePath];
                
                [ftpFilePathsArray removeObjectAtIndex:0];
                root = @"";
                
            }
            if ([ftpFilePathsArray count]>0) {
                [self downloadFromFTPServer];
                
            }
            else
            {
                [self performSelector:@selector(closeFtpControllerr) withObject:nil afterDelay:0];
                
            }
        }
        else
        {
            
        }
        
    }
    
    
    if (request == deleteFile)
    {
        NSLog(@"%@ completed!", request);
        deleteFile = nil;
        //[tbDownload reloadData];
        [self viewWillAppear:YES];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
    }
    
}



//-----
//
//				requestFailed
//
// synopsis:	[self requestFailed:request];
//					BRRequest *request	-
//
// description:	requestFailed is designed to
//
// errors:		none
//
// returns:		none
//

-(void) requestFailed:(BRRequest *) request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DropboxCreateFolderSuccess" object:self userInfo:nil];
    
    if (request == createDir)
    {
        NSLog(@"%@", request.error.message);
        
        createDir = nil;
    }
    
    if (request == deleteDir)
    {
        NSLog(@"%@", request.error.message);
        
        deleteDir = nil;
    }
    
    if (request == listDir)
    {
        
        NSLog(@"%@", request.error.message);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        listDir = nil;
    }
    
    if (request == downloadFile)
    {
        NSLog(@"%@", request.error.message);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        downloadFile = nil;
    }
    
    
    if (request == deleteFile)
    {
        NSLog(@"%@", request.error.message);
        deleteFile = nil;
    }
}

#pragma mark Drive Methods

- (void)loadDriveFiles:(NSString *)folderId {
    
    if([DriveHelperClass getSharedInstance].driveService.authorizer == nil)
    {
        [DriveHelperClass getSharedInstance].driveService = [[GTLServiceDrive alloc] init];
        [DriveHelperClass getSharedInstance].driveService.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeyChainItemName
                                                                                                                             clientID:kClientID
                                                                                                                         clientSecret:kClientSecret];
    }
    
    NSLog(@"drive service %@",[DriveHelperClass getSharedInstance].driveService.authorizer);
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
    // or mimeType ='text/directory'
    query.q = @"mimeType = 'application/pdf' and mimeType='application/vnd.google-apps.folder'";
    
    query.q = [NSString stringWithFormat:@"'%@' IN parents", folderId];
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[DriveHelperClass getSharedInstance].driveService executeQuery:query
                                                  completionHandler:^(GTLServiceTicket *ticket,
                                                                      GTLDriveFileList *files,
                                                                      NSError *error) {
                                                      
                                                      if (!error) {
                                                          self.driveFiles = [[NSMutableArray alloc]init];
                                                          [self.driveFiles addObjectsFromArray:files.items];
                                                          if ([self.driveFiles count]==0)
                                                          {
                                                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                              
                                                          }
                                                          for (int i =0;i<[driveFiles count]; i++)
                                                          {
                                                              GTLDriveFile * file =[self.driveFiles objectAtIndex:i];
                                                              NSDictionary * dic = file.JSON;
                                                              NSLog(@"dic is %@",dic);
                                                              NSString * str = file.mimeType;
                                                              
                                                              //  NSString * strExtension = @"pdf";
                                                              if ([str isEqualToString:@"application/pdf"]||[str isEqualToString:@"application/vnd.google-apps.folder"])
                                                              {
                                                                  NSLog(@"file id %@ ",file.identifier);
                                                                  NSLog(@"file title %d is %@",i,str);
                                                                  
                                                                  NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
                                                                  [dic setObject:file.identifier
                                                                          forKey:@"id"];
                                                                  [dic setObject:file.title                                                                        forKey:@"title"];
                                                                  [dic setObject:str                                                                        forKey:@"mimeType"];
                                                                  [dic setObject:file.description                                                                        forKey:@"description"];
                                                                  
                                                                  // [dic setObject:file.downloadUrl forKey:@"url"];
                                                                  [driveFilesArray addObject:dic];
                                                                  
                                                              }
                                                              
                                                              FolderItem *item = [[FolderItem alloc] init];
                                                              item.isChecked = NO;
                                                              [arrmetadata addObject:item];
                                                              [self performSelector:@selector(postNoftifier) withObject:self afterDelay:0.5 ];
                                                              
                                                              [tbDownload reloadData];
                                                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                              
                                                          }
                                                          
                                                      } else {
                                                          
                                                          NSLog(@"An error occurred: %@", error);
                                                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                      }
                                                  }];
    
    //[MBProgressHUD hideHUDForView:self.view animated:YES];
    
    
}
-(void)addFileMetaDataInfo:(GTLDriveFile*)file numberOfChilderns:(int)totalChildren
{
    NSString *fileName = @"";
    NSString *downloadURL = @"";
    
    BOOL isFolder = NO;
    
    if (file.originalFilename.length)
        fileName = file.originalFilename;
    else
        fileName = file.title;
    
    if ([file.mimeType isEqualToString:@"application/vnd.google-apps.folder"]) {
        isFolder = YES;
    } else {
        //the file download url not exists for native google docs. Sicne we can set the import file mime type
        //here we set the mime as pdf. Since we can download the file content in the form of pdf
        if (!file.downloadUrl) {
            GTLDriveFileExportLinks *fileExportLinks;
            
            NSString    *exportFormat = @"application/pdf";
            
            fileExportLinks = [file exportLinks];
            downloadURL = [fileExportLinks JSONValueForKey:exportFormat];
        } else {
            downloadURL = file.downloadUrl;
        }
    }
    
    if (![fileNames containsObject:fileName]) {
        [fileNames addObject:fileName];
        
        NSArray *fileInfoArray = [NSArray arrayWithObjects:file.identifier, file.mimeType, downloadURL,
                                  [NSNumber numberWithBool:isFolder], nil];
        NSDictionary *dict = [NSDictionary dictionaryWithObject:fileInfoArray forKey:fileName];
        
        [self.driveFiles addObject:dict];
    }
}


+ (void)retrieveAllFilesWithService:(GTLServiceDrive *)service
                    completionBlock:(void (^)(NSArray *, NSError *))completionBlock {
    // The service can be set to automatically fetch all pages of the result. More information
    // can be found on <a href="https://code.google.com/p/google-api-objectivec-client/wiki/Introduction#Result_Pages">https://code.google.com/p/google-api-objectivec-client/wiki/Introduction#Result_Pages</a>.
    service.shouldFetchNextPages = YES;
    
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
    // queryTicket can be used to track the status of the request.
    GTLServiceTicket *queryTicket =
    [service executeQuery:query
        completionHandler:^(GTLServiceTicket *ticket, GTLDriveFileList *files,
                            NSError *error) {
            if (error == nil) {
                completionBlock(files.items, nil);
            } else {
                NSLog(@"An error occurred: %@", error);
                completionBlock(nil, error);
            }
        }];
}

#pragma mark - Box Methods

- (void)fetchFolderItemsWithFolderID:(NSString *)folderID name:(NSString *)name
{
    
    //  https://api.box.com/2.0/folders/0/items?access_token=fYw4Qab6szMbkFkHCUUPUvlagcYwOpw9
    
    
    NSString *str=  [NSString stringWithFormat:@"https://api.box.com/2.0/folders/%@/items?limit=2000&offset=0&access_token=%@",folderID,[[arrUseraccounts objectAtIndex:[DropboxDownloadFileViewControlller getSharedInstance].index] objectForKey:@"acces_token"]];
    
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:str]
                                                  cachePolicy:NSURLCacheStorageAllowed
                                              timeoutInterval:20];
    NSURLResponse *response;
    NSError *error;
    
    NSData * data = [NSURLConnection sendSynchronousRequest:request
                                          returningResponse:&response
                                                      error:&error];
    
    NSMutableDictionary *userdata = [[NSMutableDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error]];
    
    int totalcount =[[userdata objectForKey:@"total_count"]integerValue];
    int limit =[[userdata objectForKey:@"limit"]integerValue];
    int rowCount = 0;
    if (totalcount>limit)
    {
        rowCount = limit;
    }
    else
    {
        rowCount = totalcount;
    }
    for (int p = 0;p <rowCount;p++)
    {
        if ([[[[userdata objectForKey:@"entries"] objectAtIndex:p] objectForKey:@"type"] isEqualToString:@"folder"])
        {
            
            [folderItemsArray addObject: [[userdata objectForKey:@"entries"] objectAtIndex:p]];
            
        }
        else if ([[[[userdata objectForKey:@"entries"] objectAtIndex:p]objectForKey:@"type"] isEqualToString:@"file"])
        {
            NSString * str =[[[userdata objectForKey:@"entries"] objectAtIndex:p] objectForKey:@"name"];
            if ([[str pathExtension] isEqualToString:@"pdf"]||[[str pathExtension]isEqualToString:@"PDF"]||[[str pathExtension]isEqualToString:@"Pdf"])
            {
                [folderItemsArray addObject: [[userdata objectForKey:@"entries"] objectAtIndex:p]];
                
                
            }
        }
        FolderItem *item = [[FolderItem alloc] init];
        item.isChecked = NO;
        [arrmetadata addObject:item];
        
    }
    if (fetching == YES) {
        [tbDownload reloadData];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
    [self performSelector:@selector(postNoftifier) withObject:self afterDelay:0.5 ];
    
    
}
-(void)postNoftifier
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"popStatusNotification" object:self];
    
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    
}

#pragma mark - View Disappear



-(void)viewDidDisappear:(BOOL)animated
{
    
    if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"dropbox"])
    {
        if (tbDownload.isEditing) {
            [tbDownload setEditing:NO animated:YES];
            editBarButton.title = @"Edit";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkControllerCancel"
                                                                object:self];
            
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CreateFolderClick" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeleteClick" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RenameClick" object:nil];
        
        //[[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"box"])
    {
        //[[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CreateFolderClick" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RenameClick" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeleteClick" object:nil];
        
        NSLog(@"Box");
    }
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"google"])
    {
        //[[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CreateFolderClick" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RenameClick" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeleteClick" object:nil];
        
        NSLog(@"google");
    }
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"ftp"])
    {
        //[[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CreateFolderClick" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RenameClick" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeleteClick" object:nil];
        
        NSLog(@"ftp");
    }
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"sugarsync"])
    {
        //[[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CreateFolderClick" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RenameClick" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeleteClick" object:nil];
        
        NSLog(@"sugarsync");
    }
    
}

#pragma mark - Edit Click

-(void)editBarButton_clickk:(id)sender
{
    UIBarButtonItem *btn = (UIBarButtonItem *)sender;
    NSLog(@"%@",btn.title);
    
    if([btn.title isEqualToString:@"Edit"])
    {
        btn.title=@"Cancel";
        
        if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"dropbox"])
        {
            for (int i =0; i< [marrDownloadData count]; i++) {
                
                DBMetadata *data = [marrDownloadData objectAtIndex:i];
                
                
                
                
                NSLog(@"selected %@",data.path);
                
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                FileItemTableCell *cell = (FileItemTableCell*)[tbDownload cellForRowAtIndexPath:newIndexPath];
                
                FolderItem* item = [arrmetadata objectAtIndex:i];
                item.isChecked = NO;
                [cell setChecked:item.isChecked];
                
                [tbDownload reloadData];
                
            }
            [tbDownload setEditing:YES animated:YES];
            [tbDownload performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
            
            [filePathsArray removeAllObjects];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkController"
                                                                object:self];
            
            
        }
        if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"box"])
            
        {
            
            for (int i =0; i< [folderItemsArray count]; i++) {
                
                // DBMetadata *data = [marrDownloadData objectAtIndex:i];
                //NSLog(@"selected %@",data.path);
                
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                FileItemTableCell *cell = (FileItemTableCell*)[tbDownload cellForRowAtIndexPath:newIndexPath];
                
                FolderItem* item = [arrmetadata objectAtIndex:i];
                item.isChecked = NO;
                [cell setChecked:item.isChecked];
                
                [tbDownload reloadData];
                
            }
            [tbDownload setEditing:YES animated:YES];
            [tbDownload performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
            
            [boxFilePathsArray removeAllObjects];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkController"
                                                                object:self];
            
        }
        if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"google"])
            
        {
            for (int i =0; i< [driveFilesArray count]; i++) {
                
                // DBMetadata *data = [marrDownloadData objectAtIndex:i];
                //NSLog(@"selected %@",data.path);
                
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                FileItemTableCell *cell = (FileItemTableCell*)[tbDownload cellForRowAtIndexPath:newIndexPath];
                
                FolderItem* item = [arrmetadata objectAtIndex:i];
                item.isChecked = NO;
                [cell setChecked:item.isChecked];
                
                [tbDownload reloadData];
                
            }
            [tbDownload setEditing:YES animated:YES];
            [tbDownload performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
            
            [driveFilePathsArray removeAllObjects];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkController"
                                                                object:self];
            
            
            
        }
        else
        {
            for (int i =0; i< [ftpListArray count]; i++) {
                
                // DBMetadata *data = [marrDownloadData objectAtIndex:i];
                //NSLog(@"selected %@",data.path);
                
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                FileItemTableCell *cell = (FileItemTableCell*)[tbDownload cellForRowAtIndexPath:newIndexPath];
                
                FolderItem* item = [arrmetadata objectAtIndex:i];
                item.isChecked = NO;
                [cell setChecked:item.isChecked];
                
                [tbDownload reloadData];
                
            }
            [tbDownload setEditing:YES animated:YES];
            [tbDownload performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
            
            [ftpFilePathsArray removeAllObjects];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkController"
                                                                object:self];
            
        }
    }
    
    else{
        btn.title=@"Edit";
        [tbDownload setEditing:NO animated:YES];
        // [tbDownload performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkControllerCancel"
                                                            object:self];
        
        
    }
    
    //self.editing=YES;
    NSLog(@"=%d",self.editing);
    // [super setEditing:!self.editing animated:YES];
    //[self.tableView setEditing:YES animated:YES];
}

#pragma mark - Dropbox Methods



-(void)fetchAllDropboxData
{
    DropboxManager *dbManager = [DropboxManager dbManager];
    [dbManager restClient].delegate = self;
    [[dbManager restClient] loadMetadata:loadData];
}
-(void)downloadFromdropbox
{
    //[self performSelector:@selector(spinner) withObject:nil];
    
    for (int indexx = 0; indexx<[filePathsArray count]; indexx++)
    {
        NSLog(@"mnmnmnmnmn %@",[filePathsArray objectAtIndex:indexx]);
        NSString *filename;
        if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"dropbox"])
        {
            // NSArray *array = [[filePathsArray objectAtIndex:indexx] componentsSeparatedByString:@"/"];
            filename = [filePathsArray objectAtIndex:indexx];
        }
        
        if ([sqliteRowsArray containsObject:filename])
        {
            [dropBoxOperationQueue cancelAllOperations];
            [DownloadingSingletonClass getSharedInstance].dropBoxDownload = YES;
 
            [self performSelectorOnMainThread:@selector(boxShowAlert:) withObject:filename waitUntilDone:NO];
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            for (int i =0; i< [marrDownloadData count]; i++) {
                
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                FileItemTableCell *cell = (FileItemTableCell*)[tbDownload cellForRowAtIndexPath:newIndexPath];
                
                FolderItem* item = [arrmetadata objectAtIndex:i];
                item.isChecked = NO;
                [cell setChecked:item.isChecked];
                
                [tbDownload reloadData];
                
            }
            
            [filePathsArray removeAllObjects];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NoFiles" object:self];
            
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            
            break;
            
            
            
        }
        else
        {
            if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"dropbox"])
            {
                
                [self downloadFileFromDropBox:[filePathsArray objectAtIndex:indexx]];
                
            }
        }
    }
    while ([DownloadingSingletonClass getSharedInstance].dropBoxDownload == NO)
    {
        NSLog(@"thread is running .....");
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
}
-(void)downloadFileFromDropBox:(NSString *)filePath
{
    
    [self docDataToDisplay];
    
    arrdownlaodfiels = [[NSMutableArray alloc] init];
    NSArray *array = [filePath componentsSeparatedByString:@"/"];
    NSString *filename = [array lastObject];
    
    NSLog(@"check %@",sqliteRowsArray);
    NSLog(@"sdsd %@",filename);
    if ([sqliteRowsArray containsObject:filename])
    {
        
        [self performSelectorOnMainThread:@selector(boxShowAlert:) withObject:filename waitUntilDone:YES];
        [DownloadingSingletonClass getSharedInstance].dropBoxDownload = YES;
        [dropBoxOperationQueue cancelAllOperations];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        
        for (int i =0; i< [marrDownloadData count]; i++) {
            
            DBMetadata *data = [marrDownloadData objectAtIndex:i];
            
            
            if ([data.path isEqualToString:[NSString stringWithFormat:@"/%@",filename]] ) {
                
                
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                FileItemTableCell *cell = (FileItemTableCell*)[tbDownload cellForRowAtIndexPath:newIndexPath];
                
                FolderItem* item = [arrmetadata objectAtIndex:i];
                item.isChecked = NO;
                
                
                [cell setChecked:item.isChecked];
                [tbDownload reloadData];
                
                
                break;
                
            }
            
        }
        
        
        if ([[filePathsArray objectAtIndex:pdfCount] isEqualToString:filePath] ) {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
        }
        
    }
    
    else
    {
        NSLog(@"downloading filepath is %@",filePath);
        
        
        pdfCount = pdfCount + 1;
        
        for (int i = 0; i<[arrtimers count]; i++){
            
            NSTimer *timerobj  = (NSTimer *)[arrtimers objectAtIndex:i];
            [timerobj invalidate];
            timerobj = nil;
        }
        timer = [NSTimer scheduledTimerWithTimeInterval: 5
                                                 target: self
                                               selector: @selector(checkProcess)
                                               userInfo: nil
                                                repeats: YES];
        [arrtimers addObject:timer];
        
        strrootpath = nil;
        
        DropboxManager *dbManager = [DropboxManager dbManager];
        [dbManager restClient].delegate = self;
        [[dbManager restClient] loadMetadata:filePath withHash:hash];
        
        
        
    }
    
}

-(void)checkProcess
{
    
    if (bisprocessing) {
    }
    else
    {
        
        DropboxManager *dbManager = [DropboxManager dbManager];
        [dbManager restClient].delegate = self;
        for (int i = 0; i<[arrtimers count]; i++) {
            
            NSTimer *timerobj  = (NSTimer *)[arrtimers objectAtIndex:i];
            [timerobj invalidate];
            timerobj = nil;
        }
        
        //  for (int i = 0; i< [arrdownlaodfiels count]; i++) {
        
        if ([arrdownlaodfiels count]!=0) {
            
            [[dbManager restClient] loadFile:[[arrdownlaodfiels objectAtIndex:0] objectForKey:@"dropboxpath"] intoPath:[[arrdownlaodfiels objectAtIndex:0] objectForKey:@"documentspath"]];
            
        }
        
        // }
        
        
        
        
    }
}
-(void)docDataToDisplay
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *directoryContent = [[NSFileManager defaultManager] directoryContentsAtPath: documentsDirectory];
    
    NSArray * tempArray = [[NSArray alloc ]init];
    for (int k =0; k<[directoryContent count ]; k++)
    {
        NSString * str = [directoryContent objectAtIndex:k];
        tempArray =  [str componentsSeparatedByString:@","];
        NSLog(@"%@",tempArray);
        for (int j = 0;j<[tempArray count]; j++)
        {
            if ([sqliteRowsArray containsObject:[tempArray objectAtIndex:j]])
            {
                
            }
            else
            {
                [sqliteRowsArray addObject:[NSString stringWithFormat:@"/%@",[tempArray objectAtIndex:j]]];
                
            }
            
        }
        
    }
}

-(NSString*)getDoumentPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    
    return documentsDirectory;
}



#pragma mark - DBRestClientDelegate Methods for Load Data
- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata *)metadata
{
    hash=metadata.hash;
    if(!tbDownload.editing&&dbEditing == YES){
        for (int i = 0; i < [metadata.contents count]; i++) {
            DBMetadata *data = [metadata.contents objectAtIndex:i];
            if ([[data.path pathExtension]isEqualToString:@"pdf"]||[[data.path pathExtension]isEqualToString:@""]||[[data.path pathExtension]isEqualToString:@"PDF"])
            {
                [marrDownloadData addObject:data];
                
            }
            
            FolderItem *item = [[FolderItem alloc] init];
            item.isChecked = NO;
            [arrmetadata addObject:item];
            
        }
        [self performSelector:@selector(postNoftifier) withObject:self afterDelay:0.5 ];
        
    }
    
    else{
        
        bisprocessing = true;
        NSError * error;
        NSString *dataPath = [self getDoumentPath];
        
        
        NSString *strDirPath=[dataPath stringByAppendingPathComponent:metadata.path];
        
        if ([[arrLocalFilepaths objectForKey:metadata.path] length]>0) {
            
            wastepath = [arrLocalFilepaths objectForKey:metadata.path];
            
        }
        
        if ([wastepath length]>0) {
            strDirPath = [strDirPath stringByReplacingOccurrencesOfString:wastepath withString:@""];
        }
        // NSString *strDirPath=[dataPath stringByAppendingPathComponent:[self getDropBoxDirectoryPath:metadata.path withfilename:metadata.filename]];
        NSLog(@"check meta data %@",[self getDropBoxDirectoryPath:metadata.path withfilename:metadata.filename]);
        
        if (strrootpath == nil) {
            strrootpath = metadata.path;
        }
        
        if(metadata.isDirectory){
            if (![[NSFileManager defaultManager] fileExistsAtPath:strDirPath])
                [[NSFileManager defaultManager] createDirectoryAtPath:strDirPath withIntermediateDirectories:NO attributes:nil error:&error];
            bisprocessing = false;
        }
        else{
            bisprocessing = false;
            // [[self restClient] loadFile:metadata.path intoPath:strDirPath];
            NSDictionary *dic = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:metadata.path,strDirPath, nil] forKeys:[NSArray arrayWithObjects:@"dropboxpath",@"documentspath", nil]];
            
            NSLog(@"dropbox downloading path ectension is %@",metadata.path);
            NSString * downloadingFileExt = [metadata.path lastPathComponent];
            downloadingFileExt=[downloadingFileExt uppercaseString];
            if ([downloadingFileExt isEqualToString:@"PDF"]) {
            [arrdownlaodfiels addObject:dic];
            }
        }
        
        for (DBMetadata* child in [metadata.contents reverseObjectEnumerator]) {
            NSString *path = child.path;
            
            NSLog(@"path for childs %@",path);
            
            if (!child.isDirectory) {
                
                strDirPath= [dataPath stringByAppendingPathComponent:path];
                
                if ([wastepath length]>0) {
                    strDirPath = [strDirPath stringByReplacingOccurrencesOfString:wastepath withString:@""];
                }
                
                
                //    strDirPath= [dataPath stringByAppendingPathComponent:[self getDropBoxDirectoryPath:path withfilename:metadata.filename]];
                NSLog(@"check this  path for childs %@",strDirPath);
                
                
                NSDictionary *dic = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:path,strDirPath, nil] forKeys:[NSArray arrayWithObjects:@"dropboxpath",@"documentspath", nil]];
                
                NSLog(@"dropbox downloading path ectension is %@",path);
                NSString * downloadingFileExt = [path lastPathComponent];
                if ([[[downloadingFileExt pathExtension] uppercaseString] isEqualToString:@"PDF"]) {
                    [arrdownlaodfiels addObject:dic];
                    bisprocessing = false;
                }
                
              
                
            } else {
                
                strDirPath= [dataPath stringByAppendingPathComponent:path];
                
                
                
                if ([wastepath length]>0) {
                    strDirPath = [strDirPath stringByReplacingOccurrencesOfString:wastepath withString:@""];
                }
                
                
                //  strDirPath= [dataPath stringByAppendingPathComponent:[self getDropBoxDirectoryPath:path withfilename:child.filename]];
                
                bisprocessing = true;
                
                if (![[NSFileManager defaultManager] fileExistsAtPath:strDirPath])
                    [[NSFileManager defaultManager] createDirectoryAtPath:strDirPath withIntermediateDirectories:NO attributes:nil error:&error];
                
                
                DropboxManager *dbManager = [DropboxManager dbManager];
                [dbManager restClient].delegate = self;
                [[dbManager restClient] loadMetadata:child.path withHash:hash];
                
                
            }
        }
    }
    NSLog(@"check the rocking  %@",arrdownlaodfiels);
    [tbDownload reloadData];
    if ([filePathsArray count]==0)
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
    }
    
    
}

-(NSString*)getDropBoxDirectoryPath:(NSString*)path withfilename:(NSString *)filename{
    NSString *haystack = path;
    
    NSString *prefix = filename;
    NSRange prefixRange = [haystack rangeOfString:prefix];
    
    NSRange needleRange = NSMakeRange(prefixRange.location,haystack.length - prefixRange.location);
    NSString *needle = [haystack substringWithRange:needleRange];
    NSLog(@"needle: %@", needle);
    return needle;
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error
{
    [DownloadingSingletonClass getSharedInstance].dropBoxDownload =YES;
    [tbDownload reloadData];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - DBRestClientDelegate Methods Load File for Download Data
- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)destPath
{
    
    NSLog(@"file path is %@",[destPath lastPathComponent]);

  
    NSLog(@"%@",filePathsArray);
    if ([arrdownlaodfiels count] != 0) {
        
        NSLog(@"path extension is  %@",[[arrdownlaodfiels objectAtIndex:0] objectForKey:@"dropboxpath"]);
        
        
        [self pdfThumbnail:[[arrdownlaodfiels objectAtIndex:0] objectForKey:@"documentspath"]];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"BGDownloadSuccess" object:nil];
        [arrdownlaodfiels removeObjectAtIndex:0];
    }
    
    if ([arrdownlaodfiels count] != 0) {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        DropboxManager *dbManager = [DropboxManager dbManager];
        [dbManager restClient].delegate = self;
        
        [[dbManager restClient] loadFile:[[arrdownlaodfiels objectAtIndex:0] objectForKey:@"dropboxpath"] intoPath:[[arrdownlaodfiels objectAtIndex:0] objectForKey:@"documentspath"]];

      
    }
    filesCount = filesCount + 1;
    
    if (arrdownlaodfiels == nil || [arrdownlaodfiels count] == 0)
    {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [DownloadingSingletonClass getSharedInstance].dropBoxDownload = YES;
        NSLog(@"Thread is stopped.....");
        
        [arrLocalFilepaths removeAllObjects];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Download Success" object:destPath];
        [self.navigationController popViewControllerAnimated:YES];
        
        
    }
    //[MBProgressHUD hideHUDForView:self.view animated:YES];
    
}

-(void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error
{
    [DownloadingSingletonClass getSharedInstance].dropBoxDownload  = YES;
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Download"
                                                   message:@"Failed to download"
                                                  delegate:nil
                                         cancelButtonTitle:@"Ok"
                                         otherButtonTitles:nil];
    [alert show];
    
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
}

#pragma mark - UITableView Delegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"dropbox"])
    {
        return [marrDownloadData count];
        
    }
    
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"box"])
    {
        NSLog(@"Box");
        
        if ([folderItemsArray count]>0)
        {
            return [ folderItemsArray count];
            
        }       else{
            
            return 0;
            
        }
        
    }
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"google"])
    {
        return [driveFilesArray count];
        
    }
    if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"ftp"])
    {
        return [ftpListArray count];
        
    }
    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"dropbox"])
    {
        
        FileItemTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Dropbox_Cell"];
        
        
        DBMetadata *metadata = [marrDownloadData objectAtIndex:indexPath.row];
        
        
        
        [cell.btnIcon setTitle:metadata.path forState:UIControlStateDisabled];
        //[cell.btnIcon addTarget:self action:@selector(btnDownloadPress:) forControlEvents:UIControlEventTouchUpInside];
        
        FolderItem* item = [arrmetadata objectAtIndex:indexPath.row];
        
        if (tableView.editing)
        {
            [cell setChecked:item.isChecked];
        }
        
        if (metadata.isDirectory) {
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.imageView.image = [UIImage imageNamed:@"folder.png"];
            
        }else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.btnIcon.hidden = NO;
            cell.imageView.image = [UIImage imageNamed:@"pdf.png"];
            
        }
        
        cell.lblTitle.text = metadata.filename;
        
        return cell;
    }
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"box"])
        
    {
        FileItemTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Dropbox_Cell"];
        
        [cell.btnIcon setTitle:[[[[folderItemsArray objectAtIndex:0] objectForKey:@"entries"] objectAtIndex:indexPath.row] objectForKey:@"name"] forState:UIControlStateDisabled];
        
        FolderItem* item = [arrmetadata objectAtIndex:indexPath.row];
        
        if (tableView.editing)
        {
            [cell setChecked:item.isChecked];
        }
        cell.lblTitle.text = [[folderItemsArray objectAtIndex:indexPath.row] objectForKey:@"name"];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.btnIcon.hidden = NO;
        if ([[[folderItemsArray objectAtIndex:indexPath.row]objectForKey:@"type"]isEqualToString:@"folder"]) {
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.imageView.image = [UIImage imageNamed:@"folder.png"];
            
        }else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.btnIcon.hidden = NO;
            cell.imageView.image = [UIImage imageNamed:@"pdf.png"];
            
        }
        return cell;
        
    }
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"google"])
        
    {
        FileItemTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Dropbox_Cell"];
        
        [cell.btnIcon setTitle:[[[[folderItemsArray objectAtIndex:0] objectForKey:@"entries"] objectAtIndex:indexPath.row] objectForKey:@"name"] forState:UIControlStateDisabled];
        
        FolderItem* item = [arrmetadata objectAtIndex:indexPath.row];
        
        if (tableView.editing)
        {
            [cell setChecked:item.isChecked];
        }
        cell.lblTitle.text = [[driveFilesArray objectAtIndex:indexPath.row] objectForKey:@"title"];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.btnIcon.hidden = NO;
        
        NSString * str = [[driveFilesArray objectAtIndex:indexPath.row]objectForKey:@"title"];
        if ([[str pathExtension]isEqualToString:@"pdf"])
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.btnIcon.hidden = NO;
            cell.imageView.image = [UIImage imageNamed:@"pdf.png"];
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.imageView.image = [UIImage imageNamed:@"folder.png"];
            
        }
        
        return cell;
    }
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"ftp"])
    {
        FileItemTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Dropbox_Cell"];
        
        [cell.btnIcon setTitle:[ftpListArray objectAtIndex:indexPath.row] forState:UIControlStateDisabled];
        
        FolderItem* item = [arrmetadata objectAtIndex:indexPath.row];
        
        if (tableView.editing)
        {
            [cell setChecked:item.isChecked];
        }
        cell.lblTitle.text = [ftpListArray objectAtIndex:indexPath.row];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.btnIcon.hidden = NO;
        
        NSString * str = [ftpListArray objectAtIndex:indexPath.row];
        if ([[str pathExtension]isEqualToString:@"pdf"])
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.btnIcon.hidden = NO;
            cell.imageView.image = [UIImage imageNamed:@"pdf.png"];
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.imageView.image = [UIImage imageNamed:@"folder.png"];
            
        }
        
        return cell;
        
    }
    else
    {
        FileItemTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Dropbox_Cell"];
        
        [cell.btnIcon setTitle:[[[[folderItemsArray objectAtIndex:0] objectForKey:@"entries"] objectAtIndex:indexPath.row] objectForKey:@"name"] forState:UIControlStateDisabled];
        
        FolderItem* item = [arrmetadata objectAtIndex:indexPath.row];
        
        if (tableView.editing)
        {
            [cell setChecked:item.isChecked];
        }
        cell.lblTitle.text = [[driveFilesArray objectAtIndex:indexPath.row] objectForKey:@"title"];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.btnIcon.hidden = NO;
        
        NSString * str = [[driveFilesArray objectAtIndex:indexPath.row]objectForKey:@"title"];
        if ([[str pathExtension]isEqualToString:@"pdf"])
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.btnIcon.hidden = NO;
            cell.imageView.image = [UIImage imageNamed:@"pdf.png"];
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.imageView.image = [UIImage imageNamed:@"folder.png"];
            
        }
        
        return cell;
        
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"dropbox"])
    {
        
        FolderItem* item = [arrmetadata objectAtIndex:indexPath.row];
        DBMetadata *metadata = [marrDownloadData objectAtIndex:indexPath.row];
        
        NSLog(@"check this %@",[arrmetadata objectAtIndex:indexPath.row]);
        NSLog(@"fthis %@",[marrDownloadData objectAtIndex:indexPath.row]);
        if (tableView.editing)
        {
            FileItemTableCell *cell = (FileItemTableCell*)[tableView cellForRowAtIndexPath:indexPath];
            item.isChecked = !item.isChecked;
            
            DBMetadata *metadata = [marrDownloadData objectAtIndex:indexPath.row];
            folder_file=metadata.filename;
            [cell setChecked:item.isChecked];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if (metadata.isDirectory && !tableView.editing)
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            DropboxDownloadFileViewControlller *dropboxDownloadFileViewControlller = [storyboard instantiateViewControllerWithIdentifier:@"DropboxDownloadFileViewControlller"];
            dropboxDownloadFileViewControlller.loadData = metadata.path;
            [self.navigationController pushViewController:dropboxDownloadFileViewControlller animated:YES];
            
            [folderPath addObject:metadata.path];
            folderDocpath = metadata.path;
            NSLog(@"%@",folderPath);
            
        }
        else {
            
            //  UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
            
            if (item.isChecked == YES)
            {
                //selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
                [downloadingButton setTitle:metadata.path forState:UIControlStateDisabled];
                
                pdfValue = pdfValue+1;
                
                // NSString * str = [NSString stringWithFormat:@"Pdf%d",pdfValue] ;
                if (![filePathsArray containsObject:metadata.path])
                {
                    [filePathsArray addObject:metadata.path];
                    [arrLocalFilepaths setObject:loadData forKey:metadata.path];
                    
                }
            }
            else
                if (item.isChecked == NO)
                {
                    pdfValue = pdfValue-1;
                    
                    //selectedCell.accessoryType = UITableViewCellAccessoryNone;
                    if ([filePathsArray containsObject:metadata.path])
                    {
                        [filePathsArray removeObject:metadata.path] ;
                        [arrLocalFilepaths removeObjectForKey:metadata.path];
                        
                    }
                }
            
        }
        NSLog(@"Filepaths array is %@",filePathsArray);
        
        if ([filePathsArray count]==1)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SingleFile" object:self];
        }
        else if([filePathsArray count]>1)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MultipleFiles" object:self];
            
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NoFiles" object:self];
            
        }
        
        
    }
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"box"])
    {
        FolderItem* item = [arrmetadata objectAtIndex:indexPath.row];
        if (tableView.editing)
        {
            FileItemTableCell *cell = (FileItemTableCell*)[tableView cellForRowAtIndexPath:indexPath];
            item.isChecked = !item.isChecked;
            
            folder_file=[[folderItemsArray objectAtIndex:indexPath.row] objectForKey:@"name"];
            [cell setChecked:item.isChecked];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if ([[[folderItemsArray objectAtIndex:indexPath.row]objectForKey:@"type"] isEqualToString:@"folder"]&& !tableView.editing)
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            DropboxDownloadFileViewControlller *dropboxDownloadFileViewControlller = [storyboard instantiateViewControllerWithIdentifier:@"DropboxDownloadFileViewControlller"];
            dropboxDownloadFileViewControlller.boxFolderId = [[folderItemsArray objectAtIndex:indexPath.row] objectForKey:@"id"];
            dropboxDownloadFileViewControlller.boxFolderName = [[folderItemsArray objectAtIndex:indexPath.row] objectForKey:@"name"];
            [self.navigationController pushViewController:dropboxDownloadFileViewControlller animated:YES];
            
        }
        else
        {
            
            NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
            
            if (item.isChecked == YES)
            {
                //selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
                [downloadingButton setTitle:[[folderItemsArray objectAtIndex:indexPath.row] objectForKey:@"name"] forState:UIControlStateDisabled];
                
                pdfValue = pdfValue+1;
                
                if (![boxFilePathsArray containsObject:[[folderItemsArray objectAtIndex:indexPath.row] objectForKey:@"name"]])
                {
                    [dic setObject:[[folderItemsArray objectAtIndex:indexPath.row] objectForKey:@"id"] forKey:@"folderId"];
                    [dic setObject:[[folderItemsArray objectAtIndex:indexPath.row] objectForKey:@"name"] forKey:@"folderName"];
                    [dic setObject:[[folderItemsArray objectAtIndex:indexPath.row] objectForKey:@"type"] forKey:@"type"];
                    [dic setObject:[[folderItemsArray objectAtIndex:indexPath.row] objectForKey:@"etag"] forKey:@"etag"];
                    [dic setObject:@"/" forKey:@"path"];
                    [boxFilePathsArray addObject:dic];
                }
                [AppDelegate sharedInstance].boxSelectedFiles = boxFilePathsArray;
            }
            
            else
            {
                if (item.isChecked == NO)
                {
                    pdfValue = pdfValue-1;
                    
                    
                    for (int i =0; i<[self.boxFilePathsArray count]; i++)
                    {
                        
                        if ([[[folderItemsArray objectAtIndex:indexPath.row]objectForKey:@"name"] isEqualToString:[[boxFilePathsArray objectAtIndex:i]objectForKey:@"folderName"]]) {
                            [self.boxFilePathsArray removeObjectAtIndex:i];
                        }
                    }
                    [AppDelegate sharedInstance].boxSelectedFiles = boxFilePathsArray;
                }
            }
        }
        
        NSLog(@"boxFilePathsArray array is %@",boxFilePathsArray);
        
        
        
        
        if ([boxFilePathsArray count]==1)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SingleFile" object:self];
        }
        else if([boxFilePathsArray count]>1)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MultipleFiles" object:self];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NoFiles" object:self];
        }
        
    }
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"google"])
    {
        
        FolderItem* item = [arrmetadata objectAtIndex:indexPath.row];
        if (tableView.editing)
        {
            FileItemTableCell *cell = (FileItemTableCell*)[tableView cellForRowAtIndexPath:indexPath];
            item.isChecked = !item.isChecked;
            
            folder_file=[[driveFilesArray objectAtIndex:indexPath.row] objectForKey:@"title"];
            [cell setChecked:item.isChecked];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        NSString * str = [[driveFilesArray objectAtIndex:indexPath.row]objectForKey:@"mimeType"];
        if ([str isEqualToString:@"application/vnd.google-apps.folder"]&& !tableView.editing)
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            DropboxDownloadFileViewControlller *dropboxDownloadFileViewControlller = [storyboard instantiateViewControllerWithIdentifier:@"DropboxDownloadFileViewControlller"];
            dropboxDownloadFileViewControlller.driveFilesId = [[driveFilesArray objectAtIndex:indexPath.row] objectForKey:@"id"];
            [self.navigationController pushViewController:dropboxDownloadFileViewControlller animated:YES];
        }
        else
        {
            
            NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
            
            if (item.isChecked == YES)
            {
                //selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
                [downloadingButton setTitle:[[driveFilesArray objectAtIndex:indexPath.row] objectForKey:@"title"] forState:UIControlStateDisabled];
                
                pdfValue = pdfValue+1;
                
                if (![driveFilePathsArray containsObject:[[driveFilesArray objectAtIndex:indexPath.row] objectForKey:@"name"]])
                {
                    [dic setObject:[[driveFilesArray objectAtIndex:indexPath.row] objectForKey:@"id"] forKey:@"folderId"];
                    [dic setObject:[[driveFilesArray objectAtIndex:indexPath.row] objectForKey:@"title"] forKey:@"folderName"];
                    [dic setObject:[[driveFilesArray objectAtIndex:indexPath.row] objectForKey:@"mimeType"] forKey:@"type"];
                    [dic setObject:@"/" forKey:@"path"];
                    
                    [driveFilePathsArray addObject:dic];
                }
                //[AppDelegate sharedInstance].boxSelectedFiles = driveFilePathsArray;
            }
            
            else
            {
                if (item.isChecked == NO)
                {
                    pdfValue = pdfValue-1;
                    
                    
                    for (int i =0; i<[self.driveFilePathsArray count]; i++)
                    {
                        
                        if ([[[driveFilesArray objectAtIndex:indexPath.row]objectForKey:@"title"] isEqualToString:[[driveFilePathsArray objectAtIndex:i]objectForKey:@"folderName"]]) {
                            [self.driveFilePathsArray removeObjectAtIndex:i];
                        }
                    }
                    //[AppDelegate sharedInstance].boxSelectedFiles = boxFilePathsArray;
                }
            }
        }
        
        NSLog(@"boxFilePathsArray array is %@",driveFilePathsArray);
        
        if ([driveFilePathsArray count]==1)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SingleFile" object:self];
        }
        else if([driveFilePathsArray count]>1)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MultipleFiles" object:self];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NoFiles" object:self];
        }
        
        
    }
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"ftp"])
    {
        FolderItem* item = [arrmetadata objectAtIndex:indexPath.row];
        if (tableView.editing)
        {
            FileItemTableCell *cell = (FileItemTableCell*)[tableView cellForRowAtIndexPath:indexPath];
            item.isChecked = !item.isChecked;
            
            folder_file=[ftpListArray objectAtIndex:indexPath.row];
            [cell setChecked:item.isChecked];
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        NSString * str = [ftpListArray objectAtIndex:indexPath.row];
        if ([[str pathExtension] isEqualToString:@""]&& !tableView.editing)
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            DropboxDownloadFileViewControlller *dropboxDownloadFileViewControlller = [storyboard instantiateViewControllerWithIdentifier:@"DropboxDownloadFileViewControlller"];
            dropboxDownloadFileViewControlller.ftpFolderName = [ftpListArray objectAtIndex:indexPath.row];
            
            ftpFolderPath = [ftpFolderPath stringByAppendingString:[NSString stringWithFormat:@"/%@",dropboxDownloadFileViewControlller.ftpFolderName]];
            
            [AppDelegate sharedInstance].ftpDownloadpath =[ [AppDelegate sharedInstance].ftpDownloadpath stringByAppendingString:[NSString stringWithFormat:@"%@/",dropboxDownloadFileViewControlller.ftpFolderName]];
            NSLog(@"folder path is %@ and appdel is %@",ftpFolderPath,[AppDelegate sharedInstance].ftpDownloadpath);
            [self.navigationController pushViewController:dropboxDownloadFileViewControlller animated:YES];
        }
        else
        {
            NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
            
            if (item.isChecked == YES)
            {
                //selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
                [downloadingButton setTitle:[ftpListArray objectAtIndex:indexPath.row] forState:UIControlStateDisabled];
                
                pdfValue = pdfValue+1;
                
                if (![ftpFilePathsArray containsObject:[ftpListArray objectAtIndex:indexPath.row]])
                {
                    
                    [dic setObject:[ftpListArray objectAtIndex:indexPath.row] forKey:@"folderName"];
                    if ([[[ftpListArray objectAtIndex:indexPath.row]pathExtension]isEqualToString:@""]) {
                        [dic setObject:@"folder" forKey:@"type"];
                        
                    }
                    else
                    {
                        [dic setObject:@"file" forKey:@"type"];
                        
                    }
                    
                    [dic setObject:@"/" forKey:@"path"];
                    
                    [ftpFilePathsArray addObject:dic];
                }
                //[AppDelegate sharedInstance].boxSelectedFiles = driveFilePathsArray;
            }
            
            else
            {
                if (item.isChecked == NO)
                {
                    pdfValue = pdfValue-1;
                    
                    
                    for (int i =0; i<[self.ftpFilePathsArray count]; i++)
                    {
                        
                        if ([[ftpListArray objectAtIndex:indexPath.row] isEqualToString:[[ftpFilePathsArray objectAtIndex:i]objectForKey:@"folderName"]]) {
                            [self.ftpFilePathsArray removeObjectAtIndex:i];
                        }
                    }
                    //[AppDelegate sharedInstance].boxSelectedFiles = boxFilePathsArray;
                }
            }
        }
        
        NSLog(@"ftpFilePathsArray array is %@",ftpFilePathsArray);
        
        if ([ftpFilePathsArray count]==1)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SingleFile" object:self];
        }
        else if([ftpFilePathsArray count]>1)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MultipleFiles" object:self];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NoFiles" object:self];
        }
        
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

#pragma mark - Action Methods
-(IBAction)btnDownloadPress:(id)sender
{
    
}
-(void)spinner
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
}


-(IBAction)multipleFileDownload:(id)sender
{
    fetching = NO;
    [self docDataToDisplay];
    
    if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"dropbox"])
    {
        dbEditing = NO;
        dropBoxOperationQueue = [NSOperationQueue new];
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                selector:@selector(downloadFromdropbox)
                                                                                  object:nil];
        
        // Add the operation to the queue and let it to be executed.
        
        [operation setQueuePriority:NSOperationQueuePriorityVeryHigh];
        [dropBoxOperationQueue addOperation:operation];
        [DownloadingSingletonClass getSharedInstance].dropBoxDownload = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Download Success" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DocumentViewNotification" object:nil];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }
    
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"box"])
    {
        //[self performSelector:@selector(spinner) withObject:nil];
        
        NSLog(@"box files array %@",boxFilePathsArray);
        NSLog(@"temp array is %@",[AppDelegate sharedInstance].boxSelectedFiles);
        if (boxDownloadProcess == YES)
        {
            [self performSelectorOnMainThread:@selector(downloadInProgress) withObject:nil waitUntilDone:NO];
        }
        
        boxOperationQueue = [NSOperationQueue new];
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                selector:@selector(downloadfrombox)
                                                                                  object:nil];
        
        // Add the operation to the queue and let it to be executed.
        
        [operation setQueuePriority:NSOperationQueuePriorityVeryHigh];
        [boxOperationQueue addOperation:operation];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Download Success" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DocumentViewNotification" object:nil];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
        //  [[NSNotificationCenter defaultCenter] postNotificationName:@"Download Success" object:nil];
    }
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"google"])
    {
        NSLog(@"box files array %@",driveFilePathsArray);
        
        [self downloadFromDrive];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Download Success" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DocumentViewNotification" object:nil];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"ftp"])
    {
        NSLog(@"box files array %@",ftpFilePathsArray);
        //  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        ftpStatus = @"Downloading";
        
        ftpOperationQueue = [NSOperationQueue new];
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                selector:@selector(downloadFromFTPServer)
                                                                                  object:nil];
        
        // Add the operation to the queue and let it to be executed.
        
        [operation setQueuePriority:NSOperationQueuePriorityVeryHigh];
        [ftpOperationQueue addOperation:operation];
        ftpDownload = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Download Success" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DocumentViewNotification" object:nil];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
        
        // [self downloadFromFTPServer];
        
        
    }
}
-(void)downloadInProgress
{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Please Wait...." message:@"Downloading In Progress" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show ];
}
#pragma mark Box Download Methods

-(void)downloadfrombox
{
    NSString *filename = nil;
    
    NSLog(@"%@",[AppDelegate sharedInstance].boxSelectedFiles);
    if ([[AppDelegate sharedInstance].boxSelectedFiles count]>0)
    {
        filename = [[[AppDelegate sharedInstance].boxSelectedFiles objectAtIndex:0]objectForKey:@"folderName"];
        
        NSLog(@"%@",[[[AppDelegate sharedInstance].boxSelectedFiles objectAtIndex:0]objectForKey:@"path"]);
        
        NSString * str = [NSString stringWithFormat:@"%@%@",[[[AppDelegate sharedInstance].boxSelectedFiles objectAtIndex:0]objectForKey:@"path"],filename];
        if ([sqliteRowsArray containsObject:str])
        {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            
            [boxOperationQueue cancelAllOperations];
            [self performSelectorOnMainThread:@selector(boxShowAlert:) withObject:filename waitUntilDone:NO];
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            for (int i =0; i< [marrDownloadData count]; i++) {
                
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                FileItemTableCell *cell = (FileItemTableCell*)[tbDownload cellForRowAtIndexPath:newIndexPath];
                
                FolderItem* item = [arrmetadata objectAtIndex:i];
                item.isChecked = NO;
                [cell setChecked:item.isChecked];
                
                [tbDownload reloadData];
                
            }
            
            [[AppDelegate sharedInstance].boxSelectedFiles removeAllObjects];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NoFiles" object:self];
            
            
        }
        else
        {
            
            pdfCount = pdfCount + 1;
            filesCount = filesCount + 1;
            NSLog(@"files is %@",[[[AppDelegate sharedInstance].boxSelectedFiles objectAtIndex:0]objectForKey:@"folderName"]);
            NSString * folderId =[[[AppDelegate sharedInstance].boxSelectedFiles objectAtIndex:0]objectForKey:@"folderId"];
            NSString * folderName =[[[AppDelegate sharedInstance].boxSelectedFiles objectAtIndex:0]objectForKey:@"folderName"];
            NSString * type =[[[AppDelegate sharedInstance].boxSelectedFiles objectAtIndex:0]objectForKey:@"type"];
            
            if ([[[[AppDelegate sharedInstance].boxSelectedFiles objectAtIndex:0]objectForKey:@"path"] length]>0)
            {
                root = [[[AppDelegate sharedInstance].boxSelectedFiles objectAtIndex:0]objectForKey:@"path"];
            }
            
            if ([type isEqualToString:@"folder"])
            {
                boxDownloadingType = @"folder";
                [self downloadFilesWithFolderID:folderId name:folderName];
                boxFolderPath =[NSString stringWithFormat:@"/%@",folderName];
                root = [root stringByAppendingString:boxFolderPath];
                [self downloadableFolderFiles:folderId name:folderName];
                
            }
            
            else
            {
                boxDownloadingType = @"file";
                boxFolderPath = @"";
                itemCount = 0;
                [self downloadFilesWithFolderID:folderId name:folderName];
                
                if ([[AppDelegate sharedInstance].boxSelectedFiles count]>0) {
                    
                    NSString * filePath  = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",root,[[[AppDelegate sharedInstance].boxSelectedFiles objectAtIndex:0]objectForKey:@"folderName"]]];
                    NSLog(@"thumbnail file path is %@",filePath);
                    
                    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                        
                        NSError *error = nil;
                        
                        PDFThumbnail *pdfThumbnail=[[PDFThumbnail alloc]init];
                        [pdfThumbnail createThumbnailFromPDFFilePath:filePath];
                        
                        // Return to the main queue once the request has been processed.
                        
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            
                            if ( error )
                                NSLog(@"error");
                            else
                                NSLog(@"completed");
                            [[NSNotificationCenter defaultCenter]postNotificationName:@"BGDownloadSuccess" object:nil];
                            
                            
                        }];
                        
                        
                    }];
                    
                    // Optionally, set the operation priority. This is useful when flooding
                    // the operation queue with different requests.
                    
                    [operation setQueuePriority:NSOperationQueuePriorityNormal];
                    [boxOperationQueue addOperation:operation];
                    
                    
                    
                    [[AppDelegate sharedInstance].boxSelectedFiles removeObjectAtIndex:0];
                    root = @"";
                    
                }
                if ([[AppDelegate sharedInstance].boxSelectedFiles count]>0) {
                    
                    
                    [self downloadfrombox];
                    
                }
                else
                {
                    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                            selector:@selector(closeBoxControllerr)
                                                                                              object:nil];
                    
                    // Add the operation to the queue and let it to be executed.
                    
                    [operation setQueuePriority:NSOperationQueuePriorityVeryHigh];
                    [boxOperationQueue addOperation:operation];
                    
                    //  [self performSelector:@selector(closeBoxControllerr) withObject:nil afterDelay:0];
                    
                }
                
            }
        }
        
    }
    else
    {
        
        [self performSelector:@selector(closeBoxControllerr) withObject:nil afterDelay:0];
        
    }
}
-(void)boxShowAlert:(id)sender
{
    NSLog(@"sender is %@",sender);
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@",sender ] message:@"File Already Exists" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show ];
}

-(void)downloadableFolderFiles:(NSString *)folderID name:(NSString *)name
{
    
    NSString *str =  [NSString stringWithFormat:@"https://api.box.com/2.0/folders/%@/items?access_token=%@",folderID,[[arrUseraccounts objectAtIndex:[DropboxDownloadFileViewControlller getSharedInstance].index] objectForKey:@"acces_token"]];
    
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:str]
                                                  cachePolicy:NSURLCacheStorageAllowed
                                              timeoutInterval:20];
    
    
    NSURLResponse * response = nil;
    NSError * error = nil;
    
    NSData * data = [NSURLConnection sendSynchronousRequest:request
                                          returningResponse:&response
                                                      error:&error];
    
    if (error == nil)
    {
        
        NSMutableDictionary *userdata = [[NSMutableDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error]];
        
        for (int i = 0;i <[[userdata objectForKey:@"total_count"]integerValue];i++)
        {
            if ([[[[userdata objectForKey:@"entries"] objectAtIndex:i] objectForKey:@"type"] isEqualToString:@"folder"])
            {
                NSMutableDictionary * dic = [[NSMutableDictionary alloc] initWithDictionary:[[userdata objectForKey:@"entries"] objectAtIndex:i]];
                [dic setObject:[NSString stringWithFormat:@"%@",root] forKey:@"path"];
                [boxFilesItemsArray addObject: dic];
                
            }
            else if ([[[[userdata objectForKey:@"entries"] objectAtIndex:i]objectForKey:@"type"] isEqualToString:@"file"])
            {
                NSString * str =[[[userdata objectForKey:@"entries"] objectAtIndex:i] objectForKey:@"name"];
                if ([[str pathExtension] isEqualToString:@"pdf"]||[[str pathExtension]isEqualToString:@"PDF"])
                {
                    NSMutableDictionary * dic = [[NSMutableDictionary alloc] initWithDictionary:[[userdata objectForKey:@"entries"] objectAtIndex:i]];
                    [dic setObject:[NSString stringWithFormat:@"%@",root] forKey:@"path"];
                    [boxFilesItemsArray addObject: dic];
                }
            }
        }
        
        if ([[AppDelegate sharedInstance].boxSelectedFiles count]>0) {
            
            [[AppDelegate sharedInstance].boxSelectedFiles removeObjectAtIndex:0];
            root = @"";
            
        }
        if ([[AppDelegate sharedInstance].boxSelectedFiles count]>0) {
            
            
            [self downloadfrombox];
            
        }
        else
        {
            
            NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                    selector:@selector(closeBoxControllerr)
                                                                                      object:nil];
            
            // Add the operation to the queue and let it to be executed.
            
            [operation setQueuePriority:NSOperationQueuePriorityVeryHigh];
            [boxOperationQueue addOperation:operation];
            
            
            //[self performSelector:@selector(closeBoxControllerr) withObject:nil afterDelay:0];
            
            
            
        }
        
    }
    
}

- (void)downloadFilesWithFolderID:(NSString *)folderID name:(NSString *)name
{
    
    arrdownlaodfiels = [[NSMutableArray alloc] init];
    
    
    NSLog(@"check %@",sqliteRowsArray);
    NSLog(@"sdsd %@",folderID);
    if ([sqliteRowsArray containsObject:name])
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@",name ] message:@"File Already Exists" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show ];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        for (int i =0; i< [folderItemsArray count]; i++) {
            
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            FileItemTableCell *cell = (FileItemTableCell*)[tbDownload cellForRowAtIndexPath:newIndexPath];
            
            FolderItem* item = [arrmetadata objectAtIndex:i];
            item.isChecked = NO;
            
            
            
            [cell setChecked:item.isChecked];
            
            [tbDownload reloadData];
            
            
            break;
            
        }
        
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        fetching = YES;
        
    }
    else
    {
        NSLog(@"downloading filename is %@",name);
        
        if ([self checkExpiredBoxToken] <2)
        {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            NSLog(@"Time to create new access token");
            [self createNewAccesToken];
        }
        
        NSString *str =  [NSString stringWithFormat:@"https://api.box.com/2.0/files/%@/content?access_token=%@",folderID,[[arrUseraccounts objectAtIndex:[DropboxDownloadFileViewControlller getSharedInstance].index] objectForKey:@"acces_token"]];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:str]
                                                      cachePolicy:NSURLCacheStorageAllowed
                                                  timeoutInterval:20];
        NSURLResponse *response;
        NSError *error;
        
        NSData * data = [NSURLConnection sendSynchronousRequest:request
                                              returningResponse:&response
                                                          error:&error];
        NSString *filePath;
        if ([boxDownloadingType isEqualToString:@"file"])
        {
            filePath  = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",root,name]];
            [data writeToFile:filePath atomically:YES];
            
        }
        else
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
            if (boxFolderPath == nil) {
                boxFolderPath = @"";
            }
            
            NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",root,name]];
            if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
                [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
            [data writeToFile:dataPath atomically:YES];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"BGDownloadSuccess" object:nil];
            
            
        }
        
        
    }
}

-(void)closeBoxControllerr
{
    
    if ([boxFilesItemsArray count]>0)
    {
        [[AppDelegate sharedInstance].boxSelectedFiles removeAllObjects];
        
        NSLog(@"%@",root);
        //  boxFilePath = root;
        for (int k = 0; k<[boxFilesItemsArray count]; k++)
        {
            NSLog(@"%d",[boxFilesItemsArray count]);
            NSString * folderId =  [[boxFilesItemsArray objectAtIndex:k] objectForKey:@"id"];
            NSString *   folderName =  [[boxFilesItemsArray objectAtIndex:k]objectForKey:@"name"];
            NSString *    type =  [[boxFilesItemsArray objectAtIndex:k]objectForKey:@"type"];
            
            NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
            [dic setObject:folderId forKey:@"folderId"];
            [dic setObject:folderName forKey:@"folderName"];
            [dic setObject:type forKey:@"type"];
            [dic setObject:[[boxFilesItemsArray objectAtIndex:k]objectForKey:@"path"] forKey:@"path"];
            [[AppDelegate sharedInstance].boxSelectedFiles addObject:dic];
            
            
        }
        
        
        [boxFilesItemsArray removeAllObjects];
        [self multipleFileDownload:nil];
        
    }
    
    if ([driveFilePathsArray count]==0 && [boxFilesItemsArray count]==0)
    {
        boxDownloadProcess = NO;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [driveFilePathsArray removeAllObjects];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Download Success" object:nil];
        [boxOperationQueue cancelAllOperations];
        // [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}
#pragma mark - Drive Download

-(void)downloadFromDrive
{
    NSString *filename = nil;
    
    NSLog(@"%@",driveFilePathsArray);
    if ([driveFilePathsArray count]>0)
    {
        filename = [[driveFilePathsArray objectAtIndex:0]objectForKey:@"folderName"];
        
        NSLog(@"%@",[[driveFilePathsArray objectAtIndex:0]objectForKey:@"path"]);
        
        NSString * str = [NSString stringWithFormat:@"%@%@",[[driveFilePathsArray objectAtIndex:0]objectForKey:@"path"],filename];
        if ([sqliteRowsArray containsObject:str])
        {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@",filename ] message:@"File Already Exists" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show ];
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            for (int i =0; i< [marrDownloadData count]; i++) {
                
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                FileItemTableCell *cell = (FileItemTableCell*)[tbDownload cellForRowAtIndexPath:newIndexPath];
                
                FolderItem* item = [arrmetadata objectAtIndex:i];
                item.isChecked = NO;
                [cell setChecked:item.isChecked];
                
                [tbDownload reloadData];
                
            }
            
            [driveFilePathsArray removeAllObjects];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NoFiles" object:self];
            
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            
        }
        else
        {
            
            pdfCount = pdfCount + 1;
            filesCount = filesCount + 1;
            NSLog(@"files is %@",[[driveFilePathsArray objectAtIndex:0]objectForKey:@"folderName"]);
            NSString * folderId =[[driveFilePathsArray objectAtIndex:0]objectForKey:@"folderId"];
            NSString * folderName =[[driveFilePathsArray objectAtIndex:0]objectForKey:@"folderName"];
            NSString * type =[[driveFilePathsArray objectAtIndex:0]objectForKey:@"type"];
            
            if ([[[driveFilePathsArray objectAtIndex:0]objectForKey:@"path"] length]>0)
            {
                root = [[driveFilePathsArray objectAtIndex:0]objectForKey:@"path"];
            }
            if ([type isEqualToString:@"application/vnd.google-apps.folder"])
            {
                boxDownloadingType = @"folder";
                [self driveFolderDownload:folderName];
                
                boxFolderPath =[NSString stringWithFormat:@"%@",folderName];
                root = [root stringByAppendingString:boxFolderPath];
                [self getFileMetadataWithService:folderId];
                
                // [self downloadableFolderFiles:folderId name:folderName];
                
            }
            
            else
            {
                boxDownloadingType = @"file";
                boxFolderPath = @"";
                itemCount = 0;
                
                [self getFileMetadataWithService:folderId];
                
                
            }
        }
        
    }
    else
    {
        [self performSelector:@selector(closeDriveControllerr) withObject:nil afterDelay:0];
        
    }
    
}
-(void)driveFolderDownload:(NSString *)name
{
    arrdownlaodfiels = [[NSMutableArray alloc] init];
    
    
    NSLog(@"check %@",sqliteRowsArray);
    if ([sqliteRowsArray containsObject:name])
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@",name ] message:@"File Already Exists" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show ];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        for (int i =0; i< [folderItemsArray count]; i++) {
            
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            FileItemTableCell *cell = (FileItemTableCell*)[tbDownload cellForRowAtIndexPath:newIndexPath];
            
            FolderItem* item = [arrmetadata objectAtIndex:i];
            item.isChecked = NO;
            
            
            
            [cell setChecked:item.isChecked];
            
            [tbDownload reloadData];
            
            
            break;
            
        }
        
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        fetching = YES;
        
    }
    else
    {
        NSError * error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
        if (boxFolderPath == nil) {
            boxFolderPath = @"";
        }
        
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",root,name]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
    }
}

-(void)driveChildFiles:(NSString *) folderId
{
    
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
    query.q = @"mimeType = 'application/pdf' and mimeType='application/vnd.google-apps.folder'";
    query.q = [NSString stringWithFormat:@"'%@' IN parents", folderId];
    
    [[DriveHelperClass getSharedInstance].driveService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
                                                                                              GTLDriveFileList *files,
                                                                                              NSError *error)
     {
         
         self.driveFiles = [[NSMutableArray alloc]init];
         [self.driveFiles addObjectsFromArray:files.items];
         if ([self.driveFiles count]==0)
         {
             
         }
         for (int i =0;i<[driveFiles count]; i++)
         {
             GTLDriveFile * file =[self.driveFiles objectAtIndex:i];
             NSString * str = file.mimeType;
             if ([str isEqualToString:@"application/pdf"]||[str isEqualToString:@"application/vnd.google-apps.folder"])
             {
                 NSLog(@"file id %@ ",file.identifier);
                 NSLog(@"file %d Type is %@",i,str);
                 
                 NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
                 
                 [dic setObject:file.identifier forKey:@"folderId"];
                 [dic setObject:file.title forKey:@"folderName"];
                 [dic setObject:str forKey:@"type"];
                 [dic setObject:[NSString stringWithFormat:@"%@/",root] forKey:@"path"];
                 [boxFilesItemsArray addObject: dic];
                 
             }
         }
         
         if ([driveFilePathsArray count]>0) {
             
             [driveFilePathsArray removeObjectAtIndex:0];
             root = @"";
             
         }
         if ([driveFilePathsArray count]>0) {
             [self downloadFromDrive];
             
         }
         else
         {
             [self performSelector:@selector(closeDriveControllerr) withObject:nil afterDelay:0];
             
         }
         
     }];
    
    
    
    
}
-(void)getFileMetadataWithService:(NSString *)fileId
{
    GTLQuery *query = [GTLQueryDrive queryForFilesGetWithFileId:fileId];
    [[DriveHelperClass getSharedInstance].driveService executeQuery:query
                                                  completionHandler:^(GTLServiceTicket *ticket, GTLDriveFile *file,
                                                                      NSError *error) {
                                                      if (error == nil) {
                                                          NSLog(@"Title: %@", file.title);
                                                          NSLog(@"Description: %@", file.descriptionProperty);
                                                          NSLog(@"MIME type: %@", file.mimeType);
                                                          NSLog(@"download url:%@",file.downloadUrl);
                                                          NSLog(@"export link:%@",file.exportLinks);
                                                          if ([file.mimeType isEqualToString:@"application/vnd.google-apps.folder"])
                                                          {
                                                              [self driveChildFiles:fileId];
                                                          }
                                                          else
                                                          {
                                                              [self downloadFileContentWithService:@"example"
                                                                                              file:file];
                                                          }
                                                          
                                                      } else {
                                                          NSLog(@"An error occurred: %@", error);
                                                      }
                                                  }];
    
    
}


-(void)downloadFileContentWithService:(NSString *)loaclpath
                                 file:(GTLDriveFile *)file
{
    
    // NSLog(@"download file");
    NSLog(@"downloading file is %@",file.title);
    arrdownlaodfiels = [[NSMutableArray alloc] init];
    
    if ([sqliteRowsArray containsObject:file.title])
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@",file.title ] message:@"File Already Exists" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show ];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        for (int i =0; i< [driveFilesArray count]; i++) {
            
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            FileItemTableCell *cell = (FileItemTableCell*)[tbDownload cellForRowAtIndexPath:newIndexPath];
            
            FolderItem* item = [arrmetadata objectAtIndex:i];
            item.isChecked = NO;
            
            [cell setChecked:item.isChecked];
            
            [tbDownload reloadData];
            
            
            break;
            
        }
        
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        fetching = YES;
        
    }
    else
    {
        if (file.downloadUrl != nil)
        {
            NSLog(@"begin download");
            GTMHTTPFetcher *fetcher =[[DriveHelperClass getSharedInstance].driveService.fetcherService fetcherWithURLString:file.downloadUrl];
            
            
            NSString * filePath  = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",root,file.title]];
            
            //fetcher.downloadPath =filePath;
            [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
                if (error == nil) {
                    NSLog(@"download ok");
                    [data writeToFile:filePath atomically:YES];
                    
                    PDFThumbnail *pdfThumbnail=[[PDFThumbnail alloc]init];
                    [pdfThumbnail createThumbnailFromPDFFilePath:filePath];
                    
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"BGDownloadSuccess" object:nil];
                    if ([driveFilePathsArray count]==0) {
                        
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"BGDownloadSuccess" object:nil];
                    }
                } else {
                    NSLog(@"An error occurred: %@", error);
                }
            }];
        }
        else
        {
            NSLog(@"folder ");
        }
    }
    
    if ([driveFilePathsArray count]>0) {
        
        
        [driveFilePathsArray removeObjectAtIndex:0];
        root = @"";
        
    }
    if ([driveFilePathsArray count]>0) {
        [self downloadFromDrive];
        
    }
    else
    {
        [self performSelector:@selector(closeDriveControllerr) withObject:nil afterDelay:0];
        
    }
    
}

-(void)pdfThumbnail:(NSString *)filepath
{
    
    NSLog(@"thumbnail file path is %@",filepath);
    PDFThumbnail *pdfThumbnail=[[PDFThumbnail alloc]init];
    [pdfThumbnail createThumbnailFromPDFFilePath:filepath];
    
    
    
}
-(void)closeDriveControllerr
{
    if ([boxFilesItemsArray count]>0)
    {
        [[AppDelegate sharedInstance].boxSelectedFiles removeAllObjects];
        
        NSLog(@"%@",root);
        //  boxFilePath = root;
        for (int k = 0; k<[boxFilesItemsArray count]; k++)
        {
            // NSLog(@"files inside folder is %@",boxFilesItemsArray);
            NSString * folderId =  [[boxFilesItemsArray objectAtIndex:k] objectForKey:@"folderId"];
            NSString *   folderName =  [[boxFilesItemsArray objectAtIndex:k]objectForKey:@"folderName"];
            NSString *    type =  [[boxFilesItemsArray objectAtIndex:k]objectForKey:@"type"];
            
            NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
            [dic setObject:folderId forKey:@"folderId"];
            [dic setObject:folderName forKey:@"folderName"];
            [dic setObject:type forKey:@"type"];
            [dic setObject:[[boxFilesItemsArray objectAtIndex:k]objectForKey:@"path"] forKey:@"path"];
            [driveFilePathsArray addObject:dic];
            
        }
        [boxFilesItemsArray removeAllObjects];
        [self multipleFileDownload:nil];
        
    }
    
    if ([driveFilePathsArray count]==0 && [boxFilesItemsArray count]==0)
    {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [driveFilePathsArray removeAllObjects];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Download Success" object:nil];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - Ftp Download

-(void)downloadFromFTPServer
{
    NSString *filename = nil;
    
    NSLog(@"%@",ftpFilePathsArray);
    if ([ftpFilePathsArray count]>0)
    {
        filename = [[ftpFilePathsArray objectAtIndex:0]objectForKey:@"folderName"];
        
        NSLog(@"%@",[[ftpFilePathsArray objectAtIndex:0]objectForKey:@"path"]);
        
        NSString * str = [NSString stringWithFormat:@"%@%@",[[ftpFilePathsArray objectAtIndex:0]objectForKey:@"path"],filename];
        if ([sqliteRowsArray containsObject:str])
        {
            [ftpOperationQueue cancelAllOperations];
            ftpDownload = YES;
            NSLog(@"FTP thread is stopped ................ ");
            [self performSelectorOnMainThread:@selector(boxShowAlert:) withObject:filename waitUntilDone:NO];
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            for (int i =0; i< [marrDownloadData count]; i++) {
                
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                FileItemTableCell *cell = (FileItemTableCell*)[tbDownload cellForRowAtIndexPath:newIndexPath];
                
                FolderItem* item = [arrmetadata objectAtIndex:i];
                item.isChecked = NO;
                [cell setChecked:item.isChecked];
                
                [tbDownload reloadData];
                
            }
            
            [ftpFilePathsArray removeAllObjects];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NoFiles" object:self];
            
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            
        }
        else
        {
            
            pdfCount = pdfCount + 1;
            filesCount = filesCount + 1;
            NSLog(@"files is %@",[[ftpFilePathsArray objectAtIndex:0]objectForKey:@"folderName"]);
            // NSString * folderId =[[ftpFilePathsArray objectAtIndex:0]objectForKey:@"folderId"];
            NSString * folderName =[[ftpFilePathsArray objectAtIndex:0]objectForKey:@"folderName"];
            NSString * type =[[ftpFilePathsArray objectAtIndex:0]objectForKey:@"type"];
            
            if ([[[ftpFilePathsArray objectAtIndex:0]objectForKey:@"path"] length]>0)
            {
                root = [[ftpFilePathsArray objectAtIndex:0]objectForKey:@"path"];
            }
            if ([type isEqualToString:@"folder"])
            {
                boxDownloadingType = @"folder";
                [self ftpFolderDownload:folderName];
                boxFolderPath =[NSString stringWithFormat:@"%@",folderName];
                root = [root stringByAppendingString:boxFolderPath];
                //[self getFileMetadataWithService:folderName];
                
            }
            
            else
            {
                boxDownloadingType = @"file";
                boxFolderPath = @"";
                itemCount = 0;
                [self downloadFileContentFtp:folderName];
                
            }
        }
        
        while (ftpDownload==NO)
        {
            NSLog(@"Ftp thread Running ............ ");
            
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        
    }
    else
    {
        [self performSelector:@selector(closeFtpControllerr) withObject:nil afterDelay:0];
        
    }
    
}
-(void)ftpFolderDownload:(NSString *)name
{
    arrdownlaodfiels = [[NSMutableArray alloc] init];
    
    
    NSLog(@"check %@",sqliteRowsArray);
    if ([sqliteRowsArray containsObject:name])
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@",name ] message:@"File Already Exists" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show ];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        for (int i =0; i< [folderItemsArray count]; i++) {
            
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            FileItemTableCell *cell = (FileItemTableCell*)[tbDownload cellForRowAtIndexPath:newIndexPath];
            
            FolderItem* item = [arrmetadata objectAtIndex:i];
            item.isChecked = NO;
            
            
            
            [cell setChecked:item.isChecked];
            
            [tbDownload reloadData];
            
            
            break;
            
        }
        
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        fetching = YES;
        
    }
    else
    {
        NSError * error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
        if (boxFolderPath == nil) {
            boxFolderPath = @"";
        }
        
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",root,name]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"BGDownloadSuccess" object:nil];
        
        listDir = [[BRRequestListDirectory alloc] initWithDelegate:self];
        listDir.hostname = [[arrUseraccounts objectAtIndex:[DropboxDownloadFileViewControlller getSharedInstance].index] objectForKey:@"host"];
        listDir.path = [NSString stringWithFormat:@"%@/%@",root,name];
        listDir.username = [[arrUseraccounts objectAtIndex:[DropboxDownloadFileViewControlller getSharedInstance].index] objectForKey:@"name"];
        listDir.password = [[arrUseraccounts objectAtIndex:[DropboxDownloadFileViewControlller getSharedInstance].index] objectForKey:@"password"];
        [listDir start];
    }
    
}


-(void)downloadFileContentFtp:(NSString *)file

{
    
    // NSLog(@"download file");
    NSLog(@"downloading file is %@",file);
    arrdownlaodfiels = [[NSMutableArray alloc] init];
    
    if ([sqliteRowsArray containsObject:file])
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@",file ] message:@"File Already Exists" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show ];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        for (int i =0; i< [ftpListArray count]; i++) {
            
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            FileItemTableCell *cell = (FileItemTableCell*)[tbDownload cellForRowAtIndexPath:newIndexPath];
            
            FolderItem* item = [arrmetadata objectAtIndex:i];
            item.isChecked = NO;
            
            [cell setChecked:item.isChecked];
            
            [tbDownload reloadData];
            
            
            break;
            
        }
        
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        fetching = YES;
        
    }
    else
    {
        
        downloadData = [NSMutableData dataWithCapacity: 1];
        
        
        NSString*fname = [[ftpFilePathsArray objectAtIndex:0] objectForKey:@"folderName"];
        
        if ([[fname pathExtension]isEqualToString:@""])
        {
            
        }
        else
        {
            downloadFile = [[BRRequestDownload alloc] initWithDelegate:self];
            
            downloadFile.hostname = [[arrUseraccounts objectAtIndex:[DropboxDownloadFileViewControlller getSharedInstance].index] objectForKey:@"host"];
            
            if (!ftpFolderPath) {
                ftpFolderPath = @"";
            }
            else
            {
                fname = [NSString stringWithFormat:@"/%@",fname];
                
            }
            downloadFile.path =  [NSString stringWithFormat:@"%@%@",root,fname];
            //   downloadFile.path = [NSString stringWithFormat:@"%@%@",ftpFolderPath,fname];
            downloadingName = fname;
            downloadFile.username = [[arrUseraccounts objectAtIndex:[DropboxDownloadFileViewControlller getSharedInstance].index] objectForKey:@"name"];
            downloadFile.password = [[arrUseraccounts objectAtIndex:[DropboxDownloadFileViewControlller getSharedInstance].index] objectForKey:@"password"];
            
            [downloadFile start];
            
        }
        
    }
    
}
-(void)closeFtpControllerr
{
    
    
    if ([boxFilesItemsArray count]>0)
    {
        [[AppDelegate sharedInstance].boxSelectedFiles removeAllObjects];
        
        NSLog(@"%@",root);
        //  boxFilePath = root;
        for (int k = 0; k<[boxFilesItemsArray count]; k++)
        {
            // NSLog(@"files inside folder is %@",boxFilesItemsArray);
            NSString *   folderName =  [[boxFilesItemsArray objectAtIndex:k]objectForKey:@"folderName"];
            NSString *    type =  [[boxFilesItemsArray objectAtIndex:k]objectForKey:@"type"];
            
            NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
            [dic setObject:folderName forKey:@"folderName"];
            [dic setObject:type forKey:@"type"];
            [dic setObject:[[boxFilesItemsArray objectAtIndex:k]objectForKey:@"path"] forKey:@"path"];
            [ftpFilePathsArray addObject:dic];
            
        }
        [boxFilesItemsArray removeAllObjects];
        [self multipleFileDownload:nil];
        
    }
    
    if ([ftpFilePathsArray count]==0 && [boxFilesItemsArray count]==0)
    {
        ftpStatus = @"Downloaded";
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [ftpFilePathsArray removeAllObjects];
        ftpDownload = YES;
        NSLog(@"Ftp thread stopped ............ ");
        [[NSNotificationCenter defaultCenter]postNotificationName:@"BGDownloadSuccess" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Download Success" object:nil];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}


#pragma mark - Create Folder

-(void)createFolder
{
    // [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CreateFolderClick" object:nil];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Create Folder"
                                                    message:@"Enter folder name"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Done",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 1;
    [alert show];
    
}
-(void)folder
{
    if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"dropbox"])
    {
        
        DropboxManager *dbManager = [DropboxManager dbManager];
        [dbManager restClient].delegate = self;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        // For error information
        
        [[dbManager restClient] createFolder:tempString];
        
        
        [tbDownload setEditing:NO];
        editButton.title = @"Edit";
        
        [filePathsArray removeAllObjects];
        
        pdfValue = 0;
        
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        for (int i =0; i< [arrmetadata count]; i++) {
            
            FolderItem *item = (FolderItem *)[arrmetadata objectAtIndex:i];
            item.isChecked = NO;
            
        }
    }
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"box"])
    {
        
        /*
         curl https://api.box.com/2.0/folders \
         -H "Authorization: Bearer ACCESS_TOKEN" \
         -d '{"name":"New Folder", "parent": {"id": "0"}}' \
         -X POST
         */
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        
        NSString * accessToken =  [[arrUseraccounts objectAtIndex:[DropboxDownloadFileViewControlller getSharedInstance].index] objectForKey:@"acces_token"];
        
        NSDictionary *cid = [[NSDictionary alloc] initWithObjectsAndKeys:tempString,@"name",[NSDictionary dictionaryWithObject:boxFolderId forKey:@"id"],@"parent", nil];
        NSError *error;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:cid options:0 error:&error];
        
        NSMutableData *data = [[NSMutableData alloc] initWithData:postData];
        
        ASIFormDataRequest *postParams = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.box.com/2.0/folders?access_token=%@",accessToken]]];
        [postParams setPostBody:data];
        [postParams setRequestMethod:@"POST"];
        [postParams startAsynchronous];
        postParams.delegate = self ;
        postParams.userInfo = [NSDictionary dictionaryWithObject:@"CreateFolder" forKey:@"id"];
        
        NSLog(@"Url is ---> %@",postParams.url);
        NSLog(@"response string is-----> %@",postParams.responseString);
        
        
        
        
        [tbDownload setEditing:NO];
        editButton.title = @"Edit";
        
        pdfValue = 0;
        
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        for (int i =0; i< [arrmetadata count]; i++) {
            
            FolderItem *item = (FolderItem *)[arrmetadata objectAtIndex:i];
            item.isChecked = NO;
            
        }
        
    }
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"google"])
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        GTLDriveFile *folderObj = [GTLDriveFile object];
        folderObj.title = tempString;
        folderObj.mimeType = @"application/vnd.google-apps.folder";
        
        // To create a folder in a specific parent folder, specify the identifier
        // of the parent:
        // _resourceId is the identifier from the parent folder
        if (driveFilesId.length && ![driveFilesId isEqualToString:@"0"]) {
            GTLDriveParentReference *parentRef = [GTLDriveParentReference object];
            parentRef.identifier = driveFilesId;
            folderObj.parents = [NSArray arrayWithObject:parentRef];
        }
        
        GTLQueryDrive *query = [GTLQueryDrive queryForFilesInsertWithObject:folderObj uploadParameters:nil];
        GTLServiceTicket *queryTicket =
        [[DriveHelperClass getSharedInstance].driveService executeQuery:query
                                                      completionHandler:^(GTLServiceTicket *ticket, id object,
                                                                          NSError *error) {
                                                          if (!error) {
                                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"DropboxCreateFolderSuccess" object:self userInfo:nil];
                                                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                              [self viewWillAppear:YES];
                                                              [tbDownload reloadData];                }
                                                          else
                                                          {
                                                              NSLog(@"error %@",error);
                                                          }
                                                      }];
        
        [tbDownload setEditing:NO];
        editButton.title = @"Edit";
        
        pdfValue = 0;
        
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        for (int i =0; i< [arrmetadata count]; i++) {
            
            FolderItem *item = (FolderItem *)[arrmetadata objectAtIndex:i];
            item.isChecked = NO;
            
        }
        
    }
    
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"ftp"])
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        createDir = [[BRRequestCreateDirectory alloc] initWithDelegate:self];
        
        createDir.hostname = [[arrUseraccounts objectAtIndex:[DropboxDownloadFileViewControlller getSharedInstance].index] objectForKey:@"host"];
        if (! [AppDelegate sharedInstance].ftpDownloadpath) {
            [AppDelegate sharedInstance].ftpDownloadpath = @"";
        }
        
        createDir.path = [NSString stringWithFormat:@"%@%@", [AppDelegate sharedInstance].ftpDownloadpath,tempString];
        createDir.username = [[arrUseraccounts objectAtIndex:[DropboxDownloadFileViewControlller getSharedInstance].index] objectForKey:@"name"];
        createDir.password = [[arrUseraccounts objectAtIndex:[DropboxDownloadFileViewControlller getSharedInstance].index] objectForKey:@"password"];
        
        [createDir start];
        
        
        [tbDownload setEditing:NO];
        editButton.title = @"Edit";
        pdfValue = 0;
        
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        for (int i =0; i< [arrmetadata count]; i++)
        {
            FolderItem *item = (FolderItem *)[arrmetadata objectAtIndex:i];
            item.isChecked = NO;
        }
    }
}

// Folder is the metadata for the newly created folder
- (void)restClient:(DBRestClient*)client createdFolder:(DBMetadata*)folder
{
    NSLog(@"Created Folder Path %@",folder.path);
    NSLog(@"Created Folder name %@",folder.filename);
    [marrDownloadData removeAllObjects];
    [arrmetadata removeAllObjects];
    DropboxManager *dbManager = [DropboxManager dbManager];
    [dbManager restClient].delegate = self;
    
    [[dbManager restClient] loadMetadata:loadData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DropboxCreateFolderSuccess" object:self userInfo:nil];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    
}
// [error userInfo] contains the root and path
- (void)restClient:(DBRestClient*)client createFolderFailedWithError:(NSError*)error{
    NSLog(@"create folder error %@",error.userInfo );
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}

#pragma mark - ASIHTTP Delegate

- (void)requestFinished:(ASIHTTPRequest *)request
{
    
    if ([[request.userInfo objectForKey:@"id"] isEqualToString:@"CreateFolder"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DropboxCreateFolderSuccess" object:self userInfo:nil];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"response is %@",request.responseString);
        [self viewWillAppear:YES];
        [tbDownload reloadData];
        
    }
    if ([[request.userInfo objectForKey:@"id"] isEqualToString:@"DeleteFolder"])
    {
        NSLog(@"response is %@",request.responseString);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DropboxDeleteSucess" object:self userInfo:nil];
        [self viewWillAppear:YES];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [tbDownload reloadData];
        
    }
    if ([[request.userInfo objectForKey:@"id"] isEqualToString:@"accessToken"])
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSLog(@"response is %@",request.responseString);
        NSMutableArray *arrJson= [[NSMutableArray alloc]initWithObjects:[request.responseString JSONValue],nil];
        NSLog(@"%@",[request.responseString JSONValue] );
        
        NSLog(@"old access token is  -> %@", [[arrUseraccounts objectAtIndex:[DropboxDownloadFileViewControlller getSharedInstance].index] objectForKey:@"acces_token"]);
        
        NSLog(@"new access token is  -> %@", [[arrJson objectAtIndex:0]objectForKey:@"access_token"]);
        
        
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
        NSDictionary *oldDict = (NSDictionary *)[arrUseraccounts objectAtIndex:[DropboxDownloadFileViewControlller getSharedInstance].index];
        [newDict addEntriesFromDictionary:oldDict];
        [newDict setObject:[[arrJson objectAtIndex:0]objectForKey:@"access_token"] forKey:@"acces_token"];
        [newDict setObject:[[arrJson objectAtIndex:0]objectForKey:@"refresh_token"] forKey:@"refresh_token"];
        
        NSDate *datePlusOneMinute = [[NSDate date] dateByAddingTimeInterval:[[[arrJson objectAtIndex:0]objectForKey:@"expires_in"]integerValue]];
        [newDict setObject:[[arrJson objectAtIndex:0]objectForKey:@"expires_in"] forKey:@"request_time"];
        [newDict setObject:datePlusOneMinute forKey:@"expire_date"];
        
        [newDict setObject:@"updated" forKey:@"tokenStatus"];
        
        [arrUseraccounts replaceObjectAtIndex:[DropboxDownloadFileViewControlller getSharedInstance].index withObject:newDict];
        
        [arrUseraccounts writeToFile:[[DocumentManager getSharedInstance] getUserAccountpath] atomically:YES];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self viewWillAppear:YES];
        [tbDownload reloadData];
    }
    else if ([[request.userInfo objectForKey:@"id"] isEqualToString:@"RenameFolder"])
    {
        [arrmetadata removeAllObjects];
        NSLog(@"response is %@",request.responseString);
        
        [self viewWillAppear:YES];
        [tbDownload reloadData];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DropboxRenameSuccess" object:self userInfo:nil];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
    else if ([[request.userInfo objectForKey:@"id"]isEqualToString:@"drive"])
    {
        NSLog(@"response is %@",request.responseString);
        
    }
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}



#pragma mark - Rename Folder

-(void)renameFolder
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"RenameClick" object:nil];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rename"
                                                    message:@"Enter New name"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Done",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 2;
    [alert show];
    
}
-(void)rename
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // For error information
    
    
    if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"dropbox"])
    {
        NSString *newDirectoryName;
        if ([[[filePathsArray objectAtIndex:0]pathExtension]isEqualToString:@""])
        {
            newDirectoryName =tempString;
            
        }
        else
        {
            if ([[tempString pathExtension]isEqualToString:@""])
            {
                newDirectoryName = [NSString stringWithFormat:@"%@.pdf",tempString];
            }
            else
            {
                newDirectoryName = tempString;
            }
        }
        
        NSString *oldPath = [filePathsArray objectAtIndex:0];
        NSString *newPath = [[oldPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:newDirectoryName];
        DropboxManager *dbManager = [DropboxManager dbManager];
        [dbManager restClient].delegate = self;
        for (int k =0; k < [filePathsArray count]; k++)
        {
            
            [[dbManager restClient] moveFrom:oldPath toPath:newPath];
        }
        
        
        [tbDownload setEditing:NO];
        editButton.title = @"Edit";
        
        [filePathsArray removeAllObjects];
    }
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"box"])
    {
        
        
        // https://developers.box.com/docs/#folders-update-information-about-a-folder
        
        NSString *newDirectoryName;
        NSString *str;
        NSString*fid = [[boxFilePathsArray objectAtIndex:0] objectForKey:@"folderId"];
        NSString * type = [[boxFilePathsArray objectAtIndex:0]objectForKey:@"type"];
        NSString * str_access_token = [[arrUseraccounts objectAtIndex:[DropboxDownloadFileViewControlller getSharedInstance].index] objectForKey:@"acces_token"];
        
        if ([type isEqualToString:@"folder"])
        {
            newDirectoryName =tempString;
            
            str =  [NSString stringWithFormat:@"https://api.box.com/2.0/folders/%@?access_token=%@",fid,str_access_token];
            
        }
        else
        {
            newDirectoryName = [NSString stringWithFormat:@"%@.pdf",tempString];
            
            str =  [NSString stringWithFormat:@"https://api.box.com/2.0/files/%@?access_token=%@",fid,str_access_token];
            
        }
        
        NSDictionary *cid = [[NSDictionary alloc] initWithObjectsAndKeys:newDirectoryName,@"name", nil];
        NSError *error;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:cid options:0 error:&error];
        NSMutableData *data = [[NSMutableData alloc] initWithData:postData];
        
        ASIFormDataRequest *postParams = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:str]];
        //[postParams setPostValue:newDirectoryName forKey:@"name"];
        [postParams setPostBody:data];
        [postParams setRequestMethod:@"PUT"];
        [postParams startAsynchronous];
        postParams.delegate = self ;
        postParams.userInfo = [NSDictionary dictionaryWithObject:@"RenameFolder" forKey:@"id"];
        
        [tbDownload setEditing:NO];
        editButton.title = @"Edit";
        [boxFilePathsArray removeAllObjects];
    }
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"google"])
    {
        
        NSString *newDirectoryName;
        
        NSString*fid = [[driveFilePathsArray objectAtIndex:0] objectForKey:@"folderId"];
        NSString * oldFileName = [[driveFilePathsArray objectAtIndex:0]objectForKey:@"folderName"];
        
        if ([[oldFileName pathExtension]isEqualToString:@""])
        {
            newDirectoryName =tempString;
        }
        else
        {
            newDirectoryName = [NSString stringWithFormat:@"%@.pdf",tempString];
        }
        
        
        [self renameFileWithService:[DriveHelperClass getSharedInstance].driveService fileId:fid newTitle:newDirectoryName completionBlock:^(GTLDriveFile * file,NSError * error){
            if (!error) {
                [arrmetadata removeAllObjects];
                [self viewWillAppear:YES];
                [tbDownload reloadData];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DropboxRenameSuccess" object:self userInfo:nil];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
            else
            {
                NSLog(@"error %@",error);
            }
        }];
        
        
        
        [tbDownload setEditing:NO];
        editButton.title = @"Edit";
        [boxFilePathsArray removeAllObjects];
    }
    
    pdfValue = 0;
    
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    for (int i =0; i< [arrmetadata count]; i++) {
        
        FolderItem *item = (FolderItem *)[arrmetadata objectAtIndex:i];
        item.isChecked = NO;
        
    }
    
    
    
}

- (void)restClient:(DBRestClient*)client movedPath:(NSString *)from_path to:(DBMetadata *)result
{
    
    DropboxManager *dbManager = [DropboxManager dbManager];
    [dbManager restClient].delegate = self;
    [marrDownloadData removeAllObjects];
    [arrmetadata removeAllObjects];
    [[dbManager restClient] loadMetadata:loadData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DropboxRenameSuccess" object:self userInfo:nil];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
- (void)restClient:(DBRestClient*)client movePathFailedWithError:(NSError*)error
{
    NSLog(@"rename error %@",error.userInfo );
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}
-(void)renameFileWithService:(GTLServiceDrive *)service
                      fileId:(NSString *)fileId
                    newTitle:(NSString *)newTitle
             completionBlock:(void (^)(GTLDriveFile *, NSError *))completionBlock {
    GTLDriveFile *file = [GTLDriveFile object];
    file.title = newTitle;
    
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesPatchWithObject:file
                                                                fileId:fileId];
    // queryTicket can be used to track the status of the request.
    GTLServiceTicket *queryTicket =
    [service executeQuery:query
        completionHandler:^(GTLServiceTicket *ticket, GTLDriveFile *updatedFile,
                            NSError *error) {
            if (error == nil) {
                completionBlock(updatedFile, nil);
            } else {
                NSLog(@"An error occurred: %@", error);
                completionBlock(nil, error);
            }
        }];
    
}
-(void)updateFileWithService:(GTLServiceDrive *)service
                      fileId:(NSString *)fileId
                    newTitle:(NSString *)newTitle
              newDescription:(NSString *)newDescription
                 newMimeType:(NSString *)newMimeType
                     newData:(NSData *)newData
               isNewRevision:(BOOL)isNewRevision
             completionBlock:(void (^)(GTLDriveFile *, NSError *))completionBlock {
    // First retrieve the file from the API.
    GTLQueryDrive *getQuery = [GTLQueryDrive queryForFilesGetWithFileId:fileId];
    // getQueryTicket can be used to track the status of the request.
    GTLServiceTicket *getQueryTicket =
    [service executeQuery:getQuery
        completionHandler:^(GTLServiceTicket *ticket, GTLDriveFile *file,
                            NSError *error) {
            if (error == nil) {
                // File's new metadata.
                file.title = newTitle;
                file.descriptionProperty = newDescription;
                file.mimeType = newMimeType;
                
                // File's new content.
                GTLUploadParameters *uploadParameters =
                [GTLUploadParameters uploadParametersWithData:newData
                                                     MIMEType:newMimeType];
                
                // Send the request to the API.
                GTLQueryDrive *updateQuery =
                [GTLQueryDrive queryForFilesUpdateWithObject:file
                                                      fileId:fileId
                                            uploadParameters:uploadParameters];
                updateQuery.newRevision = isNewRevision;
                // updateQueryTicket can be used to track the status of the request.
                GTLServiceTicket *updateQueryTicket =
                [service executeQuery:updateQuery
                    completionHandler:^(GTLServiceTicket *ticket,
                                        GTLDriveFile *updatedFile,
                                        NSError *error) {
                        if (error == nil) {
                            completionBlock(updatedFile, nil);
                        } else {
                            NSLog(@"An error occurred: %@", error);
                            completionBlock(nil, error);
                        }
                    }];
            } else {
                NSLog(@"An error occurred: %@", error);
                completionBlock(nil, error);
            }
        }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DropboxCreateFolderSuccess" object:self userInfo:nil];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self viewWillAppear:YES];
    [tbDownload reloadData];
    
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    tempString = @"";
    
    if (alertView.tag == 1) {
        if (buttonIndex == 0)
        {
            NSLog(@"Folder cancelled");
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        else
        {
            NSLog(@"%@", [alertView textFieldAtIndex:0].text);
            tempString =[alertView textFieldAtIndex:0].text;
            [self folder];
            
            
        }
        
    }
    else if (alertView.tag == 2) {
        if (buttonIndex == 0)
        {
            NSLog(@"Rename cancelled");
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        else
        {
            NSLog(@"%@", [alertView textFieldAtIndex:0].text);
            tempString =[alertView textFieldAtIndex:0].text;
            [self rename];
            
            
        }
        
    }
    else if (alertView.tag == 5)
    {
        if (buttonIndex ==0 )
        {
            [self confirmDelete];
            
        }
        else{
            
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            
            for (int i =0; i< [arrmetadata count]; i++) {
                
                [tbDownload setEditing:NO];
                editButton.title = @"Edit";
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                FolderItem *item = (FolderItem *)[arrmetadata objectAtIndex:i];
                item.isChecked = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DropboxDeleteSucess" object:self userInfo:nil];
                
            }
            
        }
    }
    
    
}

#pragma mark - Delete Folder

-(void)DeleteClick
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeleteClick" object:nil];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete"
                                                    message:@"Are you sure you want to Delete ?"
                                                   delegate:self
                                          cancelButtonTitle:@"Yes"
                                          otherButtonTitles:@"No",nil];
    alert.tag = 5;
    [alert show];
    
    
    
}
-(void)confirmDelete
{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // For error information
    
    if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"dropbox"])
    {
        DropboxManager *dbManager = [DropboxManager dbManager];
        [dbManager restClient].delegate = self;
        NSLog(@"yup %@",filePathsArray);
        for (int k =0; k < [filePathsArray count]; k++)
        {
            [[dbManager restClient] deletePath:[filePathsArray objectAtIndex:k]];
        }
    }
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"box"])
    {
        
        NSString * access = [[arrUseraccounts objectAtIndex:[DropboxDownloadFileViewControlller getSharedInstance].index] objectForKey:@"acces_token"];
        NSLog(@"%@",boxFilePathsArray);
        for (int k =0; k < [boxFilePathsArray count]; k++)
        {
            NSString*fid = [[boxFilePathsArray objectAtIndex:k] objectForKey:@"folderId"];
            NSString * type = [[boxFilePathsArray objectAtIndex:k]objectForKey:@"type"];
            NSString * etag = [[boxFilePathsArray objectAtIndex:k]objectForKey:@"etag"];
            
            [self deleteBoxItem:access :fid :type :etag];
            
        }
    }
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"google"])
    {
        for (int k =0; k < [driveFilePathsArray count]; k++)
        {
            NSString*fid = [[driveFilePathsArray objectAtIndex:k] objectForKey:@"folderId"];
            
            [self deleteFileWithService:[DriveHelperClass getSharedInstance].driveService fileId:fid];
            
        }
    }
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"ftp"])
    {
        for (int k =0; k < [ftpFilePathsArray count]; k++)
        {
            NSString*fname = [[ftpFilePathsArray objectAtIndex:k] objectForKey:@"folderName"];
            
            NSArray *nameArray = [fname componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
            NSString * docfileName = [nameArray lastObject];
            
            if ([[fname pathExtension]isEqualToString:@""])
            {
                deleteDir = [[BRRequestDelete alloc] initWithDelegate:self];
                
                deleteDir.hostname = [[arrUseraccounts objectAtIndex:[DropboxDownloadFileViewControlller getSharedInstance].index] objectForKey:@"host"];
                if (!ftpFolderPath) {
                    ftpFolderPath = @"";
                }
                else
                {
                    fname = [NSString stringWithFormat:@"%@",fname];
                    
                }
                deleteDir.path = [NSString stringWithFormat:@"%@%@/",[AppDelegate sharedInstance].ftpDownloadpath,docfileName];
                deleteDir.username = [[arrUseraccounts objectAtIndex:[DropboxDownloadFileViewControlller getSharedInstance].index] objectForKey:@"name"];
                deleteDir.password = [[arrUseraccounts objectAtIndex:[DropboxDownloadFileViewControlller getSharedInstance].index] objectForKey:@"password"];
                
                [deleteDir start];
                
            }
            else
            {
                deleteFile = [[BRRequestDelete alloc] initWithDelegate:self];
                deleteFile.hostname = [[arrUseraccounts objectAtIndex:[DropboxDownloadFileViewControlller getSharedInstance].index] objectForKey:@"host"];
                if (!ftpFolderPath) {
                    ftpFolderPath = @"";
                }
                else
                {
                    fname = [NSString stringWithFormat:@"/%@",fname];
                    
                }
                deleteFile.path = [NSString stringWithFormat:@"%@%@",ftpFolderPath,fname];
                deleteFile.username = [[arrUseraccounts objectAtIndex:[DropboxDownloadFileViewControlller getSharedInstance].index] objectForKey:@"name"];
                deleteFile.password = [[arrUseraccounts objectAtIndex:[DropboxDownloadFileViewControlller getSharedInstance].index] objectForKey:@"password"];
                
                [deleteFile start];
                
            }
            
        }
    }
    
    
    [tbDownload setEditing:NO];
    editButton.title = @"Edit";
    
    [filePathsArray removeAllObjects];
    [boxFilePathsArray removeAllObjects];
    
    
    pdfValue = 0;
    
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    for (int i =0; i< [arrmetadata count]; i++)
    {
        FolderItem *item = (FolderItem *)[arrmetadata objectAtIndex:i];
        item.isChecked = NO;
    }
    
}

-(void)deleteBoxItem:(NSString *)str_access_token :(NSString *)folder_id :(NSString *)type :(NSString *)etag
{
    /*
     https://api.box.com/2.0/folders/FOLDER_ID?recursive=true  \
     -H "Authorization: Bearer ACCESS_TOKEN" \
     -X DELETE
     */
    /*
     https://api.box.com/2.0/files/FILE_ID  \
     -H "Authorization: Bearer ACCESS_TOKEN" \
     -H "If-Match: a_unique_value" \
     -X DELETE
     */
    
    NSString *str;
    if ([type isEqualToString:@"folder"])
    {
        str =  [NSString stringWithFormat:@"https://api.box.com/2.0/folders/%@?recursive=true&access_token=%@",folder_id,str_access_token];
        
    }
    else
    {
        str =  [NSString stringWithFormat:@"https://api.box.com/2.0/files/%@?access_token=%@&If-Match=%@",folder_id,str_access_token,etag];
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"DropboxDeleteSucess" object:self userInfo:nil];
        
    }
    ASIFormDataRequest *postParams = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:str]];
    [postParams setRequestMethod:@"DELETE"];
    [postParams startAsynchronous];
    postParams.delegate = self ;
    postParams.userInfo = [NSDictionary dictionaryWithObject:@"DeleteFolder" forKey:@"id"];
    
    NSLog(@"Url is ---> %@",postParams.url);
    NSLog(@"response string is-----> %@",postParams.responseString);
    
    
}

- (void)restClient:(DBRestClient*)client deletedPath:(NSString *)path
{
    [marrDownloadData removeAllObjects];
    [arrmetadata removeAllObjects];
    DropboxManager *dbManager = [DropboxManager dbManager];
    [dbManager restClient].delegate = self;
    [[dbManager restClient] loadMetadata:loadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DropboxDeleteSucess" object:self userInfo:nil];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    
}
- (void)restClient:(DBRestClient*)client deletePathFailedWithError:(NSError*)error
{
    NSLog(@"Delete error %@",error.userInfo );
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}
-(void)deleteFileWithService:(GTLServiceDrive *)service
                      fileId:(NSString *)fileId {
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesDeleteWithFileId:fileId];
    // queryTicket can be used to track the status of the request.
    GTLServiceTicket *queryTicket =
    [service executeQuery:query
        completionHandler:^(GTLServiceTicket *ticket, id object,
                            NSError *error) {
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DropboxDeleteSucess" object:self userInfo:nil];
                [self viewWillAppear:YES];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [tbDownload reloadData];
            }
            else
            {
                NSLog(@"error %@",error);
            }
        }];
}

-(IBAction)back:(id)sender;
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end