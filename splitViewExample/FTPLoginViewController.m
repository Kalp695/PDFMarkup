//
//  FTPLoginViewController.m
//  PDFMarkUP
//
//  Created by ravi on 31/08/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import "FTPLoginViewController.h"
#import "DocumentManager.h"
#import "CommonMethods.h"
#import "MBProgressHUD.h"

@interface FTPLoginViewController ()

@end

@implementation FTPLoginViewController
@synthesize username,password,hostTextField;

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
    
    password.delegate = self;
    username.delegate = self;
    hostTextField.delegate = self;

}
-(IBAction)cancelClick:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];

}

-(IBAction)connect:(id)sender
{
    login = [[BRRequestLogin alloc] initWithDelegate:self];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    login.hostname = hostTextField.text;
    login.username = username.text;
    login.password = password.text;
    [login start];

}
-(void) requestCompleted: (BRRequest *) request
{
    
    if (request == login)
    {
        //called after 'request' is completed successfully
        NSLog(@"%@ completed!", request);
        
        NSMutableArray *arruseraccounts = [[NSMutableArray alloc] initWithContentsOfFile:[[DocumentManager getSharedInstance] getUserAccountpath]];
        NSMutableDictionary *userdata = [[NSMutableDictionary alloc] init];
        [userdata setObject:login.hostname forKey:@"host"];
        [userdata setObject:login.username forKey:@"name"];
        [userdata setObject:login.password forKey:@"password"];
        [userdata setObject:@"ftp" forKey:@"AccountType"];
        [arruseraccounts addObject:userdata];
        [arruseraccounts writeToFile:[[DocumentManager getSharedInstance] getUserAccountpath] atomically:YES];
        
        NSLog(@"FTP Server details is %@ ",arruseraccounts);
        [self dismissModalViewControllerAnimated:YES];
        [self performSelector:@selector(closeFtpController) withObject:nil afterDelay:1.0];

        
    }
    
}

-(void)closeFtpController
{
         [[NSNotificationCenter defaultCenter] postNotificationName:@"googleSucces" object:self];
}


//-----
//
//				requestFailed


-(void) requestFailed:(BRRequest *) request
{
    if (request == login)
    {
        NSLog(@"%@", request.error.message);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        login = nil;
        if ([request.error.message isEqualToString:@"Unknown error!"]) {
            [CommonMethods showAlert:request.error.message MSG:@"Invalid Host Name"];

        }
        else if([request.error.message isEqualToString:@"Stream timed out with no response from server."])
        {
            [CommonMethods showAlert:request.error.message MSG:@"Invalid Host Name"];

        }
        else
        {
            [CommonMethods showAlert:request.error.message MSG:@"Invalid Credentials"];

        }
     //   [MBProgressHUD hideHUDForView:self.view animated:YES];


    }
    
}

- (BOOL) textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    return YES;
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
