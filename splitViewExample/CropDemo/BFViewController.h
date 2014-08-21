//
//  BFViewController.h
//  CropDemo
//
//  Created by John Nichols on 2/28/13.
//  Copyright (c) 2013 John Nichols. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BFCropInterface.h"
#import "LoadingView.h"

@protocol cropPhotoDelegate
- (void)cropPhoto:(UIImage *)cropImage withImageNo:(int)image_no;
- (void)cancelCropPhoto;
@end

@interface BFViewController : UIViewController{
       __weak id<cropPhotoDelegate> _delegate;
        IBOutlet UIButton *cropButton;
        IBOutlet UIButton *useButton;
        IBOutlet UIButton *originalButton;
        LoadingView *loadingView;
    UIBarButtonItem *cropBarButton;
}

@property (nonatomic, strong) IBOutlet UIImageView *displayImage;
@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) UIImage *useImage;
@property  (nonatomic, assign) NSInteger image_no;
@property (nonatomic, strong) BFCropInterface *cropper;
@property (nonatomic, weak) id<cropPhotoDelegate> delegate;

- (IBAction)cropPressed:(id)sender;
- (IBAction)originalPressed:(id)sender;
- (IBAction)usePressed:(id)sender;

@end
