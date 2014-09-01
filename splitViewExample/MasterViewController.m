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
@interface MasterViewController () {
    
    
}
@end

@implementation MasterViewController
@synthesize _objects,leftArrayTitles,leftImagesArray,accountsArray,accountsImagesArray;
@synthesize arrUseraccounts;


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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //  self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    //    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    //    self.navigationItem.rightBarButtonItem = addButton;
    
    
    
    
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
        else if ([[[arrUseraccounts valueForKey:@"AccountType"] objectAtIndex:i] isEqualToString:@"sugar"]) {
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
-(void)viewWillAppear:(BOOL)animated
{
    
    
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
    
    [self.tableView reloadData];
    
    
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
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0)
    {
        return [leftArrayTitles count];
    }
    else{
        return [arrUseraccounts count];
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(section == 0)
    {
        return @"";
        
    }
    else
    {
        
        return @"Accounts";
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==0)
    {
        static NSString *CellIdentifier = @"Cell";
        LeftTableViewCell *cell = (LeftTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        //cell.leftFolderImage.image = [UIImage imageNamed:[leftImagesArray objectAtIndex:indexPath.row] ];
        cell.imageView.image =[UIImage imageNamed:[leftImagesArray objectAtIndex:indexPath.row]];
        cell.label.text = [leftArrayTitles objectAtIndex:indexPath.row ];
        
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
        
        if ([[[arrUseraccounts objectAtIndex:indexPath.row] objectForKey:@"AccountType"] isEqualToString:@"dropbox"]) {
            
            cell.imageView.image =[UIImage imageNamed:@"Dropbox-small.png"];
            cell.label.text = [[arrUseraccounts objectAtIndex:indexPath.row] objectForKey:@"username"];
            
            
        }
        else if ([[[arrUseraccounts objectAtIndex:indexPath.row] objectForKey:@"AccountType"] isEqualToString:@"google"])
        {
            cell.imageView.image =[UIImage imageNamed:@"Google_Drive_Small.png"];
            cell.label.text = [[[arrUseraccounts objectAtIndex:indexPath.row] objectForKey:@"email"] capitalizedString];
            
            
        }
        else if ([[[arrUseraccounts objectAtIndex:indexPath.row] objectForKey:@"AccountType"] isEqualToString:@"box"])
        {
            cell.imageView.image =[UIImage imageNamed:@"box_small.png"];
            cell.label.text = [[[arrUseraccounts objectAtIndex:indexPath.row] objectForKey:@"name"] capitalizedString];
            
            
        }
        else if ([[[arrUseraccounts objectAtIndex:indexPath.row] objectForKey:@"AccountType"] isEqualToString:@"ftp"])
        {
            cell.imageView.image =[UIImage imageNamed:@"ftp.png"];
            cell.label.text = [[[arrUseraccounts objectAtIndex:indexPath.row] objectForKey:@"name"] capitalizedString];
            
            
        }
        else if ([[[arrUseraccounts objectAtIndex:indexPath.row] objectForKey:@"AccountType"] isEqualToString:@"sugarsync"])
        {
            cell.imageView.image =[UIImage imageNamed:@"box_small.png"];
            cell.label.text = [[[arrUseraccounts objectAtIndex:indexPath.row] objectForKey:@"name"] capitalizedString];
            
            
        }

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
    
    

    NSDate *object = _objects[indexPath.row];
    
    if (indexPath.section == 0)
    {
        self.detailViewController.titleTop = [leftArrayTitles objectAtIndex:indexPath.row ];
        self.detailViewController.detailItem = object;
        
    }
    if (indexPath.section == 1)
    {
        
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
        //        UIStoryboard * storyboard = self.storyboard;
        //        
        //        DetailViewController * detail = [storyboard instantiateViewControllerWithIdentifier: @ "DropboxDownloadFileViewControlller"];
        //        
        //        [self.navigationController pushViewController: detail animated: YES];
        
    }
    
    
}

@end
