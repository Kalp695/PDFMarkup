//
//  DocumentViewController.m
//  splitViewExample
//
//  Created by ravi on 23/07/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import "DocumentViewController.h"
#import "FileItemTableCell.h"
#import "AppDelegate.h"
#import "PdfFilesViewController.h"
@interface DocumentViewController ()

@end

@implementation DocumentViewController
{
    AppDelegate * appDel;
}
@synthesize documentsGridButton,documentsTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDel.documentStatus isEqualToString:@"GridView"])
    {
        [self.view bringSubviewToFront:documentScrollView];
        documentScrollView.hidden = NO;
        documentsTableView.hidden = YES;
        [self gridViewButton_click:appDel.documentStatus ];
    }
    else if([appDel.documentStatus isEqualToString:@"TableView"])
    {
        [self.view bringSubviewToFront:documentsTableView];
        documentsTableView.hidden = NO;
        documentScrollView.hidden = YES;
        
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /////// **** Code For Documents View ***** ////////
    
    
    documentsTableView.delegate = self;
    documentsTableView.dataSource = self;
    documentsTableView.hidden = YES;
    documenmtsArray = [[NSMutableArray alloc ]init];
    [self getFilesFromDatabase ];

}

#pragma mark - Documents View

//////  **** Code For Documents **** /////
-(void)getFilesFromDatabase
{
  //  NSLog(@"Files in database is %@",[[DBManager getSharedInstance ]getPdfList]);
    
//    for (int i = 0; i<[[[DBManager getSharedInstance ]getPdfList]count]; i++)
//    {
//        
//        if ([documenmtsArray containsObject:[[[DBManager getSharedInstance ]getPdfList] objectAtIndex:i]])
//        {
//            
//        }
//        else
//        {
//            [documenmtsArray addObject:[[[DBManager getSharedInstance ]getPdfList] objectAtIndex:i]];
//            
//        }
//    }
//    
}

-(IBAction)gridViewButton_click:(id)sender
{
    documentsTableView.hidden = YES;
    documentScrollView.hidden = NO;
    CGRect frame;
    for (int ij=0; ij<[documenmtsArray count]; ij++)
    {
        
        UIButton *btn_image = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn_image addTarget:self
                      action:@selector(pdfFiles:)
            forControlEvents:UIControlEventTouchUpInside];
        btn_image.tag = ij+0;
        [btn_image setImage:[UIImage imageNamed:@"folder_large.png"] forState:UIControlStateNormal];
        frame =CGRectMake(ij%3*170+20,ij/3*210+0,180,180);
        [ btn_image setFrame: frame];
        [documentScrollView addSubview:btn_image];
        
        
        UILabel * titleLabel = [[UILabel alloc ]init];
        titleLabel.text = [[documenmtsArray objectAtIndex:ij]objectForKey:@"Date"];
        titleLabel.textColor = [UIColor blackColor ];
        titleLabel.font =[UIFont fontWithName:@"Helvetica" size:22];
        titleLabel.numberOfLines = 0;
        frame =CGRectMake(ij%3*170+62,ij/3*190+170,135,80);
        [ titleLabel setFrame: frame];
        [documentScrollView addSubview:titleLabel];
        
        
        UILabel * itemCountLabel = [[UILabel alloc ]init];
    //    itemCountLabel.text = [NSString stringWithFormat:@"%d items",[[[DBManager getSharedInstance ]getPdfList]count]];
        itemCountLabel.textColor = [UIColor blackColor ];
        itemCountLabel.font =[UIFont fontWithName:@"Helvetica" size:15];
        itemCountLabel.numberOfLines = 0;
        frame =CGRectMake(ij%3*170+75,ij/3*188+190,135,80);
        [ itemCountLabel setFrame: frame];
        [documentScrollView addSubview:itemCountLabel];

    }
    
}

-(IBAction)tableViewButton_click:(id)sender
{
    documentsTableView.hidden = NO;
    [documentsTableView reloadData];
    documentScrollView.hidden = YES;
}
-(void)pdfFiles:(id)sender
{
    
  
    
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == documentsTableView)
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
    
        return [documenmtsArray count ];
    
 }

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
        
        NSLog(@"Printed data is %@",[documenmtsArray objectAtIndex:indexPath.row]);
        
        cell.label.text = [[documenmtsArray objectAtIndex:indexPath.row]objectForKey:@"Date"];
    
    
    
        cell.folderImage.image = [UIImage imageNamed:@"folder.png"];   
    
        UIImageView *dot =[[UIImageView alloc] initWithFrame:CGRectMake(390,15,25,25)];
        dot.image=[UIImage imageNamed:@"normalDisclosure.png"];
        [cell addSubview:dot];
        
        tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        
        return cell;
        

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == documentsTableView)
    {
        
        UIStoryboard * storyboard = self.storyboard;
        
        PdfFilesViewController * detail = [storyboard instantiateViewControllerWithIdentifier: @ "PdfFilesViewController"];
        
        [self.navigationController pushViewController: detail animated: YES];
        
    }
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
