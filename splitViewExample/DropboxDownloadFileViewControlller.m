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
static DropboxDownloadFileViewControlller *sharedInstance = nil;

static NSString *const kKeychainItemName = @"Google Drive Quickstart";

 //NEW
//NSString *clientid = @"879626031062-c8nbgptfp05vsbbl5leg1281r0dnpnav.apps.googleusercontent.com";
//NSString *clientsecret = @"_os033TfvtRQwleJWXH_iGbM";

NSString *clientid = @"879626031062-a2dg654a283hekudfv86ga205mriso24.apps.googleusercontent.com";
NSString *clientsecret = @"ajRru9ga-PqaK9zPMntknmpr";



/*
// old
NSString *clientid = @"879626031062-8a2nnn1rc296rrebo2nlr9dhjchc951l.apps.googleusercontent.com";
NSString *clientsecret = @"Xq9r7kUePIxfeDcmQsA2Wjrn";
*/
 /*
static NSString *const kClientId = @"879626031062-a2dg654a283hekudfv86ga205mriso24.apps.googleusercontent.com";
static NSString *const kClientSecret = @"ajRru9ga-PqaK9zPMntknmpr";
*/

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
@synthesize driveFiles;
NSString *wastepath = nil;

// Box
@synthesize boxAccessToken;
@synthesize boxRefreshToken;
@synthesize filePathsArray;
@synthesize boxFilePathsArray;

// Drive
@synthesize driveService;

@synthesize boxFolderId,boxFolderName,index;
-(void)viewWillAppear:(BOOL)animated
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(multipleFileDownload:) name:@"DownloadClick" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(createFolder)
                                                 name:@"CreateFolderClick"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DeleteClick) name:@"DeleteClick" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renameFolder) name:@"RenameClick" object:nil];
    
    
    if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"dropbox"])
    {

    }
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"box"])
    {
        NSLog(@"Box");
        arrUseraccounts = [[NSMutableArray alloc] initWithContentsOfFile:[[DocumentManager getSharedInstance] getUserAccountpath]];
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
    if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"google"])
    {
        [self fetchDataFromDrive];
        [self loadDriveFiles];
       // [[self class ]retrieveAllFilesWithService:[DropboxDownloadFileViewControlller getSharedInstance].driveService completionBlock:nil];
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
        NSLog(@"google Drive");
        
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
#pragma mark - googleDrive Methods
- (GTLServiceDrive *)driveService {
    static GTLServiceDrive *service = nil;
    
    if (!service) {
        service = [[GTLServiceDrive alloc] init];
        
        // Have the service object set tickets to fetch consecutive pages
        // of the feed so we do not need to manually fetch them.
        service.shouldFetchNextPages = YES;
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically.
        service.retryEnabled = YES;
    }
    return service;
}

-(void)fetchDataFromDrive
{
    
//    GTLServiceDrive *driveServic = [GTLQueryDrive queryForFilesList];
//    NSString *id = @"root";
//    
//    GTLQueryDrive *query = [GTLQueryDrive queryForFilesGetWithFileId:id];
//    [driveServic executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
//                                                         GTLDriveFile *file,
//                                                         NSError *error) {
//        if (error == nil) {
//            NSLog(@"Have file");
//            // Process metadata
//        } else {
//            NSLog(@"An error occurred: %@", error);
//        }
//    }];
    
    
    
//    self.driveService.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
//                                                                                         clientID:clientid
//                                                                                     clientSecret:clientsecret];
    
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"PDFMarkup" accessGroup:nil];
    NSString *authToken = [keychain objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *authRefresh = [keychain objectForKey:(__bridge id)(kSecValueData)];
    NSLog(@"auth is %@ , %@",authToken,authRefresh);

    
    GTMOAuth2Authentication * auth = [[GTMOAuth2Authentication alloc]init];
    auth.accessToken = authToken;
    auth.refreshToken = authRefresh;
    [[self driveService] setAuthorizer:auth];
    if ([auth canAuthorize]) {
        [self isAuthorizedWithAuthentication:auth];
    }
    NSLog(@"%@",[DropboxDownloadFileViewControlller getSharedInstance].driveService.authorizer);
    
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
    query.q = [NSString stringWithFormat:@"'%@' IN parents", @"root"];
    
    [driveService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
                                                              GTLDriveFileList *files,
                                                              NSError *error) {
        if (error == nil)
        {
            if (self.driveFiles == nil) {
                self.driveFiles = [[NSMutableArray alloc] init];
            }
            [self.driveFiles removeAllObjects];
            [self.driveFiles addObjectsFromArray:files.items];
            [tbDownload reloadData];
        }
        
    }];
    
    
//    NSString* currentFolderID = @"root";//folder id for the Google Drive root directory
//    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
//    NSString* queryQ = [NSString stringWithFormat: @"trashed = false and '%@' in parents", currentFolderID];
//    query.q  = queryQ;
//    GTLServiceDrive * _googleService;
//    [_googleService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
//                                                           GTLDriveFileList *files,
//                                                           NSError *error)
//     {
//         if (error == nil)
//         {
//              NSLog(@"data from gDrive is %@",files.items);
//         }
//     }];
  
    
    NSString * driveFolderId = @"root";
    NSString *scopee = @"https://www.googleapis.com/auth/drive.file";

    NSString *str=  [NSString stringWithFormat:@"https://www.googleapis.com/drive/v2/files?q=%@inparents&scope=%@",driveFolderId,scopee];
    
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:str]
                                                  cachePolicy:NSURLCacheStorageAllowed
                                              timeoutInterval:20];
    NSURLResponse *response;
    NSError *error;
    
    NSData * data = [NSURLConnection sendSynchronousRequest:request
                                          returningResponse:&response
                                                      error:&error];
    
    NSMutableDictionary *userdata = [[NSMutableDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error]];
    NSLog(@"gjghjgj %@",userdata);

    
