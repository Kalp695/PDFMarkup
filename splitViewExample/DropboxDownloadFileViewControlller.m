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

    NSMutableString  * pdfFileNames;
    NSString * documentFolder;
    
    int pdfValue;
    
    NSMutableArray *columns;
    
    UIBarButtonItem *editButton;

    NSMutableArray *arrUseraccounts;
    
    
    // BOX
    
    NSMutableArray * folderItemsArray;
    NSMutableArray * boxPdfFilesArray;
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
@synthesize boxFolderId,boxFolderName,index;
-(void)viewWillAppear:(BOOL)animated
{
    
    if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"dropbox"])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(multipleFileDownload:) name:@"DownloadClick" object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(createFolder)
                                                     name:@"CreateFolderClick"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DeleteClick) name:@"DeleteClick" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renameFolder) name:@"RenameClick" object:nil];

    }
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"box"])
    {
        NSLog(@"Box");
        arrUseraccounts = [[NSMutableArray alloc] initWithContentsOfFile:[[DocumentManager getSharedInstance] getUserAccountpath]];
        self.title = [[arrUseraccounts objectAtIndex:[DropboxDownloadFileViewControlller getSharedInstance].index] objectForKey:@"name"];

       // BoxFolderViewController *rootVC = (BoxFolderViewController *)self.topViewController;
      //  rootVC fetchFolderItemsWithFolderID:BoxAPIFolderIDRoot name:@"All Files"];
        folderItemsArray = [[NSMutableArray alloc]init];
        boxPdfFilesArray = [[NSMutableArray alloc]init];
        if (!boxFolderId) {
            boxFolderId = BoxAPIFolderIDRoot;
            boxFolderName =@"All Files";
        }
        [self fetchFolderItemsWithFolderID:boxFolderId name:boxFolderName];

    }
}
- (void)fetchFolderItemsWithFolderID:(NSString *)folderID name:(NSString *)name
{
    
 //  https://api.box.com/2.0/folders/0/items?access_token=fYw4Qab6szMbkFkHCUUPUvlagcYwOpw9
    
    
    NSString *str =  [NSString stringWithFormat:@"https://api.box.com/2.0/folders/%@/items?access_token=%@",folderID,[[arrUseraccounts objectAtIndex:[DropboxDownloadFileViewControlller getSharedInstance].index] objectForKey:@"acces_token"]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:str]
                                                  cachePolicy:NSURLCacheStorageAllowed
                                              timeoutInterval:20];
    NSURLResponse *response;
    NSError *error;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    NSData * data = [NSURLConnection sendSynchronousRequest:request
                                          returningResponse:&response
                                                      error:&error];
   
    NSMutableDictionary *userdata = [[NSMutableDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error]];

    for (int i = 0;i <[[userdata objectForKey:@"total_count"]integerValue];i++)
    {
        if ([[[[userdata objectForKey:@"entries"] objectAtIndex:i] objectForKey:@"type"] isEqualToString:@"folder"])
        {
            [folderItemsArray addObject:userdata];
            
        }
        else if ([[[[userdata objectForKey:@"entries"] objectAtIndex:i]objectForKey:@"type"] isEqualToString:@"file"])
        {
            NSString * str =[[[userdata objectForKey:@"entries"] objectAtIndex:i] objectForKey:@"name"];
            if ([[str pathExtension] isEqualToString:@"pdf"])
            {
                [folderItemsArray addObject:userdata];
                
            }
        }
    }
    [tbDownload reloadData];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    /*
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                               
                               if ([data length] >0 && error == nil) {
                                   
                                   
                                   NSError *myError = nil;
                                   
                                 
                                   NSMutableDictionary *userdata = [[NSMutableDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&myError]];
                                   
                                   for (int i = 0;i <[[userdata objectForKey:@"total_count"]integerValue];i++)
                                   {
                                       if ([[[[userdata objectForKey:@"entries"] objectAtIndex:i] objectForKey:@"type"] isEqualToString:@"folder"])
                                       {
                                           [folderItemsArray addObject:userdata];
                                           
                                       }
                                       else if ([[[[userdata objectForKey:@"entries"] objectAtIndex:i]objectForKey:@"type"] isEqualToString:@"file"])
                                       {
                                           NSString * str =[[[userdata objectForKey:@"entries"] objectAtIndex:i] objectForKey:@"name"];
                                           if ([[str pathExtension] isEqualToString:@"pdf"])
                                           {
                                               [folderItemsArray addObject:userdata];

                                           }
                                       }
                                   }
                                   
                                   NSLog(@"List Of items from box is %@",folderItemsArray);
                                   
                                   [tbDownload reloadData];

                                   [MBProgressHUD hideHUDForView:self.view animated:YES];
                                   
                                   return ;

                               } else if ([data length] == 0 && error == nil) {
                                   
                                   NSLog(@"Nothing was downloaded.");
                                   
                               } else if (error != nil) {
                                   
                                   NSLog(@"Error = %@", error);
                               }
                           }];
    

    
*/
    
    
    
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CreateFolderClick" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeleteClick" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RenameClick" object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"box"])
    {

        NSLog(@"Box");
    }
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"dropbox"])
    {
    if (!loadData) {
        loadData = @"";
    }
    pdfValue = 0;
    filesCount = 0;
    pdfCount = 0;
    
    marrDownloadData = [[NSMutableArray alloc] init];
    arrmetadata = [[NSMutableArray alloc] init];
    filePathsArray = [[NSMutableArray alloc ]init];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    arrtimers = [[NSMutableArray alloc] init];
    [self performSelector:@selector(fetchAllDropboxData) withObject:nil afterDelay:.1];

       
    self.title = [[[AppDelegate sharedInstance] dicUserdetails] objectForKey:@"username"];
    
    

    columns = [[NSMutableArray alloc] init];
    sqliteFilesArray = [[NSMutableArray alloc]init];
    sqliteRowsArray = [[NSMutableArray alloc ]init];
    folderPath =  [[NSMutableArray alloc ]init] ;
    
    arrLocalFilepaths = [[NSMutableDictionary alloc] init];
    }
    else if ([[DropboxDownloadFileViewControlller getSharedInstance].accountStatus isEqualToString:@"box"])
    {
        NSLog(@"Box name");
        
       // [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    }
    
    self.tbDownload.allowsSelectionDuringEditing=YES;
    
    
    editButton = [[UIBarButtonItem alloc]
                  initWithTitle:@"Edit"
                  style:UIBarButtonItemStyleBordered
                  target:self
                  action:@selector(editBarButton_clickk:)];
    editBarButton.title = @"Edit";
    self.navigationItem.rightBarButtonItem = editButton;

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
            
          //  [filePathsArray removeObject:[NSString stringWithFormat:@"/%@",filename]];


        }
        

      //  FileItemTableCell *cell = (FileItemTableCell*)[tbDownload cellForRowAtIndexPath:indexPath];
      //  item.isChecked = !item.isChecked;

        if ([[filePathsArray objectAtIndex:pdfCount] isEqualToString:filePath] ) {
            
            
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];

        }
        
    }
    else
    {
        NSLog(@"downloading filepath is %@",filePath);
        
        
        pdfCount = pdfCount + 1;
        
        for (int i = 0; i<[arrtimers count]; i++) {
            
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
            
      //      dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                [[dbManager restClient] loadFile:[[arrdownlaodfiels objectAtIndex:0] objectForKey:@"dropboxpath"] intoPath:[[arrdownlaodfiels objectAtIndex:0] objectForKey:@"documentspath"]];

       //         dispatch_async(dispatch_get_main_queue(), ^(void){
                    //Run UI Updates
         //       });
           // });

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
        
        for (int j = 0;j<[tempArray count]; j++)
        {
            if ([sqliteRowsArray containsObject:[tempArray objectAtIndex:j]])
            {
                
            }
            else
            {
                [sqliteRowsArray addObject:[tempArray objectAtIndex:j]];
                
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

    NSLog(@"check the rocking shit %@",arrdownlaodfiels);
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
                
             //   dispatch_async(dispatch_get_main_queue(), ^(void){
                    //Run UI Updates
             //   });
          //  });
       
       // [[dbManager restClient] loadFile:[[arrdownlaodfiels objectAtIndex:0] objectForKey:@"dropboxpath"] intoPath:[[arrdownlaodfiels objectAtIndex:0] objectForKey:@"documentspath"]];


    }
    filesCount = filesCount + 1;
    /*
    NSString *path = destPath;
    path = [path substringFromIndex:[path rangeOfString:@"Documents/"].location + [@"Documents/" length]];
    path = [path substringToIndex:[path rangeOfString:@".pdf"].location];
    
    NSString * finalPath = [NSString stringWithFormat:@"%@.pdf",path ];
    NSLog(@"%@",finalPath);
    */
    //[columns addObject:finalPath];
    
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
           return [[[folderItemsArray objectAtIndex:0] objectForKey:@"total_count"]integerValue];

       }       else{

           return 0;

       }

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
    else
    {
        FileItemTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Dropbox_Cell"];
        
        
             FolderItem* item = [arrmetadata objectAtIndex:indexPath.row];
        
        if (tableView.editing)
        {
            [cell setChecked:item.isChecked];
        }
        cell.lblTitle.text = [[[[folderItemsArray objectAtIndex:0] objectForKey:@"entries"] objectAtIndex:indexPath.row] objectForKey:@"name"];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.btnIcon.hidden = NO;
        if ([[[[[folderItemsArray objectAtIndex:0] objectForKey:@"entries"] objectAtIndex:indexPath.row] objectForKey:@"type"]isEqualToString:@"folder"]) {
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.imageView.image = [UIImage imageNamed:@"folder.png"];
            
        }else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.btnIcon.hidden = NO;
            cell.imageView.image = [UIImage imageNamed:@"pdf.png"];
            
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
        /*
           if (!metadata.isDirectory)
           {
               [cell setChecked:item.isChecked];

           }
         */
        
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

    NSLog(@"Filepaths array is %@",arrLocalFilepaths);
    
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
       
        
        if ([[[[[folderItemsArray objectAtIndex:0] objectForKey:@"entries"] objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"folder"]) {
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            DropboxDownloadFileViewControlller *dropboxDownloadFileViewControlller = [storyboard instantiateViewControllerWithIdentifier:@"DropboxDownloadFileViewControlller"];
            dropboxDownloadFileViewControlller.boxFolderId = [[[[folderItemsArray objectAtIndex:0] objectForKey:@"entries"] objectAtIndex:indexPath.row] objectForKey:@"id"];
            dropboxDownloadFileViewControlller.boxFolderName = [[[[folderItemsArray objectAtIndex:0] objectForKey:@"entries"] objectAtIndex:indexPath.row] objectForKey:@"name"];
            [self.navigationController pushViewController:dropboxDownloadFileViewControlller animated:YES];

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
-(IBAction)multipleFileDownload:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

   //  documentFolder =[NSString stringWithFormat:@"Folder %d",[[[DBManager getSharedInstance ]getPdfList]count]];
    [self docDataToDisplay];

    
 //   [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

    for (int index = 0; index<[filePathsArray count]; index++)
    {
        NSLog(@"mnmnmnmnmn %d",index);
        
        NSArray *array = [[filePathsArray objectAtIndex:index] componentsSeparatedByString:@"/"];
        NSString *filename = [array lastObject];
        if ([sqliteRowsArray containsObject:filename])
        {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@",filename ] message:@"File Already Exists" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show ];
            
            
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            
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

            [filePathsArray removeAllObjects];

            [[NSNotificationCenter defaultCenter] postNotificationName:@"NoFiles" object:self];

            [[UIApplication sharedApplication] endIgnoringInteractionEvents];

            break;
            
            
            
        }
        else
        {
            
            [self downloadFileFromDropBox:[filePathsArray objectAtIndex:index]];

        }

    }
}

#pragma mark - Create Folder

-(void)createFolder
{
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
// Folder is the metadata for the newly created folder
- (void)restClient:(DBRestClient*)client createdFolder:(DBMetadata*)folder{
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

    
}

#pragma mark - Delete Folder

-(void)DeleteClick
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // For error information
    DropboxManager *dbManager = [DropboxManager dbManager];
    [dbManager restClient].delegate = self;
    NSLog(@"yup %@",filePathsArray);
    for (int k =0; k < [filePathsArray count]; k++)
    {
        
        
        [[dbManager restClient] deletePath:[filePathsArray objectAtIndex:k]];
    }
    
    
    
    [tbDownload setEditing:NO];
    editButton.title = @"Edit";
    
    [filePathsArray removeAllObjects];
    
    //[documentsCollectionView reloadData];
    
    pdfValue = 0;
    
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    for (int i =0; i< [arrmetadata count]; i++) {
        
        FolderItem *item = (FolderItem *)[arrmetadata objectAtIndex:i];
        item.isChecked = NO;
        
    }
    
    

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