//
//  DetailViewController.m
//  splitViewExample
//
//  Created by CFA IT on 7/18/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import "DetailViewController.h"
#import "MasterViewController.h"
#import "CollectionViewCell.h"
#import "AppDelegate.h"
#import "DocumentViewController.h"
#import "PdfFilesViewController.h"
#import "MBProgressHUD.h"
#import "FolderChooseViewController.h"
#import "DropboxManager.h"
#import "DocumentManager.h"
#import "DropboxDownloadFileViewControlller.h"

#import "JSON.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

static DetailViewController *sharedInstance = nil;

@interface Item : NSObject

@property (retain, nonatomic) NSString *title;

@property (retain, nonatomic) UIImage *image;

@property (assign, nonatomic) BOOL isChecked;

@property (retain, nonatomic) NSString *accounttype;

@end


@implementation Item

@end


@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController
{
    NSArray * arr;
    AppDelegate * appDel ;
    int pdfValue;
    BOOL uploadPdfCheck;
    NSMutableArray * checkableArray;
    
    NSArray * foldersListArray;
    
    NSString * renameText;
    
    UITableView *popDisplayTableView;
    
    BOOL bprocessing;
    BOOL buploading;
    int filecount;
    NSString *strpdfname;
    
}
+(DetailViewController*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        
    }
    return sharedInstance;
}

@synthesize titleTop,accountInfo,indexPathh;
@synthesize loadData;
@synthesize folderPath;

@synthesize documentsGridButton,documentsTableView;
@synthesize arrUseraccounts;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
    self.title = titleTop;
    
    if ([self.title isEqualToString:@"Documents" ]) {
        rightTableView.hidden = YES;
        accountsLabel.hidden = YES;
        documentView.hidden  = NO;
        [self docDataToDisplay];
        
        self.navigationController.view.backgroundColor=[UIColor whiteColor];
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }
    else if ([self.title isEqualToString:@"Network" ])
    {
        accountsLabel.hidden = NO;
        documentView.hidden = YES;
        rightTableView.hidden = NO;
        [rightTableView reloadData];
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }
    
    else if ([accountInfo isEqualToString:@"DropBox"])
    {
        UIStoryboard * storyboard = self.storyboard;
        
        DetailViewController * detail = [storyboard instantiateViewControllerWithIdentifier: @"DropboxDownloadFileViewControlller"];
        [DropboxDownloadFileViewControlller getSharedInstance].accountStatus = @"dropbox";
        [FolderChooseViewController getSharedInstance].accountName = @"dropbox";
        
        [FolderChooseViewController getSharedInstance].indexCount = indexPathh;
        
        [DropboxDownloadFileViewControlller getSharedInstance].index = indexPathh;
        
        [self.navigationController pushViewController: detail animated: YES];
    }
    else if ([accountInfo isEqualToString:@"box"])
    {
        UIStoryboard * storyboard = self.storyboard;
        
        DetailViewController * detail = [storyboard instantiateViewControllerWithIdentifier: @"DropboxDownloadFileViewControlller"];
        [DropboxDownloadFileViewControlller getSharedInstance].accountStatus = @"box";
        [FolderChooseViewController getSharedInstance].accountName = @"box";
        [FolderChooseViewController getSharedInstance].indexCount = indexPathh;
        [DropboxDownloadFileViewControlller getSharedInstance].index = indexPathh;
        [self.navigationController pushViewController: detail animated: YES];
        
    }
    [self gridViewButton_click:nil] ;
    
}


- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    // Notifier for Upload Click Event
    
    arrUseraccounts = [[NSMutableArray alloc] initWithContentsOfFile:[[DocumentManager getSharedInstance] getUserAccountpath]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UploadClick) name:@"UploadClick" object:nil];
    // Notifier for Delete Click Event
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteClick) name:@"DeleteClick" object:nil];
    
    // Notifier for Rename Click Event
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renameClick) name:@"RenameClick" object:nil];
    
    // Notifier for Create Folder Event
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createfolder) name:@"CreateFolder" object:nil];
    
    
    // Notifier for UploadTo Folder Event
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadToFolder) name:@"UploadToFolder" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadCancel) name:@"UploadCancel" object:nil];
    
    popOverListArray = [[NSMutableArray alloc]init];
    items = [NSMutableArray arrayWithCapacity:0];
    
    
    
    for (int i = 0; i< [arrUseraccounts count]; i++) {
        
        Item *item = [[Item alloc] init];
        
        
        if ([[[arrUseraccounts objectAtIndex:i] objectForKey:@"AccountType"] isEqualToString:@"dropbox"]) {
            
            item.title = [[arrUseraccounts objectAtIndex:i] objectForKey:@"username"];
            item.image = [UIImage imageNamed:@"Dropbox-small.png" ];
            item.accounttype = @"dropbox";
            
            
            
        }
        else if ([[[arrUseraccounts objectAtIndex:i] objectForKey:@"AccountType"] isEqualToString:@"google"]) {
            
            item.title = [[arrUseraccounts objectAtIndex:i] objectForKey:@"name"];
            item.image = [UIImage imageNamed:@"Google_Drive_Small.png" ];
            item.accounttype = @"google";
            
            
        }
        else if ([[[arrUseraccounts objectAtIndex:i] objectForKey:@"AccountType"] isEqualToString:@"box"]) {
            
            item.title = [[arrUseraccounts objectAtIndex:i] objectForKey:@"name"];
            item.image = [UIImage imageNamed:@"box_small.png" ];
            item.accounttype = @"box";
            
            
        }
        item.isChecked = NO;
        
        [items addObject:item];
        
        
    }
    //    if ([[[[AppDelegate sharedInstance] dicUserdetails] objectForKey:@"username"] isKindOfClass:[NSArray class]]) {
    //        for (int i = 0; i<[[[[AppDelegate sharedInstance] dicUserdetails] objectForKey:@"username"] count]; i++) {
    //            if([[AppDelegate sharedInstance] dicUserdetails]!=nil){
    //
    //            Item *item = [[Item alloc] init];
    //            item.title = [[[AppDelegate sharedInstance] dicUserdetails] objectForKey:@"username"];
    //            item.isChecked = NO;
    //            item.image = [UIImage imageNamed:@"Dropbox.png" ];
    //            [items addObject:item];
    //            }
    //
    //        }
    //
    //    }
    //    else
    //    {
    //        if([[AppDelegate sharedInstance] dicUserdetails]!=nil){
    //
    //            Item *item = [[Item alloc] init];
    //            item.title = [[[AppDelegate sharedInstance] dicUserdetails] objectForKey:@"username"];
    //            item.isChecked = NO;
    //            item.image = [UIImage imageNamed:@"Dropbox.png" ];
    //            [items addObject:item];
    //        }
    //    }
    
    
    
    
    Item *item = [[Item alloc] init];
    item.title = @"Add Account";
    item.image = [UIImage imageNamed:@"plusIcon3.png" ];
    item.isChecked = NO;
    [items addObject:item];
    
    
    
    [rightTableView reloadData ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(docDataToDisplay) name:@"Download Success" object:nil];
    
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDel.documentStatus isEqualToString:@"GridView"])
    {
        [documentView bringSubviewToFront:documentsCollectionView];
        documentsCollectionView.hidden = NO;
        documentsTableView.hidden = YES;
        [self gridViewButton_click:appDel.documentStatus ];
        [documentsCollectionView reloadData];
        
    }
    else if([appDel.documentStatus isEqualToString:@"TableView"])
    {
        documentsCollectionView.hidden = YES;
        documentsTableView.hidden = NO;
        [documentsTableView reloadData ];
    }
    
    [self docDataToDisplay];
    // appDel.documentStatus = @"GridView";
    
    
    
    
    
    //  MasterViewController * object = [[MasterViewController alloc ]init];
    
    
}