//    ASIFormDataRequest *postParams = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.googleapis.com/drive/v2/files?q=%@inparents&scope=%@",driveFolderId,scopee]]];
//    //[postParams setPostBody:data];
//    [postParams setRequestMethod:@"GET"];
//    [postParams startAsynchronous];
//    postParams.delegate = self ;
//    postParams.userInfo = [NSDictionary dictionaryWithObject:@"drive" forKey:@"id"];
//
    
    
}
- (void)loadDriveFiles {
    
     fileFetchStatusFailure = NO;
    
    //for more info about fetching the files check this link
    //https://developers.google.com/drive/v2/reference/children/list
    
    GTLQueryDrive *query2 = [GTLQueryDrive queryForFilesList];
    //query2.maxResults = 1000;

    
    // queryTicket can be used to track the status of the request.
    [driveService executeQuery:query2
                  completionHandler:^(GTLServiceTicket *ticket,
                                      GTLDriveChildList *children, NSError *error) {
                      GTLBatchQuery *batchQuery = [GTLBatchQuery batchQuery];
                      //incase there is no files under this folder then we can avoid the fetching process
                      if (!children.items.count) {
                          [self.driveFiles removeAllObjects];
                          [fileNames removeAllObjects];
                          [self performSelectorOnMainThread:@selector(reloadTableDataFromMainThread) withObject:nil waitUntilDone:NO];
                          return ;
                      }
                      
                      if (error == nil) {
                          int totalChildren = children.items.count;
                          count = 0;
                          
                          [self.driveFiles removeAllObjects];
                          //[fileNames removeAllObjects];                                                    //http://stackoverflow.com/questions/14603432/listing-all-files-from-specified-folders-in-google-drive-through-ios-google-driv/14610713#14610713
                          for (GTLDriveChildReference *child in children) {
                              GTLQuery *query = [GTLQueryDrive queryForFilesGetWithFileId:child.identifier];
                              query.completionBlock = ^(GTLServiceTicket *ticket, GTLDriveFile *file, NSError *error) {
                                  
                                  //increment count inside this call is very important. Becasue the execute query call is asynchronous
                                  // count ++;
                                  NSLog(@"Google Drive: retrieving children info: %d", count);
                                  if (error == nil) {
                                      if (file != nil) { //checking the file resource is available or not
                                          //only add the file info if that file was not in trash
                                          if (file.labels.trashed.intValue != 1 )
                                              [self addFileMetaDataInfo:file numberOfChilderns:totalChildren];
                                      }
                                      
                                      //the process passed all the files then we need to sort the reterived files
                                      if (count == totalChildren) {
                                          NSLog(@"Google Drive: processed all children, now stopping HUDView - 1");
                                          [self performSelectorOnMainThread:@selector(reloadTableDataFromMainThread) withObject:nil waitUntilDone:NO];
                                      }
                                  } else {
                                      //the file resource was not found
                                      NSLog(@"Google Drive: error occurred while retrieving file info: %@", error);
                                      
                                      if (count == totalChildren) {
                                          NSLog(@"Google Drive: processed all children, now stopping HUDView - 2");
                                          [self performSelectorOnMainThread:@selector(reloadTableDataFromMainThread)
                                                                 withObject:nil waitUntilDone:NO];
                                      }
                                  }
                              };
                              //add the query into batch query. Since we no need to iterate the google server for each child.
                              [batchQuery addQuery:query];
                          }
                          //finally execute the batch query. Since the file reterive process is much faster because it will get all file metadata info at once
                          [self.driveService executeQuery:batchQuery
                                        completionHandler:^(GTLServiceTicket *ticket,
                                                            GTLDriveFile *file,
                                                            NSError *error) {
                                        }];
                          
                          NSLog(@"\nGoogle Drive: file count in the folder: %d", children.items.count);
                      } else {
                          NSLog(@"Google Drive: error occurred while retrieving children list from parent folder: %@", error);
                      }
                  }];
    
    
    
    
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
- (void)isAuthorizedWithAuthentication:(GTMOAuth2Authentication *)auth
{
  
    [[self driveService] setAuthorizer:auth];
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
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    
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
            
        }
        
        
    }
}



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
        // [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CreateFolderClick" object:nil];
        //  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeleteClick" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RenameClick" object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"box"])
    {
        
        NSLog(@"Box");
    }
}


