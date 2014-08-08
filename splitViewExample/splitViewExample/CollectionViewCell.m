//
//  CollectionViewCell.m
//  CollectionView
//
//  Created by Yashesh Chauhan on 11/09/12.
//  Copyright (c) 2012 Yashesh Chauhan. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell
@synthesize collectionViewImageView;
@synthesize collectionViewLabel;
@synthesize collectionEditButton;
@synthesize editimage;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