-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UploadClick" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UploadCancel" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeleteClick" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RenameClick" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CreateFolder" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UploadToFolder" object:nil];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    if (!loadData) {
        loadData = @"";
    }
    appDel = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSLog(@"doc status %@",appDel.documentStatus);
    
    
    if ([appDel.documentStatus isEqualToString:@"GridView"])
    {
        [documentView bringSubviewToFront:documentsCollectionView];
        documentsCollectionView.hidden = NO;
        documentsTableView.hidden = YES;
        [self gridViewButton_click:appDel.documentStatus ];
        
    }
    else if([appDel.documentStatus isEqualToString:@"TableView"])
    {
        documentsCollectionView.hidden = YES;
        documentsTableView.hidden = NO;
        [documentsTableView reloadData ];
    }
    
    documentsTableView.allowsSelectionDuringEditing=YES;
    foldersListArray = [[NSArray alloc]init];
    documentsCollectionView.delegate = self;
    documentsCollectionView.dataSource = self;
    
    
    // [documentsCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    
    rightTableView.allowsSelectionDuringEditing=YES;
    self.title = @"Documents";
    
    if ([self.title isEqualToString:@"Documents" ]) {
        rightTableView.hidden = YES;
        accountsLabel.hidden = YES;
        documentView.hidden = NO;
        self.navigationController.view.backgroundColor=[UIColor whiteColor];
    }
    
    else
    {
        rightTableView.hidden = NO;
        accountsLabel.hidden = NO;
        documentView.hidden = YES;
    }
    
    UINib *nib = [UINib nibWithNibName:@"FileItemCell" bundle:nil];
    [rightTableView registerNib:nib forCellReuseIdentifier:@"FileItemCell"];
    
    checkableArray = [[NSMutableArray alloc]init];
    filePathsArray = [[NSMutableArray alloc]init];
    /////// **** Code For Documents View ***** ////////
    
    
    documentsTableView.delegate = self;
    documentsTableView.dataSource = self;
    documentsTableView.hidden = YES;
    documentsCollectionView.hidden = NO;
    documenmtsArray = [[NSMutableArray alloc ]init];
    downloadsArray = [[NSMutableArray alloc ]init];
    
    sqliteRowsArray = [[NSMutableArray alloc ]init];
    sqliteFilesArray = [[NSMutableArray alloc ]init];
    marrDownloadData = [[NSMutableArray alloc] init];
    arrtimer = [[NSMutableArray alloc] init];
    arrLocalFilepaths = [[NSMutableDictionary alloc] init];
    
    
    // [self gridViewButton_click:nil] ;
    
    [self docDataToDisplay ];
    //[self listOfPDFFiles];
    
    
}


#pragma mark - Documents View

//////  **** Code For Documents **** /////
-(void)docDataToDisplay
{
    if (![downloadsArray containsObject:@"Downloads"])
    {
        [downloadsArray addObject:@"Downloads"];
    }
    
    
    documenmtsArray = [[NSMutableArray alloc]init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    
    
    
    
    
    NSArray *directoryContent = nil;
    if (!loadData) {
        directoryContent = [[NSFileManager defaultManager] directoryContentsAtPath: documentsDirectory];
        
    }
    else
    {
        NSString *filename = [documentsDirectory stringByAppendingPathComponent:loadData];
        NSError * error;
        
        directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filename error:&error];
    }
    NSLog(@"All files and Folder at main path %@ ",directoryContent);
    
    
    
    NSArray * tempArray = [[NSArray alloc ]init];
    for (int k =0; k<[directoryContent count ]; k++)
    {
        
        if([[[directoryContent objectAtIndex:k]  pathExtension] isEqualToString:@"pdf"]||[[[directoryContent objectAtIndex:k]  pathExtension] isEqualToString:@""]||[[[directoryContent objectAtIndex:k]  pathExtension] isEqualToString:@"PDF"])
        {
            
            NSString * str = [directoryContent objectAtIndex:k];
            tempArray =  [str componentsSeparatedByString:@","];
            
            for (int j = 0;j<[tempArray count]; j++)
            {
                if ([documenmtsArray containsObject:[tempArray objectAtIndex:j]])
                {
                    
                }
                else
                {
                    [documenmtsArray addObject:[tempArray objectAtIndex:j]];
                    
                }
                
            }
        }
    }
    
    
    
    NSLog(@"files and Folder at main path %@ ",documenmtsArray);
    
    for (int i = 0; i<[documenmtsArray count]; i++) {
        
        Item *item = [[Item alloc] init];
        item.isChecked = NO;
        [checkableArray addObject:item];
        
    }
    
    [documentsCollectionView reloadData];
    [documentsTableView reloadData];
    
}

-(IBAction)gridViewButton_click:(id)sender
{
    
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDel.documentStatus = @"GridView";
    [documentView bringSubviewToFront:documentsCollectionView];
    documentsTableView.hidden = YES;
    documentsCollectionView.hidden = NO;
    [documentsCollectionView reloadData];
}

-(IBAction)tableViewButton_click:(id)sender
{
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDel.documentStatus = @"TableView";
    
    
    documentsTableView.hidden = NO;
    [documentsTableView reloadData];
    documentsCollectionView.hidden = YES;
}
-(IBAction)editBarButton_click:(id)sender
{
    UIBarButtonItem *btn = (UIBarButtonItem *)sender;
    NSLog(@"%@",btn.title);
    
    if([btn.title isEqualToString:@"Edit"]){
        btn.title=@"Cancel";
        
        [filePathsArray removeAllObjects];
        
        //  [documentsCollectionView reloadData];
        
        pdfValue = 0;
        
        
        for (int i =0; i< [checkableArray count]; i++) {
            
            Item *item = (Item *)[checkableArray objectAtIndex:i];
            item.isChecked = NO;
            
        }
        
        [documentsTableView setEditing:YES animated:YES];
        [documentsTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DocumentsEdit"
                                                            object:self];
    }
    else{
        
        
        
        btn.title=@"Edit";
        [documentsTableView setEditing:NO animated:YES];
        [documentsTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DocumentsEditCancel"
                                                            object:self];
        
    }
    
    [documentsCollectionView reloadData];
    
    
}

