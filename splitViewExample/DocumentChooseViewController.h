//
//  DocumentChooseViewController.h
//  splitViewExample
//
//  Created by ravi on 02/08/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface DocumentChooseViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

{
    NSMutableArray *marrDownloadData;
    // DBRestClient *restClient;
    IBOutlet UILabel * pathLabel;
}


@property (nonatomic, strong) NSString *loadData;
@property (nonatomic, strong) IBOutlet UITableView *tbDownload;
-(IBAction)chooseBarButton_click:(id)sender;
-(IBAction)uploadButton_click:(id)sender;

@end
