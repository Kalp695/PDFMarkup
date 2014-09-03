//
//  NetworkMenuController.m
//  splitViewExample
//
//  Created by mahesh babu on 22/07/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import "NetworkMenuController.h"
#import "MasterViewController.h"
@interface NetworkMenuController ()

@end

@implementation NetworkMenuController



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
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];   //it hides
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNetworkEditCanceltNotification:)
                                                 name:@"NetworkControllerCancel"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(DropboxCreateFolderSuccess:)
                                                 name:@"DropboxCreateFolderSuccess"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(DropboxDeleteFolderSuccess:)
                                                 name:@"DropboxDeleteFolderSuccess"
                                               object:nil];

    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(DropboxDeleteSucess:)
                                                 name:@"DropboxDeleteSucess"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(DropboxRenameSucess:)
                                                 name:@"DropboxRenameSuccess"
                                               object:nil];

    
    
    
    createFolderButton.titleLabel.textColor = [UIColor whiteColor];

    deleteButton.userInteractionEnabled = NO;
    createFolderButton.userInteractionEnabled = YES;
    downloadButton.userInteractionEnabled = NO;
    renameButton.userInteractionEnabled = NO;

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTestNotification:) name:@"MultipleFiles" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTestNotification:) name:@"SingleFile" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTestNotification:) name:@"NoFiles" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(docDataToDisplay:) name:@"Download Success" object:nil];

}
- (void) receiveTestNotification:(NSNotification *) notification
{
    
    if ([[notification name] isEqualToString:@"MultipleFiles"])
    {
        deleteButton.titleLabel.textColor = [UIColor whiteColor];
        createFolderButton.titleLabel.textColor = [UIColor whiteColor];
        downloadButton.titleLabel.textColor = [UIColor whiteColor];
        renameButton.titleLabel.textColor = [UIColor grayColor ];
    
        deleteButton.userInteractionEnabled = YES;
        createFolderButton.userInteractionEnabled = YES;
        downloadButton.userInteractionEnabled = YES;
        renameButton.userInteractionEnabled = NO;

        
    }
    else if ([[notification name] isEqualToString:@"SingleFile"])
    {
        downloadButton.titleLabel.textColor = [UIColor whiteColor];
        createFolderButton.titleLabel.textColor = [UIColor whiteColor];
        renameButton.titleLabel.textColor = [UIColor whiteColor];
        deleteButton.titleLabel.textColor = [UIColor whiteColor];
        
        deleteButton.userInteractionEnabled = YES;
        createFolderButton.userInteractionEnabled = YES;
        downloadButton.userInteractionEnabled = YES;
        renameButton.userInteractionEnabled = YES;

        
    }
    else
    {
        downloadButton.titleLabel.textColor = [UIColor grayColor];
        createFolderButton.titleLabel.textColor = [UIColor whiteColor];
        renameButton.titleLabel.textColor = [UIColor grayColor];
        deleteButton.titleLabel.textColor = [UIColor grayColor];
        
        deleteButton.userInteractionEnabled = NO;
        createFolderButton.userInteractionEnabled = YES;
        downloadButton.userInteractionEnabled = NO;
        renameButton.userInteractionEnabled = NO;


    }
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];    // it shows
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NetworkControllerCancel" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NetworkController" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MultipleFiles" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SingleFile" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NoFiles" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Download Success" object:nil];



}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    // Do any additional setup after loading the view.
}

-(void)docDataToDisplay:(NSNotification *) notification
{
      [self.navigationController popToRootViewControllerAnimated:YES];

}
-(IBAction)action_download:(id)sender
{
 //   tags 1 - downloadButton , 2 - deleteButton , 3 - renameButton , 4 - createFolderButton ;
    UIButton * btn = (UIButton *)sender;

    if ([btn tag] == 1)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadClick" object:self];

    }
    else if ([btn tag] == 2){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteClick" object:self];

    }
    else if ([btn tag] == 3){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RenameClick" object:self];

    } else if ([btn tag] == 4){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateFolderClick" object:self];

    }

}

- (void)receiveNetworkEditCanceltNotification:(NSNotification *) notification
{
    
    [self.navigationController popViewControllerAnimated:NO];
}
- (void)DropboxCreateFolderSuccess:(NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DropboxCreateFolderSuccess" object:nil];

    [self.navigationController popViewControllerAnimated:NO];
}
- (void)DropboxDeleteFolderSuccess:(NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DropboxDeleteFolderSuccess" object:nil];
    
    [self.navigationController popViewControllerAnimated:NO];
}
- (void)DropboxDeleteSucess:(NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DropboxDeleteSucess" object:nil];
    
    [self.navigationController popViewControllerAnimated:NO];
}
- (void)DropboxRenameSucess:(NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DropboxRenameSuccess" object:nil];
    
    [self.navigationController popViewControllerAnimated:NO];
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
