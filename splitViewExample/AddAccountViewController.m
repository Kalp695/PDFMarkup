//
//  AddAccountViewController.m
//  splitViewExample
//
//  Created by ravi on 21/07/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import "AddAccountViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "AppDelegate.h"
#import "GoogleLoginViewController.h"
#import "DocumentManager.h"

@interface AddAccountViewController ()<DBRestClientDelegate>

@end


@implementation AddAccountViewController



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
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}
-(void)viewDidAppear
{
    

}
-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDropboxNotification:)
                                                 name:@"isDropboxLinked"
                                               object:nil];

}
-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"isDropboxLinked" object:nil];
}

-(void)receiveDropboxNotification:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"isDropboxLinked"])
    {
        
        DropboxManager *dbManager = [DropboxManager dbManager];
        [dbManager restClient].delegate = self;
        [[dbManager restClient] loadAccountInfo];
      //  [self.restClient loadAccountInfo];
        
    }
    
}

- (void)restClient:(DBRestClient*)client loadedAccountInfo:(DBAccountInfo*)info {
    NSLog(@"UserID: %@ %@", [info displayName], [info userId]);
    
    NSDictionary *dicdetails = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[info displayName],[info userId],@"dropbox", nil] forKeys:[NSArray arrayWithObjects:@"username",@"userid",@"AccountType", nil]];
    [AppDelegate sharedInstance].dicUserdetails = [[NSDictionary alloc] initWithDictionary:dicdetails];
    
   
    NSMutableArray *arruseraccounts = [[NSMutableArray alloc] initWithContentsOfFile:[[DocumentManager getSharedInstance] getUserAccountpath]];
    [arruseraccounts addObject:dicdetails];
    
    [arruseraccounts writeToFile:[[DocumentManager getSharedInstance] getUserAccountpath] atomically:YES];
    [[NSUserDefaults standardUserDefaults] setValue:[AppDelegate sharedInstance].dicUserdetails forKey:@"Dropboxuser"];
   // NSLog(@"dic details %@",[AppDelegate sharedInstance].dicUserdetails);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshLefttable" object:self];

    [self.navigationController popViewControllerAnimated:YES];


}

-(IBAction)accountsButtonAction:(id)sender
{
    if ([sender tag]==1)
    {
        NSLog(@"Drop Box");
        
       // if (![[DBSession sharedSession] isLinked])
       // {
        
        for (int i =0; i<[[[AppDelegate sharedInstance] arrDropboxUserids] count]; i++) {
            
          //  [[DBSession sharedSession] unlinkUserId:[[[AppDelegate sharedInstance] arrDropboxUserids] objectAtIndex:i]];

            
        }

              [[DBSession sharedSession] linkFromController:self];
       // }
    }
    else if ([sender tag]== 4)
    {
        
        
    }
    else if ([sender tag] == 5)
    {
        
        
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        GoogleLoginViewController *dropboxDownloadFileViewControlller = [storyboard instantiateViewControllerWithIdentifier:@"GoogleLoginViewController"];
       
        [self.navigationController pushViewController:dropboxDownloadFileViewControlller animated:YES];
    }
}

-(void)userDetails
{
   

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
