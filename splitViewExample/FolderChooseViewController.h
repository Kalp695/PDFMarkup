//
//  FolderChooseViewController.h
//  splitViewExample
//
//  Created by ravi on 30/07/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface FolderChooseViewController : UIViewController<DBRestClientDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *marrDownloadData;
  //  DBRestClient *restClient;

}


@property (nonatomic, strong) NSString *loadData;
@property (nonatomic, strong) IBOutlet UITableView *tbDownload;
-(IBAction)chooseBarButton_click:(id)sender;
-(IBAction)uploadButton_click:(id)sender;
-(IBAction)cancelButton_click:(id)sender;

@end
