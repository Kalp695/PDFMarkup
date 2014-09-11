//
//  FileItemTableCell.h
//  SiteVistor
//
//  Created by HJC on 10-12-9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FileItemTableCell : UITableViewCell
{
@private
	UIImageView*	m_checkImageView;
    IBOutlet UILabel *label;
    IBOutlet UIImageView __weak * folderImage;
    IBOutlet UIImageView __weak * indicatorImageView;

	BOOL m_checked;
    IBOutlet UIImageView __weak * cellSeperatorImage;

    
}

- (void) setChecked:(BOOL)checked;
// Add Account s
@property(nonatomic,retain) UILabel *label;
@property(nonatomic,weak)IBOutlet UIImageView * folderImage;
@property(nonatomic,weak)IBOutlet UIImageView * indicatorImageView;


// Dropbox Cell

@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UIButton *btnIcon;

//Documents Cell

@property (nonatomic, weak) IBOutlet UILabel *lblTitleDocuments;
@property (nonatomic, weak) IBOutlet UILabel *lblItemsCount;
@property (nonatomic, weak) IBOutlet UIImageView *folderImageDocuments;
@property (nonatomic, weak) IBOutlet UIImageView *cellSeperatorImage;


@end
