//
//  CommonFunction.h
//  PDFMarkup
//
//  Created by CFA IT on 7/11/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseCommon.h"
#import "UIImage+Compress.h"

@interface CommonFunction : NSObject{
    DatabaseCommon *databaseCommon;
    
}



- (UIColor*)defaultSystemTintColor;
-(UIBezierPath *) pathWithPoints: (UIBezierPath *) prevPathpoints withX :(CGFloat)dx withY :(CGFloat)dy receiveStartPoint:(CGPoint*)startPoint;
-(UIBezierPath *) markupViewWithPoints: (UIBezierPath *) prevPathpoints withmarkupView :(UIView*)markupView withparentView :(UIView*)parentView;
float distanceBezierPoints(UIBezierPath *prevPathpoints);
float distanceBetweenTwo_Points(CGPoint a, CGPoint b) ;
- (void) saveDataToDiskWithFilename:(NSString *)filename withCollection:(NSMutableArray*)collection;
- (NSMutableArray*) loadDataFromDiskWithFilename:(NSString *)filename;
-(NSDictionary*)getTermsDictionary;
-(NSString*)getPDFFileName;
-(NSString*)getDoumentPath;
-(NSString*)getFileNameFromPath:(NSString*)strPath;
-(NSString*)getFolderPathFromFullPath:(NSString*)filePath;
-(CGRect)getimageFrame:(int)image_no inWidth:(CGFloat)width inHeight:(CGFloat)height;
-(NSInteger)getNewImageFileNameIndex:(NSString*)directoryPath inPageIndex:(NSInteger)index;
-(UIImage *)writeImageWithPath:(NSString*)directoryPath inImageName:(NSString*)imageName inImageno:(int)imageNo inImage: (UIImage *)img inWidth:  (int)Width inHeight:(int)Height;
-(NSMutableArray*)saveAndGetImageFrame:(NSMutableArray*)frameArr inPageName:(NSString*)pageName inAppend:(BOOL)append inDirectoryPath:(NSString*)directoryPath inImageID:(int)imageID;
-(NSString*)saveAndGetImageCaptionWithIndex:(int)index nCaptionText:(NSString*)caption inDirectoryPath:(NSString*)directoryPath;
-(CGRect)getImageFrameFromImage_no:(NSMutableArray*)frameArr inImageID :(int)imageID;
-(NSString*)saveAndGetFooterWithIndex:(NSString*)text;

@property(nonatomic,retain) NSString *folderPath;

@end