-(void)listOfPDFFiles
{
    
    
    
}

#pragma mark - Upload to Dropbox from Doc Directory

-(void)UploadClick
{
    pdfValue = 0;
    
    [self chooseFolder];
    // NSLog(@"DropBox uploading files array is %@",[[filePathsArray objectAtIndex:pdfValue]objectForKey:@"PdfName"] );
    
}

-(void)uploadCancel
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    [documentsTableView setEditing:NO];
    editBarButton.title = @"Edit";
    
    [filePathsArray removeAllObjects];
    
    [documentsCollectionView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadCancelled" object:self userInfo:nil];
    
}

-(void)uploadToFolder
{
    
    /*
     //for box
     curl https://upload.box.com/api/2.0/files/content \
     -H "Authorization: Bearer ACCESS_TOKEN" \
     -F filename=@FILE_NAME \
     -F parent_id=PARENT_FOLDER_ID
     
     
     BoxFileBlock fileBlock = ^(BoxFile *file)
     {
     
     dispatch_sync(dispatch_get_main_queue(), ^{
     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"File Upload Successful" message:[NSString stringWithFormat:@"File has id: %@", file.modelID] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
     [alertView show];
     });
     };
     
     BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
     {
     BOXLog(@"status code: %i", response.statusCode);
     BOXLog(@"upload response JSON: %@", JSONDictionary);
     };
     
     BoxFilesRequestBuilder *builder = [[BoxFilesRequestBuilder alloc] init];
     builder.name = @"box.png";
     builder.parentID = BoxAPIFolderIDRoot;
     
     NSString *path = [[NSBundle mainBundle] pathForResource:@"box.png" ofType:nil];
     NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:path];
     NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
     long long contentLength = [[fileAttributes objectForKey:NSFileSize] longLongValue];
     
     [[BoxSDK sharedSDK].filesManager uploadFileWithInputStream:inputStream contentLength:contentLength MIMEType:nil requestBuilder:builder success:fileBlock failure:failureBlock progress:nil];
     
     */
    
    
    
    for (int i = 0; i<[arrtimer count]; i++) {
        
        NSTimer *timerobj  = (NSTimer *)[arrtimer objectAtIndex:i];
        [timerobj invalidate];
        timerobj = nil;
    }
    timer = [NSTimer scheduledTimerWithTimeInterval: 1
                                             target: self
                                           selector: @selector(checkProcess)
                                           userInfo: nil
                                            repeats: YES];
    [arrtimer addObject:timer];
    
    filecount = 0;
    
    NSLog(@"folder path is %@", [DetailViewController  getSharedInstance].folderPath);
    if ([DetailViewController getSharedInstance].folderPath == nil)
    {
        [DetailViewController getSharedInstance].folderPath = @"/";
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    
    uploadPdfCheck = FALSE;
    
    NSLog(@"yup %@",filePathsArray);
    
    DropboxManager *dbManager = [DropboxManager dbManager];
    [dbManager restClient].delegate = self;
    
    for (int k =0; k < [filePathsArray count]; k++)
    {
        
        NSLog(@"check %@",[[filePathsArray objectAtIndex:k] objectForKey:@"PdfName"] );
        if ([[[[filePathsArray objectAtIndex:k] objectForKey:@"PdfName"] pathExtension] isEqualToString:@"pdf"]) {
            
            buploading = true;
            filecount++;
            
            
            NSString *strUploadpdfname = [[filePathsArray objectAtIndex:k]objectForKey:@"PdfName"];
            
            if ([[arrLocalFilepaths objectForKey:[[filePathsArray objectAtIndex:k]objectForKey:@"PdfPath"]] length]>0) {
                
                
                strpdfname = [arrLocalFilepaths objectForKey:[[filePathsArray objectAtIndex:k]objectForKey:@"PdfPath"]];
            }
            if ([strpdfname length]>0) {
                
                strUploadpdfname = [strUploadpdfname stringByReplacingOccurrencesOfString:strpdfname withString:@""];
                
                
            }
            
            NSLog(@"struploadfiles name %@",strUploadpdfname);
            
            [[dbManager restClient] uploadFile:strUploadpdfname toPath: [DetailViewController  getSharedInstance].folderPath withParentRev:nil fromPath:[[filePathsArray objectAtIndex:k]objectForKey:@"PdfPath"]];
            
        }
        else if ([[[[filePathsArray objectAtIndex:k] objectForKey:@"PdfName"] pathExtension] isEqualToString:@""])
        {
            
            bprocessing = true;
            
            NSString *strUploadpdfname = [[filePathsArray objectAtIndex:k]objectForKey:@"PdfName"];
            
            if ([[arrLocalFilepaths objectForKey:[[filePathsArray objectAtIndex:k]objectForKey:@"PdfPath"]] length]>0) {
                
                
                strpdfname = [arrLocalFilepaths objectForKey:[[filePathsArray objectAtIndex:k]objectForKey:@"PdfPath"]];
            }
            if ([strpdfname length]>0) {
                
                strUploadpdfname = [strUploadpdfname stringByReplacingOccurrencesOfString:strpdfname withString:@""];
                
                
            }
            [[dbManager restClient] createFolder:[NSString stringWithFormat:@"%@/%@",[DetailViewController  getSharedInstance].folderPath,strUploadpdfname]];
            
        }
    }
    
}
// Folder is the metadata for the newly created folder
- (void)restClient:(DBRestClient*)client createdFolder:(DBMetadata*)folder{
    NSLog(@"Created Folder Path %@",folder.path);
    NSLog(@"Created Folder name %@",folder.filename);
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *strpath;
    
    NSLog(@"check folder path %@",[DetailViewController  getSharedInstance].folderPath);
    NSLog(@"check before folder path %@",folder.path);
    if ([[DetailViewController  getSharedInstance].folderPath isEqualToString:@"/"]) {
        strpath  = [NSString stringWithFormat:@"%@",folder.path];
    }
    else
    {
        strpath  = [[NSString stringWithFormat:@"%@",folder.path] stringByReplacingOccurrencesOfString:[DetailViewController  getSharedInstance].folderPath withString:@""];
        
    }
    
    NSLog(@"after file path is %@",strpath);
    
    NSString *folderpath = nil;
    if ([strpdfname length]>0) {
        
        folderpath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",strpdfname,strpath]];
        
    }
    else
    {
        folderpath = [documentsDirectory stringByAppendingPathComponent:strpath];
        
    }
    //    NSString *folderpath = [documentsDirectory stringByAppendingPathComponent:strpath];
    
    NSError *error;
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderpath error:&error];
    
    DropboxManager *dbManager = [DropboxManager dbManager];
    [dbManager restClient].delegate = self;
    
    arrFolderdoc = [[NSMutableArray alloc] init];
    NSLog(@"directory is %@",directoryContent);
    NSString *strdropboxpath = [NSString stringWithFormat:@"%@",folder.path];
    
    for (int i =0; i<[directoryContent count]; i++) {
        
        if ([[[directoryContent objectAtIndex:i] pathExtension] isEqualToString:@"pdf"]) {
            
            buploading = true;
            filecount++;
            
            
            
            
            [[dbManager restClient] uploadFile:[directoryContent objectAtIndex:i] toPath:strdropboxpath withParentRev:nil fromPath:[NSString stringWithFormat:@"%@/%@",folderpath,[directoryContent objectAtIndex:i]]];
            [arrFolderdoc addObject:[NSString stringWithFormat:@"%@/%@",folderpath,[directoryContent objectAtIndex:i]]];
            
        }
        else if ([[[directoryContent objectAtIndex:i] pathExtension] isEqualToString:@""])
        {
            bprocessing = true;
            [[dbManager restClient] createFolder:[NSString stringWithFormat:@"%@/%@",strdropboxpath,[directoryContent objectAtIndex:i]]];
        }
    }
    
    bprocessing = false;
    
    
    
    
    
}
// [error userInfo] contains the root and path
- (void)restClient:(DBRestClient*)client createFolderFailedWithError:(NSError*)error{
    NSLog(@"%@",error.userInfo );
    
    NSString *errorstring = [error.userInfo objectForKey:@"error"];
    NSString *strfilepath = [error.userInfo objectForKey:@"path"];
    if ([errorstring rangeOfString:@"because a file or folder already exists at path"].location == NSNotFound) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        bprocessing = false;
        
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
    }
    else {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSLog(@"check folder path %@",[DetailViewController  getSharedInstance].folderPath);
        NSLog(@"check before folder path %@",strfilepath);
        
        NSString *strpath;
        if ([[DetailViewController  getSharedInstance].folderPath isEqualToString:@"/"]) {
            strpath  = [NSString stringWithFormat:@"%@",strfilepath];
        }
        else
        {
            strpath  = [[NSString stringWithFormat:@"%@",strfilepath] stringByReplacingOccurrencesOfString:[DetailViewController  getSharedInstance].folderPath withString:@""];
            
        }
        
        NSLog(@"check after folder path %@",strfilepath);
        
        DropboxManager *dbManager = [DropboxManager dbManager];
        [dbManager restClient].delegate = self;
        
        NSString *folderpath = [documentsDirectory stringByAppendingPathComponent:strpath];
        
        NSError *error;
        NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderpath error:&error];
        
        arrFolderdoc = [[NSMutableArray alloc] init];
        
        
        for (int i =0; i<[directoryContent count]; i++) {
            
            if ([[[directoryContent objectAtIndex:i] pathExtension] isEqualToString:@"pdf"]) {
                buploading = true;
                filecount++;
                [[dbManager restClient] uploadFile:[directoryContent objectAtIndex:i] toPath:strfilepath withParentRev:nil fromPath:[NSString stringWithFormat:@"%@/%@",folderpath,[directoryContent objectAtIndex:i]]];
                [arrFolderdoc addObject:[NSString stringWithFormat:@"%@/%@",folderpath,[directoryContent objectAtIndex:i]]];
                
            }
            else if ([[[directoryContent objectAtIndex:i] pathExtension] isEqualToString:@""])
            {
                bprocessing = true;
                [[dbManager restClient] createFolder:[NSString stringWithFormat:@"%@/%@",strfilepath,[directoryContent objectAtIndex:i]]];
            }
            
        }
        
        
        bprocessing = false;
        
        
    }
    
    
}
- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath
          metadata:(DBMetadata*)metadata{
    
    filecount -- ;
    
    if ([[[[filePathsArray lastObject]objectForKey:@"PdfPath"] pathExtension] isEqualToString:@"pdf"]) {
        if ([[[filePathsArray lastObject]objectForKey:@"PdfPath"]isEqualToString:srcPath])
        {
            
            buploading = false;
            
            /*
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             
             
             [[[UIAlertView alloc]
             initWithTitle:@"" message:@"Uploaded"
             delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]
             
             show];
             
             
             [documentsTableView setEditing:NO];
             editBarButton.title = @"Edit";
             
             [filePathsArray removeAllObjects];
             
             [documentsCollectionView reloadData];
             
             pdfValue = 0;
             
             [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadSucess" object:self userInfo:nil];
             
             [[UIApplication sharedApplication] endIgnoringInteractionEvents];
             
             for (int i =0; i< [checkableArray count]; i++) {
             
             
             Item *item = (Item *)[checkableArray objectAtIndex:i];
             item.isChecked = NO;
             
             
             
             
             }
             
             [documentsTableView reloadData];
             
             */
        }
        
        
    }
    else
    {
        if ([[arrFolderdoc lastObject] isEqualToString:srcPath])
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            buploading = false;
            
            /*
             [[[UIAlertView alloc]
             initWithTitle:@"" message:@"Uploaded"
             delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]
             
             show];
             
             bprocessing = false;
             
             [documentsTableView setEditing:NO];
             editBarButton.title = @"Edit";
             [documentsCollectionView reloadData];
             
             [filePathsArray removeAllObjects];
             pdfValue = 0;
             
             [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadSucess" object:self userInfo:nil];
             
             [[UIApplication sharedApplication] endIgnoringInteractionEvents];
             
             for (int i =0; i< [checkableArray count]; i++) {
             
             
             Item *item = (Item *)[checkableArray objectAtIndex:i];
             item.isChecked = NO;
             [documentsTableView reloadData];
             
             
             
             
             }*/
            
        }
        
        
    }
    
    
    
    if (uploadPdfCheck == TRUE)
    {
        
        
    }
    
    
}


