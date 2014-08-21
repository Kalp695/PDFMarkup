//
//  UIImage+Compress.m
//  ConditionReportNew
//
//  Created by CFA IT on 10/23/13.
//  Copyright (c) 2013 CFA IT. All rights reserved.
//

#import "UIImage+Compress.h"
#define MAX_IMAGEPIX 200.0          // max pix 200.0px
#define MAX_IMAGEDATA_LEN 50000.0   // max data length 5K

@implementation UIImage (Compress)
- (UIImage *)compressedImage {
    NSData *imageData = UIImageJPEGRepresentation(self, 0.7f);
   UIImage *newImage=[UIImage imageWithData:imageData];
    
    return newImage;
    
}


- (UIImage *)compressedImageToSmallSize
{
    CGSize imageSize = self.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
   
    /*
    if (width <= MAX_IMAGEPIX && height <= MAX_IMAGEPIX) {
        // no need to compress.
        return self;
    }
     */
    
    if (width == 0 || height == 0) {
        // void zero exception
        return self;
    }
    
    UIImage *newImage = nil;
    CGFloat widthFactor = MAX_IMAGEPIX / width;
    CGFloat heightFactor = MAX_IMAGEPIX / height;
    CGFloat scaleFactor = 0.0;
    
    if (widthFactor > heightFactor)
        scaleFactor = heightFactor; // scale to fit height
    else
        scaleFactor = widthFactor; // scale to fit width
    
    CGFloat scaledWidth  = width * scaleFactor;
    CGFloat scaledHeight = height * scaleFactor;
    CGSize targetSize = CGSizeMake(scaledWidth, scaledHeight);
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [self drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImageJPEGRepresentation(newImage, 0.5f);
    newImage=[UIImage imageWithData:imageData];
    NSInteger yourImgSize = [imageData length];
    
    NSLog(@"before compression yourImgSize=%fkb",yourImgSize/1000.0f);

    
    /*
    UIGraphicsBeginImageContext(CGSizeMake(Width,Height));
    [newImage drawInRect:CGRectMake(0,0,Width, Height)];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    imageData = UIImageJPEGRepresentation(newImage, 0.01f);
    newImage=[UIImage imageWithData:imageData];
    yourImgSize = [imageData length];
    
    
    NSLog(@"after compression yourImgSize=%fkb",yourImgSize/1000.0f);
     */

    
    return newImage;
    
}



- (UIImage *)compressImage:(UIImage *)image{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float maxHeight = 600.0;
    float maxWidth = 800.0;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    float compressionQuality = 0.5;//50 percent compression
    
    if (actualHeight > maxHeight || actualWidth > maxWidth) {
        if(imgRatio < maxRatio){
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio){
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }else{
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithData:imageData];
}


- (NSData *)compressedData:(CGFloat)compressionQuality {
    assert(compressionQuality <= 1.0 && compressionQuality >= 0);
    
    return UIImageJPEGRepresentation(self, compressionQuality);
}

- (CGFloat)compressionQuality {
    NSData *data = UIImageJPEGRepresentation(self, 1.0);
    NSUInteger dataLength = [data length];
    
    if(dataLength > MAX_IMAGEDATA_LEN) {
        return 1.0 - MAX_IMAGEDATA_LEN / dataLength;
    } else {
        return 1.0;
    }
}

- (NSData *)compressedData {
    CGFloat quality = [self compressionQuality];
    
    return [self compressedData:quality];
}

@end
