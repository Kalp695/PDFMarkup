//
//  CollectionViewCell.h
//  CollectionView
//
//  Created by Yashesh Chauhan on 11/09/12.
//  Copyright (c) 2012 Yashesh Chauhan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewCell : UICollectionViewCell{
 
 IBOutlet   UILabel * collectionViewLabel;
 IBOutlet UIImageView * collectionViewImageView;
    
    IBOutlet UIButton * collectionEditButton;

}
@property (retain, nonatomic) IBOutlet UIButton * collectionEditButton;
@property (retain, nonatomic) IBOutlet UILabel * collectionViewLabel;
@property (retain, nonatomic) IBOutlet UIImageView * collectionViewImageView;
@property (retain,nonatomic) IBOutlet UIImageView *editimage;
@end