-(void)checkProcess
{
    
    if (filecount == 0 && !bprocessing) {
        
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        [[[UIAlertView alloc]
          initWithTitle:@"" message:@"Uploaded"
          delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]
         
         show];
        
        
        [documentsTableView setEditing:NO];
        editBarButton.title = @"Edit";
        
        [filePathsArray removeAllObjects];
        
        [documentsCollectionView reloadData];
        
        pdfValue = 0;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadSucess" object:self userInfo:nil];
        
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        for (int i =0; i< [checkableArray count]; i++) {
            
            
            Item *item = (Item *)[checkableArray objectAtIndex:i];
            item.isChecked = NO;
            
            
            
            
        }
        
        [documentsTableView reloadData];
        [DetailViewController  getSharedInstance].folderPath = nil;
        
        
        for (int i = 0; i<[arrtimer count]; i++) {
            
            NSTimer *timerobj  = (NSTimer *)[arrtimer objectAtIndex:i];
            [timerobj invalidate];
            timerobj = nil;
        }
        
    }
}
-(void)chooseFolder
{
    
    FolderChooseViewController *viewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"FolderChooseViewController"];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewcontroller];
    
    // viewcontroller.delegate = self;
    
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:nav animated:YES];
    //superView of viewController's view is modalViewController's view, which we were after
    nav.view.superview.frame = CGRectMake(57,200,500,500);
    
    // The navigation controller is now owned by the current view controller
    // and the root view controller is owned by the navigation controller,
    // so both objects should be released to prevent over-retention.
    
    
    
}
//- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata *)metadata
//{
//    for (int i = 0; i < [metadata.contents count]; i++) {
//        DBMetadata *data = [metadata.contents objectAtIndex:i];
//        [popOverListArray addObject:data];
//    }
//    [popDisplayTableView reloadData];
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
//}
//
//- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error
//{
//    [popDisplayTableView reloadData];
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
//}

