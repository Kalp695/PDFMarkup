//
//  PreviewViewController.m
//  PDFMarkup
//
//  Created by CFA IT on 7/16/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import "PreviewViewController.h"
#import "PDFRenderer.h"
#import "CommonFunction.h"

@interface PreviewViewController ()

@end

@implementation PreviewViewController

@synthesize reportID=_reportID;
@synthesize pdfFilePath=_pdfFilePath;
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
    
    /*
    PDFRenderer *pdfRenderer=[[PDFRenderer alloc]init];
    [pdfRenderer drawPDFWithReportID:_reportID withPDFFilePath:_pdfFilePath];
    
    
    CommonFunction *commonFunction=[[CommonFunction alloc]init];
    NSString *path = [commonFunction getPDFFileName];
    NSURL *targetURL = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [webView loadRequest:request];
    */
    
}

-(IBAction)cancel_click:(id)sender{
    if(_delegate){
        [_delegate cancel_click];
        [self.view.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
        [webView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
        [webView removeFromSuperview];
        webView=nil;
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
