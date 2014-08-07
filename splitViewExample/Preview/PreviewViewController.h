//
//  PreviewViewController.h
//  PDFMarkup
//
//  Created by CFA IT on 7/16/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ExportDelegate
- (void)cancel_click;
@end


@interface PreviewViewController : UIViewController{
    IBOutlet UIWebView *webView;
}

-(IBAction)cancel_click:(id)sender;
@property (nonatomic,retain) NSString *reportID ;
@property (strong, nonatomic) NSString *pdfFilePath;
@property (nonatomic,retain) id <ExportDelegate> delegate;


@end