-(void)editBarButton_clickk:(id)sender
{
    UIBarButtonItem *btn = (UIBarButtonItem *)sender;
    NSLog(@"%@",btn.title);
    
    if([btn.title isEqualToString:@"Edit"]){
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
        else
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
    }
    
    else{
        btn.title=@"Edit";
        [tbDownload setEditing:NO animated:YES];
        [tbDownload performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
        
        
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
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@",filename ] message:@"File Already Exists" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show ];
        
        
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
    if(!tbDownload.editing){
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
            [arrdownlaodfiels addObject:dic];
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
                NSLog(@"check this fucking path for childs %@",strDirPath);
                
                
                NSDictionary *dic = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:path,strDirPath, nil] forKeys:[NSArray arrayWithObjects:@"dropboxpath",@"documentspath", nil]];
                
                [arrdownlaodfiels addObject:dic];
                bisprocessing = false;
                
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
    [tbDownload reloadData];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - DBRestClientDelegate Methods for Download Data
- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)destPath
{
    
    NSLog(@"file path is %@",destPath);
    
    NSLog(@"%@",filePathsArray);
    if ([arrdownlaodfiels count] != 0) {
        
        [arrdownlaodfiels removeObjectAtIndex:0];
        
    }
    
    if ([arrdownlaodfiels count] != 0) {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        DropboxManager *dbManager = [DropboxManager dbManager];
        [dbManager restClient].delegate = self;
        // dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [[dbManager restClient] loadFile:[[arrdownlaodfiels objectAtIndex:0] objectForKey:@"dropboxpath"] intoPath:[[arrdownlaodfiels objectAtIndex:0] objectForKey:@"documentspath"]];
        
    }
    filesCount = filesCount + 1;
    
    if (arrdownlaodfiels == nil || [arrdownlaodfiels count] == 0)
    {
        
        
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [arrLocalFilepaths removeAllObjects];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Download Success" object:destPath];
        [self.navigationController popViewControllerAnimated:YES];
        
        
    }
    //[MBProgressHUD hideHUDForView:self.view animated:YES];
    
}

-(void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error
{
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
        return [driveFiles count];
        
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
    else
    {
        FileItemTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Dropbox_Cell"];
        
        [cell.btnIcon setTitle:[[[[folderItemsArray objectAtIndex:0] objectForKey:@"entries"] objectAtIndex:indexPath.row] objectForKey:@"name"] forState:UIControlStateDisabled];
        
        FolderItem* item = [arrmetadata objectAtIndex:indexPath.row];
        
        if (tableView.editing)
        {
            [cell setChecked:item.isChecked];
        }
        cell.lblTitle.text = [driveFiles objectAtIndex:indexPath.row];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.btnIcon.hidden = NO;
//        if ([[[driveFiles objectAtIndex:indexPath.row]objectForKey:@"type"]isEqualToString:@"folder"]) {
//            
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            cell.imageView.image = [UIImage imageNamed:@"folder.png"];
//            
//        }else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.btnIcon.hidden = NO;
            cell.imageView.image = [UIImage imageNamed:@"pdf.png"];
            
     //   }
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
            
            UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
            
            if (item.isChecked == YES)
            {
                //selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
                [downloadingButton setTitle:metadata.path forState:UIControlStateDisabled];
                
                pdfValue = pdfValue+1;
                
                NSString * str = [NSString stringWithFormat:@"Pdf%d",pdfValue] ;
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
    else
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
    [self performSelector:@selector(spinner) withObject:nil];
    [self docDataToDisplay];

    if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"dropbox"])
    {
        
        for (int indexx = 0; indexx<[filePathsArray count]; indexx++)
        {
            NSLog(@"mnmnmnmnmn %@",[filePathsArray objectAtIndex:indexx]);
            NSString *filename;
            if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"dropbox"])
            {
                NSArray *array = [[filePathsArray objectAtIndex:indexx] componentsSeparatedByString:@"/"];
                filename = [array lastObject];
            }
            else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"box"])
            {
                filename = [[filePathsArray objectAtIndex:indexx]objectForKey:@"folderName"];
            }
            if ([sqliteRowsArray containsObject:filename])
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
    }
    
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"box"])
    {
        NSLog(@"box files array %@",boxFilePathsArray);
        NSLog(@"temp array is %@",[AppDelegate sharedInstance].boxSelectedFiles);
        
        [self downloadfrombox];
        
    }
    
}


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
            
            [[AppDelegate sharedInstance].boxSelectedFiles removeAllObjects];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NoFiles" object:self];
            
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            
        }
        else
        {
            
            pdfCount = pdfCount + 1;
            filesCount = filesCount + 1;
            NSLog(@"files is %@",[[[AppDelegate sharedInstance].boxSelectedFiles objectAtIndex:0]objectForKey:@"folderName"]);
            NSString * folderId =[[[AppDelegate sharedInstance].boxSelectedFiles objectAtIndex:0]objectForKey:@"folderId"];
            NSString * folderName =[[[AppDelegate sharedInstance].boxSelectedFiles objectAtIndex:0]objectForKey:@"folderName"];
            NSString * type =[[[AppDelegate sharedInstance].boxSelectedFiles objectAtIndex:0]objectForKey:@"type"];
            
            if ([[[[AppDelegate sharedInstance].boxSelectedFiles objectAtIndex:0]objectForKey:@"path"] length]>0) {
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
                    
                    [[AppDelegate sharedInstance].boxSelectedFiles removeObjectAtIndex:0];
                    root = @"";
                    
                }
                if ([[AppDelegate sharedInstance].boxSelectedFiles count]>0) {
                    [self downloadfrombox];
                    
                }
                else
                {
                    [self performSelector:@selector(closeBoxControllerr) withObject:nil afterDelay:0];
                    
                }
                
            }
        }

    }
    else
    {
        [self performSelector:@selector(closeBoxControllerr) withObject:nil afterDelay:0];

    }
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
            [self performSelector:@selector(closeBoxControllerr) withObject:nil afterDelay:0];
            
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
    
    if ([[AppDelegate sharedInstance].boxSelectedFiles count]==0 && [boxFilesItemsArray count]==0)
    {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [[AppDelegate sharedInstance].boxSelectedFiles removeAllObjects];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Download Success" object:nil];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}
#pragma mark - Create Folder

-(void)createFolder
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CreateFolderClick" object:nil];
    
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


-(void)requestFailed:(id)sender;
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}
#pragma mark - Rename Folder

-(void)renameFolder
{
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeleteClick" object:nil];
    
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


-(IBAction)back:(id)sender;
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end