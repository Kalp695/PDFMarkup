//
//  DetailViewController.h
//  splitViewExample
//
//  Created by CFA IT on 7/18/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileItemTableCell.h"
#import <DropboxSDK/DropboxSDK.h>
#import "CollectionViewCell.h"
#import "BRRequestUpload.h"
#import "BRRequestCreateDirectory.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate,UITableViewDelegate,UITableViewDataSource,DBRestClientDelegate,UICollectionViewDataSource,UICollectionViewDelegate,BRRequestDelegate>{
    IBOutlet UIBarButtonItem *editBarButton;
    IBOutlet FileItemTableCell *fileItemTableCell;
    NSMutableArray *items;
    
    IBOutlet UITableView *rightTableView;
    
    IBOutlet UILabel * accountsLabel;
    // DBRestClient *restClient;
    
    // Code For Documents View
    
    IBOutlet UIView * documentView;
    // IBOutlet UIScrollView * documentScrollView;
    NSMutableArray * documenmtsArray;
    NSMutableArray * downloadsArray;
    
    NSArray * sqliteRowsArray;
    NSMutableArray * sqliteFilesArray;
    
    NSMutableArray * filePathsArray;
    
    IBOutlet UICollectionView *documentsCollectionView;
    
    NSString *hash;
    NSString *folder_file;
    DBMetadata* currentChild;
    NSMutableArray *marrDownloadData;
    NSMutableArray *arrmetadata;
    NSMutableArray *arrFolderdoc;
    
    // code for pop over
    NSMutableArray * popOverListArray;
    UIPopoverController *popoverController;
    NSMutableString *strdirpath ;
    NSTimer *timer;
    NSMutableArray *arrtimer;
    NSMutableDictionary *arrLocalFilepaths;
    
    NSData *uploadData;
    BRRequestUpload *uploadFile;
    BRRequestCreateDirectory *createDir;
    
    
}
+(DetailViewController*)getSharedInstance;

@property(nonatomic,retain)  NSString * folderPath;
@property(nonatomic,retain)  NSString * docFolderPath;

@property(nonatomic,retain)  NSString * folderID;

@property (retain, nonatomic) NSString * titleTop;
@property (retain, nonatomic) NSString * accountInfo;
@property (assign, nonatomic) int indexPathh;

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (nonatomic,retain) NSString *loadData;
@property (strong, nonatomic) NSMutableArray *arrUseraccounts;

-(IBAction)editBarButton_click:(id)sender;


// Code For Documents View

-(IBAction)gridViewButton_click:(id)sender;
-(IBAction)tableViewButton_click:(id)sender;

@property(nonatomic,retain) IBOutlet UITableView * documentsTableView;
@property(nonatomic,retain) IBOutlet UIButton * documentsGridButton;

//box
@property (nonatomic, strong)  NSMutableArray * boxUploadingArray;
// Drive
@property (nonatomic, strong)  NSMutableArray * driveUploadingArray;
@property (nonatomic, retain)  NSMutableArray * driveFiles;
@property (nonatomic, retain)  NSString * createdFolderName;
@property(nonatomic,retain) NSString * folderNameNospace;
@property(nonatomic,retain)  NSString * ftpFolderPath;


@end
