//
//  DocumentsEditViewController.m
//  splitViewExample
//
//  Created by ravi on 25/07/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import "DocumentsEditViewController.h"

@interface DocumentsEditViewController ()

@end

@implementation DocumentsEditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    renameButton.userInteractionEnabled = NO;
    openInOtherFolder.userInteractionEnabled = NO;
    uploadButton.userInteractionEnabled = NO;
    createFolderButton.userInteractionEnabled = YES;
    deleteButton.userInteractionEnabled = NO;
    mailToButton.userInteractionEnabled = NO;
    createFolderButton.titleLabel.textColor = [UIColor whiteColor];


    [self.navigationController setNavigationBarHidden:YES];   //it hides
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNetworkEditCanceltNotification:)
                                                 name:@"DocumentsEditCancel"
                                               object:nil];
    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTestNotification:) name:@"UploadMultipleFiles" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTestNotification:) name:@"UploadSingleFile" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTestNotification:) name:@"UploadNoFiles" object:nil];
}
- (void) receiveTestNotification:(NSNotification *) notification
{
    
    if ([[notification name] isEqualToString:@"UploadMultipleFiles"])
    {
       mailToButton.titleLabel.textColor = [UIColor whiteColor];
        deleteButton.titleLabel.textColor = [UIColor whiteColor];
        createFolderButton.titleLabel.textColor = [UIColor whiteColor];
        uploadButton.titleLabel.textColor = [UIColor whiteColor];
        
        // User Interaction disabled
        openInOtherFolder.titleLabel.textColor = [UIColor grayColor];
        renameButton.titleLabel.textColor = [UIColor grayColor ];
        
        renameButton.userInteractionEnabled = NO;
        openInOtherFolder.userInteractionEnabled = NO;
        
        uploadButton.userInteractionEnabled = YES;
        createFolderButton.userInteractionEnabled = YES;
        deleteButton.userInteractionEnabled = YES;
        mailToButton.userInteractionEnabled = YES;

    }
    else if ([[notification name] isEqualToString:@"UploadSingleFile"])
    {
        mailToButton.titleLabel.textColor = [UIColor whiteColor];
        openInOtherFolder.titleLabel.textColor = [UIColor whiteColor];
        uploadButton.titleLabel.textColor = [UIColor whiteColor];
        createFolderButton.titleLabel.textColor = [UIColor whiteColor];
        renameButton.titleLabel.textColor = [UIColor whiteColor];
        deleteButton.titleLabel.textColor = [UIColor whiteColor];
        
        renameButton.userInteractionEnabled = YES;
        openInOtherFolder.userInteractionEnabled = YES;
        
        uploadButton.userInteractionEnabled = YES;
        createFolderButton.userInteractionEnabled = YES;
        deleteButton.userInteractionEnabled = YES;
        mailToButton.userInteractionEnabled = YES;
        
    }
    else
    {
        mailToButton.titleLabel.textColor = [UIColor grayColor];
        openInOtherFolder.titleLabel.textColor = [UIColor grayColor];
        uploadButton.titleLabel.textColor = [UIColor grayColor];
        createFolderButton.titleLabel.textColor = [UIColor whiteColor];
        renameButton.titleLabel.textColor = [UIColor grayColor];
        deleteButton.titleLabel.textColor = [UIColor grayColor];
        
        
        renameButton.userInteractionEnabled = NO;
        openInOtherFolder.userInteractionEnabled = NO;
        uploadButton.userInteractionEnabled = NO;
        createFolderButton.userInteractionEnabled = YES;
        deleteButton.userInteractionEnabled = NO;
        mailToButton.userInteractionEnabled = NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];    // it shows
    
}
-(IBAction)action_btn:(id)sender
{
  
    
    
    
    UIButton * btn = (UIButton *)sender;
    
    if ([btn tag] == 1)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renameSucessNotifier:) name:@"RenameSucess" object:nil];

        NSLog(@"Rename");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RenameClick" object:self];

        
    }
    if ([btn tag] == 2)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteSucessNotifier:) name:@"DeleteSucess" object:nil];

        NSLog(@"Delete");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteClick" object:self];

        
    }

    if ([btn tag] == 3)
    {
        NSLog(@"Mail To");
    }

    if ([btn tag] == 4)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadSucessNotifier:) name:@"UploadSucess" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadSucessNotifier:) name:@"UploadCancelled" object:nil];

        NSLog(@"Upload");

        [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadClick" object:self];
    }

    if ([btn tag]==5)
    {
        NSLog(@"Open In other folder");

    }
    if ([btn tag]==6)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createFolderNotifier:) name:@"CreateFolderSuccess" object:nil];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateFolder" object:self];

        NSLog(@"Create Folder");

    }
    
}
- (void)UploadCancelledNotifier:(NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UploadCancelled" object:nil];
    
    
    [self.navigationController popToRootViewControllerAnimated:YES];

}
- (void)createFolderNotifier:(NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CreateFolderSuccess" object:nil];
    
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}


- (void)uploadSucessNotifier:(NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UploadSucess" object:nil];

    [self.navigationController popViewControllerAnimated:NO];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)deleteSucessNotifier:(NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeleteSucess" object:nil];
    
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}
- (void)renameSucessNotifier:(NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RenameSucess" object:nil];
    
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)receiveNetworkEditCanceltNotification:(NSNotification *) notification
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UploadControllerCancel" object:nil];

    
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
