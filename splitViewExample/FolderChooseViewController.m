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
    
    
    self.navigationItem.rightBarButtonItems =
    [NSArray arrayWithObjects:upload, nil];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(cancelButton_click:)];
    self.navigationItem.leftBarButtonItems =
    [NSArray arrayWithObjects:cancel, nil];
    NSLog(@"check account name is %@",[FolderChooseViewController getSharedInstance].accountName);
    
    //  if ([[FolderChooseViewController getSharedInstance].accountName isEqualToString:@"dropbox"]) {
    if (!loadData) {
        loadData = @"/";
    }
    [self fetchAllDropboxData];
    
    //   }
    //    else if ([[FolderChooseViewController getSharedInstance].accountName isEqualToString:@"box"])
    //    {
    //        NSLog(@"Box");
    //        arrUseraccounts = [[NSMutableArray alloc] initWithContentsOfFile:[[DocumentManager getSharedInstance] getUserAccountpath]];
    //        self.title = [[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount] objectForKey:@"name"];
    //
    //        folderItemsArray = [[NSMutableArray alloc]init];
    //        if (!boxFolderId) {
    //            boxFolderId = BoxAPIFolderIDRoot;
    //            boxFolderName =@"All Files";
    //        }
    //        [self fetchFolderItemsWithFolderID:boxFolderId name:boxFolderName];
    //
    //    }
    
    //folderPath = @"/";
    tbDownload.delegate = self;
    tbDownload.dataSource = self;
    
    self.title = @"Folders";
    marrDownloadData = [[NSMutableArray alloc ]init];
    
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)fetchFolderItemsWithFolderID:(NSString *)folderID name:(NSString *)name
{
    
    //  https://api.box.com/2.0/folders/0/items?access_token=fYw4Qab6szMbkFkHCUUPUvlagcYwOpw9
    
    
    NSString *str =  [NSString stringWithFormat:@"https://api.box.com/2.0/folders/%@/items?access_token=%@",folderID,[[arrUseraccounts objectAtIndex:[FolderChooseViewController getSharedInstance].indexCount] objectForKey:@"acces_token"]];
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
    }
    [tbDownload reloadData];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}


-(IBAction)cancelButton_click:(id)sender
{
    
    
    [self dismissModalViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadCancel"
                                                        object:self];
}
#pragma mark - Dropbox Methods

-(IBAction)chooseBarButton_click:(id)sender
{
    
    [self dismissModalViewControllerAnimated:YES];
    //    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadToFolder"
                                                        object:self];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [DetailViewController getSharedInstance].folderPath = loadData;
    
    
    
    
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
    //  if ([[FolderChooseViewController getSharedInstance].accountName isEqualToString:@"dropbox"]) {
    
    return [marrDownloadData count];
    //   }
    //    else  if ([[FolderChooseViewController getSharedInstance].accountName isEqualToString:@"box"]) {
    //        if ([folderItemsArray count]>0)
    //        {
    //            return [[[folderItemsArray objectAtIndex:0] objectForKey:@"total_count"]integerValue];
    //
    //        }       else{
    //
    //            return 0;
    //
    //        }
    //    }
    //    else
    //    {
    //        return 0;
    //    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TableIdentifier=@"Cell";
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:TableIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableIdentifier];
    }
    
    
    
    DBMetadata * metadata = [marrDownloadData objectAtIndex:indexPath.row];
    cell.textLabel.text=metadata.filename;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.textLabel.textColor=[UIColor blackColor];
    cell.textLabel.font=[UIFont fontWithName:@"Helvetica" size:18];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //  if ([[FolderChooseViewController getSharedInstance].accountName isEqualToString:@"dropbox"]) {
    
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
    
    //   }
    //    else  if ([[FolderChooseViewController getSharedInstance].accountName isEqualToString:@"box"]) {
    //
    //        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    //        FolderChooseViewController *FolderChooseViewController = [storyboard instantiateViewControllerWithIdentifier:@"DropboxDownloadFileViewControlller"];
    //        FolderChooseViewController.boxFolderId = [[[[folderItemsArray objectAtIndex:0] objectForKey:@"entries"] objectAtIndex:indexPath.row] objectForKey:@"id"];
    //        FolderChooseViewController.boxFolderName = [[[[folderItemsArray objectAtIndex:0] objectForKey:@"entries"] objectAtIndex:indexPath.row] objectForKey:@"name"];
    //        [self.navigationController pushViewController:FolderChooseViewController animated:YES];
    //
    //
    //    }
    
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

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
