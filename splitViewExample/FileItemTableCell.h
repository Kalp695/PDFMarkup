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
    IBOutlet UIImageView * folderImage;
    IBOutlet UIImageView * indicatorImageView;

	BOOL			m_checked;
    IBOutlet UIImageView * cellSeperatorImage;

    
}

- (void) setChecked:(BOOL)checked;
// Add Account s
@property(nonatomic,retain) UILabel *label;
@property(nonatomic,retain)IBOutlet UIImageView * folderImage;
@property(nonatomic,retain)IBOutlet UIImageView * indicatorImageView;


// Dropbox Cell

@property (nonatomic, strong) IBOutlet UILabel *lblTitle;
@property (nonatomic, strong) IBOutlet UIButton *btnIcon;

//Documents Cell

@property (nonatomic, strong) IBOutlet UILabel *lblTitleDocuments;
@property (nonatomic, strong) IBOutlet UILabel *lblItemsCount;
@property (nonatomic, strong) IBOutlet UIImageView *folderImageDocuments;
@property (nonatomic, strong) IBOutlet UIImageView *cellSeperatorImage;


@end
