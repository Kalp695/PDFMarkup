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
#import "PDFFileName.h"

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
-(NSInteger)getNewImageFileNameIndexWithFileName: (NSString*)fileName withPath:(NSString*)directoryPath inPageIndex:(NSInteger)index;
-(UIImage *)writeImageWithFileName: (NSString*)fileName withPath:(NSString*)directoryPath inImageName:(NSString*)imageName inImageno:(int)imageNo inImage: (UIImage *)img inWidth:  (int)Width inHeight:(int)Height;
-(NSMutableArray*)saveAndGetImageFrame:(NSMutableArray*)frameArr inFileName:(NSString*)fileName inAppend:(BOOL)append inDirectoryPath:(NSString*)directoryPath inImageID:(int)imageID;
-(NSString*)saveAndGetImageCaptionWithIndex:(int)index nCaptionText:(NSString*)caption inDirectoryPath:(NSString*)directoryPath;
-(CGRect)getImageFrameFromImage_no:(NSMutableArray*)frameArr inImageID :(int)imageID;
-(NSString*)saveAndGetFooterWithIndex:(NSString*)text;
- (void) saveFileDataToDiskWithFilename:(NSString *)filename withCollection:(NSMutableArray*)imageCollection;
- (NSMutableArray*) loadFileDataFromDiskWithFilename:(NSString *)filename;
- (void)deleteFileWithFilePath:(NSString *) filenPath;
-(NSMutableArray*)getAllFilesWithFilePath:(NSString*)dirPath WithFileName:(NSString*)fileName withExtension:(NSString*)ext;
-(void)renameFileWithFilePath:(NSString*)dirPath WithFileName:(NSString*)fileName withExtension:(NSString*)ext withCurrentIndex:(NSInteger)currentIndex withCount:(NSInteger)totalCount;
- (void)deleteFile:(NSString *) filenPath;


@property(nonatomic,retain) NSString *folderPath;

@end
