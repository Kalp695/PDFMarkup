//
//  MasterViewController.m
//  splitViewExample
//
//  Created by CFA IT on 7/18/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"
#import "AppDelegate.h"
#import "NetworkMenuController.h"
#import "DocumentsEditViewController.h"
#import "DocumentManager.h"
#import "DownloadingSingletonClass.h"

@interface MasterViewController () {
    
}
@end

@implementation MasterViewController
{
    UIActivityIndicatorView *ac;
}
@synthesize _objects,leftArrayTitles,leftImagesArray,accountsArray,accountsImagesArray;
@synthesize arrUseraccounts;
@synthesize popStatus;

bool bdropbox,bgoogle,bbox,bftp,bsugar;
- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = NO;
    self.preferredContentSize = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

+ (MasterViewController *) sharedInstance {
    static MasterViewController *sharedObj = nil ;
    
    if(!sharedObj) {
        sharedObj = [[MasterViewController alloc] init];
    }
    
    return sharedObj;
    
}
-(void)viewWillAppear:(BOOL)animated
{

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];

    arrUseraccounts = [[NSMutableArray alloc] initWithContentsOfFile:[[DocumentManager getSharedInstance] getUserAccountpath]];
    NSLog(@"check %@",[arrUseraccounts valueForKey:@"AccountType"]);
    accountsArray = [[NSMutableArray alloc ]init];
    accountsImagesArray = [[NSMutableArray alloc ]init];
    
    
    [[DBSession sharedSession] userIds];
    if ([[[[AppDelegate sharedInstance] dicUserdetails] objectForKey:@"username"] isKindOfClass:[NSArray class]]) {
        for (int i = 0; i<[[[[AppDelegate sharedInstance] dicUserdetails] objectForKey:@"username"] count]; i++) {
            
            if([[AppDelegate sharedInstance] dicUserdetails]!=nil){
                [accountsArray addObject:[[[AppDelegate sharedInstance] dicUserdetails] objectForKey:@"username"]];
                [accountsImagesArray addObject:@"Dropbox-small.png"];
            }
        }
    }
    else
    {
        if([[AppDelegate sharedInstance] dicUserdetails]!=nil){
            [accountsArray addObject:[[[AppDelegate sharedInstance] dicUserdetails] objectForKey:@"username"]];
            [accountsImagesArray addObject:@"Dropbox-small.png"];
        }
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveReloadNotification:)
                                                 name:@"RefreshLefttable"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveReloadNotification:)
                                                 name:@"BoxRefreshLefttable"
                                               object:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removeAccount)
                                                 name:@"removeAccount"
                                               object:nil];
    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNetworkEdittNotification:)
                                                 name:@"NetworkController"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDocumentEdittNotification:)
                                                 name:@"DocumentsEdit"
                                               object:nil];
    
    activityIndicatorframe.origin.y = 0;
    [self.tableView reloadData];
    
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    float currentVersion = 7.0;
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= currentVersion) {
//        // iOS 7
//        self.navigationController.navigationBar.frame = CGRectMake(self.navigationController.navigationBar.frame.origin.x, self.navigationController.navigationBar.frame.origin.y, self.navigationController.navigationBar.frame.size.width, 64);
//    }
    
	// Do any additional setup after loading the view, typically from a nib.
    //  self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    //    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    //    self.navigationItem.rightBarButtonItem = addButton;
    
    bgProcessArray = [[NSMutableArray alloc]init];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popStatusChange) name:@"popStatusNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadStart:) name:@"DownloadStart" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadStart:) name:@"UploadStart" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadCompletee:) name:@"UploadCompleted" object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadCompletee:) name:@"Download Success" object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadCompletee:) name:@"DownloadComplete" object:nil];
    
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *butImage = [[UIImage imageNamed:@"prefs2.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [button setBackgroundImage:butImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(settingsClick:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.title = nil;
    leftArrayTitles =  [[NSMutableArray alloc]initWithObjects:@"Documents",@"Network", nil];
    
    if ([[DBSession sharedSession] isLinked])
    {
        accountsArray = [[NSMutableArray alloc ]initWithObjects:@" DropBox", nil];
        accountsImagesArray = [[NSMutableArray alloc ]initWithObjects:@"Dropbox-small.png", nil];
    }
    
    leftImagesArray = [[NSMutableArray alloc]initWithObjects:@"document.png",@"globe.png", nil] ;
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    // self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    
    [self.tableView reloadData ];
    
    [MasterViewController sharedInstance].popStatus = YES;
}
-(void)popStatusChange
{
   
    [MasterViewController sharedInstance].popStatus = YES;
    
    if ([MasterViewController sharedInstance].popStatus == YES)
    {
        self.tableView.userInteractionEnabled = YES;
    }
    
}
-(void)downloadStart:(NSNotification *)notification
{
    
    NSLog(@"sender obj is %@",notification.object);
    [DownloadingSingletonClass getSharedInstance].activityViewStatus = notification.object;
    
    if ([notification.name isEqualToString:@"UploadStart"])
    {
   //     [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UploadStart" object:nil];

//        if ([[AppDelegate sharedInstance].bgRunningStatus isEqualToString:@"Uploading"])
//        {
            if (![bgProcessArray containsObject:@"Uploading in progress"]) {
                [bgProcessArray addObject:@"Uploading in progress"];
                
            }
       // }

      
    }
    else
    {
   //     [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DownloadStart" object:nil];
//
//        if ([[AppDelegate sharedInstance].bgRunningStatus isEqualToString:@"Downloading"])
//        {
            if (![bgProcessArray containsObject:@"Downloading in progress"]) {
            [bgProcessArray addObject:@"Downloading in progress"];
            
      //  }
        }
        
    }
    
    [DownloadingSingletonClass getSharedInstance].activityView = YES;
    [self.tableView reloadData];
    
}

-(void)downloadCompletee:(NSNotification *)notification
{
    
    if ([notification.name isEqualToString:@"UploadCompleted"])
    {
        //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"UploadCompleted" object:nil];

        [bgProcessArray removeObject:@"Uploading in progress"];
        
    }
    else
    {
        //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"DownloadComplete" object:nil];
       [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BGDownloadSuccess" object:nil];
        
        [bgProcessArray removeObject:@"Downloading in progress"];
    }
    NSLog(@"sections array is %@",bgProcessArray);
    if ([bgProcessArray count]==0)
    {
        [DownloadingSingletonClass getSharedInstance].activityView = NO;
        
    }
    self.tableView.userInteractionEnabled = YES;

  
    [self performSelectorOnMainThread:@selector(reloadDat) withObject:nil waitUntilDone:NO];

}
-(void)reloadDat
{
    [ac removeFromSuperview];
    ac = nil;
    [self.tableView reloadData];

}
-(int)getNumberOfSections
{
    
    int noOfSections;
    
    for (int i = 0; i<[[arrUseraccounts valueForKey:@"AccountType"] count]; i++) {
        
        if ([[[arrUseraccounts valueForKey:@"AccountType"] objectAtIndex:i] isEqualToString:@"dropbox"]) {
            if (bdropbox) {
                break;
            }
            else
            {
                bdropbox = true;
                noOfSections++;
            }
        }
        else if ([[[arrUseraccounts valueForKey:@"AccountType"] objectAtIndex:i] isEqualToString:@"google"]) {
            if (bgoogle) {
                break;
            }
            else
            {
                bgoogle = true;
                noOfSections++;
                
            }
        }
        else if ([[[arrUseraccounts valueForKey:@"AccountType"] objectAtIndex:i] isEqualToString:@"ftp"]) {
            if (bftp) {
                break;
            }
            else
            {
                bftp = true;
                noOfSections++;
                
            }
        }
        else if ([[[arrUseraccounts valueForKey:@"AccountType"] objectAtIndex:i] isEqualToString:@"box"]) {
            if (bbox) {
                break;
            }
            else
            {
                bbox = true;
                noOfSections++;
                
            }
        }
        else if ([[[arrUseraccounts valueForKey:@"AccountType"] objectAtIndex:i] isEqualToString:@"sugarsync"]) {
            if (bsugar) {
                break;
            }
            else
            {
                bsugar = true;
                noOfSections++;
                
            }
        }
    }
    
    return noOfSections;
    
}

-(void)removeAccount
{
    arrUseraccounts = [[NSMutableArray alloc] initWithContentsOfFile:[[DocumentManager getSharedInstance] getUserAccountpath]];
    [self.tableView reloadData];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"removeAccount" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RefreshLefttable" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BoxRefreshLefttable" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NetworkController" object:nil];
    
    
}

- (void)receiveNetworkEdittNotification:(NSNotification *) notification
{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NetworkMenuController"];
    [self.navigationController pushViewController:loginVC animated:NO];
}
- (void)receiveDocumentEdittNotification:(NSNotification *) notification
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DocumentsEdit" object:nil];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"DocumentsEditViewController"];
    [self.navigationController pushViewController:loginVC animated:NO];
}
- (void)receiveReloadNotification:(NSNotification *) notification
{
    
    arrUseraccounts = [[NSMutableArray alloc] initWithContentsOfFile:[[DocumentManager getSharedInstance] getUserAccountpath]];
    
    NSLog(@"check %@",[arrUseraccounts valueForKey:@"AccountType"]);
    
    
    
    [self.tableView reloadData];
    
    if ([[[[AppDelegate sharedInstance] dicUserdetails] objectForKey:@"username"] isKindOfClass:[NSArray class]]) {
        
        for (int i = 0; i<[[[[AppDelegate sharedInstance] dicUserdetails] objectForKey:@"username"] count]; i++) {
            if([[AppDelegate sharedInstance] dicUserdetails]!=nil){
                [accountsArray addObject:[[[AppDelegate sharedInstance] dicUserdetails] objectForKey:@"username"]];
                [accountsImagesArray addObject:@"Dropbox-small.png"];
            }
        }
    }
    else
    {
        if([[AppDelegate sharedInstance] dicUserdetails]!=nil){
            [accountsArray addObject:[[[AppDelegate sharedInstance] dicUserdetails] objectForKey:@"username"]];
            [accountsImagesArray addObject:@"Dropbox-small.png"];
        }
    }
    
    
    [self.tableView reloadData];
    
    
}

-(void)settingsClick:(id)sender
{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:leftImagesArray atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
-(void)insertNewSection:(id)sender
{
    
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    
    [_objects insertObject:accountsArray atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([arrUseraccounts count] == 0)
    {
        return 1;
        
    }
    else
    {
        if ([DownloadingSingletonClass getSharedInstance].activityView == YES)
        {
            int i = 2 + [bgProcessArray count];
            return i;
            
        }
        else
        {
            return 2;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0)
    {
        return [leftArrayTitles count];
    }
    else if(section == 1)
    {
        return [arrUseraccounts count];
    }
    else
    {
        return 1;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // Create the view for the header
    UIView *sectionView;
    
    CGRect sectionFrame = CGRectMake(0.0, 0.0, 200.0, 60.0);
    sectionView = [[UIView alloc] initWithFrame:sectionFrame];
    sectionView.backgroundColor=[UIColor groupTableViewBackgroundColor];
    sectionView.alpha = 0.9;
    
    
    // Create the label
    CGRect labelFrame = CGRectMake(15.0, 3.0, 200.0, 22.0);
    UILabel *sectionLabel = [[UILabel alloc] initWithFrame:labelFrame];
    if(section==1)
    {
    sectionLabel.text =  @"Account";
    }
    else if(section==2)
    {
        sectionLabel.text =  [bgProcessArray objectAtIndex:0];
    }
    else if(section==3)
    {
        sectionLabel.text =  [bgProcessArray objectAtIndex:1];
    }
    sectionLabel.font = [UIFont systemFontOfSize:15.0f];
    sectionLabel.textColor = [UIColor blackColor];
    sectionLabel.shadowColor = [UIColor grayColor];
    sectionLabel.shadowOffset = CGSizeMake(0, 1);
    sectionLabel.backgroundColor = [UIColor clearColor];
    [sectionView addSubview:sectionLabel];
    
    // Return the header section view
    return sectionView;
}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(section == 0)
    {
        return @"";
        
    }
    else if(section == 1)
    {
        
        return @"Accounts";
        
    }
    else if (section == 2)
    {
        NSLog(@"Section title Array is %@",bgProcessArray );
        
        return [bgProcessArray objectAtIndex:0];
        
    }
    else if(section ==3)
    {
        return [bgProcessArray objectAtIndex:1];
        
    }
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if(section == 0)
    {
        return 0.0f;
        
    }
    
    return 30.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section ==0)
    {
        static NSString *CellIdentifier = @"Cell";
        LeftTableViewCell *cell = (LeftTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        cell.leftFolderImage.image = [UIImage imageNamed:[leftImagesArray objectAtIndex:indexPath.row] ];
        //cell.imageView.image =[UIImage imageNamed:[leftImagesArray objectAtIndex:indexPath.row]];
        cell.label.text = [leftArrayTitles objectAtIndex:indexPath.row ];
        cell.label.font=[UIFont systemFontOfSize:16.0f];
        //cell.imageView.frame=CGRectMake(5, 8, 20, 20);
        tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        activityIndicatorframe.origin.y = activityIndicatorframe.origin.y+cell.frame.origin.y+cell.frame.size.height;
        
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.layer.cornerRadius = 0;
        bgColorView.layer.masksToBounds = YES;
        [bgColorView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"blue.png"]]];
        [cell setSelectedBackgroundView:bgColorView];
        return cell;
        
    }
    else if (indexPath.section ==1)
    {
        static NSString *CellIdentifier = @"Cell";
        LeftTableViewCell *cell = (LeftTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        cell.label.font=[UIFont systemFontOfSize:16.0f];
        cell.cellSeperator.hidden = NO;
        if ([[[arrUseraccounts objectAtIndex:indexPath.row] objectForKey:@"AccountType"] isEqualToString:@"dropbox"]) {
            
            cell.leftFolderImage.image =[UIImage imageNamed:@"Dropbox-small.png"];
            cell.leftFolderImage.frame=CGRectMake(5, 20, 30, 25);
            cell.label.text = [[arrUseraccounts objectAtIndex:indexPath.row] objectForKey:@"username"];
        }
        else if ([[[arrUseraccounts objectAtIndex:indexPath.row] objectForKey:@"AccountType"] isEqualToString:@"google"])
        {
            cell.leftFolderImage.image =[UIImage imageNamed:@"Google_Drive_Small.png"];
            cell.leftFolderImage.frame=CGRectMake(5, 16, 30, 30);
            cell.label.text = [[arrUseraccounts objectAtIndex:indexPath.row] objectForKey:@"email"];
        }
        else if ([[[arrUseraccounts objectAtIndex:indexPath.row] objectForKey:@"AccountType"] isEqualToString:@"box"])
        {
            cell.leftFolderImage.image =[UIImage imageNamed:@"box_small.png"];
            cell.leftFolderImage.frame=CGRectMake(5, 12, 40, 30);
            cell.label.text = [[arrUseraccounts objectAtIndex:indexPath.row] objectForKey:@"name"];
        }
        else if ([[[arrUseraccounts objectAtIndex:indexPath.row] objectForKey:@"AccountType"] isEqualToString:@"ftp"])
        {
            cell.leftFolderImage.image =[UIImage imageNamed:@"ftp.png"];
            cell.leftFolderImage.frame=CGRectMake(5, 12, 30, 30);
            cell.label.text = [[arrUseraccounts objectAtIndex:indexPath.row] objectForKey:@"name"];
        }
        else if ([[[arrUseraccounts objectAtIndex:indexPath.row] objectForKey:@"AccountType"] isEqualToString:@"sugarsync"])
        {
            cell.leftFolderImage.image =[UIImage imageNamed:@"SugarSync.png"];
            cell.leftFolderImage.frame=CGRectMake(5, 12, 30, 30);
            cell.label.text = [[arrUseraccounts objectAtIndex:indexPath.row] objectForKey:@"name"];
        }
        //activityIndicatorframe = cell.label.frame;
        // activityIndicatorframe = cell.label.frame;
        activityIndicatorframe.origin.y = activityIndicatorframe.origin.y+cell.frame.origin.y+cell.frame.size.height;
        cell.label.font = [UIFont fontWithName:@"System" size:14];
        tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.layer.cornerRadius = 0;
        bgColorView.layer.masksToBounds = YES;
        [bgColorView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"blue.png"]]];
        [cell setSelectedBackgroundView:bgColorView];
        return cell;
        
    }
    
    else
    {
        static NSString *CellIdentifier = @"Cell";
        LeftTableViewCell *cell = (LeftTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        cell.imageView.hidden = YES;
        cell.label.hidden = YES;
        
        ac = [[UIActivityIndicatorView alloc]
              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [ac startAnimating];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(70, 10, 320, 50)];
        //NSLog(@"view frame is %f",view.frame.origin.y);
        [view addSubview:ac];
        [cell addSubview:view];
        
        tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        activityIndicatorframe.origin.y = activityIndicatorframe.origin.y+cell.frame.origin.y+cell.frame.size.height;
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
      //  UIView *bgColorView = [[UIView alloc] init];
      //  bgColorView.layer.cornerRadius = 0;
       // bgColorView.layer.masksToBounds = YES;
        //[bgColorView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"blue.png"]]];
      //  [cell setSelectedBackgroundView:bgColorView];
        
        return cell;
        
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [_objects removeObjectAtIndex:indexPath.row];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//    }
//}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // UITableViewCellSelectionStyleGray

    
    /*********************** Do not edit if download is in progress ***********/
    
    if ([[AppDelegate sharedInstance].bgRunningStatus isEqualToString:@"Downloading"])
        {
        if(indexPath.section==0 && (indexPath.row==0)) //load the document tab
        {
            
        }
        else if (indexPath.section == 2||indexPath.section == 3)
        {
                // downloading or uploading progress section
        }
        else
        {
            
            [self performSelectorOnMainThread:@selector(downloadInProgress) withObject:nil waitUntilDone:NO];
            return;
        }
        
        
        }
    
    
    /*********************** End ***********/
    
    
    
    NSDate *object = _objects[indexPath.row];
    if ([MasterViewController sharedInstance].popStatus == YES)
    {
        if (indexPath.section == 0)
        {
            self.detailViewController.titleTop = [leftArrayTitles objectAtIndex:indexPath.row ];
            [AppDelegate sharedInstance].topTitle = [leftArrayTitles objectAtIndex:indexPath.row];
            self.detailViewController.detailItem = object;
            
        }
        if (indexPath.section == 1)
        {
            [MasterViewController sharedInstance].popStatus = NO;
            //self.tableView.userInteractionEnabled = NO;
            if ([[[arrUseraccounts objectAtIndex:indexPath.row] objectForKey:@"AccountType"] isEqualToString:@"dropbox"]) {
                
                self.detailViewController.titleTop = [[[arrUseraccounts objectAtIndex:indexPath.row] objectForKey:@"name"] capitalizedString];
                self.detailViewController.accountInfo =  @"DropBox";
                self.detailViewController.indexPathh = indexPath.row;
                self.detailViewController.detailItem = object;
                
            }
            else if ([[[arrUseraccounts objectAtIndex:indexPath.row] objectForKey:@"AccountType"] isEqualToString:@"google"]) {
                
                self.detailViewController.titleTop = [[[arrUseraccounts objectAtIndex:indexPath.row] objectForKey:@"name"] capitalizedString];
                
                self.detailViewController.accountInfo =  @"google";
                self.detailViewController.detailItem = object;
            }
            else if ([[[arrUseraccounts objectAtIndex:indexPath.row] objectForKey:@"AccountType"] isEqualToString:@"box"]) {
                
                self.detailViewController.titleTop = [[[arrUseraccounts objectAtIndex:indexPath.row] objectForKey:@"name"] capitalizedString];
                self.detailViewController.accountInfo =  @"box";
                self.detailViewController.indexPathh = indexPath.row;
                self.detailViewController.detailItem = object;
            }
            else if ([[[arrUseraccounts objectAtIndex:indexPath.row] objectForKey:@"AccountType"] isEqualToString:@"sugarsync"]) {
                
                self.detailViewController.titleTop = [[[arrUseraccounts objectAtIndex:indexPath.row] objectForKey:@"name"] capitalizedString];
                self.detailViewController.accountInfo =  @"sugarsync";
                self.detailViewController.indexPathh = indexPath.row;
                self.detailViewController.detailItem = object;
            }
            else if ([[[arrUseraccounts objectAtIndex:indexPath.row] objectForKey:@"AccountType"] isEqualToString:@"ftp"]) {
                
                self.detailViewController.titleTop = [[[arrUseraccounts objectAtIndex:indexPath.row] objectForKey:@"name"] capitalizedString];
                self.detailViewController.accountInfo =  @"ftp";
                self.detailViewController.indexPathh = indexPath.row;
                self.detailViewController.detailItem = object;
            }
            
        }
        
    }
    
    
}


-(void)downloadInProgress
{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Please Wait...." message:@"Downloading In Progress" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show ];
    
}

@end
