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

#import "GTLUploadParameters.h"

#import "GTLDrive.h"
#import "GTMOAuth2ViewControllerTouch.h"

#import "DriveHelperClass.h"
#import "DriveConstants.h"
#import "CommonMethods.h"
#import "DownloadingSingletonClass.h"
#import "ZipArchive.h"
#import "SSZipArchive.h"
#import "FTPManager.h"

#import "SugarSyncConstants.h"
#import "SugarSyncClient.h"
#import "SugarSyncHelper.h"

static NSString *const kKeychainItemName = @"Google Drive Quickstart";

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
@property (nonatomic, retain) GTLServiceDrive *driveService;

- (void)configureView;
@end

@implementation DetailViewController
{
    
    
    FMServer* server;
    FTPManager* man;
    BOOL succeeded;
    // temp file
    BOOL isFolder;
    NSMutableData  *pdfData;
    
    NSString * appFile;
    NSMutableArray * tempPathArray;
    
    NSArray * arr;
    AppDelegate * appDel ;
    int pdfValue;
    BOOL uploadPdfCheck;
    NSMutableArray * checkableArray;
    
    NSArray * foldersListArray;
    
    NSString * renameText;
    int passValueDidSelect;
    UITableView *popDisplayTableView;
    
    BOOL bprocessing;
    BOOL buploading;
    int filecount;
    NSString *strpdfname;
    NSString * boxParentId;
    NSString * boxFolderPaths;
    
    NSString * driveParentId;
    NSString * driveFolderPaths;
    NSMutableArray * arrJsonn;
    
    NSString * driveFolder;
    
    NSMutableArray * uploadingArray;
    NSMutableArray * uploadingUserAcntsArray;

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
@synthesize folderID;
@synthesize boxUploadingArray;
@synthesize documentsGridButton,documentsTableView;
@synthesize arrUseraccounts;
@synthesize driveService,driveUploadingArray,driveFiles,docFolderPath,ftpFolderPath;
@synthesize createdFolderName,folderNameNospace;
@synthesize uploadIndex;

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
    NSLog(@"toptile is %@",[AppDelegate sharedInstance].topTitle);
    
    if ([[AppDelegate sharedInstance].topTitle isEqualToString:@"Network"])
    {
        
        editBarButton.title = @"";
        accountsLabel.hidden = NO;
        documentView.hidden = YES;
        rightTableView.hidden = NO;
        [rightTableView reloadData];
        [self.navigationController popToRootViewControllerAnimated:YES];

     
    }
    else
    {
        rightTableView.hidden = YES;
        accountsLabel.hidden = YES;
        documentView.hidden  = NO;
        [self docDataToDisplay];
        
        self.navigationController.view.backgroundColor=[UIColor whiteColor];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    if ([self.title isEqualToString:@"Documents" ]) {
        editBarButton.title = @"Edit";

    }
    else if ([self.title isEqualToString:@"Network" ])
    {
    }
    
    else if ([accountInfo isEqualToString:@"DropBox"])
    {
  
       [self performSelector:@selector(performPushOnMainthread) withObject:nil afterDelay:0.6];

    }
    else if ([accountInfo isEqualToString:@"box"])
    {
        
        [AppDelegate sharedInstance].popStatus = NO;
        [self performSelector:@selector(performPushOnMainthread) withObject:nil afterDelay:0.6];

        
    }
    else if ([accountInfo isEqualToString:@"google"])
    {
        [self performSelector:@selector(performPushOnMainthread) withObject:nil afterDelay:0.6];
        
    }
    else if ([accountInfo isEqualToString:@"sugarsync"])
    {
        [self performSelector:@selector(performPushOnMainthread) withObject:nil afterDelay:0.6];
        
    }
    else if ([accountInfo isEqualToString:@"ftp"])
    {
        
        [self performSelector:@selector(performPushOnMainthread) withObject:nil afterDelay:0.6];
                
        
    }
    else
    {
        accountsLabel.hidden = NO;
        documentView.hidden = YES;
        rightTableView.hidden = NO;
        [rightTableView reloadData];
        
    }
    if ([[AppDelegate sharedInstance].documentStatus isEqualToString:@"GridView"])
    {
        [self.view bringSubviewToFront:documentView];
        [documentView bringSubviewToFront:documentsCollectionView];
        documentsCollectionView.hidden = NO;
        documentsTableView.hidden = YES;
        [self gridViewButton_click:[AppDelegate sharedInstance].documentStatus ];
        [documentsCollectionView reloadData];
        
    }
    else if([[AppDelegate sharedInstance].documentStatus isEqualToString:@"TableView"])
    {
        [self.view bringSubviewToFront:documentView];
        [documentView bringSubviewToFront:documentsTableView];
        documentsCollectionView.hidden = YES;
        documentsTableView.hidden = NO;
        [documentsTableView reloadData ];
    }
    
    //[self gridViewButton_click:nil];
    
}
-(void)performPushOnMainthread
{
    if ([accountInfo isEqualToString:@"DropBox"])
    {
        [self performSelectorOnMainThread:@selector(performDropboxPush) withObject:nil waitUntilDone:NO];
       // [self performSelector:@selector(performDropboxPush) withObject:nil afterDelay:0.3];
        
    }
    else if ([accountInfo isEqualToString:@"box"])
    {
        
        [AppDelegate sharedInstance].popStatus = NO;
        [self performSelectorOnMainThread:@selector(performBoxPush) withObject:nil waitUntilDone:NO];

        //[self performSelector:@selector(performBoxPush) withObject:nil afterDelay:0.3];
        
        
    }
    else if ([accountInfo isEqualToString:@"google"])
    {
        [self performSelectorOnMainThread:@selector(googlePush) withObject:nil waitUntilDone:NO];

       // [self performSelector:@selector(googlePush) withObject:nil afterDelay:0.3];
        
    }
    else if ([accountInfo isEqualToString:@"sugarsync"])
    {
        [self performSelectorOnMainThread:@selector(sugarSyncPush) withObject:nil waitUntilDone:NO];

    
        
    }
    else if ([accountInfo isEqualToString:@"ftp"])
    {
        [self performSelectorOnMainThread:@selector(ftpPush) withObject:nil waitUntilDone:NO];

        //[self performSelector:@selector(ftpPush) withObject:nil afterDelay:0.3];
        
        
    }
}

-(void)performDropboxPush
{
    UIStoryboard * storyboard = self.storyboard;
    
    DetailViewController * detail = [storyboard instantiateViewControllerWithIdentifier: @"DropboxDownloadFileViewControlller"];
    [DropboxDownloadFileViewControlller getSharedInstance].accountStatus = @"dropbox";
    [FolderChooseViewController getSharedInstance].accountName = @"dropbox";
    [DropboxDownloadFileViewControlller getSharedInstance].index = indexPathh;
    
    [self.navigationController pushViewController: detail animated: YES];
    
}

-(void)performBoxPush
{
    
    UIStoryboard * storyboard = self.storyboard;
    
    DetailViewController * detail = [storyboard instantiateViewControllerWithIdentifier: @"DropboxDownloadFileViewControlller"];
    [DropboxDownloadFileViewControlller getSharedInstance].accountStatus = @"box";
    [FolderChooseViewController getSharedInstance].accountName = @"box";
    [DropboxDownloadFileViewControlller getSharedInstance].index = indexPathh;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.navigationController pushViewController: detail animated: YES];
    
}

-(void)googlePush
{
    UIStoryboard * storyboard = self.storyboard;
    
    DetailViewController * detail = [storyboard instantiateViewControllerWithIdentifier: @"DropboxDownloadFileViewControlller"];
    [DropboxDownloadFileViewControlller getSharedInstance].accountStatus = @"google";
    [FolderChooseViewController getSharedInstance].accountName = @"google";
    [DropboxDownloadFileViewControlller getSharedInstance].index = indexPathh;
    [self.navigationController pushViewController: detail animated: YES];
    
}
-(void)ftpPush
{
    UIStoryboard * storyboard = self.storyboard;
    
    DetailViewController * detail = [storyboard instantiateViewControllerWithIdentifier: @"DropboxDownloadFileViewControlller"];
    [DropboxDownloadFileViewControlller getSharedInstance].accountStatus = @"ftp";
    [FolderChooseViewController getSharedInstance].accountName = @"ftp";
    [DropboxDownloadFileViewControlller getSharedInstance].index = indexPathh;
    [self.navigationController pushViewController: detail animated: YES];
    
}
-(void)sugarSyncPush
{
    UIStoryboard * storyboard = self.storyboard;
    
    DetailViewController * detail = [storyboard instantiateViewControllerWithIdentifier: @"DropboxDownloadFileViewControlller"];
    [DropboxDownloadFileViewControlller getSharedInstance].accountStatus = @"sugarsync";
    [FolderChooseViewController getSharedInstance].accountName = @"sugarsync";
    [DropboxDownloadFileViewControlller getSharedInstance].index = indexPathh;
    [self.navigationController pushViewController:detail animated: YES];
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
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"toptile is %@",[AppDelegate sharedInstance].topTitle);

    if (![[AppDelegate sharedInstance].topTitle isEqualToString:@""]) {
        self.title = [AppDelegate sharedInstance].topTitle;
        titleTop =[AppDelegate sharedInstance].topTitle;
    }
    arrUseraccounts = [[NSMutableArray alloc] initWithContentsOfFile:[[DocumentManager getSharedInstance] getUserAccountpath]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UploadClick) name:@"UploadClick" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mailClick) name:@"MailClick" object:nil];
    
    // Notifier for Delete Click Event
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DriveDownloadSucces) name:@"BGDownloadSuccess" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DriveDownloadSuccess) name:@"DocumentViewNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteClick) name:@"DeleteClick" object:nil];
    
    // Notifier for Rename Click Event
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renameClick) name:@"RenameClick" object:nil];
    
    // Notifier for Create Folder Event
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createfolder) name:@"CreateFolder" object:nil];
    
    
    // Notifier for UploadTo Folder Event
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadToNetwork) name:@"UploadToFolder" object:nil];
    
    
    
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
            
            item.title = [[arrUseraccounts objectAtIndex:i] objectForKey:@"email"];
            item.image = [UIImage imageNamed:@"Google_Drive_Small.png" ];
            item.accounttype = @"google";
        }
        else if ([[[arrUseraccounts objectAtIndex:i] objectForKey:@"AccountType"] isEqualToString:@"box"]) {
            
            item.title = [[arrUseraccounts objectAtIndex:i] objectForKey:@"name"];
            item.image = [UIImage imageNamed:@"box_small.png" ];
            item.accounttype = @"box";
        }
        else if ([[[arrUseraccounts objectAtIndex:i] objectForKey:@"AccountType"] isEqualToString:@"ftp"]) {
            
            item.title = [[arrUseraccounts objectAtIndex:i] objectForKey:@"host"];
            item.image = [UIImage imageNamed:@"ftp.png" ];
            item.accounttype = @"ftp";
        }
        else if ([[[arrUseraccounts objectAtIndex:i] objectForKey:@"AccountType"] isEqualToString:@"sugarsync"]) {
            
            item.title = [[arrUseraccounts objectAtIndex:i] objectForKey:@"name"];
            item.image = [UIImage imageNamed:@"SugarSync.png" ];
            item.accounttype = @"sugarsync";
        }
        item.isChecked = NO;
        
        [items addObject:item];
        
        
    }
    
    Item *item = [[Item alloc] init];
    item.title = @"Add Account";
    item.image = [UIImage imageNamed:@"plusIcon3.png" ];
    item.isChecked = NO;
    [items addObject:item];
    
    
    
    [rightTableView reloadData ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(docDataToDisplay) name:@"Download Success" object:nil];
    
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   
    if ([[AppDelegate sharedInstance].topTitle isEqualToString:@"Network"])
    {
        NSLog(@"network ");
        NSLog(@"array values is %@",items);
        accountsLabel.hidden = NO;
        documentView.hidden = YES;
        rightTableView.hidden = NO;
        [rightTableView reloadData];

    }
    else
    {
        rightTableView.hidden = YES;
        accountsLabel.hidden = YES;
        documentView.hidden  = NO;
        NSLog(@"Documents ");
        if ([[AppDelegate sharedInstance].documentStatus isEqualToString:@"GridView"])
        {
            [self.view bringSubviewToFront:documentView];
            [documentView bringSubviewToFront:documentsCollectionView];
            documentsCollectionView.hidden = NO;
            documentsTableView.hidden = YES;
            [self gridViewButton_click:[AppDelegate sharedInstance].documentStatus ];
            [documentsCollectionView reloadData];
            [gridViewButton setBackgroundImage:[UIImage imageNamed:@"grid-selected.png"] forState:UIControlStateNormal];
            [tableViewButton setBackgroundImage:[UIImage imageNamed:@"table-normal.png"] forState:UIControlStateNormal];
            
           
            
        }
        else if([[AppDelegate sharedInstance].documentStatus isEqualToString:@"TableView"])
        {
            documentsCollectionView.hidden = YES;
            documentsTableView.hidden = NO;
            [documentsTableView reloadData ];
            
            [gridViewButton setBackgroundImage:[UIImage imageNamed:@"grid-normal.png"] forState:UIControlStateNormal];
            [tableViewButton setBackgroundImage:[UIImage imageNamed:@"table-selected.png"] forState:UIControlStateNormal];
        }
    }
    
    [self docDataToDisplay];
    // appDel.documentStatus = @"GridView";
    //  MasterViewController * object = [[MasterViewController alloc ]init];
}

-(void)viewWillDisappear:(BOOL)animated
{
    //[AppDelegate sharedInstance].topTitle = @"";
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UploadClick" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UploadCancel" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeleteClick" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RenameClick" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CreateFolder" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UploadToFolder" object:nil];
   // [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BGDownloadSuccess" object:nil];
    // [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DocumentViewNotification" object:nil];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configureView];
    
    if (!loadData) {
        loadData = @"";
    }
    
    folderPath = [[NSString alloc]init];
    boxFolderPaths = [[NSString alloc]init];
    driveFolderPaths = [[NSString alloc]init];
    driveUploadingArray = [[NSMutableArray alloc]init];
    uploadingArray = [[NSMutableArray alloc]init];
    arrboxIDS = [[NSMutableArray alloc] init];
    
    //docFolderPath = [[NSString alloc]init];
    appDel = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSLog(@"doc status %@",[AppDelegate sharedInstance].documentStatus);
    
    boxUploadingArray = [[NSMutableArray alloc]init];
    if ([[AppDelegate sharedInstance].documentStatus isEqualToString:@"GridView"])
    {
        [documentView bringSubviewToFront:documentsCollectionView];
        documentsCollectionView.hidden = NO;
        documentsTableView.hidden = YES;
        [gridViewButton setBackgroundImage:[UIImage imageNamed:@"grid-selected.png"] forState:UIControlStateNormal];
        [tableViewButton setBackgroundImage:[UIImage imageNamed:@"table-normal.png"] forState:UIControlStateNormal];
        

    }
    else if([[AppDelegate sharedInstance].documentStatus isEqualToString:@"TableView"])
    {
        documentsCollectionView.hidden = YES;
        documentsTableView.hidden = NO;
        [documentsTableView reloadData ];
        [gridViewButton setBackgroundImage:[UIImage imageNamed:@"grid-normal.png"] forState:UIControlStateNormal];
        [tableViewButton setBackgroundImage:[UIImage imageNamed:@"table-selected.png"] forState:UIControlStateNormal];
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
    
    man = [[FTPManager alloc] init];
    
    
}

