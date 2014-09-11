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
    IBOutlet UILabel __weak *label;
    IBOutlet UIImageView __weak * leftFolderImage;
}
@property(nonatomic,weak)IBOutlet UIImageView * leftFolderImage;


@property(nonatomic,weak) UILabel *label;

@end