#pragma mark - Delete to Dropbox Methods

#pragma mark - Delete to Dropbox Methods

-(void)deleteClick
{
    
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
    NSError *error;
    
    // Create file manager
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    // Point to Document directory
    NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"Documents"];
    
    
    NSLog(@"yup %@",filePathsArray);
    for (int k =0; k < [filePathsArray count]; k++)
    {
        
        NSLog(@"check %@",[[filePathsArray objectAtIndex:k] objectForKey:@"PdfPath"] );
        
        
        if ([fileMgr removeItemAtPath:[[filePathsArray objectAtIndex:k] objectForKey:@"PdfPath"] error:&error] != YES)
            NSLog(@"Unable to delete file: %@", [error localizedDescription]);
        
        // Show contents of Documents directory
        NSLog(@"Documents directory: %@",
              [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
    }
    
    
    [documentsTableView setEditing:NO];
    editBarButton.title = @"Edit";
    
    [filePathsArray removeAllObjects];
    
    //[documentsCollectionView reloadData];
    
    pdfValue = 0;
    
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    for (int i =0; i< [checkableArray count]; i++) {
        
        Item *item = (Item *)[checkableArray objectAtIndex:i];
        item.isChecked = NO;
        
    }
    
    //[documentsTableView reloadData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteSucess" object:self userInfo:nil];
    
    [self docDataToDisplay];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}
#pragma mark - Rename Files to Dropbox Methods

-(void)renameClick
{
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // For error information
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rename"
                                                    message:@"Enter new name"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Done",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 1;
    [alert show];
    
}
-(void)rename
{
    
    
    if ([[[[filePathsArray objectAtIndex:0]objectForKey:@"PdfName"] pathExtension]isEqualToString:@""]) {
        
        NSLog(@"Rename for directory");
        
        NSString *newDirectoryName =renameText;
        NSString *oldPath = [[filePathsArray objectAtIndex:0] objectForKey:@"PdfPath"];
        NSString *newPath = [[oldPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:newDirectoryName];
        NSError *error = nil;
        [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:&error];
        if (error) {
            NSLog(@"%@",error.localizedDescription);
            // handle error
        }
        
    }
    else
    {
        NSError *error;
        
        // Create file manager
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        
        // Point to Document directory
        NSString *documentsDirectory = [NSHomeDirectory()
                                        stringByAppendingPathComponent:@"Documents"];
        
        
        NSLog(@"yup %@",filePathsArray);
        for (int k =0; k < [filePathsArray count]; k++)
        {
            
            NSLog(@"check %@",[[filePathsArray objectAtIndex:k] objectForKey:@"PdfPath"] );
            NSLog(@"Rename Text is %@",renameText );
            
            // Rename the file, by moving the file
            NSString *filePath2 = [documentsDirectory
                                   stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf",renameText]];
            
            // Attempt the move
            if ([fileMgr moveItemAtPath:[[filePathsArray objectAtIndex:k] objectForKey:@"PdfPath"] toPath:filePath2 error:&error] != YES)
                NSLog(@"Unable to move file: %@", [error localizedDescription]);
            
            // Show contents of Documents directory
            NSLog(@"Documents directory: %@",
                  [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
            
            
        }
    }
    
    [documentsTableView setEditing:NO];
    editBarButton.title = @"Edit";
    
    [filePathsArray removeAllObjects];
    
    //  [documentsCollectionView reloadData];
    
    pdfValue = 0;
    
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    for (int i =0; i< [checkableArray count]; i++) {
        
        Item *item = (Item *)[checkableArray objectAtIndex:i];
        item.isChecked = NO;
        
    }
    
    //[documentsTableView reloadData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RenameSucess" object:self userInfo:nil];
    
    [self docDataToDisplay];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}
#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    renameText = @"";
    
    if (alertView.tag == 1) {
        if (buttonIndex == 0)
        {
            NSLog(@"rename canceld");
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        else
        {
            NSLog(@"%@", [alertView textFieldAtIndex:0].text);
            renameText =[alertView textFieldAtIndex:0].text;
            [self rename];
            
            
        }
        
    }
    else if (alertView.tag == 2)
    {
        if (buttonIndex == 0)
        {
            NSLog(@"Folder creation canceld");
        }
        else
        {
            NSLog(@"%@", [alertView textFieldAtIndex:0].text);
            renameText =[alertView textFieldAtIndex:0].text;
            [self folderCreation];
            
            
        }
        
        
    }
    else if (alertView.tag == 5)
    {
        if (buttonIndex ==0 )
        {
            [self confirmDelete];
            
        }
        else{
            [documentsTableView setEditing:NO];
            editBarButton.title = @"Edit";
            
            [filePathsArray removeAllObjects];
            
            //[documentsCollectionView reloadData];
            
            pdfValue = 0;
            
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            
            for (int i =0; i< [checkableArray count]; i++) {
                
                Item *item = (Item *)[checkableArray objectAtIndex:i];
                item.isChecked = NO;
                
            }
            
            [self docDataToDisplay];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteSucess" object:self userInfo:nil];
            
        }
    }
    
    
}

#pragma mark - Create Folder to Dropbox Methods

-(void)createfolder
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Create Folder"
                                                    message:@"Enter folder name"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Done",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 2;
    [alert show];
}
-(void)folderCreation
{
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:renameText];
    NSError * error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"File already exists"
                                                        message:@"Please Try with another name"
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
        
        
        NSLog(@"file already exists");
    }
    
    [documentsTableView setEditing:NO];
    editBarButton.title = @"Edit";
    
    [filePathsArray removeAllObjects];
    
    //  [documentsCollectionView reloadData];
    
    pdfValue = 0;
    
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    for (int i =0; i< [checkableArray count]; i++) {
        
        Item *item = (Item *)[checkableArray objectAtIndex:i];
        item.isChecked = NO;
        
    }
    
    //[documentsTableView reloadData];
    [self docDataToDisplay];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateFolderSuccess" object:self userInfo:nil];
    
    
}


#pragma mark - CollectionViewDelegates

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [documenmtsArray count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    if ([[[documenmtsArray objectAtIndex:indexPath.row]pathExtension] isEqualToString:@""] )
    {
        // cell.coll .image = [UIImage imageNamed:@"folder_large.png"];
        cell.collectionViewImageView.image = [UIImage imageNamed:@"folder_large.png"];
        
    }
    else
    {
        cell.collectionViewImageView.image = [UIImage imageNamed:@"pdf_Large.png"];
        
    }
    
    
    cell.collectionViewLabel .text = [documenmtsArray objectAtIndex:indexPath.row ];
    
    // cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-frame.png"]];
    
    
    if ([editBarButton.title isEqualToString:@"Cancel"])
    {
        cell.editimage.hidden = NO;
        cell.editimage.image = [UIImage imageNamed:@"Unselected.png"];
    }
    else
    {
        cell.editimage.hidden = YES;
    }
    
    
    
    
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([editBarButton.title isEqualToString:@"Edit"]) {
        NSString *pdfFilePath;
        CommonFunction *commonFunction=[[CommonFunction alloc]init];
        
        if (loadData) {
            
            pdfFilePath=[[commonFunction getDoumentPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",loadData,[documenmtsArray objectAtIndex:indexPath.row]]];
            
        }
        else
        {
            pdfFilePath=[[commonFunction getDoumentPath] stringByAppendingPathComponent:[documenmtsArray objectAtIndex:indexPath.row]];
            
        }
        
        
        if ([[[documenmtsArray objectAtIndex:indexPath.row]pathExtension] isEqualToString:@""] )
        {
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            DetailViewController *dropboxDownloadFileViewControlller = [storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
            if (loadData) {
                dropboxDownloadFileViewControlller.loadData = [NSString stringWithFormat:@"%@/%@",loadData,[documenmtsArray objectAtIndex:indexPath.row]];
                
            }
            else
            {
                dropboxDownloadFileViewControlller.loadData = [NSString stringWithFormat:@"%@",[documenmtsArray objectAtIndex:indexPath.row]];
                
                
            }
            [self.navigationController pushViewController:dropboxDownloadFileViewControlller animated:YES];
            
            
            
        }
        else
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"Nav_reader"];
            ReaderViewController *readerViewController=(ReaderViewController*)[navController.viewControllers objectAtIndex:0];
            [readerViewController setPdfFilePath:pdfFilePath];
            
            [self.navigationController presentViewController:navController animated:YES completion:nil];
        }
        
    }
    else
    {
        Item * item = [checkableArray objectAtIndex:indexPath.row];
        
        if ([editBarButton.title isEqualToString:@"Cancel"])
        {
            CollectionViewCell *cell = (CollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
            item.isChecked = !item.isChecked;
            if ([cell.editimage.image isEqual:[UIImage imageNamed:@"Unselected.png"]]) {
                cell.editimage.image = [UIImage imageNamed:@"Selected.png"];
            }
            else
            {
                cell.editimage.image = [UIImage imageNamed:@"Unselected.png"];
                
            }
        }
        
        NSString *pdfFilePath;
        CommonFunction *commonFunction=[[CommonFunction alloc]init];
        
        
        
        if (loadData) {
            
            pdfFilePath=[[commonFunction getDoumentPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",loadData,[documenmtsArray objectAtIndex:indexPath.row]]];
            
        }
        else
        {
            pdfFilePath=[[commonFunction getDoumentPath] stringByAppendingPathComponent:[documenmtsArray objectAtIndex:indexPath.row]];
            
        }
        
        NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
        
        if (item.isChecked == YES)
        {
            
            pdfValue = pdfValue+1;
            
            if (loadData) {
                [dic setValue:[NSString stringWithFormat:@"%@/%@",loadData,[documenmtsArray objectAtIndex:indexPath.row]] forKey:@"PdfName"];
                
                [dic setValue:pdfFilePath forKey:@"PdfPath"];
                [filePathsArray addObject:dic];
                
                [arrLocalFilepaths setObject:loadData forKey:pdfFilePath];
                
                
            }
            else
            {
                [dic setValue:[NSString stringWithFormat:@"%@",[documenmtsArray objectAtIndex:indexPath.row]] forKey:@"PdfName"];
                [dic setValue:pdfFilePath forKey:@"PdfPath"];
                [filePathsArray addObject:dic];
                
                
            }
            
            
        }
        else
            if (item.isChecked == NO)
            {
                pdfValue = pdfValue-1;
                
                if ([filePathsArray count]>0)
                {
                    
                    if ([filePathsArray count]>0)
                    {
                        
                        for (int i = 0; i< [filePathsArray count]; i++) {
                            
                            if ([[[filePathsArray objectAtIndex:i] objectForKey:@"PdfName"] isEqualToString:[NSString stringWithFormat:@"/%@",[documenmtsArray objectAtIndex:indexPath.row]]]) {
                                
                                [arrLocalFilepaths removeObjectForKey:[[filePathsArray objectAtIndex:i] objectForKey:@"PdfPath"]];
                                [filePathsArray removeObjectAtIndex:i];
                                
                                
                            }
                        }
                        
                        
                        
                    }
                    
                }
            }
        if ([filePathsArray count]==1)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadSingleFile" object:self];
        }
        else if([filePathsArray count]>1)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadMultipleFiles" object:self];
            
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadNoFiles" object:self];
            
        }
        
        
        
        
    }
    
}



#pragma mark - DBRestClientDelegate Methods for Load Data
- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata *)metadata
{
    hash=metadata.hash;
    NSLog(@"hash is %@",metadata.hash);
    for (int i = 0; i < [metadata.contents count]; i++)
    {
        DBMetadata *data = [metadata.contents objectAtIndex:i];
        
        if ([data isDirectory])
        {
            [popOverListArray addObject:data];
            
        }
    }
    
    [popDisplayTableView reloadData];
    
    
    
    if ([filePathsArray count]==0)
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
    }
}

-(NSString*)getDropBoxDirectoryPath:(NSString*)path{
    
    
    NSString *haystack = @"MOREvalue:hello World:valueANDMORE";
    haystack=path;
    NSString *prefix = folder_file;
    NSRange prefixRange = [haystack rangeOfString:prefix];
    
    NSRange needleRange = NSMakeRange(prefixRange.location,haystack.length - prefixRange.location);
    NSString *needle = [haystack substringWithRange:needleRange];
    NSLog(@"needle: %@", needle);
    return needle;
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - DBRestClientDelegate Methods for Download Data
- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)destPath
{
    
    NSLog(@"file path is %@",destPath);
    
    NSLog(@"%@",filePathsArray);
    
    
    
    
}

-(void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@""
                                                   message:[error localizedDescription]
                                                  delegate:nil
                                         cancelButtonTitle:@"Ok"
                                         otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == documentsTableView)
    {
        return 1;
    }
    else if(tableView == popDisplayTableView)
    {
        return 1;
        
    }
    else
    {
        return 1;
        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == documentsTableView)
    {
        NSLog(@"--> %@",documenmtsArray);
        return [documenmtsArray count ];
    }
    else if (tableView == popDisplayTableView)
    {
        return [popOverListArray count];
    }
    
    else
    {
        if ([titleTop isEqualToString:@"Network"])
        {
            return [items count];
        }
        else
        {
            return 0;
        }
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == documentsTableView)
    {
        
        static NSString *CellIdentifier = @"Cell";
        FileItemTableCell *cell;
        cell = (FileItemTableCell*)[documentsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if(cell == nil)
        {
            NSArray *nib;
            nib = [[NSBundle mainBundle] loadNibNamed:@"FileItemCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        
        Item * item = [checkableArray objectAtIndex:indexPath.row];
        
        if (tableView.editing)
        {
            [cell setChecked:item.isChecked];
        }
        
        cell.label.text = [documenmtsArray objectAtIndex:indexPath.row];
        if ([[[documenmtsArray objectAtIndex:indexPath.row]pathExtension] isEqualToString:@""] )
        {
            cell.folderImage.image = [UIImage imageNamed:@"folder.png"];
            
        }
        else
        {
            cell.folderImage.image = [UIImage imageNamed:@"pdf.png"];
            
            
        }
        UIImageView *dot =[[UIImageView alloc] initWithFrame:CGRectMake(390,15,25,25)];
        dot.image=[UIImage imageNamed:@"normalDisclosure.png"];
        [cell addSubview:dot];
        
        tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        
        return cell;
        
    }
    else if (tableView == popDisplayTableView)
    {
        static NSString *TableIdentifier=@"Cell";
        
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:TableIdentifier];
        if (cell==nil) {
            cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableIdentifier];
        }
        DBMetadata *metadata = [popOverListArray objectAtIndex:indexPath.row];
        
        cell.textLabel.text=metadata.filename;
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.textLabel.textColor=[UIColor blackColor];
        cell.textLabel.font=[UIFont fontWithName:@"Helvetica" size:18];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
        
    }
    else
    {
        if ([titleTop isEqualToString:@"Network"]) {
            
            static NSString *cellIdentifier = @"Cell";
            FileItemTableCell *cell = (FileItemTableCell *)[rightTableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            // If there is no cell to reuse, create a new one
            if(cell == nil)
            {
                NSArray *nib;
                nib = [[NSBundle mainBundle] loadNibNamed:@"FileItemCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            
            Item* item = [items objectAtIndex:indexPath.row];
            cell.label.text = item.title;
            cell.folderImage.image = [UIImage imageNamed:@"Dropbox-small.png"];
            if ([cell.label.text isEqualToString:@"Add Account"])
            {
                UIImageView *dot =[[UIImageView alloc] initWithFrame:CGRectMake(340,10,30,30)];
                dot.image=[UIImage imageNamed:@"normalDisclosure.png"];
                [cell addSubview:dot];
                
                
            }
            else
            {
                UIImageView *dot =[[UIImageView alloc] initWithFrame:CGRectMake(340,10,30,30)];
                dot.image=[UIImage imageNamed:@"circularDisclosure.png"];
                [cell addSubview:dot];
                
            }
            tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
            return cell;
        }
        else
        {
            static NSString *CellIdentifier = @"Cell";
            FileItemTableCell *cell;
            cell = (FileItemTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            return cell;
        }
        
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    /**********************NEW CODE***********************/
    
    if (tableView == documentsTableView)
    {
        
        Item * item = [checkableArray objectAtIndex:indexPath.row];
        
        if (tableView.editing)
        {
            FileItemTableCell *cell = (FileItemTableCell*)[tableView cellForRowAtIndexPath:indexPath];
            item.isChecked = !item.isChecked;
            
            [cell setChecked:item.isChecked];
        }
        
        NSString *pdfFilePath;
        CommonFunction *commonFunction=[[CommonFunction alloc]init];
        if (loadData) {
            
            pdfFilePath=[[commonFunction getDoumentPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",loadData,[documenmtsArray objectAtIndex:indexPath.row]]];
            
        }
        else
        {
            pdfFilePath=[[commonFunction getDoumentPath] stringByAppendingPathComponent:[documenmtsArray objectAtIndex:indexPath.row]];
            
        }
        
        if (!tableView.editing)
        {
            if ([[[documenmtsArray objectAtIndex:indexPath.row]pathExtension] isEqualToString:@""] )
            {
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                DetailViewController *dropboxDownloadFileViewControlller = [storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
                if (loadData) {
                    dropboxDownloadFileViewControlller.loadData = [NSString stringWithFormat:@"%@/%@",loadData,[documenmtsArray objectAtIndex:indexPath.row]];
                    
                }
                else
                {
                    dropboxDownloadFileViewControlller.loadData = [NSString stringWithFormat:@"%@",[documenmtsArray objectAtIndex:indexPath.row]];
                    
                    
                }
                appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                
                [appDel.documentStatus isEqualToString:@"TableView"];
                [self.navigationController pushViewController:dropboxDownloadFileViewControlller animated:YES];
                
                
            }
            else
            {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"Nav_reader"];
                ReaderViewController *readerViewController=(ReaderViewController*)[navController.viewControllers objectAtIndex:0];
                [readerViewController setPdfFilePath:pdfFilePath];
                
                [self.navigationController presentViewController:navController animated:YES completion:nil];
            }
            
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
        
        if (item.isChecked == YES)
        {
            
            pdfValue = pdfValue+1;
            
            if (loadData) {
                [dic setValue:[NSString stringWithFormat:@"%@/%@",loadData,[documenmtsArray objectAtIndex:indexPath.row]] forKey:@"PdfName"];
                
                [dic setValue:pdfFilePath forKey:@"PdfPath"];
                [filePathsArray addObject:dic];
                
                [arrLocalFilepaths setObject:loadData forKey:pdfFilePath];
                
                
            }
            else
            {
                [dic setValue:[NSString stringWithFormat:@"%@",[documenmtsArray objectAtIndex:indexPath.row]] forKey:@"PdfName"];
                [dic setValue:pdfFilePath forKey:@"PdfPath"];
                [filePathsArray addObject:dic];
                
                
            }
            
            //            //NSString * str = [NSString stringWithFormat:@"Pdf%d",pdfValue] ;
            //            if (![filePathsArray containsObject:[documenmtsArray objectAtIndex:indexPath.row]])
            //            {
            //                NSLog(@"%@",[documenmtsArray objectAtIndex:indexPath.row]);
            //                [dic setValue:[documenmtsArray objectAtIndex:indexPath.row] forKey:@"PdfName"];
            //
            //                [filePathsArray addObject:dic];
            //
            //            }
        }
        else
            if (item.isChecked == NO)
            {
                pdfValue = pdfValue-1;
                
                if ([filePathsArray count]>0)
                {
                    
                    for (int i = 0; i< [filePathsArray count]; i++) {
                        
                        if ([[[filePathsArray objectAtIndex:i] objectForKey:@"PdfName"] isEqualToString:[NSString stringWithFormat:@"/%@",[documenmtsArray objectAtIndex:indexPath.row]]]) {
                            
                            [arrLocalFilepaths removeObjectForKey:[[filePathsArray objectAtIndex:i] objectForKey:@"PdfPath"]];
                            
                            [filePathsArray removeObjectAtIndex:i];
                            
                        }
                    }
                    
                    
                    
                }
            }
        if ([filePathsArray count]==1)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadSingleFile" object:self];
        }
        else if([filePathsArray count]>1)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadMultipleFiles" object:self];
            
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadNoFiles" object:self];
            
        }
        
        
    }
    else if (tableView == popDisplayTableView)
    {
        DBMetadata *metadata = [marrDownloadData objectAtIndex:indexPath.row];
        
        if (metadata.isDirectory)
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            DetailViewController *detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
            detailViewController.loadData = metadata.path;
            [self.navigationController pushViewController:detailViewController animated:YES];
            
            
            
        }
        
    }
    else
    {
        Item* item = [items objectAtIndex:indexPath.row];
        
        if (self.editing)
        {
            FileItemTableCell *cell = (FileItemTableCell*)[tableView cellForRowAtIndexPath:indexPath];
            item.isChecked = !item.isChecked;
            [cell setChecked:item.isChecked];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if ([titleTop isEqualToString:@"Network"])
        {
            
            Item* item = [items objectAtIndex:indexPath.row];
            
            if ([item.title isEqualToString:@"Add Account"])
            {
                UIStoryboard * storyboard = self.storyboard;
                
                DetailViewController * detail = [storyboard instantiateViewControllerWithIdentifier: @ "AddAccountViewController"];
                
                [self.navigationController pushViewController: detail animated: YES];
                
            }
            else
            {
                if ([item.accounttype isEqualToString:@"dropbox"]) {
                    
                    UIStoryboard * storyboard = self.storyboard;
                    
                    DetailViewController * detail = [storyboard instantiateViewControllerWithIdentifier: @ "DropboxDownloadFileViewControlller"];
                    [DropboxDownloadFileViewControlller getSharedInstance].accountStatus = @"dropbox";
                    
                    [self.navigationController pushViewController: detail animated: YES];
                }
                if ([item.accounttype isEqualToString:@"box"]) {
                    
                    UIStoryboard * storyboard = self.storyboard;
                    
                    DetailViewController * detail = [storyboard instantiateViewControllerWithIdentifier: @ "DropboxDownloadFileViewControlller"];
                    [DropboxDownloadFileViewControlller getSharedInstance].accountStatus = @"box";
                    [DropboxDownloadFileViewControlller getSharedInstance].index = indexPath.row;
                    
                    [self.navigationController pushViewController: detail animated: YES];
                }
                
                
            }
            
        }
        else
        {
            
        }
        
        
    }
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == rightTableView)
    {
        Item* item = [items objectAtIndex:indexPath.row];
        
        if (([item.title isEqualToString:@"Add Account"])) {
            
            return UITableViewCellEditingStyleNone;
            
            
        }
        else
        {
            
            return UITableViewCellEditingStyleDelete;
            
        }
    }
    else
    {
        return UITableViewCellEditingStyleNone;
        
    }
    
    
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == rightTableView)
    {
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            
            Item* item = [items objectAtIndex:indexPath.row];
            NSLog(@"remove account %@",item.title);
            
            NSLog(@"%@",arrUseraccounts);
            
            
            for (int k=0; k<[arrUseraccounts count]; k++)
            {
                if ([item.accounttype isEqualToString:@"box"])
                {
                    if ([item.title isEqualToString:[[arrUseraccounts objectAtIndex:k]objectForKey:@"name"]]) {
                        
                        [arrUseraccounts removeObjectAtIndex:k];
                        
                        NSMutableArray *arrUpdatedUserAccounts = [[NSMutableArray alloc] initWithContentsOfFile:[[DocumentManager getSharedInstance] getUserAccountpath]];
                        arrUpdatedUserAccounts = arrUseraccounts;
                        [arrUpdatedUserAccounts writeToFile:[[DocumentManager getSharedInstance] getUserAccountpath] atomically:YES];
                        
                        [BoxSDK sharedSDK].OAuth2Session.accessToken = nil;
                        [BoxSDK sharedSDK].OAuth2Session.refreshToken = nil;
                        [appDel setRefreshTokenInKeychain:nil];
                    }
                }
                else if ([item.accounttype isEqualToString:@"dropbox"])
                {
                    if ([item.title isEqualToString:[[arrUseraccounts objectAtIndex:k]objectForKey:@"username"]]) {
                        
                        //[[DBSession sharedSession] unlinkAll];
                        [[DBSession sharedSession] unlinkUserId:[[arrUseraccounts objectAtIndex:k]objectForKey:@"userid"]];
                        
                        [arrUseraccounts removeObjectAtIndex:k];
                        
                        NSMutableArray *arrUpdatedUserAccounts = [[NSMutableArray alloc] initWithContentsOfFile:[[DocumentManager getSharedInstance] getUserAccountpath]];
                        arrUpdatedUserAccounts = arrUseraccounts;
                        [arrUpdatedUserAccounts writeToFile:[[DocumentManager getSharedInstance] getUserAccountpath] atomically:YES];
                        
                        
                    }
                }
                
            }
            [self viewWillAppear:YES];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"removeAccount" object:nil];
        }
        
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Remove";
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
    
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    //[self.navigationItem setLeftBarButtonItem:nil animated:YES];
    //self.masterPopoverController = nil;
    
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation{
    return NO;
}

@end
