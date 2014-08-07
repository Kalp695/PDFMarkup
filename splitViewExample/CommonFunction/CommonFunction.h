//
//  CommonFunction.h
//  PDFMarkup
//
//  Created by CFA IT on 7/11/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseCommon.h"

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

@property(nonatomic,retain) NSString *folderPath;

@end