-(void)runOnMainThread
{
    
}
-(void)DriveDownloadSucces
{

//    if ([[AppDelegate sharedInstance].documentStatus isEqualToString:@"GridView"]) {
//        [documentView bringSubviewToFront:documentsCollectionView];
//        documentView.hidden  = NO;
//        documentsCollectionView.hidden = NO;
//    }
//    
//    

    NSLog(@"Document Status is %@",[AppDelegate sharedInstance].documentStatus);
        self.title = @"Documents";
    
    [self docDataToDisplay];
}
#pragma mark - Documents View

//////  **** Code For Documents **** /////
-(void)docDataToDisplay
{
    
    NSLog(@"reload calling ");
    
    if (![downloadsArray containsObject:@"Downloads"])
    {
        [downloadsArray addObject:@"Downloads"];
    }
    
    
    //documenmtsArray = [[NSMutableArray alloc]init];
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
                    NSString *string = [tempArray objectAtIndex:j];
                    if ([string rangeOfString:@"-PdfMarkUpTemp"].location == NSNotFound) {
                        [documenmtsArray addObject:[tempArray objectAtIndex:j]];
                        
                    } else
                    {
                        //NSLog(@"string contains -PdfMarkUp");
                        NSString *docRootPath = [documentsDirectory stringByAppendingPathComponent:loadData];
                        NSString * fakePath = [docRootPath stringByAppendingPathComponent:string];
                        NSFileManager *fileMgr = [NSFileManager defaultManager];
                        NSError *error;
                        if ([fileMgr removeItemAtPath:fakePath error:&error] != YES)
                            NSLog(@"Unable to delete file: %@", [error localizedDescription]);

                        
                    }

                    
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
    
    if ([documenmtsArray count]==0)
    {
        gridViewButton.hidden = YES;
        tableViewButton.hidden = YES;
    }
    else{
        gridViewButton.hidden = NO;
        tableViewButton.hidden = NO;
        
    }
    if ([[AppDelegate sharedInstance].topTitle isEqualToString:@"Network"])
    {
        NSLog(@"network ");
        accountsLabel.hidden = NO;
        documentView.hidden = YES;
        rightTableView.hidden = NO;
        [rightTableView reloadData];
        
    }
    else
    {
        rightTableView.hidden = YES;
        accountsLabel.hidden = YES;
        documentView.hidden  = NO;
        NSLog(@"Documents ");

    if ([[AppDelegate sharedInstance].documentStatus isEqualToString:@"GridView"])
    {
        [self.view bringSubviewToFront:documentView];
        [documentView bringSubviewToFront:documentsCollectionView];
        documentView.hidden  = NO;
        documentsTableView.hidden = YES;
        documentsCollectionView.hidden = NO;
        [documentsCollectionView reloadData];

    }
   else
   {
       [self.view bringSubviewToFront:documentView];
       documentsCollectionView.hidden = YES;
       documentsTableView.hidden = NO;
       [documentsTableView reloadData];
       [documentView bringSubviewToFront:documentsTableView];
   }
    
    }
}

-(void)DriveDownloadSuccess
{
   // rightTableView.hidden = YES;
  //  accountsLabel.hidden = YES;
   // documentView.hidden  = NO;
    self.title = @"Documents";
    
    [self docDataToDisplay];
}

-(IBAction)gridViewButton_click:(id)sender
{
    
    [gridViewButton setBackgroundImage:[UIImage imageNamed:@"grid-selected.png"] forState:UIControlStateNormal];
    [tableViewButton setBackgroundImage:[UIImage imageNamed:@"table-normal.png"] forState:UIControlStateNormal];
  
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [AppDelegate sharedInstance].documentStatus = @"GridView";
    [documentView bringSubviewToFront:documentsCollectionView];
    documentsTableView.hidden = YES;
    documentsCollectionView.hidden = NO;
    [documentsCollectionView reloadData];
}

-(IBAction)tableViewButton_click:(id)sender
{
    [gridViewButton setBackgroundImage:[UIImage imageNamed:@"grid-normal.png"] forState:UIControlStateNormal];
    [tableViewButton setBackgroundImage:[UIImage imageNamed:@"table-selected.png"] forState:UIControlStateNormal];
    
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [AppDelegate sharedInstance].documentStatus = @"TableView";
    
    documentsTableView.hidden = NO;
    [documentsTableView reloadData];
    documentsCollectionView.hidden = YES;
}

-(IBAction)editBarButton_click:(id)sender
{
    UIBarButtonItem *btn = (UIBarButtonItem *)sender;
    NSLog(@"%@",btn.title);
    if ([[AppDelegate sharedInstance].topTitle isEqualToString:@"Network"])
    {
    }
    else
    {
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
    
}

-(void)listOfPDFFiles
{

}

#pragma mark - Upload to Dropbox from Doc Directory
#pragma mark Upload Methods
//[[AppDelegate sharedInstance].bgRunningStatus isEqualToString:@"Downloading"]
-(void)UploadClick
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        UIAlertView	*alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Please check your network connectivity."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
  else
  {

      pdfValue = 0;
      arrJsonn = [[NSMutableArray alloc]init];
    
      NSLog(@"useraccounts is %@",arrUseraccounts);
      if ([arrUseraccounts count]>0)
      {
        
          [self popOver];
      }
      else
      {
          UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"PDF Markup" message:@"No network available to upload" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
          [alert show];
      }
   
  }
}

-(void)popOver
{
    UIViewController *popoverContent=[[UIViewController alloc] init];
    popDisplayTableView =[[UITableView alloc] initWithFrame:CGRectMake(265, 100, 0, 0)    style:UITableViewStylePlain];
    UIView *popoverView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 10)];
    
    popoverView.backgroundColor=[UIColor whiteColor];
    
    popoverContent.view=popoverView;
    popoverContent.contentSizeForViewInPopover=CGSizeMake(250, 300);
    popoverContent.view=popDisplayTableView; //Adding tableView to popover
    popDisplayTableView.delegate=self;
    popDisplayTableView.dataSource=self;
    popoverController=[[UIPopoverController alloc]    initWithContentViewController:popoverContent];
    [popoverController presentPopoverFromRect:CGRectMake(0, 360, 0, 0) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    
}
-(void)uploadCancel
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    [documentsTableView setEditing:NO];
    editBarButton.title = @"Edit";
    
    [filePathsArray removeAllObjects];
    [uploadingArray removeAllObjects];
    [documentsCollectionView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadCancelled" object:self userInfo:nil];
    
}

-(void)uploadToNetwork
{
    
    [self performSelectorOnMainThread:@selector(uploadInBG) withObject:nil waitUntilDone:NO];
    
}

-(void)uploadInBG
{
    
    [AppDelegate sharedInstance].bgRunningStatusUpload = @"Uploading";
    [self uploadFolders];
    
//[[NSNotificationCenter defaultCenter] postNotificationName:@"UploadClick" object:self];
//    
//    if ([[AppDelegate sharedInstance].bgRunningStatusUpload isEqualToString:@"Uploading"])
//    {
//        [self performSelectorOnMainThread:@selector(uploadInProgress) withObject:nil waitUntilDone:NO];
//    }
//    else
//    {
//        [AppDelegate sharedInstance].bgRunningStatusUpload = @"Uploading";
//        [self uploadFolders];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadClick" object:self];
//    }
}

-(void)uploadInProgress
{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Please Wait...." message:@"Uploading In Progress" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show ];
    [documentsTableView setEditing:NO animated:YES];
    editBarButton.title = @"Edit";
    [documentsTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DocumentsEditCancel"
                                                        object:self];
    [documentsCollectionView reloadData];

}

