//
//  DocumentChooseViewController.m
//  splitViewExample
//
//  Created by ravi on 02/08/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import "DocumentChooseViewController.h"
#import "ReaderViewController.h"
@interface DocumentChooseViewController ()

@end

@implementation DocumentChooseViewController
{
    NSMutableArray * documenmtsArray;
    NSString * renameText;
    NSString * exportText;

}
@synthesize loadData,tbDownload;
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
    
    UIBarButtonItem * save = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveBarButton_click:)];
    
  
    UIBarButtonItem *createFolder = [[UIBarButtonItem alloc] initWithTitle:@"Create Folder"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                                    action:@selector(createFolder)];
    self.navigationItem.rightBarButtonItems =
    [NSArray arrayWithObjects:save, createFolder, nil];
    
    exportText = @"Report";

    
    if (!loadData) {
        loadData = @"";
        pathLabel.text = @"/";
    }
    else{
        pathLabel.text = loadData;

    }
    [self docDataToDisplay];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
#pragma mark - Create Folder to Dropbox Methods

-(void)createFolder
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
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:loadData];
    NSString * finalPath = [dataPath stringByAppendingPathComponent:renameText];
    
    NSError * error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:finalPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:finalPath withIntermediateDirectories:NO attributes:nil error:&error];
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
    
    
    //  [documentsCollectionView reloadData];
    
    
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    
    //[documentsTableView reloadData];
    [self docDataToDisplay];
    [tbDownload reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateFolderSuccess" object:self userInfo:nil];
    
    
}
#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    renameText = @"";
    if (alertView.tag == 1)
    {
        NSLog(@"alert text is %@", [alertView textFieldAtIndex:0].text);
        exportText  =[alertView textFieldAtIndex:0].text;
        [self savePdf];
    }

     if (alertView.tag == 2)
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
    
}

-(void)docDataToDisplay
{
    
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
        
        if([[[directoryContent objectAtIndex:k]  pathExtension] isEqualToString:@""])
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
        
    }
    
    [tbDownload reloadData];
    
}
-(IBAction)cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];

}
-(void)savePdf
{
    [self dismissModalViewControllerAnimated:YES];
    
    [ReaderViewController getSharedInstance].savedFolderPath = loadData;
    [ReaderViewController getSharedInstance].pdfName = exportText;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadDocFolder"
                                                        object:self];
    
}
-(IBAction)saveBarButton_click:(id)sender
{
    
    //    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter pdf name"
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Done",nil];
   // [alert textFieldAtIndex:0].text = exportText;
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 1;
    [alert show];
    [[alert textFieldAtIndex:0] setText:exportText];

    
    
}
#pragma mark - UITableView Delegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [documenmtsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TableIdentifier=@"Cell";
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:TableIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableIdentifier];
    }
    
    cell.textLabel.text=[documenmtsArray objectAtIndex:indexPath.row];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.textLabel.textColor=[UIColor blackColor];
    cell.textLabel.font=[UIFont fontWithName:@"Helvetica" size:18];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    DocumentChooseViewController *dropboxDownloadFileViewControlller = [storyboard instantiateViewControllerWithIdentifier:@"DocumentChooseViewController"];
    if (loadData) {
        dropboxDownloadFileViewControlller.loadData = [NSString stringWithFormat:@"%@/%@",loadData,[documenmtsArray objectAtIndex:indexPath.row]];
        
    }
    else
    {
        dropboxDownloadFileViewControlller.loadData = [NSString stringWithFormat:@"%@",[documenmtsArray objectAtIndex:indexPath.row]];
        
        
    }
    pathLabel.text = loadData;

    [self.navigationController pushViewController:dropboxDownloadFileViewControlller animated:YES];

    
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
