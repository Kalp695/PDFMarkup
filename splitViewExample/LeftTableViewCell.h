//
//  FileItemTableCell.h
//  SiteVistor
//
//  Created by HJC on 10-12-9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LeftTableViewCell : UITableViewCell
{
@private
    IBOutlet UILabel *label;
    IBOutlet UIImageView * leftFolderImage;
}
@property(nonatomic,retain)IBOutlet UIImageView * leftFolderImage;


@property(nonatomic,retain) UILabel *label;

@end