-(void)uploadFolders
{
    
    uploadingArray =[[NSMutableArray alloc]initWithArray:filePathsArray];
    uploadingUserAcntsArray = [[NSMutableArray alloc]initWithArray:arrUseraccounts];
    
    NSLog(@"uploading files is %@",uploadingArray);
    filecount = 0;
    uploadPdfCheck = FALSE;
    
    NSLog(@"yup %@",uploadingArray);
    
    [documentsTableView setEditing:NO];
    [documentsCollectionView reloadData];
    
    editBarButton.title = @"Edit";
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadSucess" object:self userInfo:nil];

    if([[[uploadingUserAcntsArray objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"AccountType"]isEqualToString:@"dropbox"])
    {
        /*
         NSInvocationOperation *dropBoxFlattenedFileOperation = [[NSInvocationOperation alloc] initWithTarget:self
         selector:@selector(flattenedFile)
         object:nil];
         
         // Add the operation to the queue and let it to be executed.
         
         [dropBoxFlattenedFileOperation setQueuePriority:NSOperationQueuePriorityVeryHigh];
         [dropBoxUploadOperationQueue addOperation:dropBoxFlattenedFileOperation];
         */
        dropBoxUploadOperationQueue = [NSOperationQueue new];
        
        NSInvocationOperation *dropboxUploadOperation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                             selector:@selector(uploadToFolder)
                                                                                               object:nil];
        
        // Add the operation to the queue and let it to be executed.
        [dropboxUploadOperation setQueuePriority:NSOperationQueuePriorityVeryHigh];
        [dropBoxUploadOperationQueue addOperation:dropboxUploadOperation];
        
        [DownloadingSingletonClass getSharedInstance].dropBoxUpload = NO;
        
        
    }
    else if([[[uploadingUserAcntsArray objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"AccountType"]isEqualToString:@"box"])
    {
        
       // [self checkExpiredBoxToken];
        boxUploadOperationQueue = [NSOperationQueue new];

        NSInvocationOperation *uploadOperation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                      selector:@selector(uploadToFolder)
                                                                                        object:nil];
        
        // Add the operation to the queue and let it to be executed.
        // [uploadOperation addDependency:flattenedFileOperation];
        
        [uploadOperation setQueuePriority:NSOperationQueuePriorityHigh];
        
        [boxUploadOperationQueue addOperation:uploadOperation];

        
    }
    else if([[[uploadingUserAcntsArray objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"AccountType"]isEqualToString:@"google"])
    {
        
        [self uploadToFolder];
        
    }
    else if([[[uploadingUserAcntsArray objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"AccountType"]isEqualToString:@"ftp"])
    {
        ftpUploadOperationQueue = [NSOperationQueue new];
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                selector:@selector(uploadToFolder)
                                                                                  object:nil];
        
        // Add the operation to the queue and let it to be executed.
        
        [operation setQueuePriority:NSOperationQueuePriorityVeryHigh];
        [ftpUploadOperationQueue addOperation:operation];
        [DownloadingSingletonClass getSharedInstance].ftpUpload = NO;
        // [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    else
    {
        sugarSyncUploadOperationQueue = [NSOperationQueue new];
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                selector:@selector(uploadToFolder)
                                                                                  object:nil];
        
        // Add the operation to the queue and let it to be executed.
        
        [operation setQueuePriority:NSOperationQueuePriorityVeryHigh];
        [sugarSyncUploadOperationQueue addOperation:operation];
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
        NSLog(@"Time to create new access token");
        [self createNewAccesToken];
    }
    else
    {
        boxUploadOperationQueue = [NSOperationQueue new];
        
        
        NSInvocationOperation *uploadOperation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                      selector:@selector(uploadToFolder)
                                                                                        object:nil];
        
        [uploadOperation setQueuePriority:NSOperationQueuePriorityHigh];
        
        [boxUploadOperationQueue addOperation:uploadOperation];
        
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

-(void)flattenedFile
{
    
    //for (int i = 0; i<[uploadingArray count];i++) {
        
        
        tempPathArray = [[NSMutableArray alloc]init];
        
        NSString * originalPath = [[uploadingArray objectAtIndex:0] objectForKey:@"PdfPath"];
        NSString * originalName = [[uploadingArray objectAtIndex:0] objectForKey:@"PdfName"];
        NSString * originalID = [[uploadingArray objectAtIndex:0] objectForKey:@"folderID"];

        if ([[originalName pathExtension] isEqualToString: @""])
        {
            NSLog(@"no flattened file");
        }
        else{
            // appFile = [NSString stringWithFormat:@"%@-temp",originalName];
            appFile = [[NSString alloc]initWithFormat:@"%@--PdfMarkUpTemp.pdf",[originalName stringByDeletingPathExtension]]  ;
            
//            NSString *newPathToFile = [originalPath stringByDeletingLastPathComponent];
//            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            NSArray *firstSplit = [originalPath componentsSeparatedByString:@"Documents"];
            NSLog(@"paths in doc is %@",firstSplit);
            NSString * newPath;
            

       
//                if (![originalName isEqualToString:[firstSplit lastObject]])
//                {
//                  newPath = [NSString stringWithFormat:@"%@%@",newPathToFile,appFile];
//                
//                 }
//                 else
//                 {
//                  newPath = [NSString stringWithFormat:@"%@%@",documentsDirectory,appFile];
         
                //newPath = [NSString stringWithFormat:@"%@%@",documentsDirectory,appFile];
  

            NSLog(@"new path is %@",newPath);
            appFile = newPath;
            
            
            NSString *strFakepath = [originalPath stringByReplacingOccurrencesOfString:@".pdf" withString:@"--PdfMarkUpTemp.pdf"];
            PDFRenderer *pdfRenderer=[[PDFRenderer alloc]init];
            [pdfRenderer drawPDFWithReportID:nil withPDFFilePath:originalPath withSavePDFFilePath:strFakepath withPreview:NO];
            
            NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
            [dic setObject:strFakepath forKey:@"PdfPath"];
            [dic setObject:originalName forKey:@"PdfName"];
            if (originalID == nil) {
                originalID = [DetailViewController  getSharedInstance].folderID;
            }
            if([[[uploadingUserAcntsArray objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"AccountType"]isEqualToString:@"ftp"])
            {
                
            }
            else
            {
                [dic setObject:originalID forKey:@"folderID"];

            }
            
            [tempPathArray addObject:dic];
            
            
            [uploadingArray replaceObjectAtIndex:0 withObject:[tempPathArray objectAtIndex:0]];
            
            //          [[[filePathsArray objectAtIndex:i] objectForKey:@"PdfPath"] stringByReplacingOccurrencesOfString:[[filePathsArray objectAtIndex:i] objectForKey:@"PdfPath"] withString:appFile ];
            
            NSLog(@"gsfgdshfdsfgdssdgsgfsdgf %@",[[uploadingArray objectAtIndex:0] objectForKey:@"PdfPath"]);
        }
   // }
    
}

-(void)deletingFakePath
{
    // path will exixits in filepath array 1st object every time .
    for (int i = 0; i<[uploadingArray count];i++) {
        if ([[[[uploadingArray objectAtIndex:0]objectForKey:@"PdfPath"]pathExtension]isEqualToString:@""])
        {
            NSLog(@"Folder");
        }
        else{
            NSString * originalPath = [[uploadingArray objectAtIndex:0] objectForKey:@"PdfPath"];
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            NSError *error;
            NSString *documentsDirectory = [NSHomeDirectory()
                                            stringByAppendingPathComponent:@"Documents"];
            
            if ([fileMgr removeItemAtPath:originalPath error:&error] != YES)
                NSLog(@"Unable to delete file: %@", [error localizedDescription]);
            
            // Show contents of Documents directory
            NSLog(@"Documents directory: %@",
                  [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
        }
        
    }
    
}

-(void)uploadToFolder
{
    if([[[uploadingUserAcntsArray objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"AccountType"]isEqualToString:@"dropbox"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadSucess" object:self userInfo:nil];
        
        DropboxManager *dbManager = [DropboxManager dbManager];
        [dbManager restClient].delegate = self;
        
        // [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
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
        
        
        NSLog(@"folder path is %@", [DetailViewController  getSharedInstance].folderPath);
        if ([DetailViewController getSharedInstance].folderPath == nil)
        {
            [DetailViewController getSharedInstance].folderPath = @"/";
        }
        for (int k =0; k < [uploadingArray count]; k++)
        {
            NSLog(@"check %@",[[uploadingArray objectAtIndex:k] objectForKey:@"PdfName"] );
            if ([[[[uploadingArray objectAtIndex:k] objectForKey:@"PdfName"] pathExtension] isEqualToString:@"pdf"]){
                
                buploading = true;
                filecount++;
                
                [self flattenedFile];
                
                NSString *strUploadpdfname = [[uploadingArray objectAtIndex:k]objectForKey:@"PdfName"];
                
                if ([[arrLocalFilepaths objectForKey:[[uploadingArray objectAtIndex:k]objectForKey:@"PdfPath"]] length]>0) {
                    
                    
                    strpdfname = [arrLocalFilepaths objectForKey:[[uploadingArray objectAtIndex:k]objectForKey:@"PdfPath"]];
                }
                if ([strpdfname length]>0) {
                    
                    strUploadpdfname = [strUploadpdfname stringByReplacingOccurrencesOfString:strpdfname withString:@""];
                    
                }
                
                NSLog(@"struploadfiles name %@",strUploadpdfname);
                
                [[dbManager restClient] uploadFile:strUploadpdfname toPath: [DetailViewController  getSharedInstance].folderPath withParentRev:nil fromPath:[[uploadingArray objectAtIndex:k]objectForKey:@"PdfPath"]];
                
            }
            else if ([[[[uploadingArray objectAtIndex:k] objectForKey:@"PdfName"] pathExtension] isEqualToString:@""])
            {
                
                bprocessing = true;
                
                NSString *strUploadpdfname = [[uploadingArray objectAtIndex:k]objectForKey:@"PdfName"];
                
                if ([[arrLocalFilepaths objectForKey:[[uploadingArray objectAtIndex:k]objectForKey:@"PdfPath"]] length]>0) {
                    
                    
                    strpdfname = [arrLocalFilepaths objectForKey:[[uploadingArray objectAtIndex:k]objectForKey:@"PdfPath"]];
                }
                if ([strpdfname length]>0) {
                    
                    strUploadpdfname = [strUploadpdfname stringByReplacingOccurrencesOfString:strpdfname withString:@""];
                    
                    
                }
                [[dbManager restClient] createFolder:[NSString stringWithFormat:@"%@/%@",[DetailViewController  getSharedInstance].folderPath,strUploadpdfname]];
                
            }
        }
        while ([DownloadingSingletonClass getSharedInstance].dropBoxUpload == NO)
        {
            NSLog(@"thread is running .....");
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        
    }
    else if([[[uploadingUserAcntsArray objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"AccountType"]isEqualToString:@"box"])
    {
        // https://developers.box.com/docs/#files-upload-a-file
        
        
        //[self performSelectorOnMainThread:@selector(showOnMainThread) withObject:nil waitUntilDone:NO];
        
        NSString * extension = @"pdf";
        if ([[[[[uploadingArray objectAtIndex:0] objectForKey:@"PdfName"] pathExtension]lowercaseString] isEqualToString:[extension lowercaseString]])
        {
            
            
            NSLog(@"check uploading array %@",uploadingArray);
            [self flattenedFile];
            
            NSString *myString = [[uploadingArray objectAtIndex:0]objectForKey:@"PdfName"];
            NSArray *nameArray = [myString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
            NSArray* words = [[nameArray lastObject] componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceCharacterSet]];
            NSString* nospacestring = [words componentsJoinedByString:@""];
            NSString * filename = [NSString stringWithFormat:@"%@",nospacestring];
            
            
            
            if (boxParentId == nil) {
                boxParentId =[DetailViewController  getSharedInstance].folderID;
            }
            
            
            if ([[uploadingArray objectAtIndex:0] objectForKey:@"folderID"] != nil) {
                
                boxParentId =[[uploadingArray objectAtIndex:0] objectForKey:@"folderID"];

            }
            NSString * docfilepath = [[uploadingArray objectAtIndex:0]objectForKey:@"PdfPath"];
            [self uploadFileToBox:0 :filename :boxParentId :docfilepath];
            
           
            
        }
        else
        {
            
            NSString *myString = [[uploadingArray objectAtIndex:0]objectForKey:@"PdfName"];
            NSArray *nameArray = [myString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
            NSString * filename = [NSString stringWithFormat:@"%@",[nameArray lastObject]];
            if (boxParentId == nil) {
                boxParentId =[DetailViewController  getSharedInstance].folderID;
            }
            
            if ([[uploadingArray objectAtIndex:0] objectForKey:@"folderID"] != nil) {
                
                boxParentId =[[uploadingArray objectAtIndex:0] objectForKey:@"folderID"];
                
            }
            
                strRootpath = [[uploadingArray objectAtIndex:0]objectForKey:@"PdfPath"];


          
                [self uploadFolderToBox:0 :filename :boxParentId];

            
        }
        
        while ([DownloadingSingletonClass getSharedInstance].boxUpload == NO)
        {
            NSLog(@"thread is running .....");
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        
    }
    else if([[[uploadingUserAcntsArray objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"AccountType"]isEqualToString:@"google"])
    {
        NSLog(@"folder path is %@", docFolderPath);
        if (docFolderPath == nil)
        {
            docFolderPath = @"/";
            NSLog(@"doc folder path is %@",docFolderPath);
        }
        NSString * extension = @"pdf";
        if ([[[[[uploadingArray objectAtIndex:0] objectForKey:@"PdfName"] pathExtension]lowercaseString] isEqualToString:[extension lowercaseString]])
        {
            [self flattenedFile];
            NSString * docfilepath = [[uploadingArray objectAtIndex:0]objectForKey:@"PdfPath"];
            NSString *myString = [[uploadingArray objectAtIndex:0]objectForKey:@"PdfName"];
            NSArray *nameArray = [myString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
            NSString * docfileName = [nameArray lastObject];
            NSData *fileData = [NSData dataWithContentsOfFile:docfilepath];
            if (driveParentId == nil)
            {
                driveParentId =[DetailViewController  getSharedInstance].folderID;
            }
            if ([[uploadingArray objectAtIndex:0] objectForKey:@"folderID"] != nil) {
                
                driveParentId =[[uploadingArray objectAtIndex:0] objectForKey:@"folderID"];
                
            }
            
            [self uploadPdfToDrive:fileData :docfileName :driveParentId :myString];
        }
        else
        {
            // NSString * docfilepath = [[filePathsArray objectAtIndex:0]objectForKey:@"PdfPath"];
            NSString *myString = [[uploadingArray objectAtIndex:0]objectForKey:@"PdfName"];
            NSArray *nameArray = [myString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
            NSString * docfileName = [nameArray lastObject];
            
            if (driveParentId == nil)
            {
                driveParentId =[DetailViewController  getSharedInstance].folderID;
                NSLog(@"drive parent ID %@",driveParentId);
            }
            
            
            if ([[uploadingArray objectAtIndex:0] objectForKey:@"folderID"] != nil) {
                
                driveParentId =[[uploadingArray objectAtIndex:0] objectForKey:@"folderID"];
                
            }
            
            // if (strRootpath == nil) {
            strRootpath = [[uploadingArray objectAtIndex:0]objectForKey:@"PdfPath"];
            
            [self uploadFolderToDrive:docfileName :driveParentId :myString];
        }
        
//        editBarButton.title = @"Edit";
//        [documentsTableView setEditing:NO];
//        [documentsCollectionView reloadData];
//        for (int i =0; i< [checkableArray count]; i++) {
//            
//            Item *item = (Item *)[checkableArray objectAtIndex:i];
//            item.isChecked = NO;
//            
//        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadSucess" object:self userInfo:nil];
        
    }
    else if([[[uploadingUserAcntsArray objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"AccountType"]isEqualToString:@"ftp"])
    {
        
        // [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadSucess" object:self userInfo:nil];
        
        NSLog(@"folder path is %@", docFolderPath);
        if (docFolderPath == nil)
        {
            docFolderPath = @"/";
            NSLog(@"doc folder path is %@",docFolderPath);
        }
        NSString * extension = @"pdf";
        if ([[[[[uploadingArray objectAtIndex:0] objectForKey:@"PdfName"] pathExtension]lowercaseString] isEqualToString:[extension lowercaseString]])
        {
            [self flattenedFile];
            NSString * docfilepath = [[uploadingArray objectAtIndex:0]objectForKey:@"PdfPath"];
            NSString *myString = [[uploadingArray objectAtIndex:0]objectForKey:@"PdfName"];
            NSArray *nameArray = [myString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
            NSString * docfileName = [nameArray lastObject];
            NSData *fileData = [NSData dataWithContentsOfFile:docfilepath];
            
            [self uploadFileToFTP:fileData :docfileName :docfilepath];
            
        }
        else
        {
            // NSString * docfilepath = [[filePathsArray objectAtIndex:0]objectForKey:@"PdfPath"];
            
            NSString *myString = [[uploadingArray objectAtIndex:0]objectForKey:@"PdfName"];
            NSArray *nameArray = [myString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
            NSString * docfileName = [nameArray lastObject];
            createdFolderName = docfileName;
            NSArray* words = [docfileName componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceCharacterSet]];
            NSString* nospacestring = [words componentsJoinedByString:@""];
            
            
            
            NSString *pdfPath = [[uploadingArray objectAtIndex:0]objectForKey:@"PdfPath"];
            strRootpath = [[uploadingArray objectAtIndex:0]objectForKey:@"PdfPath"];

            
            [self uploadFolderToFtp:nospacestring :strRootpath];
            
        }

        
        while ([DownloadingSingletonClass getSharedInstance].ftpUpload == NO)
        {
            NSLog(@"thread is running .....");
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
    else
    {
        NSString * extension = @"pdf";
        [DownloadingSingletonClass getSharedInstance].sugarUpload = NO;

        if ([[[[[uploadingArray objectAtIndex:0] objectForKey:@"PdfName"] pathExtension]lowercaseString] isEqualToString:[extension lowercaseString]])
        {
            
            NSLog(@"check uploading array %@",uploadingArray);
            [self flattenedFile];
        
            NSString * docfilepath = [[uploadingArray objectAtIndex:0]objectForKey:@"PdfPath"];
            NSString *myString = [[uploadingArray objectAtIndex:0]objectForKey:@"PdfName"];
            NSArray *nameArray = [myString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
            NSString * docfileName = [nameArray lastObject];
            NSData *fileData = [[NSData alloc]initWithContentsOfFile:docfilepath];
            
            if (boxParentId == nil) {
                boxParentId =[DetailViewController  getSharedInstance].folderID;
            }
        
            if ([[uploadingArray objectAtIndex:0] objectForKey:@"folderID"] != nil) {
                
                boxParentId =[[uploadingArray objectAtIndex:0] objectForKey:@"folderID"];
                
            }
            
            NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",boxParentId]];
            
            [self uploadFileToSugar:0 :docfileName :url :docfilepath :fileData];
            
            
        }
        else
        {
            
            NSString *myString = [[uploadingArray objectAtIndex:0]objectForKey:@"PdfName"];
            NSArray *nameArray = [myString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
            NSString * filename = [NSString stringWithFormat:@"%@",[nameArray lastObject]];
            if (boxParentId == nil) {
                boxParentId =[DetailViewController  getSharedInstance].folderID;
            }
            
            if ([[uploadingArray objectAtIndex:0] objectForKey:@"folderID"] != nil) {
                
                boxParentId =[[uploadingArray objectAtIndex:0] objectForKey:@"folderID"];
                
            }
            
            strRootpath = [[uploadingArray objectAtIndex:0]objectForKey:@"PdfPath"];
            
            NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",boxParentId]];

            
            [self uploadFolderToSugar:0 :filename :url];
            
            
        }
        while ([DownloadingSingletonClass getSharedInstance].sugarUpload == NO)
        {
            NSLog(@"thread is running .....");
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }

    }
}
-(void)showOnMainThread
{
    [documentsCollectionView reloadData];
    
    editBarButton.title = @"Edit";
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadSucess" object:self userInfo:nil];
    
}
#pragma mark FTP Uploading
-(void)uploadFileToFTP:(NSData *)fileData :(NSString *)fileName :(NSString *)filePath
{
    // NSLog(@"file path from array is %@",filePath);
    NSLog(@"uploading file name is %@",fileName);
    NSLog(@"file path from shared instance is %@",[DetailViewController getSharedInstance].folderPath);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docpath = [filePath stringByReplacingOccurrencesOfString:[paths objectAtIndex:0] withString:@""];
    NSMutableArray *arrStrings = [[NSMutableArray alloc] initWithArray:[docpath componentsSeparatedByString:@"/"]];
    [arrStrings removeLastObject];
    NSString *strfakepath = [[[arrStrings valueForKey:@"description"] componentsJoinedByString:@"/"] stringByReplacingOccurrencesOfString:loadData withString:@""];
    
    
    FMServer* srv = [FMServer serverWithDestination:[[[uploadingUserAcntsArray objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"host"] stringByAppendingPathComponent:strfakepath] username:[[uploadingUserAcntsArray objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"name"] password:[[uploadingUserAcntsArray objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"password"]];
    
    
    succeeded = [man uploadData:fileData withFileName:fileName toServer:srv];
    if (succeeded)
    {
            if ([uploadingArray count]>0)
            {
                [self deletingFakePath];
                [uploadingArray removeObjectAtIndex:0];
            }
            if ([uploadingArray count]>0)
            {
                // [self uploadToFolder];
               
                
                [self uploadToFolder];
                
            }
            else
            {
                NSString * str = [DetailViewController  getSharedInstance].folderPath;
                
                [DetailViewController  getSharedInstance].folderPath = [NSString stringWithFormat:@"%@%@",str,folderNameNospace];
                boxFolderPaths = [boxFolderPaths stringByAppendingPathComponent:createdFolderName];
                if (!ftpFolderPath) {
                    ftpFolderPath = folderNameNospace;
                }
                ftpFolderPath = [ftpFolderPath stringByAppendingPathComponent:folderNameNospace];
                [self performSelector:@selector(closeFtpUploadControllerr) withObject:nil afterDelay:0];
                
            }
        
    }
    
}

-(void)uploadFolderToFtp:(NSString *)name :(NSString *)path
{
    
   
    NSLog(@"path is 666666 %@",path);
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docpath = [path stringByReplacingOccurrencesOfString:[paths objectAtIndex:0] withString:@""];
    
    folderNameNospace = name;
    NSLog(@"file path from shared instance is %@",[DetailViewController getSharedInstance].folderPath);
    
    FMServer* srv = [FMServer serverWithDestination:[[uploadingUserAcntsArray objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"host"]  username:[[uploadingUserAcntsArray objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"name"] password:[[uploadingUserAcntsArray objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount]objectForKey:@"password"]];
    

    succeeded = [man createNewFolder:[docpath stringByReplacingOccurrencesOfString:loadData withString:@""] atServer:srv];
    if (succeeded) {
        
       // createDir = nil;
        
        // NSString * childFolderName = [[arrJson objectAtIndex:0]objectForKey:@"name"];
        NSString * childFolderName = [[uploadingArray objectAtIndex:0] objectForKey:@"PdfName"];
        NSLog(@"uploading array is >>>>>>>>>>>>>%@",[[uploadingArray objectAtIndex:0] objectForKey:@"PdfName"]);
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *strpath;
        
        NSLog(@"check folder path>>>>>>>>>>>>>>>> %@",[DetailViewController  getSharedInstance].folderPath);
        //    strpath  = [[uploadingArray objectAtIndex:0] objectForKey:@"PdfName"];
        // NSLog(@"check before folder path %@",folder.path);
        if ([[DetailViewController  getSharedInstance].folderPath isEqualToString:@"/"]) {
            strpath  = [NSString stringWithFormat:@"/%@",childFolderName];
        }
        else
        {
            strpath  = [[NSString stringWithFormat:@"/%@",childFolderName] stringByReplacingOccurrencesOfString:[DetailViewController  getSharedInstance].folderPath withString:@""];
            
        }
        
        
        NSLog(@"check folder path <<<<<<<<<<<<<<%@",[DetailViewController  getSharedInstance].folderPath);
        NSLog(@"check before folder path %@",childFolderName);
        if ([[DetailViewController  getSharedInstance].folderPath isEqualToString:@"/"]){
            strpath  = [NSString stringWithFormat:@"/%@",childFolderName];
        }
        else
        {
            strpath  = [[NSString stringWithFormat:@"/%@",childFolderName] stringByReplacingOccurrencesOfString:[DetailViewController  getSharedInstance].folderPath withString:@""];
            
        }
        
        NSLog(@"after file path is %@",strpath);
        
        
        NSError *error;
        NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:strRootpath error:&error];
        
        
        arrFolderdoc = [[NSMutableArray alloc] init];
        NSLog(@"directory is %@",directoryContent);
        
        for (int i =0; i<[directoryContent count]; i++) {
            
            NSString *strdropboxpath = [NSString stringWithFormat:@"%@/%@",strRootpath,[directoryContent objectAtIndex:i]];
            
            if ([[[directoryContent objectAtIndex:i] pathExtension] isEqualToString:@"pdf"]) {
                
                buploading = true;
                filecount++;
                
                NSMutableDictionary * dic = [[NSMutableDictionary alloc] init ];
                [dic setObject:strdropboxpath forKey:@"PdfPath"];
                [dic setObject:[NSString stringWithFormat:@"/%@",[directoryContent objectAtIndex:i]] forKey:@"PdfName"];
                [boxUploadingArray addObject: dic];
                
            }
            else if ([[[directoryContent objectAtIndex:i] pathExtension] isEqualToString:@""])
            {
                NSMutableDictionary * dic = [[NSMutableDictionary alloc] init ];
                [dic setObject:strdropboxpath forKey:@"PdfPath"];
                [dic setObject:[NSString stringWithFormat:@"/%@",[directoryContent objectAtIndex:i]] forKey:@"PdfName"];
                
                [boxUploadingArray addObject: dic];
                
                
            }
            
        }
        
        
        if ([uploadingArray count]>0) {
            
            [uploadingArray removeObjectAtIndex:0];
            
        }
        if ([arrboxIDS count]>0) {
            
            [arrboxIDS removeObjectAtIndex:0];
        }
        if ([uploadingArray count]>0) {
            issubfolder = false;
            
            [self uploadToFolder];
            
        }
        else
        {
            boxFolderPaths = [boxFolderPaths stringByAppendingPathComponent:childFolderName];
            
            
            NSLog(@"check the  arrrrrrrrrrry %@",boxUploadingArray);
            
            [self performSelector:@selector(closeFtpUploadControllerr) withObject:nil afterDelay:0];
            
            
        }
 
        
    }
    else
    {
        
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        
                
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Pdf Markup" message:@"Failed to Upload" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
                
        
            [DownloadingSingletonClass getSharedInstance].ftpUpload = YES;
            
            [self performSelectorOnMainThread:@selector(uploadCompleted) withObject:nil waitUntilDone:NO];
            
    }

}


//-----
//				requestDataSendSize

- (void) percentCompleted: (BRRequest *) request
{
    NSLog(@"%f completed...", request.percentCompleted);
    NSLog(@"%ld bytes this iteration", request.bytesSent);
    NSLog(@"%ld total bytes", request.totalBytesSent);
}
- (long) requestDataSendSize: (BRRequestUpload *) request
{
    //----- user returns the total size of data to send. Used ONLY for percentComplete
    return [uploadData length];
}



//-----
//				requestDataToSend


- (NSData *) requestDataToSend: (BRRequestUpload *) request
{
    NSData *temp = uploadData;                                                  // this is a shallow copy of the pointer, not a deep copy
    
    uploadData = nil;                                                           // next time around, return nil...
    
    return temp;
}



-(BOOL) shouldOverwriteFileWithRequest: (BRRequest *) request
{
    //----- set this as appropriate if you want the file to be overwritten
    if (request == uploadFile)
    {
        //----- if uploading a file, we set it to YES
        return YES;
    }
    
    //----- anything else (directories, etc) we set to NO
    return NO;
}

//-----
//				requestCompleted

-(void) requestCompleted: (BRRequest *) request
{
    
    
    if (request == createDir)
    {
        
        createDir = nil;
        
        // NSString * childFolderName = [[arrJson objectAtIndex:0]objectForKey:@"name"];
        NSString * childFolderName = [[uploadingArray objectAtIndex:0] objectForKey:@"PdfName"];
        NSLog(@"uploading array is >>>>>>>>>>>>>%@",[[uploadingArray objectAtIndex:0] objectForKey:@"PdfName"]);
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *strpath;
        
        NSLog(@"check folder path>>>>>>>>>>>>>>>> %@",[DetailViewController  getSharedInstance].folderPath);
        //    strpath  = [[uploadingArray objectAtIndex:0] objectForKey:@"PdfName"];
        // NSLog(@"check before folder path %@",folder.path);
        if ([[DetailViewController  getSharedInstance].folderPath isEqualToString:@"/"]) {
            strpath  = [NSString stringWithFormat:@"/%@",childFolderName];
        }
        else
        {
            strpath  = [[NSString stringWithFormat:@"/%@",childFolderName] stringByReplacingOccurrencesOfString:[DetailViewController  getSharedInstance].folderPath withString:@""];
            
        }
        
        
        NSLog(@"check folder path <<<<<<<<<<<<<<%@",[DetailViewController  getSharedInstance].folderPath);
        NSLog(@"check before folder path %@",childFolderName);
        if ([[DetailViewController  getSharedInstance].folderPath isEqualToString:@"/"]){
            strpath  = [NSString stringWithFormat:@"/%@",childFolderName];
        }
        else
        {
            strpath  = [[NSString stringWithFormat:@"/%@",childFolderName] stringByReplacingOccurrencesOfString:[DetailViewController  getSharedInstance].folderPath withString:@""];
            
        }
        
        NSLog(@"after file path is %@",strpath);
        
        NSString *folderpath = nil;
        
        
        NSError *error;
        NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:strRootpath error:&error];
        
        
        arrFolderdoc = [[NSMutableArray alloc] init];
        NSLog(@"directory is %@",directoryContent);
        
        for (int i =0; i<[directoryContent count]; i++) {
            
            NSString *strdropboxpath = [NSString stringWithFormat:@"%@/%@",strRootpath,[directoryContent objectAtIndex:i]];
            
            if ([[[directoryContent objectAtIndex:i] pathExtension] isEqualToString:@"pdf"]) {
                
                buploading = true;
                filecount++;
                
                NSMutableDictionary * dic = [[NSMutableDictionary alloc] init ];
                [dic setObject:strdropboxpath forKey:@"PdfPath"];
                [dic setObject:[NSString stringWithFormat:@"/%@",[directoryContent objectAtIndex:i]] forKey:@"PdfName"];
                [boxUploadingArray addObject: dic];
                
            }
            else if ([[[directoryContent objectAtIndex:i] pathExtension] isEqualToString:@""])
            {
                NSMutableDictionary * dic = [[NSMutableDictionary alloc] init ];
                [dic setObject:strdropboxpath forKey:@"PdfPath"];
                [dic setObject:[NSString stringWithFormat:@"/%@",[directoryContent objectAtIndex:i]] forKey:@"PdfName"];
                
                [boxUploadingArray addObject: dic];
                
                
            }
            
        }
        
        
        if ([uploadingArray count]>0) {
            
            [uploadingArray removeObjectAtIndex:0];
            
        }
        if ([arrboxIDS count]>0) {
            
            [arrboxIDS removeObjectAtIndex:0];
        }
        if ([uploadingArray count]>0) {
            issubfolder = false;
            
            [self uploadToFolder];
            
        }
        else
        {
            boxFolderPaths = [boxFolderPaths stringByAppendingPathComponent:childFolderName];
            
            
            NSLog(@"check the  arrrrrrrrrrry %@",boxUploadingArray);
            
            [self performSelector:@selector(closeFtpUploadControllerr) withObject:nil afterDelay:0];
            
            
        }

        
        
        
        
        
    }
    
    
    if (request == uploadFile)
    {
        NSLog(@"%@ completed!", request);
        
        uploadFile = nil;
        
        if ([uploadingArray count]>0)
        {
            [self deletingFakePath];
            [uploadingArray removeObjectAtIndex:0];
        }
        if ([uploadingArray count]>0)
        {
            [self uploadToFolder];
           
        }
        else
        {
            NSString * str = [DetailViewController  getSharedInstance].folderPath;
            
            [DetailViewController  getSharedInstance].folderPath = [NSString stringWithFormat:@"%@%@",str,folderNameNospace];
            boxFolderPaths = [boxFolderPaths stringByAppendingPathComponent:createdFolderName];
            if (!ftpFolderPath) {
                ftpFolderPath = folderNameNospace;
            }
            ftpFolderPath = [ftpFolderPath stringByAppendingPathComponent:folderNameNospace];
            [self performSelector:@selector(closeFtpUploadControllerr) withObject:nil afterDelay:0];
            
        }
    }
    
}



//-----
//				requestFailed

-(void) requestFail:(BRRequest *) request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSLog(@"%@", request.error);

    if (request == createDir)
    {
        NSLog(@"%@", request.error.message);
        
        createDir = nil;
    }
    
    if (request == uploadFile)
    {
        NSLog(@"%@", request.error.message);
        
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Pdf Markup" message:request.error.message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        
        uploadFile = nil;
    }
    [DownloadingSingletonClass getSharedInstance].ftpUpload = YES;

    [self performSelectorOnMainThread:@selector(uploadCompleted) withObject:nil waitUntilDone:NO];

}

-(void)closeFtpUploadControllerr
{
    if ([boxUploadingArray count]>0)
    {
        [uploadingArray removeAllObjects];
        //  boxFilePath = root;
        for (int k = 0; k<[boxUploadingArray count]; k++)
        {
            NSLog(@"%d",[boxUploadingArray count]);
            NSString *   bfolderName =  [[boxUploadingArray objectAtIndex:k]objectForKey:@"PdfName"];
            NSString *   bfolderPath =  [[boxUploadingArray objectAtIndex:k]objectForKey:@"PdfPath"];
            
            NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
            [dic setObject:bfolderName forKey:@"PdfName"];
            [dic setObject:bfolderPath forKey:@"PdfPath"];
            
            [uploadingArray addObject:dic];
            
        }
        
        
        [boxUploadingArray removeAllObjects];
        [self uploadToFolder];
        
    }
    
    if ([uploadingArray count]==0 && [boxUploadingArray count]==0)
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [documentsTableView setEditing:NO];
        editBarButton.title = @"Edit";
        [DownloadingSingletonClass getSharedInstance].ftpUpload = YES;
        [uploadingArray removeAllObjects];
        [self performSelectorOnMainThread:@selector(uploadCompleted) withObject:nil waitUntilDone:NO];

        
        [documentsCollectionView reloadData];
        
        for (int i =0; i< [checkableArray count]; i++) {
            
            Item *item = (Item *)[checkableArray objectAtIndex:i];
            item.isChecked = NO;
            
        }

        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [documentsTableView reloadData];
    }
    
}



#pragma mark Box Uploading

-(void)uploadFileToBox:(int)sender :(NSString *)fileName :(NSString *)parentId :(NSString *)filePath
{
    
    buploading = true;
    filecount++;
    
    NSLog(@"sender %d",sender);
    
    NSString * accessToken =  [[arrUseraccounts objectAtIndex:[DetailViewController getSharedInstance].uploadIndex] objectForKey:@"acces_token"];
    
    NSString *str =  [NSString stringWithFormat:@"https://upload.box.com/api/2.0/files/content?access_token=%@&filename=@%@&parent_id=%@",accessToken,fileName,parentId];
    
    ASIFormDataRequest *postParams = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:str]];
    postParams.delegate = self ;
    postParams.userInfo = [NSDictionary dictionaryWithObject:@"upload" forKey:@"id"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    [postParams setData:data withFileName:fileName andContentType:@"application/pdf" forKey:@"filename"];
    //[postParams setFile:filePath forKey:@"filename"];
    [postParams startAsynchronous];
    NSLog(@"pdf file");
    
}

-(void)uploadFolderToBox:(int)sender :(NSString *)fileName :(NSString *)parentId
{
    
    NSLog(@"folder ");
    
    bprocessing = true;
    
    NSString *strUploadpdfname = [[uploadingArray objectAtIndex:sender]objectForKey:@"PdfName"];
    
    if ([[arrLocalFilepaths objectForKey:[[uploadingArray objectAtIndex:sender]objectForKey:@"PdfPath"]] length]>0) {
        
        
        strpdfname = [arrLocalFilepaths objectForKey:[[uploadingArray objectAtIndex:sender]objectForKey:@"PdfPath"]];
    }
    if ([strpdfname length]>0) {
        
        strUploadpdfname = [strUploadpdfname stringByReplacingOccurrencesOfString:strpdfname withString:@""];
        
        
    }
    
    NSString * accessToken =  [[arrUseraccounts objectAtIndex:[DetailViewController getSharedInstance].uploadIndex] objectForKey:@"acces_token"];
    
    NSDictionary *cid = [[NSDictionary alloc] initWithObjectsAndKeys:fileName,@"name",[NSDictionary dictionaryWithObject:parentId forKey:@"id"],@"parent", nil];
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:cid options:0 error:&error];
    
    NSMutableData *data = [[NSMutableData alloc] initWithData:postData];
    
    
    
    ASIFormDataRequest *postParams = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.box.com/2.0/folders?access_token=%@",accessToken]]];
    [postParams setPostBody:data];
    [postParams setRequestMethod:@"POST"];
    postParams.delegate = self ;
    postParams.userInfo = [NSDictionary dictionaryWithObject:@"uploadFolder" forKey:@"id"];
    [postParams startAsynchronous];
    
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
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
        
        [self checkExpiredBoxToken];
    }
    else if ([[request.userInfo objectForKey:@"id"] isEqualToString:@"upload"])
    {
        NSLog(@"response is %@",request.responseString);
        NSMutableArray *arrJson= [[NSMutableArray alloc]initWithObjects:[request.responseString JSONValue],nil];
        NSLog(@"%@",arrJson);
        if ([[[arrJson objectAtIndex:0]objectForKey:@"message"]isEqualToString:@"Item with the same name already exists"]) {
            
            NSLog(@"already exists");
        }
        
        else
        {
            
        }
        
        NSString * childFolderName = [[uploadingArray objectAtIndex:0] objectForKey:@"PdfName"];

        if ([uploadingArray count]>0) {
            
            [self deletingFakePath];
            
            [uploadingArray removeObjectAtIndex:0];
            
        }
        if ([uploadingArray count]>0) {
            [self uploadToFolder];
            
        }
        else
        {
            [self performSelector:@selector(closeBoxUploadControllerr) withObject:nil afterDelay:0];

        }
        
        
        
    }
    if ([[request.userInfo objectForKey:@"id"] isEqualToString:@"uploadFolder"])
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        // NSLog(@"response is %@",request.responseString);
        NSMutableArray *arrJson= [[NSMutableArray alloc]initWithObjects:[request.responseString JSONValue],nil];
        if ([[[arrJson objectAtIndex:0]objectForKey:@"message"]isEqualToString:@"Item with the same name already exists"]) {
            
            NSLog(@"already exists");
            [uploadingArray removeAllObjects];
            [arrboxIDS removeAllObjects];
            [boxUploadingArray removeAllObjects];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            [documentsTableView setEditing:NO];
            editBarButton.title = @"Edit";
            boxParentId = nil;
            boxFolderPaths = nil;
            
            [uploadingArray removeAllObjects];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            [DownloadingSingletonClass getSharedInstance].boxUpload = YES;
            [self performSelectorOnMainThread:@selector(uploadCompleted) withObject:nil waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(sameName) withObject:nil waitUntilDone:NO];

            for (int i =0; i< [checkableArray count]; i++) {
                
                Item *item = (Item *)[checkableArray objectAtIndex:i];
                item.isChecked = NO;
                
            }
            
            strRootpath = nil;
            
            [documentsTableView reloadData];

        }
        else
        {
            
        // NSString * childFolderName = [[arrJson objectAtIndex:0]objectForKey:@"name"];
        NSString * childFolderName = [[uploadingArray objectAtIndex:0] objectForKey:@"PdfName"];
        NSLog(@"uploading array is >>>>>>>>>>>>>%@",[[uploadingArray objectAtIndex:0] objectForKey:@"PdfName"]);
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *strpath;
        
        NSLog(@"check folder path>>>>>>>>>>>>>>>> %@",[DetailViewController  getSharedInstance].folderPath);
    //    strpath  = [[uploadingArray objectAtIndex:0] objectForKey:@"PdfName"];
        // NSLog(@"check before folder path %@",folder.path);
        if ([[DetailViewController  getSharedInstance].folderPath isEqualToString:@"/"]) {
            strpath  = [NSString stringWithFormat:@"/%@",childFolderName];
        }
        else
        {
            strpath  = [[NSString stringWithFormat:@"/%@",childFolderName] stringByReplacingOccurrencesOfString:[DetailViewController  getSharedInstance].folderPath withString:@""];
            
        }
        
        
        NSLog(@"check folder path <<<<<<<<<<<<<<%@",[DetailViewController  getSharedInstance].folderPath);
        NSLog(@"check before folder path %@",childFolderName);
        if ([[DetailViewController  getSharedInstance].folderPath isEqualToString:@"/"]){
            strpath  = [NSString stringWithFormat:@"/%@",childFolderName];
        }
        else
        {
            strpath  = [[NSString stringWithFormat:@"/%@",childFolderName] stringByReplacingOccurrencesOfString:[DetailViewController  getSharedInstance].folderPath withString:@""];
            
        }
        
        NSLog(@"after file path is %@",strpath);
        
        NSString *folderpath = nil;
        
        NSError *error;
        NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:strRootpath error:&error];
        
        
        arrFolderdoc = [[NSMutableArray alloc] init];
        NSLog(@"directory is %@",directoryContent);
        
        for (int i =0; i<[directoryContent count]; i++) {
            
            NSString *strdropboxpath = [NSString stringWithFormat:@"%@/%@",strRootpath,[directoryContent objectAtIndex:i]];
            
            if ([[[directoryContent objectAtIndex:i] pathExtension] isEqualToString:@"pdf"]) {
                
                buploading = true;
                filecount++;
                NSLog(@"arrjson is %@",arrJson);
                NSMutableDictionary * dic = [[NSMutableDictionary alloc] init ];
                [dic setObject:strdropboxpath forKey:@"PdfPath"];
                [dic setObject:[NSString stringWithFormat:@"/%@",[directoryContent objectAtIndex:i]] forKey:@"PdfName"];
                [dic setObject:[[arrJson objectAtIndex:0]objectForKey:@"id"] forKey:@"folderID"];
                [boxUploadingArray addObject: dic];
                
            }
            else if ([[[directoryContent objectAtIndex:i] pathExtension] isEqualToString:@""])
            {
                NSMutableDictionary * dic = [[NSMutableDictionary alloc] init ];
                [dic setObject:strdropboxpath forKey:@"PdfPath"];
                [dic setObject:[NSString stringWithFormat:@"/%@",[directoryContent objectAtIndex:i]] forKey:@"PdfName"];
                [dic setObject:[[arrJson objectAtIndex:0]objectForKey:@"id"] forKey:@"folderID"];
                
                [boxUploadingArray addObject: dic];
                
                
            }
            
        }
        
        if ([uploadingArray count]>0) {
            
            [uploadingArray removeObjectAtIndex:0];
            
        }
        if ([arrboxIDS count]>0) {
            
            [arrboxIDS removeObjectAtIndex:0];
        }
        if ([uploadingArray count]>0) {
            issubfolder = false;

            [self uploadToFolder];
        }
        else
        {
            boxFolderPaths = [boxFolderPaths stringByAppendingPathComponent:childFolderName];
            
            
            NSLog(@"check the  arrrrrrrrrrry %@",boxUploadingArray);

            [self performSelector:@selector(closeBoxUploadControllerr) withObject:nil afterDelay:0];

            
        }
        
        }
    }
}
-(void)sameName
{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Failed To Upload" message:@"Same name already exists" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"%@", request.error);
    [self deletingFakePath];

    [self performSelectorOnMainThread:@selector(uploadCompleted) withObject:nil waitUntilDone:NO];

}
-(void)closeBoxUploadControllerr
{
    
    if ([boxUploadingArray count]>0)
    {
        [uploadingArray removeAllObjects];
        //  boxFilePath = root;
        for (int k = 0; k<[boxUploadingArray count]; k++)
        {
            NSLog(@"%d",[boxUploadingArray count]);
            NSString *   bfolderName =  [[boxUploadingArray objectAtIndex:k]objectForKey:@"PdfName"];
            NSString *    bfolderPath =  [[boxUploadingArray objectAtIndex:k]objectForKey:@"PdfPath"];
            NSString *    bboxid =  [[boxUploadingArray objectAtIndex:k]objectForKey:@"folderID"];

            
            NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
            [dic setObject:bboxid forKey:@"folderID"];
            [dic setObject:bfolderName forKey:@"PdfName"];
            [dic setObject:bfolderPath forKey:@"PdfPath"];
            [uploadingArray addObject:dic];
            
        }
        [boxUploadingArray removeAllObjects];
        
        issubfolder = TRUE;
        [self uploadToFolder];
        
        
    }
    if ([uploadingArray count]==0 && [boxUploadingArray count]==0)
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [documentsTableView setEditing:NO];
        editBarButton.title = @"Edit";
        boxParentId = nil;
        boxFolderPaths = nil;
        
        [uploadingArray removeAllObjects];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [DownloadingSingletonClass getSharedInstance].boxUpload = YES;
        [self performSelectorOnMainThread:@selector(uploadCompleted) withObject:nil waitUntilDone:NO];
        for (int i =0; i< [checkableArray count]; i++) {
            
            Item *item = (Item *)[checkableArray objectAtIndex:i];
            item.isChecked = NO;
            
        }
        
        strRootpath = nil;
        
        [documentsTableView reloadData];
        
    }
    
}
-(void)uploadCompleted
{
    [AppDelegate sharedInstance].bgRunningStatusUpload = @"Upload completed";
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadSucess" object:self userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadCompleted" object:self userInfo:nil];
    
    [documentsCollectionView reloadData];

}
#pragma mark SugarSync Uploading

-(void)uploadFileToSugar:(int)sender :(NSString *)fileName :(NSURL *)parentId :(NSString *)filePath :(NSData *)data
{
    
    buploading = true;
    filecount++;
    
    NSLog(@"uploading file details %@ , %@, %@ ,%d",fileName,parentId,filePath,[data length]);
    
    [[SugarSyncClient getSharedInstance]createFileNamed:fileName mediaType:@"application/pdf" parentFolderURL:parentId completionHandler:^(NSURL * newFileUrl,NSError * error)
    {
        
        [[SugarSyncClient getSharedInstance]uploadFileDataWithURL:newFileUrl fileData:data completionHandler:^(NSError *error)
         {
             if (error) {
                 NSLog(@"not uploaded");
             }
             if ([uploadingArray count]>0)
             {
                 [self deletingFakePath];
                 [uploadingArray removeObjectAtIndex:0];
             }
             if ([uploadingArray count]>0)
             {
                 [self uploadToFolder];
             }
             else
             {
                 [self performSelector:@selector(closeSugarUploadControllerr) withObject:nil afterDelay:0];
                 
             }

         }];

    }];

}

-(void)uploadFolderToSugar:(int)sender :(NSString *)fileName :(NSURL *)parentId
{
    
    NSLog(@"folder ");
    
    bprocessing = true;
    
    NSString *strUploadpdfname = [[uploadingArray objectAtIndex:sender]objectForKey:@"PdfName"];
    
    if ([[arrLocalFilepaths objectForKey:[[uploadingArray objectAtIndex:sender]objectForKey:@"PdfPath"]] length]>0) {
        
        
        strpdfname = [arrLocalFilepaths objectForKey:[[uploadingArray objectAtIndex:sender]objectForKey:@"PdfPath"]];
    }
    if ([strpdfname length]>0) {
        
        strUploadpdfname = [strUploadpdfname stringByReplacingOccurrencesOfString:strpdfname withString:@""];
        
    }
    
     [[SugarSyncClient getSharedInstance]createFolderNamed:fileName parentFolderURL:parentId completionHandler:^(NSURL * newFolderUrl, NSError * error){
         
         // NSString * childFolderName = [[arrJson objectAtIndex:0]objectForKey:@"name"];
         NSString * childFolderName = [[uploadingArray objectAtIndex:0] objectForKey:@"PdfName"];
         NSLog(@"uploading array is >>>>>>>>>>>>>%@",[[uploadingArray objectAtIndex:0] objectForKey:@"PdfName"]);
         NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
         NSString *documentsDirectory = [paths objectAtIndex:0];
         NSString *strpath;
         
         NSLog(@"check folder path>>>>>>>>>>>>>>>> %@",[DetailViewController  getSharedInstance].folderPath);
         //    strpath  = [[uploadingArray objectAtIndex:0] objectForKey:@"PdfName"];
         // NSLog(@"check before folder path %@",folder.path);
         if ([[DetailViewController  getSharedInstance].folderPath isEqualToString:@"/"]) {
             strpath  = [NSString stringWithFormat:@"/%@",childFolderName];
         }
         else
         {
             strpath  = [[NSString stringWithFormat:@"/%@",childFolderName] stringByReplacingOccurrencesOfString:[DetailViewController  getSharedInstance].folderPath withString:@""];
             
         }
         
         
         NSLog(@"check folder path <<<<<<<<<<<<<<%@",[DetailViewController  getSharedInstance].folderPath);
         NSLog(@"check before folder path %@",childFolderName);
         if ([[DetailViewController  getSharedInstance].folderPath isEqualToString:@"/"]){
             strpath  = [NSString stringWithFormat:@"/%@",childFolderName];
         }
         else
         {
             strpath  = [[NSString stringWithFormat:@"/%@",childFolderName] stringByReplacingOccurrencesOfString:[DetailViewController  getSharedInstance].folderPath withString:@""];
             
         }
         
         NSLog(@"after file path is %@",strpath);
          NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:strRootpath error:&error];
         
         
         arrFolderdoc = [[NSMutableArray alloc] init];
         NSLog(@"directory is %@",directoryContent);
         
         for (int i =0; i<[directoryContent count]; i++) {
             
             NSString *strdropboxpath = [NSString stringWithFormat:@"%@/%@",strRootpath,[directoryContent objectAtIndex:i]];
             
             if ([[[directoryContent objectAtIndex:i] pathExtension] isEqualToString:@"pdf"]) {
                 
                 buploading = true;
                 filecount++;
                 NSMutableDictionary * dic = [[NSMutableDictionary alloc] init ];
                 [dic setObject:strdropboxpath forKey:@"PdfPath"];
                 [dic setObject:[NSString stringWithFormat:@"/%@",[directoryContent objectAtIndex:i]] forKey:@"PdfName"];
                 [dic setObject:newFolderUrl forKey:@"folderID"];
                 [boxUploadingArray addObject: dic];
                 
             }
             else if ([[[directoryContent objectAtIndex:i] pathExtension] isEqualToString:@""])
             {
                 NSMutableDictionary * dic = [[NSMutableDictionary alloc] init ];
                 [dic setObject:strdropboxpath forKey:@"PdfPath"];
                 [dic setObject:[NSString stringWithFormat:@"/%@",[directoryContent objectAtIndex:i]] forKey:@"PdfName"];
                 [dic setObject:newFolderUrl forKey:@"folderID"];
                 
                 [boxUploadingArray addObject: dic];
                 
                 
             }
             
         }
         
         if ([uploadingArray count]>0) {
             
             [uploadingArray removeObjectAtIndex:0];
             
         }
         if ([arrboxIDS count]>0) {
             
             [arrboxIDS removeObjectAtIndex:0];
         }
         if ([uploadingArray count]>0) {
             issubfolder = false;
             
             [self uploadToFolder];
         }
         else
         {
             boxFolderPaths = [boxFolderPaths stringByAppendingPathComponent:childFolderName];
             
             
             NSLog(@"check the  arrrrrrrrrrry %@",boxUploadingArray);
             
             [self performSelector:@selector(closeSugarUploadControllerr) withObject:nil afterDelay:0];
             
             
         }
         
     }];
}
-(void)closeSugarUploadControllerr
{
    if ([boxUploadingArray count]>0)
    {
        [uploadingArray removeAllObjects];
        //  boxFilePath = root;
        for (int k = 0; k<[boxUploadingArray count]; k++)
        {
            NSLog(@"%d",[boxUploadingArray count]);
            NSString *   sfolderName =  [[boxUploadingArray objectAtIndex:k]objectForKey:@"PdfName"];
            NSString *    sfolderPath =  [[boxUploadingArray objectAtIndex:k]objectForKey:@"PdfPath"];
            NSString *    sboxid =  [[boxUploadingArray objectAtIndex:k]objectForKey:@"folderID"];
            
            
            NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
            [dic setObject:sboxid forKey:@"folderID"];
            [dic setObject:sfolderName forKey:@"PdfName"];
            [dic setObject:sfolderPath forKey:@"PdfPath"];
            [uploadingArray addObject:dic];
            
        }
        [boxUploadingArray removeAllObjects];
        issubfolder = TRUE;
        [self uploadToFolder];
        
    }
    if ([uploadingArray count]==0 && [boxUploadingArray count]==0)
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [documentsTableView setEditing:NO];
        editBarButton.title = @"Edit";
        boxParentId = nil;
        boxFolderPaths = nil;
        [DetailViewController  getSharedInstance].folderID = nil;
        [uploadingArray removeAllObjects];
        [DownloadingSingletonClass getSharedInstance].sugarUpload = YES;
        for (int i =0; i< [checkableArray count]; i++) {
            
            Item *item = (Item *)[checkableArray objectAtIndex:i];
            item.isChecked = NO;
            
        }
        
        strRootpath = nil;
        [self performSelectorOnMainThread:@selector(uploadCompleted) withObject:nil waitUntilDone:NO];

    }
    
}


#pragma mark - Upload to Drive

-(void)uploadPdfToDrive:(NSData *)fileContent :(NSString *)fileName  :(NSString *)parentId :(NSString *)docFilePath
{
    buploading = true;
    filecount++;
    NSLog(@"doc file path is %@",docFilePath);
    
    GTLDriveFile *file = [GTLDriveFile object];
    file.title = fileName;
    file.descriptionProperty = @"Uploaded from the PDF MarkUp iOS";
    file.mimeType = @"application/pdf";
    
    NSLog(@"drive folder id for %@ is %@",fileName,parentId);
    GTLDriveParentReference *parentRef = [GTLDriveParentReference object];
    parentRef.identifier = parentId;
    if ([DetailViewController getSharedInstance].folderID.length>0) file.parents = [NSArray arrayWithObjects:parentRef,nil];
    
    NSData *data = fileContent;
    GTLUploadParameters *uploadParameters = [GTLUploadParameters uploadParametersWithData:data MIMEType:file.mimeType];
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesInsertWithObject:file
                                                       uploadParameters:uploadParameters];
    
    [[DriveHelperClass getSharedInstance].driveService executeQuery:query
                                                  completionHandler:^(GTLServiceTicket *ticket,
                                                                      GTLDriveFile *insertedFile, NSError *error) {
                                                      if (error == nil)
                                                      {
                                                          NSLog(@"File ID: %@", insertedFile.identifier);
                                                          filecount ++;
                                                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                          
                                                          if ([uploadingArray count]>0)
                                                          {
                                                              [self deletingFakePath];
                                                              [uploadingArray removeObjectAtIndex:0];
                                                          }
                                                          if ([uploadingArray count]>0)
                                                          {
                                                              [self uploadToFolder];
                                                          }
                                                          else
                                                          {
                                                              [self performSelector:@selector(closeDriveUploadControllerr) withObject:nil afterDelay:0];
                                                              
                                                          }
                                                          
                                                      }
                                                      else
                                                      {
                                                          [self deletingFakePath];

                                                          NSLog(@"An error occurred: %@", error);
                                                          [CommonMethods showAlert:@"PDF MarkUp" MSG:@"An error occurred! Please try Again"];
                                                          
                                                          [self performSelectorOnMainThread:@selector(uploadCompleted) withObject:nil waitUntilDone:NO];

                                                      }
                                                  }];
    
    
    
    
}
-(void)uploadFolderToDrive:folderName  :(NSString *)parentId :(NSString *)docFilePath
{
    NSLog(@"doc file path is %@",docFilePath);
    
    buploading = true;
    
    GTLDriveFile *folderObj = [GTLDriveFile object];
    folderObj.title = folderName;
    folderObj.mimeType = @"application/vnd.google-apps.folder";
    
    // To create a folder in a specific parent folder, specify the identifier
    // of the parent:
    // _resourceId is the identifier from the parent folder
    if (parentId.length && ![parentId isEqualToString:@"0"]) {
        GTLDriveParentReference *parentRef = [GTLDriveParentReference object];
        parentRef.identifier = parentId;
        folderObj.parents = [NSArray arrayWithObject:parentRef];
    }
    
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesInsertWithObject:folderObj uploadParameters:nil];
    //GTLServiceTicket *queryTicket =
    [[DriveHelperClass getSharedInstance].driveService executeQuery:query
                                                  completionHandler:^(GTLServiceTicket *ticket, id object,
                                                                      NSError *error) {
                                                      if (!error) {
                                                          
                                                          GTLDriveFile * file = object;
                                                          NSLog(@"object response %@",file.title);
                                                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                          
                                                          // NSMutableArray * folderDetails = [[NSMutableArray alloc]initWithArray:files.items];
                                                          
                                                          NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
                                                          [dic setObject:file.identifier
                                                                  forKey:@"id"];
                                                          [dic setObject:file.title                                                                        forKey:@"title"];
                                                          [dic setObject:file.mimeType                                                                        forKey:@"mimeType"];
                                                          NSMutableArray *arrJsonn1 = [[NSMutableArray alloc] init];
                                                          [arrJsonn addObject:dic];
                                                          [arrJsonn1 addObject:dic];
                                                          [self uploadChildFoldersToDrive:arrJsonn1 ];
                                                          
                                                      }
                                                      
                                                      else
                                                      {
                                                          [self deletingFakePath];

                                                          NSLog(@"An error occurred: %@", error);
                                                          [CommonMethods showAlert:@"PDF MarkUp" MSG:@"An error occurred! Please try Again"];
                                                          
                                                          [self performSelectorOnMainThread:@selector(uploadCompleted) withObject:nil waitUntilDone:NO];                                                      }
                                                  }];
    
    /*
     
     
     */
    
}

-(void)uploadChildFoldersToDrive:(NSMutableArray *)arrJson
{
    
    
    NSString * childFolderName = [[arrJson objectAtIndex:0]objectForKey:@"title"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *strpath;
    
    NSLog(@"check folder path %@",[DetailViewController  getSharedInstance].folderPath);
    NSLog(@"check before folder path %@",childFolderName);
    if (docFolderPath == nil)
    {
        docFolderPath = @"/";
    }
    
    if ([docFolderPath isEqualToString:@"/"]){
        strpath  = [NSString stringWithFormat:@"/%@",childFolderName];
    }
    //    else
    //    {
    //        strpath  = [[NSString stringWithFormat:@"/%@",childFolderName] stringByReplacingOccurrencesOfString:[DetailViewController  getSharedInstance].folderPath withString:@""];
    //
    //    }
    
    NSLog(@"after file path is %@",strpath);
    
    NSString *folderpathh = nil;
    NSLog(@"PdfName %@",[[uploadingArray objectAtIndex:0]objectForKey:@"PdfName"]);
    if ([boxFolderPaths length]>0) {
        
        folderpathh = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",boxFolderPaths]];
        // boxFolderPaths =
    }
    else
    {
        folderpathh = [documentsDirectory stringByAppendingPathComponent:strpath];
        
    }

    
   // folderpathh = [documentsDirectory stringByAppendingPathComponent:strRootpath];

    
    //    NSString *folderpath = [documentsDirectory stringByAppendingPathComponent:strpath];
    
    NSError *error;
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:strRootpath error:&error];
    
    
    arrFolderdoc = [[NSMutableArray alloc] init];
    NSLog(@"directory is %@",directoryContent);
    

    
    for (int i =0; i<[directoryContent count]; i++) {
        
        NSString *strdropboxpath = [NSString stringWithFormat:@"%@/%@",strRootpath,[directoryContent objectAtIndex:i]];
        
        if ([[[directoryContent objectAtIndex:i] pathExtension] isEqualToString:@"pdf"]) {
            NSMutableDictionary * dic = [[NSMutableDictionary alloc] init ];
            [dic setObject:strdropboxpath forKey:@"PdfPath"];
            [dic setObject:[NSString stringWithFormat:@"/%@",[directoryContent objectAtIndex:i]] forKey:@"PdfName"];
            [dic setObject:[[arrJson objectAtIndex:0]objectForKey:@"id"] forKey:@"folderID"];

            [driveUploadingArray addObject: dic];
        }
        else if ([[[directoryContent objectAtIndex:i] pathExtension] isEqualToString:@""])
        {
            NSMutableDictionary * dic = [[NSMutableDictionary alloc] init ];
            [dic setObject:strdropboxpath forKey:@"PdfPath"];
            [dic setObject:[NSString stringWithFormat:@"/%@",[directoryContent objectAtIndex:i]] forKey:@"PdfName"];
            // [boxFolderPaths stringByAppendingString:[NSString stringWithFormat:@"/%@",[directoryContent objectAtIndex:i]]];
            [dic setObject:[[arrJson objectAtIndex:0]objectForKey:@"id"] forKey:@"folderID"];

            [driveUploadingArray addObject: dic];
        }
    }
    
    if ([uploadingArray count]>0) {
        
        [uploadingArray removeObjectAtIndex:0];
        
    }
    if ([uploadingArray count]>0) {
        
        if ([[[[uploadingArray objectAtIndex:0] objectForKey:@"PdfName"] pathExtension]isEqualToString:@""])
        {
            //            driveParentId = [[arrJson objectAtIndex:0]objectForKey:@"id"];
            //            [arrJsonn removeObjectAtIndex:0];
            boxFolderPaths = [driveFolder stringByAppendingPathComponent:[[uploadingArray objectAtIndex:0] objectForKey:@"PdfName"]];
            
        }
        
        [self uploadToFolder];
    }
    else
    {
        driveParentId = [[arrJson objectAtIndex:0]objectForKey:@"id"];
      //  [arrJsonn removeObjectAtIndex:0];
        //boxFolderPaths = [boxFolderPaths stringByAppendingPathComponent:[[driveUploadingArray objectAtIndex:0]objectForKey:@"PdfName"]];
        driveFolder = childFolderName;
        if ([driveUploadingArray count]>0)
        {
            boxFolderPaths =  [NSString stringWithFormat:@"%@/%@",childFolderName,[[driveUploadingArray objectAtIndex:0]objectForKey:@"PdfName"]];
        }
        [self performSelector:@selector(closeDriveUploadControllerr) withObject:nil afterDelay:0];
        
    }
}

-(void)closeDriveUploadControllerr
{
    if ([driveUploadingArray count]>0)
    {
        [uploadingArray removeAllObjects];
        //  boxFilePath = root;
        for (int k = 0; k<[driveUploadingArray count]; k++)
        {
            NSLog(@"%d",[driveUploadingArray count]);
            NSString *   bfolderName =  [[driveUploadingArray objectAtIndex:k]objectForKey:@"PdfName"];
            NSString *    bfolderPath =  [[driveUploadingArray objectAtIndex:k]objectForKey:@"PdfPath"];
            NSString *    bboxid =  [[driveUploadingArray objectAtIndex:k]objectForKey:@"folderID"];

            NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
            [dic setObject:bboxid forKey:@"folderID"];
            [dic setObject:bfolderName forKey:@"PdfName"];
            [dic setObject:bfolderPath forKey:@"PdfPath"];
            
            [uploadingArray addObject:dic];
        }
        
        [driveUploadingArray removeAllObjects];
        [self uploadToFolder];
        
    }
    
    if ([uploadingArray count]==0 && [driveUploadingArray count]==0)
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [documentsTableView setEditing:NO];
        editBarButton.title = @"Edit";
        [DetailViewController getSharedInstance].folderPath = nil;
        [uploadingArray removeAllObjects];
        driveParentId = nil;
        [self performSelectorOnMainThread:@selector(uploadCompleted) withObject:nil waitUntilDone:NO];

        
        strRootpath = nil;
        
        [documentsCollectionView reloadData];
        
        for (int i =0; i< [checkableArray count]; i++) {
            
            Item *item = (Item *)[checkableArray objectAtIndex:i];
            item.isChecked = NO;
            
        }
    }
    
    [documentsTableView reloadData];
}

#pragma mark Dropbox Uploading delegate
// Folder is the metadata for the newly created folder
- (void)restClient:(DBRestClient*)client createdFolder:(DBMetadata*)folder
{
    
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
        [DownloadingSingletonClass getSharedInstance].dropBoxUpload = YES;
        
        NSLog(@"thread is Stopped .....");
        
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
    [self deletingFakePath];
    if ([[[[uploadingArray lastObject]objectForKey:@"PdfPath"] pathExtension] isEqualToString:@"pdf"]) {
        if ([[[uploadingArray lastObject]objectForKey:@"PdfPath"]isEqualToString:srcPath])
        {
            
            buploading = false;
            
        }
        
    }
    else
    {
        if ([[arrFolderdoc lastObject] isEqualToString:srcPath])
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            buploading = false;
            
        }
    }
    
    if (uploadPdfCheck == TRUE)
    {
        
    }
    
}


-(void)checkProcess
{
    
    if (filecount == 0 && !bprocessing) {
        
        //        [[[UIAlertView alloc]
        //          initWithTitle:@"PDF Markup" message:@"Files Uploaded Successfully"
        //          delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]
        //
        //         show];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        [uploadingArray removeAllObjects];
        
        [documentsCollectionView reloadData];
        
        pdfValue = 0;
       // [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadCompleted" object:nil];
        [AppDelegate sharedInstance].bgRunningStatusUpload = @"Upload completed";
        [self performSelectorOnMainThread:@selector(uploadCompleted) withObject:nil waitUntilDone:NO];

        [DownloadingSingletonClass getSharedInstance].dropBoxUpload = YES;
        NSLog(@"thread is Stopped.....");
        
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
    [self presentViewController:nav animated:YES completion:nil];
    nav.view.superview.frame = CGRectMake(57,200,500,500);
    
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
        NSArray * deleteArray = [self getFileNames:k];
        NSLog(@"deleting files is %@",deleteArray);
        
        NSString * originalPath = [[filePathsArray objectAtIndex:k] objectForKey:@"PdfPath"];
        
        for (int i=0; i<[deleteArray count]; i++)
        {
            NSString *newFileName = [deleteArray objectAtIndex:i];
            NSString *newPathToFile = [originalPath stringByDeletingLastPathComponent];
            NSString * newPath = [NSString stringWithFormat:@"%@/%@",newPathToFile,newFileName];
            NSLog(@"%@",newPath);
            
            
            if ([fileMgr removeItemAtPath:newPath error:&error] != YES)
                NSLog(@"Unable to delete file: %@", [error localizedDescription]);
            
            // Show contents of Documents directory
            NSLog(@"Documents directory: %@",
                  [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
            
        }
    }
    
    
    [documentsTableView setEditing:NO];
    editBarButton.title = @"Edit";
    
    [filePathsArray removeAllObjects];
    
    
    pdfValue = 0;
    
    
    for (int i =0; i< [checkableArray count]; i++) {
        
        Item *item = (Item *)[checkableArray objectAtIndex:i];
        item.isChecked = NO;
        
    }
    
    //[documentsTableView reloadData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteSucess" object:self userInfo:nil];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    documenmtsArray = [[NSMutableArray alloc]init];
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
    NSArray * renameArray = [self getFileNames:0];
    
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
        
        
        NSString * originalPath = [[filePathsArray objectAtIndex:0] objectForKey:@"PdfPath"];
        NSString * originalName = [[filePathsArray objectAtIndex:0] objectForKey:@"PdfName"];
        
        for (int k =0; k < [renameArray count]; k++)
        {
            NSLog(@"originalPath %@",originalPath);
            
            
            NSLog(@"Rename Text is %@",renameText );
            
            
            // Rename the file, by moving the file
            NSString *filePath2;
            
            NSString *newFileName = [renameArray objectAtIndex:k];
            NSString *newPathToFile = [originalPath stringByDeletingLastPathComponent];
            NSString * newPath = [NSString stringWithFormat:@"%@/%@",newPathToFile,newFileName];
            
            NSString* original = [[originalName lastPathComponent] stringByDeletingPathExtension];
            NSString * changedFileName = [newFileName stringByReplacingOccurrencesOfString:original withString:renameText];
            
            NSLog(@"%@",newPath);
            if (loadData != nil)
            {
                NSLog(@"%@",[[renameArray objectAtIndex:k] pathExtension]);
                filePath2 = [NSString stringWithFormat:@"%@/%@/%@",documentsDirectory,loadData,[NSString stringWithFormat:@"%@",changedFileName]];
            }
            else
            {
                filePath2  = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",changedFileName]];
                
            }
            
            // Attempt the move
            if ([fileMgr moveItemAtPath:newPath toPath:filePath2 error:&error] != YES)
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
    documenmtsArray = [[NSMutableArray alloc]init];

    [self docDataToDisplay];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}
-(NSArray *)getFileNames:(int)indexValue
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSArray *localArray = nil;
    if (!loadData) {
        localArray = [[NSFileManager defaultManager] directoryContentsAtPath: documentsDirectory];
        
    }
    else
    {
        NSString *filename = [documentsDirectory stringByAppendingPathComponent:loadData];
        NSError * error;
        
        // Rename array contains the list of all files in document directory.
        localArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filename error:&error];
    }
    
    NSString *myString = [[filePathsArray objectAtIndex:indexValue]objectForKey:@"PdfName"];
    // Getting only the file name
    NSString* theFileName = [[myString lastPathComponent] stringByDeletingPathExtension];
    
    NSString *strprdicate = [NSString stringWithFormat:@"SELF CONTAINS '%@'",theFileName];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:strprdicate];
    
    // Filtring only the same file names with different extensions .
    localArray =  [localArray filteredArrayUsingPredicate:predicate];
    
    NSLog(@"files array %@", localArray);
    return localArray;
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
    NSLog(@"%@",loadData);
    NSString *dataPath;
    if (loadData != nil)
    {
        dataPath = [NSString stringWithFormat:@"%@/%@/%@",documentsDirectory,loadData,renameText];
    }
    else
    {
        dataPath  = [documentsDirectory stringByAppendingPathComponent:renameText];
        
    }
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
        cell.collectionViewImageView.image = [UIImage imageNamed:@"folder.png"];
        
        
    }
    else
    {
        NSString * name = [documenmtsArray objectAtIndex:indexPath.row];
        NSString* theFileName = [[name lastPathComponent] stringByDeletingPathExtension];
        
        NSString * image = [NSString stringWithFormat:@"%@.png",theFileName];
        
        NSString *pdfFilePath;
        CommonFunction *commonFunction=[[CommonFunction alloc]init];
        if (loadData) {
            
            pdfFilePath=[[commonFunction getDoumentPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",loadData,image]];
            
        }
        else
        {
            pdfFilePath=[[commonFunction getDoumentPath] stringByAppendingPathComponent:[documenmtsArray objectAtIndex:indexPath.row]];
        }
        UIImage *thumbnailImage = [UIImage imageWithContentsOfFile:pdfFilePath];
        
        cell.collectionViewImageView.image = thumbnailImage;
        
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
        
        if ([[AppDelegate sharedInstance].bgRunningStatusUpload isEqualToString:@"Uploading"] ) {
            
            passValueDidSelect = indexPath.row;
            [self performSelectorOnMainThread:@selector(didSelectOnMainThread:) withObject:pdfFilePath waitUntilDone:NO];
        }
        else
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
            [gridViewButton setBackgroundImage:[UIImage imageNamed:@"grid-selected.png"] forState:UIControlStateNormal];
            [tableViewButton setBackgroundImage:[UIImage imageNamed:@"table-normal.png"] forState:UIControlStateNormal];
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
    }
    else
    {
        Item * item = [checkableArray objectAtIndex:indexPath.row];
        if ([[AppDelegate sharedInstance].bgRunningStatusUpload isEqualToString:@"Uploading"])
        {
            [self performSelectorOnMainThread:@selector(uploadInProgress) withObject:nil waitUntilDone:NO];
            
            return;
            
        }
        else{
            
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
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadSingleFile" object:filePathsArray];
        }
        else if([filePathsArray count]>1)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadMultipleFiles" object:filePathsArray];
            
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadNoFiles" object:filePathsArray];
            
        }
        
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
        return [arrUseraccounts count];
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
    if (tableView == documentsTableView)
    {
        return 75;
        
    }
    else
    {
        return 60;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == documentsTableView)
    {
        
        FileItemTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Dropbox_Cell"];
        
        
        Item * item = [checkableArray objectAtIndex:indexPath.row];
        
        if (tableView.editing)
        {
            [cell setChecked:item.isChecked];
        }
        cell.cellSeperatorImage.hidden = YES;
        cell.lblTitle.text = [documenmtsArray objectAtIndex:indexPath.row];
        cell.label.font=[UIFont systemFontOfSize:14.0f];
        if ([[[documenmtsArray objectAtIndex:indexPath.row]pathExtension] isEqualToString:@""] )
        {
            
            //cell.folderImage.frame = CGRectMake(0, 5, 65, 43);
            cell.imageView.image = [UIImage imageNamed:@"folder.png"];
            
            UIImageView *dot =[[UIImageView alloc] initWithFrame:CGRectMake(420,25,25,25)];
            dot.image=[UIImage imageNamed:@"normalDisclosure.png"];
            [cell addSubview:dot];
            
        }
        else
        {
            //cell.folderImage.frame = CGRectMake(5, 5, 56, 50);
            
            NSString * name = [documenmtsArray objectAtIndex:indexPath.row];
            NSString* theFileName = [[name lastPathComponent] stringByDeletingPathExtension];
            
            NSString * image = [NSString stringWithFormat:@"%@.png",theFileName];
            
            NSString *pdfFilePath;
            CommonFunction *commonFunction=[[CommonFunction alloc]init];
            if (loadData) {
                
                pdfFilePath=[[commonFunction getDoumentPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",loadData,image]];
                
            }
            else
            {
                pdfFilePath=[[commonFunction getDoumentPath] stringByAppendingPathComponent:[documenmtsArray objectAtIndex:indexPath.row]];
            }
            UIImage *thumbnailImage = [UIImage imageWithContentsOfFile:pdfFilePath];
            
            cell.imageView.image = thumbnailImage;
            
            
            
        }
        
        
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
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 35, 35)];
        [cell.contentView addSubview:imageView];
        UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 200, 55)];
        [cell.contentView addSubview:nameLabel];
        
        if([[[arrUseraccounts objectAtIndex:indexPath.row]objectForKey:@"AccountType"]isEqualToString:@"dropbox"])
        {
            nameLabel.text=[[arrUseraccounts objectAtIndex:indexPath.row]objectForKey:@"username"];
            imageView.image = [UIImage imageNamed:@"Dropbox-small.png"];
            
        }
        else if([[[arrUseraccounts objectAtIndex:indexPath.row]objectForKey:@"AccountType"]isEqualToString:@"box"])
        {
            nameLabel.text=[[arrUseraccounts objectAtIndex:indexPath.row]objectForKey:@"name"];
            imageView.image = [UIImage imageNamed:@"box_small.png"];
            
        }
        else if([[[arrUseraccounts objectAtIndex:indexPath.row]objectForKey:@"AccountType"]isEqualToString:@"google"])
        {
            nameLabel.text=[[arrUseraccounts objectAtIndex:indexPath.row]objectForKey:@"email"];
            imageView.image = [UIImage imageNamed:@"Google_Drive_Small.png"];
            
        }
        else if([[[arrUseraccounts objectAtIndex:indexPath.row]objectForKey:@"AccountType"]isEqualToString:@"ftp"])
        {
            nameLabel.text=[[arrUseraccounts objectAtIndex:indexPath.row]objectForKey:@"host"];
            imageView.image = [UIImage imageNamed:@"ftp.png"];
            
        }
        else if([[[arrUseraccounts objectAtIndex:indexPath.row]objectForKey:@"AccountType"]isEqualToString:@"sugarsync"])
        {
            nameLabel.text=[[arrUseraccounts objectAtIndex:indexPath.row]objectForKey:@"name"];
            imageView.image = [UIImage imageNamed:@"SugarSync.png"];
            
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        nameLabel.textColor=[UIColor blackColor];
        nameLabel.font=[UIFont fontWithName:@"Helvetica" size:14];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
        
    }
    else
    {
        if ([titleTop isEqualToString:@"Network"]) {
            
            FileItemTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Dropbox_Cell"];

//            static NSString *cellIdentifier = @"Cell";
//            FileItemTableCell *cell = (FileItemTableCell *)[rightTableView dequeueReusableCellWithIdentifier:cellIdentifier];
            // cell.cellSeperatorImage.hidden = NO;
            
            // If there is no cell to reuse, create a new one
//            if(cell == nil)
//            {
//                NSArray *nib;
//                nib = [[NSBundle mainBundle] loadNibNamed:@"FileItemCell" owner:self options:nil];
//                cell = [nib objectAtIndex:0];
//            }
            
            Item* item = [items objectAtIndex:indexPath.row];
            cell.lblTitle.frame = CGRectMake(99, 5, 485, 50);
            cell.lblTitle.text = item.title;
            //cell.folderImage.hidden = NO;
            cell.folderImage.frame = CGRectMake(15, 5, 40, 40);
            if ([cell.lblTitle.text isEqualToString:@"Add Account"])
            {
                cell.folderImage.frame = CGRectMake(15, 5, 40, 40);
                
                cell.folderImage.image = [UIImage imageNamed:@"plus.png"];
                cell.disclosureImageView.image = [UIImage imageNamed:@"normalDisclosure.png"];

//                UIImageView *dot =[[UIImageView alloc] initWithFrame:CGRectMake(380,10,30,30)];
//                dot.image=[UIImage imageNamed:@"normalDisclosure.png"];
//                [cell addSubview:dot];
                
            }
            else
            {
                cell.folderImage.image = item.image;
                
                cell.disclosureImageView.image = [UIImage imageNamed:@"circularDisclosure.png"];
                
//                UIImageView *dot =[[UIImageView alloc] initWithFrame:CGRectMake(380,10,30,30)];
//                dot.image=[UIImage imageNamed:@"circularDisclosure.png"];
//                [cell addSubview:dot];
                
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
            
            if ([[AppDelegate sharedInstance].bgRunningStatusUpload isEqualToString:@"Uploading"] ) {
                
                passValueDidSelect = indexPath.row;
                [self performSelectorOnMainThread:@selector(didSelectOnMainThread:) withObject:pdfFilePath waitUntilDone:NO];
            }
            else
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
                    
                    [[AppDelegate sharedInstance].documentStatus isEqualToString:@"TableView"];
                    [gridViewButton setBackgroundImage:[UIImage imageNamed:@"grid-normal.png"] forState:UIControlStateNormal];
                    [tableViewButton setBackgroundImage:[UIImage imageNamed:@"table-selected.png"] forState:UIControlStateNormal];
                    
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
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadSingleFile" object:filePathsArray];
        }
        else if([filePathsArray count]>1)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadMultipleFiles" object:filePathsArray];
            
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadNoFiles" object:filePathsArray];
            
        }
        
    }
    
    else if (tableView == popDisplayTableView)
    {
       
        [popoverController dismissPopoverAnimated:TRUE];
        [FolderChooseViewController getSharedInstance].indexCount = indexPath.row;
        [AppDelegate sharedInstance].accountIndex = indexPath.row;
        if([[[arrUseraccounts objectAtIndex:indexPath.row]objectForKey:@"AccountType"]isEqualToString:@"dropbox"])
        {
            [FolderChooseViewController getSharedInstance].accountName = @"dropbox";
        }
        else if([[[arrUseraccounts objectAtIndex:indexPath.row]objectForKey:@"AccountType"]isEqualToString:@"box"])
            
        {
            [FolderChooseViewController getSharedInstance].accountName = @"box";
            
        }
        else if([[[arrUseraccounts objectAtIndex:indexPath.row]objectForKey:@"AccountType"]isEqualToString:@"google"])
            
        {
            [FolderChooseViewController getSharedInstance].accountName = @"box";
            
        }
        else if([[[arrUseraccounts objectAtIndex:indexPath.row]objectForKey:@"AccountType"]isEqualToString:@"ftp"])
            
        {
            [FolderChooseViewController getSharedInstance].accountName = @"box";
            
        }
        else
        {
            [FolderChooseViewController getSharedInstance].accountName = @"box";
            
        }
        [DetailViewController getSharedInstance].uploadIndex = indexPath.row;
        NSLog(@"uploading index is %d",[DetailViewController getSharedInstance].uploadIndex);
        [self chooseFolder];
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
                
                [MasterViewController sharedInstance].popStatus = NO;
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
                if ([item.accounttype isEqualToString:@"google"]) {
                    
                    UIStoryboard * storyboard = self.storyboard;
                    
                    DetailViewController * detail = [storyboard instantiateViewControllerWithIdentifier: @ "DropboxDownloadFileViewControlller"];
                    [DropboxDownloadFileViewControlller getSharedInstance].accountStatus = @"google";
                    [DropboxDownloadFileViewControlller getSharedInstance].index = indexPath.row;
                    
                    [self.navigationController pushViewController: detail animated: YES];
                }
                if ([item.accounttype isEqualToString:@"sugarsync"]) {
                    
                    UIStoryboard * storyboard = self.storyboard;
                    
                    DetailViewController * detail = [storyboard instantiateViewControllerWithIdentifier: @ "DropboxDownloadFileViewControlller"];
                    [DropboxDownloadFileViewControlller getSharedInstance].accountStatus = @"sugarsync";
                    [DropboxDownloadFileViewControlller getSharedInstance].index = indexPath.row;
                    
                    [self.navigationController pushViewController: detail animated: YES];
                }
                if ([item.accounttype isEqualToString:@"ftp"]) {
                    
                    UIStoryboard * storyboard = self.storyboard;
                    
                    DetailViewController * detail = [storyboard instantiateViewControllerWithIdentifier: @ "DropboxDownloadFileViewControlller"];
                    [DropboxDownloadFileViewControlller getSharedInstance].accountStatus = @"ftp";
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
-(void)didSelectOnMainThread:(id)pdfFilePath
{
    NSLog(@"did select called on main thread");
    if ([[[documenmtsArray objectAtIndex:passValueDidSelect]pathExtension] isEqualToString:@""] )
    {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        DetailViewController *dropboxDownloadFileViewControlller = [storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
        if (loadData) {
            dropboxDownloadFileViewControlller.loadData = [NSString stringWithFormat:@"%@/%@",loadData,[documenmtsArray objectAtIndex:passValueDidSelect]];
            
        }
        else
        {
            dropboxDownloadFileViewControlller.loadData = [NSString stringWithFormat:@"%@",[documenmtsArray objectAtIndex:passValueDidSelect]];
            
            
        }
        appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [[AppDelegate sharedInstance].documentStatus isEqualToString:@"TableView"];
        [gridViewButton setBackgroundImage:[UIImage imageNamed:@"grid-normal.png"] forState:UIControlStateNormal];
        [tableViewButton setBackgroundImage:[UIImage imageNamed:@"table-selected.png"] forState:UIControlStateNormal];
        
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
            
            
            
                if ([item.accounttype isEqualToString:@"box"])
                {
                    if ([item.title isEqualToString:[[arrUseraccounts objectAtIndex:indexPath.row]objectForKey:@"name"]]) {
                        
                        [arrUseraccounts removeObjectAtIndex:indexPath.row];
                        
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
                    if ([item.title isEqualToString:[[arrUseraccounts objectAtIndex:indexPath.row]objectForKey:@"username"]]) {
                        
                        NSLog(@"unlink id is %@",[[arrUseraccounts objectAtIndex:indexPath.row]objectForKey:@"userid"]);
                        [[DBSession sharedSession] unlinkAll];
                        [[DBSession sharedSession] unlinkUserId:[[arrUseraccounts objectAtIndex:indexPath.row]objectForKey:@"userid"]];
                        
                        [arrUseraccounts removeObjectAtIndex:indexPath.row];
                        
                        NSMutableArray *arrUpdatedUserAccounts = [[NSMutableArray alloc] initWithContentsOfFile:[[DocumentManager getSharedInstance] getUserAccountpath]];
                        arrUpdatedUserAccounts = arrUseraccounts;
                        [arrUpdatedUserAccounts writeToFile:[[DocumentManager getSharedInstance] getUserAccountpath] atomically:YES];
                        
                        
                    }
                }
                else if ([item.accounttype isEqualToString:@"google"])
                {
                    [arrUseraccounts removeObjectAtIndex:indexPath.row];
                    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];
                    [[DriveHelperClass getSharedInstance].driveService setAuthorizer:nil];
                    // self.isAuthorized = NO;

                    
                    NSMutableArray *arrUpdatedUserAccounts = [[NSMutableArray alloc] initWithContentsOfFile:[[DocumentManager getSharedInstance] getUserAccountpath]];
                    arrUpdatedUserAccounts = arrUseraccounts;
                    [arrUpdatedUserAccounts writeToFile:[[DocumentManager getSharedInstance] getUserAccountpath] atomically:YES];
                }
                else if ([item.accounttype isEqualToString:@"ftp"])
                {
                    [arrUseraccounts removeObjectAtIndex:indexPath.row];
                    NSMutableArray *arrUpdatedUserAccounts = [[NSMutableArray alloc] initWithContentsOfFile:[[DocumentManager getSharedInstance] getUserAccountpath]];
                    arrUpdatedUserAccounts = arrUseraccounts;
                    [arrUpdatedUserAccounts writeToFile:[[DocumentManager getSharedInstance] getUserAccountpath] atomically:YES];
                }
                else if ([item.accounttype isEqualToString:@"sugarsync"])
                {
                    [arrUseraccounts removeObjectAtIndex:indexPath.row];
                    NSMutableArray *arrUpdatedUserAccounts = [[NSMutableArray alloc] initWithContentsOfFile:[[DocumentManager getSharedInstance] getUserAccountpath]];
                    arrUpdatedUserAccounts = arrUseraccounts;
                    [arrUpdatedUserAccounts writeToFile:[[DocumentManager getSharedInstance] getUserAccountpath] atomically:YES];
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



#pragma mark - Mail

-(void)copyingDataToFolder
{
    NSString *dataPath;
    pdfData = [[NSMutableData alloc]init];

    if ([filePathsArray count]==1&&![[[[filePathsArray objectAtIndex:0]objectForKey:@"PdfName"] pathExtension]isEqualToString:@""])
    {
        [self flattenedFile];

        NSString *path = [[filePathsArray objectAtIndex:0] objectForKey:@"PdfPath"];
        pdfData = [NSMutableData dataWithContentsOfFile: path];
        isFolder = NO;
        
        [self deletingFakePath];
    }
    else
    {
        isFolder = YES;

        // Created a temporary folder
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSLog(@"%@",loadData);
    if (loadData != nil)
    {
        dataPath = [NSString stringWithFormat:@"%@%@/%@",documentsDirectory,loadData,@"PDFMarkUp"];
    }
    else
    {
        dataPath  = [documentsDirectory stringByAppendingPathComponent:@"PDFMarkUp"];
        
    }
    NSError * error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];

        
        // Copied files to temporary folder

    for (int i =0;i<[filePathsArray count];i++)
    {
            NSLog(@"Copying directory");
            
            NSString *oldPath = [[filePathsArray objectAtIndex:i] objectForKey:@"PdfPath"];
            NSError *error = nil;
            NSLog(@"data path is %@",dataPath);
  
            NSError *Error = nil;
           NSFileManager *fileManager = [NSFileManager defaultManager];

        if ([[[[filePathsArray objectAtIndex:i]objectForKey:@"PdfName"]pathExtension]isEqualToString: @""])
        {
            NSString * copyFolderPath = [NSString stringWithFormat:@"%@/%@",dataPath,[[filePathsArray objectAtIndex:i]objectForKey:@"PdfName"]];

            [fileManager createDirectoryAtPath:copyFolderPath withIntermediateDirectories:NO attributes:nil error:&error];
            
            NSArray *fileList = [fileManager contentsOfDirectoryAtPath:oldPath error:&error];
            for (NSString *s in fileList) {
                
                NSString *oldFilePath = [oldPath stringByAppendingPathComponent:s];
                NSString *newFilePath = [copyFolderPath stringByAppendingPathComponent:s];

                if (![fileManager fileExistsAtPath:newFilePath]) {
                    //File does not exist, copy it
                    [fileManager copyItemAtPath:oldFilePath toPath:newFilePath error:&error];
                    PDFRenderer *pdfRenderer=[[PDFRenderer alloc]init];
                    [pdfRenderer drawPDFWithReportID:nil withPDFFilePath:oldPath withSavePDFFilePath:newFilePath withPreview:NO];

                } else {
                    NSLog(@"File exists: %@", newFilePath);
                }
            }


        }
        else
        {
            NSString * copyFile =[NSString stringWithFormat:@"%@/%@",dataPath,[[filePathsArray objectAtIndex:i]objectForKey:@"PdfName"]];
            [fileManager copyItemAtPath:oldPath toPath:copyFile error:&error];

            PDFRenderer *pdfRenderer=[[PDFRenderer alloc]init];
            [pdfRenderer drawPDFWithReportID:nil withPDFFilePath:oldPath withSavePDFFilePath:copyFile withPreview:NO];
        }
  }
        
        
    // Archiving the temporary folder
   
        
    NSString *archivePath;

    BOOL isDir=NO;
    NSArray *directoryContents = [[NSFileManager defaultManager] directoryContentsAtPath: documentsDirectory];
    
    NSString *exportPath = dataPath;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:exportPath isDirectory:&isDir] && isDir){
        directoryContents = [fileManager subpathsAtPath:exportPath];
    }
    archivePath = [exportPath stringByAppendingString:[NSString stringWithFormat:@".zip"]];
    
    ZipArchive *archiver = [[ZipArchive alloc] init];
    [archiver CreateZipFile2:archivePath];
    for(NSString *path in directoryContents)
    {
        NSString *longPath = [exportPath stringByAppendingPathComponent:path];
        if([fileManager fileExistsAtPath:longPath isDirectory:&isDir] && !isDir)
        {
            NSString * extension = @"pdf";
            if ([[longPath pathExtension]isEqualToString:@""]||[[[longPath pathExtension]lowercaseString]isEqualToString:extension]) {
                [archiver addFileToZip:longPath newname:path];
                
            }
        }
    }
    BOOL successCompressing = [archiver CloseZipFile2];
    if(successCompressing)
        NSLog(@"Success");
    else
        NSLog(@"Fail");
    NSString *path = archivePath;
    [pdfData appendData:[NSMutableData dataWithContentsOfFile: path]];
    }
    
    
    // deleting the temporary Copied files
    
    NSLog(@"Folder");
    NSString * originalPath = dataPath;
    NSString * finalZipPath = [originalPath stringByAppendingPathExtension:@"zip"];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSError *error;
    NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"Documents"];
    
    if ([fileMgr removeItemAtPath:originalPath error:&error] != YES)
        NSLog(@"Unable to delete file: %@", [error localizedDescription]);
    
    if ([fileMgr removeItemAtPath:finalZipPath error:&error] != YES)
        NSLog(@"Unable to delete file: %@", [error localizedDescription]);
    
    // Show contents of Documents directory
    NSLog(@"Documents directory: %@",
          [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
    
    
    [self performSelector:@selector(sendMail) withObject:nil afterDelay:1];

}

-(void)mailClick
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        UIAlertView	*alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Please check your network connectivity."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
  else
  {
      //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
      [self copyingDataToFolder];
  }
   
}


-(void)sendMail
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    if ( [MFMailComposeViewController canSendMail])
    {
        
        MFMailComposeViewController * mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        
        
        if (!isFolder)
        {
            [mailComposer addAttachmentData:pdfData mimeType:@"mimeType = 'application/pdf" fileName:[[filePathsArray objectAtIndex:0]objectForKey:@"PdfName"]];
            
        }
        else
        {
            
            [mailComposer addAttachmentData:pdfData mimeType:@"mimeType = 'application/zip" fileName:@"PdfMarkup.zip"];
            
        }
        
        

        [mailComposer setSubject:@"PDF MarkUp!"];
        
        NSString *emailBody =
        @"Hello,<br/><br/>PDF File from PDF Markup ..!<br/><aDownload Now</a>";
        
        [mailComposer setMessageBody:emailBody isHTML:YES];
        [self presentViewController:mailComposer animated:YES completion:nil];
    }
else
{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"PDF MarkUp" message:@"Please Add your account" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
    [self uploadCancel];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DocumentsEditCancel"
                                                        object:self];
    [documentsCollectionView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];

}
    
}
- (void)mailComposeController:(MFMailComposeViewController*)mailComposer didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    NSString *msg1;
    switch (result)
    {
        case MFMailComposeResultCancelled:
            msg1 =@"Sending Mail is cancelled";
            break;
        case MFMailComposeResultSaved:
            msg1=@"Sending Mail is Saved";
            break;
        case MFMailComposeResultSent:
            msg1 =@"Your Mail has been sent successfully";
            break;
        case MFMailComposeResultFailed:
            msg1 =@"Message sending failed";
            break;
        default:
            msg1 =@"Your Mail is not Sent";
            break;
    }
    
    NSLog(@"result is %@",msg1);
    [self uploadCancel];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DocumentsEditCancel"
                                                        object:self];
    [documentsCollectionView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
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
