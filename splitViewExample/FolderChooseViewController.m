//
//  FolderChooseViewController.m
//  splitViewExample
//
//  Created by ravi on 30/07/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import "FolderChooseViewController.h"
#import "MBProgressHUD.h"
#import "DetailViewController.h"
#import "DropboxManager.h"
#import "DocumentManager.h"
#import "AppDelegate.h"
#import "JSON.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "DriveConstants.h"
#import "DriveHelperClass.h"
#import "SugarSyncConstants.h"
#import "SugarSyncClient.h"
#import "SugarSyncHelper.h"

static FolderChooseViewController *sharedInstance = nil;


@interface FolderChooseViewController ()

@end

@implementation FolderChooseViewController
{
    
    NSMutableArray * folderItemsArray;
    NSString * folderPath;
}

+(FolderChooseViewController*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        
    }
    return sharedInstance;
}

@synthesize loadData,tbDownload,accountName,indexCount,boxFolderName,boxFolderId;
@synthesize sugarFilesId,sugarFoldersList;
@synthesize driveFoldersList,driveFiles,driveFilesId,ftpFolderName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    UIBarButtonItem * upload = [[UIBarButtonItem alloc] initWithTitle:@"Upload"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(chooseBarButton_click:)];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(cancelButton_click:)];
    self.navigationItem.rightBarButtonItems =
    [NSArray arrayWithObjects:upload,cancel, nil];
    
    
    NSLog(@"check account name is %@",[FolderChooseViewController getSharedInstance].accountName);
    arrUseraccounts = [[NSMutableArray alloc] initWithContentsOfFile:[[DocumentManager getSharedInstance] getUserAccountpath]];
    
    if([[[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"AccountType"]isEqualToString:@"dropbox"])
    {
        if (!loadData) {
            loadData = @"/";
        }
        self.title = [[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"username"];
        
        [self fetchAllDropboxData];
        
    }
    else if ([[[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"AccountType"]isEqualToString:@"box"])
    {
        NSLog(@"Box");
        
        
        self.title = [[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"name"];
        
        folderItemsArray = [[NSMutableArray alloc]init];
        if (!boxFolderId) {
            boxFolderId = BoxAPIFolderIDRoot;
            boxFolderName =@"All Files";
        }
        [self checkExpiredBoxToken];
    }
    
    else if ([[[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"AccountType"]isEqualToString:@"google"])
    {
        NSLog(@"Upload Files to drive");
        
        driveFoldersList = [[NSMutableArray alloc]init];
        driveFiles = [[NSMutableArray alloc]init];
        self.title = [[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"name"];
        if (!driveFilesId)
        {
            driveFilesId = @"root";
        }
        [self showDriveFolders:driveFilesId];
        
    }
    else if ([[[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"AccountType"]isEqualToString:@"ftp"])
    {
        NSLog(@"Upload Files to ftp");
        
        ftpFoldersArray = [[NSMutableArray alloc]init];
        self.title = [[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"name"];
        if (!ftpFolderName)
        {
            ftpFolderName = @"";
            
        }
        if (![DetailViewController getSharedInstance].folderPath) {
            [DetailViewController getSharedInstance].folderPath = @"";
        }
        [self listDirectory:ftpFolderName];
        
    }
    else if ([[[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"AccountType"]isEqualToString:@"sugarsync"])
    {
        NSLog(@"Upload Files to sugar");
        sugarFoldersList = [[NSMutableArray alloc]init];

        [self listSugarSyncFiles];
    }
    
    //folderPath = @"/";
    tbDownload.delegate = self;
    tbDownload.dataSource = self;
    
    //  self.title = @"Folders";
    marrDownloadData = [[NSMutableArray alloc ]init];
    
    
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    if ([[[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"AccountType"]isEqualToString:@"dropbox"])
    {
        [DetailViewController getSharedInstance].folderPath = loadData;
        
    }
    
    else if ([[[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"AccountType"]isEqualToString:@"box"])
    {
        [DetailViewController getSharedInstance].folderPath = @"/";
        
        [DetailViewController getSharedInstance].folderID = boxFolderId;
        
    }
    else if ([[[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"AccountType"]isEqualToString:@"google"])
    {
        [DetailViewController getSharedInstance].folderID = driveFilesId;
        
    }
    else if ([[[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"AccountType"]isEqualToString:@"sugarsync"])
    {
        [DetailViewController getSharedInstance].folderID = sugarFilesId;
        
    }
}
-(BOOL)checkExpiredBoxToken
{
    
    NSInteger secRemaining ;
    
    NSDate* date1 = [[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount] objectForKey:@"expire_date"];
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
    
    
    NSString* refresh =[NSString stringWithFormat:@"%@",[[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"refresh_token"]];
    
    
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

- (void)fetchFolderItemsWithFolderID:(NSString *)folderID name:(NSString *)name
{
    
    //  https://api.box.com/2.0/folders/0/items?access_token=fYw4Qab6szMbkFkHCUUPUvlagcYwOpw9
    
    
    NSString *str=  [NSString stringWithFormat:@"https://api.box.com/2.0/folders/%@/items?limit=2000&offset=0&access_token=%@",folderID,[[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount] objectForKey:@"acces_token"]];
    
    
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
        
    }
    [tbDownload reloadData];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    
    if ([[request.userInfo objectForKey:@"id"] isEqualToString:@"accessToken"])
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSLog(@"response is %@",request.responseString);
        NSMutableArray *arrJson= [[NSMutableArray alloc]initWithObjects:[request.responseString JSONValue],nil];
        NSLog(@"%@",[request.responseString JSONValue] );
        
        NSLog(@"old access token is  -> %@", [[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount] objectForKey:@"acces_token"]);
        
        NSLog(@"new access token is  -> %@", [[arrJson objectAtIndex:0]objectForKey:@"access_token"]);
        
        
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
        NSDictionary *oldDict = (NSDictionary *)[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount];
        [newDict addEntriesFromDictionary:oldDict];
        [newDict setObject:[[arrJson objectAtIndex:0]objectForKey:@"access_token"] forKey:@"acces_token"];
        [newDict setObject:[[arrJson objectAtIndex:0]objectForKey:@"refresh_token"] forKey:@"refresh_token"];
        
        NSDate *datePlusOneMinute = [[NSDate date] dateByAddingTimeInterval:[[[arrJson objectAtIndex:0]objectForKey:@"expires_in"]integerValue]];
        [newDict setObject:[[arrJson objectAtIndex:0]objectForKey:@"expires_in"] forKey:@"request_time"];
        [newDict setObject:datePlusOneMinute forKey:@"expire_date"];
        
        [newDict setObject:@"updated" forKey:@"tokenStatus"];
        
        [arrUseraccounts replaceObjectAtIndex:[FolderChooseViewController getSharedInstance].indexCount withObject:newDict];
        
        [arrUseraccounts writeToFile:[[DocumentManager getSharedInstance] getUserAccountpath] atomically:YES];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self viewDidLoad];
        [tbDownload reloadData];
    }
}

-(IBAction)cancelButton_click:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadCancel"
                                                        object:self];
}
#pragma mark - Google Drive
-(void)showDriveFolders:(NSString *)folderId
{
    if([DriveHelperClass getSharedInstance].driveService.authorizer == nil)
    {
        [DriveHelperClass getSharedInstance].driveService = [[GTLServiceDrive alloc] init];
        [DriveHelperClass getSharedInstance].driveService.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeyChainItemName
                                                                                                                             clientID:kClientID
                                                                                                                         clientSecret:kClientSecret];
    }
    NSLog(@"Uploading folder id is %@",folderId);
    NSLog(@"drive service %@",[DriveHelperClass getSharedInstance].driveService.authorizer);
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
    // or mimeType ='text/directory'
    query.q = @"mimeType='application/vnd.google-apps.folder' and trashed=false";
    query.q = [NSString stringWithFormat:@"'%@' IN parents", folderId];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[DriveHelperClass getSharedInstance].driveService executeQuery:query
                                                  completionHandler:^(GTLServiceTicket *ticket,
                                                                      GTLDriveFileList *files,
                                                                      NSError *error) {
                                                      if (!error) {
                                                          [self.driveFiles addObjectsFromArray:files.items];
                                                          if ([self.driveFiles count]==0)
                                                          {
                                                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                              
                                                          }
                                                          for (int i =0;i<[driveFiles count]; i++)
                                                          {
                                                              GTLDriveFile * file =[self.driveFiles objectAtIndex:i];
                                                              NSString * str = file.mimeType;
                                                              if ([str isEqualToString:@"application/vnd.google-apps.folder"])
                                                              {
                                                                  NSLog(@"file id %@ ",file.identifier);
                                                                  
                                                                  NSLog(@"file title %d is %@",i,str);
                                                                  
                                                                  NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
                                                                  [dic setObject:file.identifier
                                                                          forKey:@"id"];
                                                                  [dic setObject:str                                                                        forKey:@"mimeType"];
                                                                  [dic setObject:file.title forKey:@"title"];
                                                                  
                                                                  [driveFoldersList addObject:dic];
                                                                  
                                                              }
                                                              
                                                              
                                                              [tbDownload reloadData];
                                                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                              
                                                          }
                                                          
                                                      } else {
                                                          
                                                          NSLog(@"An error occurred: %@", error);
                                                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                      }
                                                  }];
    
}

#pragma mark - SugarSYnc Methods

-(void)listSugarSyncFiles
{
    if(sugarFilesId)
    {
        NSString * str =[NSString stringWithFormat:@"%@",sugarFilesId];
        NSLog(@"%@",str);
        NSURL * url = [NSURL URLWithString:str];
        NSURL *aaNextURL = [url URLByAppendingPathComponent: @"contents"];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[SugarSyncClient getSharedInstance]getFolderContentsWithURL:aaNextURL completionHandler:^(NSArray *theFolderContents,NSError *error)
         {
             NSLog(@"collections count is %d",[theFolderContents count]);
             for (int i =0;i<[theFolderContents count]; i++)
             {
                 
                 NSLog(@"collections count is %@",[theFolderContents objectAtIndex:i]);
                 
                 if ([[theFolderContents objectAtIndex:i] isKindOfClass:[SugarSyncCollection class]]) {
                     
                     SugarSyncCollection * content = [theFolderContents objectAtIndex:i];
                     NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
                     
                     [dic setObject:content.displayName                                                                        forKey:@"title"];
                     [dic setObject:content.ref                                                                        forKey:@"reference"];
                     [dic setObject:content.contents                                                                        forKey:@"contents"];
                     [dic setObject:content forKey:@"SugarSyncType"];
                     [sugarFoldersList addObject:dic];
                }
                 else
                 {
                     SugarSyncFile * content = [theFolderContents objectAtIndex:i];
                     NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
                     if (content.displayName) {
                         [dic setObject:content.displayName                                                                        forKey:@"title"];
                     }
                     else
                     {
                         [dic setObject:@""                                                                        forKey:@"title"];

                     }
                     if (content.ref) {
                          [dic setObject:content.ref                                                                        forKey:@"reference"];
                     }
                     else
                     {
                         [dic setObject:@""                                                                        forKey:@"reference"];
                         
                     }
                     if (content.fileData) {
                         [dic setObject:content.fileData                                                                        forKey:@"contents"];
                     }
                     else
                     {
                         [dic setObject:@""                                                                        forKey:@"contents"];
                         
                     }
                     if (content) {
                         [dic setObject:content                                                                        forKey:@"SugarSyncType"];
                     }
                     else
                     {
                         [dic setObject:@""                                                                        forKey:@"SugarSyncType"];
                         
                     }
                    
                 }
                 
                 
             }
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             [tbDownload reloadData];
             
         }];
    
    }
    else
    {
        NSString * userid = [[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount] objectForKey:@"userid"];
        NSString * urlString = [NSString stringWithFormat:@"https://api.sugarsync.com/user/%@/folders/contents?type=folder",userid];
        NSURL * url = [NSURL URLWithString:urlString];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[SugarSyncClient getSharedInstance]getCollectionWithURL:url completionHandler:^(NSArray * aCollection,NSError *error)
         {
             NSLog(@"collections count is %d",[aCollection count]);
             
             for (int i =0;i<[aCollection count]; i++)
             {
                 SugarSyncCollection * coll = [aCollection objectAtIndex:i];
                 
                 NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
                 
                 [dic setObject:coll.displayName                                                                        forKey:@"title"];
                 [dic setObject:coll.contents                                                                        forKey:@"contents"];
                 [dic setObject:coll.ref                                                                        forKey:@"reference"];
                 [dic setObject:coll forKey:@"SugarSyncType"];
                 // [dic setObject:file.downloadUrl forKey:@"url"];
                 [sugarFoldersList addObject:dic];
                 
             }
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             [tbDownload reloadData];
             
         }];
        
    }
    
}



#pragma mark - Dropbox Methods

-(IBAction)chooseBarButton_click:(id)sender
{

    [self dismissModalViewControllerAnimated:YES];
    //    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadStart"
                                                        object:@"upload"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadToFolder"
                                                        object:self];
    
    NSLog(@"box id = %@",[DetailViewController getSharedInstance].folderID);
    
}

-(void)fetchAllDropboxData
{
    
    DropboxManager *dbManager = [DropboxManager dbManager];
    [dbManager restClient].delegate = self;
    [[dbManager restClient] loadMetadata:loadData];
}
-(IBAction)uploadButton_click:(id)sender
{
    NSLog(@"Upload Click");
}
#pragma mark FTP Methods

-(void)listDirectory:(id)sender
{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    listDir = [[BRRequestListDirectory alloc] initWithDelegate:self];
    listDir.hostname = [[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"host"];
    listDir.path = ftpFolderName;
    listDir.username = [[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"name"];
    listDir.password = [[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"password"];
    [listDir start];
    
}

-(void) requestCompleted: (BRRequest *) request
{
    
    if (request == listDir)
    {
        //called after 'request' is completed successfully
        NSLog(@"%@ completed!", request);
        
        //we print each of the files name
        for (NSDictionary *file in listDir.filesInfo)
        {
            NSLog(@"%@", [file objectForKey:(id)kCFFTPResourceName]);
            if ([[[file objectForKey:(id)kCFFTPResourceName] pathExtension ]isEqualToString:@""])
            {
                [ftpFoldersArray addObject:[file objectForKey:(id)kCFFTPResourceName]];
                
            }
            
        }
        [tbDownload reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        listDir = nil;
    }
}

#pragma mark - DBRestClientDelegate Methods for Load Data
- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata *)metadata
{
    for (int i = 0; i < [metadata.contents count]; i++) {
        DBMetadata *data = [metadata.contents objectAtIndex:i];
        if (data.isDirectory)
        {
            [marrDownloadData addObject:data];
            
        }
    }
    [tbDownload reloadData];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error
{
    [tbDownload reloadData];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
#pragma mark - UITableView Delegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    
    
    if([[[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"AccountType"]isEqualToString:@"dropbox"])
    {
        return [marrDownloadData count];
    }
    else if([[[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"AccountType"]isEqualToString:@"box"])
    {
        
        return [folderItemsArray count];
    }
    else if([[[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"AccountType"]isEqualToString:@"google"])
        
    {
        return [driveFoldersList count];
        
    }
    else if([[[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"AccountType"]isEqualToString:@"ftp"])
    {
        return [ftpFoldersArray count];
        
        
    }
    else
    {
        return [sugarFoldersList count];
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TableIdentifier=@"Cell";
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:TableIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableIdentifier];
    }
    
    if([[[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"AccountType"]isEqualToString:@"dropbox"])
    {
        
        DBMetadata * metadata = [marrDownloadData objectAtIndex:indexPath.row];
        cell.textLabel.text=metadata.filename;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.textLabel.textColor=[UIColor blackColor];
        cell.textLabel.font=[UIFont fontWithName:@"Helvetica" size:18];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else  if([[[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"AccountType"]isEqualToString:@"box"])
    {
        cell.textLabel.text=[[folderItemsArray objectAtIndex:indexPath.row] objectForKey:@"name"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.textLabel.textColor=[UIColor blackColor];
        cell.textLabel.font=[UIFont fontWithName:@"Helvetica" size:18];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else  if([[[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"AccountType"]isEqualToString:@"google"])
    {
        cell.textLabel.text=[[driveFoldersList objectAtIndex:indexPath.row] objectForKey:@"title"];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.textLabel.textColor=[UIColor blackColor];
        cell.textLabel.font=[UIFont fontWithName:@"Helvetica" size:18];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else  if([[[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"AccountType"]isEqualToString:@"ftp"])
    {
        cell.textLabel.text=[ftpFoldersArray objectAtIndex:indexPath.row];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.textLabel.textColor=[UIColor blackColor];
        cell.textLabel.font=[UIFont fontWithName:@"Helvetica" size:18];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    else  if([[[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"AccountType"]isEqualToString:@"sugarsync"])
    {
        cell.textLabel.text=[[sugarFoldersList objectAtIndex:indexPath.row] objectForKey:@"title"];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.textLabel.textColor=[UIColor blackColor];
        cell.textLabel.font=[UIFont fontWithName:@"Helvetica" size:18];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if([[[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"AccountType"]isEqualToString:@"dropbox"])
    {
        
        DBMetadata *metadata = [marrDownloadData objectAtIndex:indexPath.row];
        
        if (metadata.isDirectory)
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            FolderChooseViewController *dropboxDownloadFileViewControlller = [storyboard instantiateViewControllerWithIdentifier:@"FolderChooseViewController"];
            dropboxDownloadFileViewControlller.loadData = metadata.path;
            [self.navigationController pushViewController:dropboxDownloadFileViewControlller animated:YES];
            
        }
        else{
            
            
        }
        [DetailViewController getSharedInstance].folderPath = metadata.path;
        NSLog(@"Uploading path is %@",metadata.path);
        
    }
    else  if([[[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"AccountType"]isEqualToString:@"box"])
    {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        FolderChooseViewController *FolderChooseViewController = [storyboard instantiateViewControllerWithIdentifier:@"FolderChooseViewController"];
        FolderChooseViewController.boxFolderId = [[folderItemsArray  objectAtIndex:indexPath.row] objectForKey:@"id"];
        FolderChooseViewController.boxFolderName = [[folderItemsArray objectAtIndex:indexPath.row] objectForKey:@"name"];
        [DetailViewController getSharedInstance].folderID=   boxFolderId;
        [DetailViewController getSharedInstance].folderPath = [NSString stringWithFormat:@"%@/%@",[DetailViewController getSharedInstance].folderPath,boxFolderName];
        
        [self.navigationController pushViewController:FolderChooseViewController animated:YES];
        
        
    }
    else  if([[[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"AccountType"]isEqualToString:@"google"])
    {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        FolderChooseViewController *FolderChooseViewController = [storyboard instantiateViewControllerWithIdentifier:@"FolderChooseViewController"];
        FolderChooseViewController.driveFilesId = [[driveFoldersList objectAtIndex:indexPath.row]objectForKey:@"id"];
        [self.navigationController pushViewController:FolderChooseViewController animated:YES];
        
        
    }
    else  if([[[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"AccountType"]isEqualToString:@"ftp"])
    {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        FolderChooseViewController *FolderChooseViewController = [storyboard instantiateViewControllerWithIdentifier:@"FolderChooseViewController"];
        FolderChooseViewController.ftpFolderName = [ftpFoldersArray  objectAtIndex:indexPath.row];
        if (![DetailViewController getSharedInstance].folderPath)
        {
            [DetailViewController getSharedInstance].folderPath  = @"";
        }
        [DetailViewController getSharedInstance].folderPath = [NSString stringWithFormat:@"%@/%@",[DetailViewController getSharedInstance].folderPath,FolderChooseViewController.ftpFolderName];
        NSLog(@"ftp folder Name is %@ , folder path is %@",FolderChooseViewController.ftpFolderName,[DetailViewController getSharedInstance].folderPath);
        [self.navigationController pushViewController:FolderChooseViewController animated:YES];
        
    }
    else  if([[[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"AccountType"]isEqualToString:@"sugarsync"])
    {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        FolderChooseViewController *FolderChooseViewController = [storyboard instantiateViewControllerWithIdentifier:@"FolderChooseViewController"];
        FolderChooseViewController.sugarFilesId = [[sugarFoldersList objectAtIndex:indexPath.row]objectForKey:@"reference"];
        FolderChooseViewController.boxFolderId = [[sugarFoldersList objectAtIndex:indexPath.row]objectForKey:@"reference"];
        FolderChooseViewController.boxFolderName = [[folderItemsArray objectAtIndex:indexPath.row] objectForKey:@"title"];
        [DetailViewController getSharedInstance].folderID=   boxFolderId;
        [DetailViewController getSharedInstance].folderPath = [NSString stringWithFormat:@"%@/%@",[DetailViewController getSharedInstance].folderPath,boxFolderName];
        [self.navigationController pushViewController:FolderChooseViewController animated:YES];
        
        
    }
//    [DetailViewController getSharedInstance].uploadIndex = indexPath.row;
//    NSLog(@"uploading index is %d",[DetailViewController getSharedInstance].uploadIndex);
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

#pragma mark disappear
-(void)viewWillDisappear:(BOOL)animated
{
 //   [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UploadClick" object:nil];
}

#pragma mark Memory Warning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
