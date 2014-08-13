//
//  CommonFunction.m
//  PDFMarkup
//
//  Created by CFA IT on 7/11/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import "CommonFunction.h"
#import "myShape.h"
#import "DatabaseCommon.h"

@implementation CommonFunction







/*************************File I/O***********************/
#pragma database


-(NSString*)getDirectoryPath{
    
    NSString *directoryPath=[NSString stringWithFormat:@"%@",_folderPath];
    
    return directoryPath;
}

-(NSString*)getDoumentPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    
    return documentsDirectory;
}

-(NSString*)getFolderPathFromFullPath:(NSString*)filePath{
    
    NSString *folderPath = [filePath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"/%@",[filePath lastPathComponent]] withString:@""];
    
    return folderPath;
}




-(NSString*)getPDFFileName
{
    NSString* fileName = @"Report.PDF";
    
    NSArray *arrayPaths =
    NSSearchPathForDirectoriesInDomains(
                                        NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    NSString *path = [arrayPaths objectAtIndex:0];
    NSString* pdfFileName = [path stringByAppendingPathComponent:fileName];
    
    
    arrayPaths=nil;
    path=nil;
    
    return pdfFileName;
    
}


-(NSString*)getFileNameFromPath:(NSString*)strPath{
    NSString* theFileName = [[strPath lastPathComponent] stringByDeletingPathExtension];
    
    return theFileName;
}


-(NSString*)getCurrentDate{
    NSDate *currentDate=[NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSString *dateStr= [dateFormatter stringFromDate:currentDate];
    
    return dateStr;
}


-(NSString*)getTermsType{
    
    NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:  @"Documents"];
    NSString *savedplistPath=[NSString stringWithFormat:@"%@/appStartProperty.plist",docsDir];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:savedplistPath];
    NSString  *termsType=[dictionary objectForKey:@"reportType"];
    
    return termsType;
}

-(NSString*)getSubReportType{
    
    NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:  @"Documents"];
    NSString *savedplistPath=[NSString stringWithFormat:@"%@/appStartProperty.plist",docsDir];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:savedplistPath];
    NSString  *subReportType=[dictionary objectForKey:@"subReportType"];
    
    return subReportType;
}



-(NSDictionary*)getTermsDictionary{
    
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"terms" ofType:@"plist"];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    NSString *termsType=[self getTermsType];
    NSString *subReporttype=[self getSubReportType];
    if(![subReporttype isEqualToString:@"Art"]){
        termsType=@"FPPV";
    }
    NSDictionary *termsDictionary=[dictionary objectForKey:termsType];
    
    return termsDictionary;
    
}

#pragma mark - File Saving
- (NSString *) pathForDataFileWithFilename:(NSString *)filename {
    
    
    NSString *folder = [self getDirectoryPath];
    folder = [folder stringByExpandingTildeInPath];
    
    NSString *_fileExtension = @".DrawingPad";
    return [folder stringByAppendingPathComponent:[filename stringByAppendingString:_fileExtension]];
}
/****************************************Save Data To Disk*******************************/
- (void) saveDataToDiskWithFilename:(NSString *)filename withCollection:(NSMutableArray*)collection {
    NSString * path = [self pathForDataFileWithFilename:filename];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    [archiver encodeObject:collection forKey:@"collection"];
    [archiver finishEncoding];
    
    if(![data writeToFile:path atomically:YES]) {
        NSLog(@"Didn't work!");
    }
    
}

/****************************************End*******************************/


/****************************************Load Data From Disk*******************************/
- (NSMutableArray*) loadDataFromDiskWithFilename:(NSString *)filename {
    
    NSMutableArray *collection=[[NSMutableArray alloc] init];
    NSString * path = [self pathForDataFileWithFilename:filename];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        
        NSArray *temp = [unarchiver decodeObjectForKey:@"collection"];
        [collection removeAllObjects];
        for(myShape *i in temp) {
            [collection addObject:i];
        }
        //[self drawShapes:@"Shape"];
    }
    
    return collection;
}

/****************************************End*******************************/


- (void)deleteFileWithFilename:(NSString *) filename withrowID:(NSString*)rowID {
    NSString *path = [self pathForDataFileWithFilename:filename];
    
    //NSLog(@"%@",path);
    
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    
}


- (void)deleteReport {
    NSString *directoryPath=[self getDirectoryPath];
    
    //NSLog(@"%@",path);
    
    [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:nil];
    
}

- (void)deleteSavedFile: (NSString*)fileName {
    NSString *directoryPath=[self getDirectoryPath];
    directoryPath=[directoryPath stringByAppendingPathComponent:fileName];
    //NSLog(@"%@",path);
    
    [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:nil];
    
}


-(NSString*)getCaptionWithFileName:(NSString*)fileName withRowID:(NSString*)rowID{
    NSString *caption=@"";
    NSString *directoryPath=[self getDirectoryPath];
    NSString *path = [directoryPath stringByAppendingPathComponent:@"thumbnails"];
    path=[path stringByAppendingPathComponent:@"imagecaption.plist"];
    NSMutableArray *captionarray = [[NSMutableArray alloc] initWithContentsOfFile:path];
    NSMutableDictionary *dict;
    for(dict in captionarray){
        if ([[dict allKeys] containsObject:fileName]) {
            caption=dict[fileName];
        }
    }
    return caption;
    
}





/*************************end***********************/






-(CGRect)getimageFrame:(int)image_no inWidth:(CGFloat)width inHeight:(CGFloat)height{
    int imageWidth=250;
    int imageHeight=300;
    int marginX=90;
    int marginY=100;
    int imageWidthMargin=100;
    int imageHeightMargin=90;
    CGRect frame;
    CGFloat xCoordinate,yCoordinate;
    xCoordinate=0.0f;
    yCoordinate=100.0f;
    if(abs(width-height)<=50){
        
        if(image_no==1){
            xCoordinate=marginX;
            yCoordinate=marginY;
            
        }
        
        else if(image_no==2){
            xCoordinate=marginX+imageWidth+imageWidthMargin;
            yCoordinate=marginY;
        }
        
        else if(image_no==3){
            xCoordinate=marginX;
            yCoordinate=marginY+imageHeight+imageHeightMargin;
        }
        
        else if(image_no==4){
            xCoordinate=marginX + imageWidth+imageWidthMargin;
            yCoordinate=marginY + imageHeight+imageHeightMargin;
        }
        
    }
    
    
    else if(width<height){
        
        
        if(image_no==1){
            xCoordinate=marginX;
            yCoordinate=marginY;
            
        }
        
        else if(image_no==2){
            xCoordinate=marginX+imageWidth+imageWidthMargin;
            yCoordinate=marginY;
        }
        
        else if(image_no==3){
            xCoordinate=marginX;
            yCoordinate=marginY+imageHeight+imageHeightMargin;
        }
        
        else if(image_no==4){
            xCoordinate= marginX+imageWidth+imageWidthMargin;
            yCoordinate= marginY+imageHeight+imageHeightMargin;
        }
        
    }
    else if(width>height){
        
        
        
        if(image_no==1){
            xCoordinate=marginX;
            yCoordinate=marginY;
            
        }
        else if(image_no==2){
            xCoordinate=marginX+imageWidth+imageWidthMargin;
            yCoordinate=marginY;
        }
        
        else if(image_no==3){
            xCoordinate=marginX;
            yCoordinate=marginY+imageHeight+imageHeightMargin;
        }
        
        else if(image_no==4){
            xCoordinate= marginX+imageWidth+imageWidthMargin;
            yCoordinate=marginY + imageHeight+imageHeightMargin;
        }
        
    }
    
    
    frame=CGRectMake(xCoordinate, yCoordinate, width*(3.0f/4.0f),height*(3.0f/4.0f));
    
    return frame;
}




-(NSInteger)getNewImageFileNameIndex:(NSString*)directoryPath inPageIndex:(NSInteger)index{
    
    NSString *plistPath = [NSString stringWithFormat:@"%@/imagenumber.plist",directoryPath];
    NSNumber *fileNum;
    index=index-1;
    NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    if(array==nil){
        
        array=[[NSMutableArray alloc]initWithObjects:[NSNumber numberWithInt:0],//page1
               [NSNumber numberWithInt:0],//page2Front
               [NSNumber numberWithInt:0],//Page2Back
               [NSNumber numberWithInt:0],//Page3Left
               [NSNumber numberWithInt:0],//Page3Right
               [NSNumber numberWithInt:0],//Page4
               [NSNumber numberWithInt:0],//Page5
               nil];
        fileNum=[array objectAtIndex:index];
        fileNum=[NSNumber numberWithInt:( [fileNum intValue] +1)];
        [array replaceObjectAtIndex:index withObject:fileNum];
        
    }
    else{
        fileNum=[array objectAtIndex:index];
        fileNum=[NSNumber numberWithInt:( [fileNum intValue] +1)];
        
        //array=[[NSMutableArray alloc]initWithObjects:fileNum, nil];
        [array replaceObjectAtIndex:index withObject:fileNum];
        
        fileNum=[array objectAtIndex:index];
    }
    
    [array writeToFile:plistPath atomically:YES];
    
    return ([fileNum intValue]);
}



-(UIImage *)writeImageWithPath:(NSString*)directoryPath inImageName:(NSString*)imageName inImageno:(int)imageNo inImage: (UIImage *)img inWidth:  (int)Width inHeight:(int)Height{
    
  
    
    
    
    NSString* path=[NSString stringWithFormat:@"%@/%@_big_%d.jpg",directoryPath,imageName, imageNo];
    //NSString* path = [NSHomeDirectory() stringByAppendingString:file];
    
    BOOL ok = [[NSFileManager defaultManager] createFileAtPath:path
                                                      contents:nil attributes:nil];
    
    //NSLog(@"path while creating=%@",path);
    
    if (!ok) {
        NSLog(@"Error creating file %@", path);
    } else {
        NSFileHandle* myFileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
        
        [myFileHandle writeData:UIImageJPEGRepresentation(img, 0.5)];
        [myFileHandle closeFile];
    }
    /*
     UIGraphicsBeginImageContext(CGSizeMake(Width,Height));
     [img drawInRect:CGRectMake(0,0,Width, Height)];
     UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
     img=newImage;
     UIGraphicsEndImageContext();
     */
    
    //NSData *imageData = UIImageJPEGRepresentation(img, 0.01f);
    //NSInteger yourImgSize = [imageData length];
    
    //NSLog(@"before compression yourImgSize=%fkb",yourImgSize/1000.0f);
    
    
    
    //img=[img convertToGrayscale];
    
    
    img   = [img compressImage:img];
    
    
    
    //imageData = UIImageJPEGRepresentation(img, 0.01f);
    //yourImgSize = [imageData length];
    
    
    //NSLog(@"after compression yourImgSize=%fkb",yourImgSize/1000.0f);
    
    path=[NSString stringWithFormat:@"%@/%@_small_%d.jpg",directoryPath,imageName, imageNo];
    //path = [NSHomeDirectory() stringByAppendingString:file];
    
    ok = [[NSFileManager defaultManager] createFileAtPath:path
                                                 contents:nil attributes:nil];
    
    //NSLog(@"path while creating=%@",path);
    
    if (!ok) {
        NSLog(@"Error creating file %@", path);
    } else {
        NSFileHandle* myFileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
        
        [myFileHandle writeData:UIImageJPEGRepresentation(img, 0.01f)];
        [myFileHandle closeFile];
    }
    
    
    return img;
    
}


-(NSMutableArray*)saveAndGetImageFrame:(NSMutableArray*)frameArr inPageName:(NSString*)pageName inAppend:(BOOL)append inDirectoryPath:(NSString*)directoryPath inImageID:(int)imageID{
    
    NSString *plistPath = [NSString stringWithFormat:@"%@/%@.plist",directoryPath,pageName];
    NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    
    if(frameArr==nil){
        
        frameArr=array;
        //array=[[NSMutableArray alloc]initWithObjects:[[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:imageID],@"imageID",[frameArr objectAtIndex:0],@"frame", nil],nil];
        //[array writeToFile:plistPath atomically:YES];
        return frameArr;
    }
    if(append==YES && array!=nil){
        
        [array addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:imageID],@"imageID",[frameArr objectAtIndex:0],@"frame", nil]];
        [array writeToFile:plistPath atomically:YES];
        frameArr=array;
    }
    else if(array==nil){
        array=[[NSMutableArray alloc]initWithObjects:[[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:imageID],@"imageID",[frameArr objectAtIndex:0],@"frame", nil],nil];
        [array writeToFile:plistPath atomically:YES];
        frameArr=array;
    }
    else
        [frameArr writeToFile:plistPath atomically:YES];
    
    return frameArr;
    
}



-(CGRect)getImageFrameFromImage_no:(NSMutableArray*)frameArr inImageID :(int)imageID{
    
    NSDictionary *dict;
    
    CGRect imageFrame;
    for( dict in frameArr){
        if(![dict isKindOfClass:[NSDictionary class]]){
            imageFrame=CGRectNull;
            return imageFrame;
        }
        if(imageID==[(NSNumber*)[dict objectForKey:@"imageID"] intValue])
            
            imageFrame = *(CGRect*)[[dict objectForKey:@"frame"] bytes];
        
    }
    
    return imageFrame;
    
}






-(NSString*)saveAndGetImageCaptionWithIndex:(int)index nCaptionText:(NSString*)caption inDirectoryPath:(NSString*)directoryPath{
    
    NSString *plistPath = [NSString stringWithFormat:@"%@/caption.plist",directoryPath];
    NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    
    if(array==nil){
        
        
        //array=[[NSMutableArray alloc]initWithObjects:[[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:index],@"index",[NSNull null],@"caption", nil],nil];
        array=[[NSMutableArray alloc]initWithObjects:@"", nil];
    }
    else{
        if(index==[array count]+1 && [caption isEqualToString:@""]){
            
            //array=[[NSMutableArray alloc]initWithObjects:fileNum, nil];
            
            //[array addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:index],@"index",[NSNull null],@"caption", nil]];
            [array addObject:@""];
            
        }
        else if(caption!=nil){
            
            if([array count]<index){
                for(int i=(int)[array count];i<index;i++){
                    [array addObject:@""];
                }
            }
            
            [array replaceObjectAtIndex:index-1 withObject:caption];
            
            
        }
        
        else if(caption==nil){
            
            
            
            if([array count]>=index)
                
                caption=[array objectAtIndex:index-1];
            
            return caption;
            
        }
    }
    
    [array writeToFile:plistPath atomically:YES];
    
    
    return caption;
}



-(NSString*)saveAndGetFooterWithIndex:(NSString*)text{
    
    NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:  @"Documents"];
    
    NSString *plistPath=[NSString stringWithFormat:@"%@/footer.plist",docsDir];
    
    NSMutableArray *array =[[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    
    
    
    
    
    if(array==nil && ![text isEqualToString:@""]){
        
        
        //array=[[NSMutableArray alloc]initWithObjects:[[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:index],@"index",[NSNull null],@"caption", nil],nil];
        array=[[NSMutableArray alloc]initWithObjects:text, nil];
    }
    else if(![text isEqualToString:@""]){
        
        array=[[NSMutableArray alloc]initWithObjects:text, nil];
    }
    
    if(array!=nil){
        [array writeToFile:plistPath atomically:YES];
        
        text=[array objectAtIndex:0];
    }
    return text;
}




/*************************end***********************/






- (UIColor*)defaultSystemTintColor
{
    static UIColor* systemTintColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIView* view = [[UIView alloc] init];
        systemTintColor = view.tintColor;
    });
    return systemTintColor;
}



void getAllPointsFromBezier(void *info, const CGPathElement *element)
{
    NSMutableArray *bezierPoints = (__bridge NSMutableArray *)info;
    CGPathElementType type = element->type;
    CGPoint *points = element->points;
    if (type != kCGPathElementCloseSubpath)
    {
        if ((type == kCGPathElementAddLineToPoint) ||
            (type == kCGPathElementMoveToPoint))
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[0]]];
        else if (type == kCGPathElementAddQuadCurveToPoint)
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[1]]];
        else if (type == kCGPathElementAddCurveToPoint){
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[0]]];
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[1]]];
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[2]]];
        }
    }
}


-(UIBezierPath *) markupViewWithPoints: (UIBezierPath *) prevPathpoints withmarkupView :(UIView*)markupView withparentView :(UIView*)parentView{
    
    NSMutableArray *points = [NSMutableArray array];
    CGPathApply(prevPathpoints.CGPath, (__bridge void *)points, getAllPointsFromBezier);
    
    UIBezierPath *newPath = [UIBezierPath bezierPath];
    CGPoint bPoint;
    CGPoint bPoint1;
    CGPoint bPoint2;
    CGPoint bPoint3;
    NSValue *val;
    for (int i = 0; i < points.count;){
        
        if(i==points.count)
            break;
        val = ((NSValue*) points[i]);
        bPoint=[val CGPointValue];
        bPoint=[markupView convertPoint:bPoint toView:parentView];
        
        
        
        i++;
        if(i==points.count)
            break;
        val = ((NSValue*) points[i]);
        bPoint1=[val CGPointValue];
        bPoint1=[markupView convertPoint:bPoint1 toView:parentView];
        
        
        i++;
        if(i==points.count)
            break;
        val = ((NSValue*) points[i]);
        bPoint2=[val CGPointValue];
        bPoint2=[markupView convertPoint:bPoint2 toView:parentView];
        
        
        i++;
        if(i==points.count)
            break;
        val = ((NSValue*) points[i]);
        bPoint3=[val CGPointValue];
        bPoint3=[markupView convertPoint:bPoint3 toView:parentView];
        i++;
        
        //[newPath addLineToPoint:bPoint];
        
        if(i%4==0){
            [newPath moveToPoint:bPoint];
            [newPath addCurveToPoint:bPoint3 controlPoint1:bPoint1 controlPoint2:bPoint2]; // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
            //pts[0] = pts[3];
            //pts[1] = pts[4];
        }
        
        
        
        
    }
    points=nil;
    return newPath;
    
}


// Return a Bezier path built with the supplied points
-(UIBezierPath *) pathWithPoints: (UIBezierPath *) prevPathpoints withX :(CGFloat)dx withY :(CGFloat)dy receiveStartPoint:(CGPoint*)startPoint
{
    
    
    NSMutableArray *points = [NSMutableArray array];
    CGPathApply(prevPathpoints.CGPath, (__bridge void *)points, getAllPointsFromBezier);
    
    UIBezierPath *newPath = [UIBezierPath bezierPath];
    CGPoint bPoint;
    CGPoint bPoint1;
    CGPoint bPoint2;
    CGPoint bPoint3;
    NSValue *val;
    for (int i = 0; i < points.count;){
        
        if(i==points.count)
            break;
        val = ((NSValue*) points[i]);
        bPoint=[val CGPointValue];
        bPoint=CGPointMake(bPoint.x+dx, bPoint.y+dy);
        i++;
        if(i==points.count)
            break;
        val = ((NSValue*) points[i]);
        bPoint1=[val CGPointValue];
        bPoint1=CGPointMake(bPoint1.x+dx, bPoint1.y+dy);
        
        i++;
        if(i==points.count)
            break;
        val = ((NSValue*) points[i]);
        bPoint2=[val CGPointValue];
        bPoint2=CGPointMake(bPoint2.x+dx, bPoint2.y+dy);
        
        i++;
        if(i==points.count)
            break;
        val = ((NSValue*) points[i]);
        bPoint3=[val CGPointValue];
        bPoint3=CGPointMake(bPoint3.x+dx, bPoint3.y+dy);
        i++;
        //[newPath addLineToPoint:bPoint];
        
        if(i%4==0){
            [newPath moveToPoint:bPoint];
            [newPath addCurveToPoint:bPoint3 controlPoint1:bPoint1 controlPoint2:bPoint2]; // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
            //pts[0] = pts[3];
            //pts[1] = pts[4];
        }
        
        
        
        
    }
    val = ((NSValue*) points[0]);
    bPoint=[val CGPointValue];
    bPoint=CGPointMake(bPoint.x+dx, bPoint.y+dy);
    *startPoint=bPoint;
    points=nil;
    return newPath;
}



// Calculates distance between two points
float distanceBetweenTwo_Points(CGPoint a, CGPoint b) {
    float dx = b.x - a.x;
    float dy = b.y - a.y;
    
    return sqrtf(dx * dx + dy * dy);
}


// Calculates distance between two points
float distanceBezierPoints(UIBezierPath *prevPathpoints) {
    
    
    NSMutableArray *points = [NSMutableArray array];
    CGPathApply(prevPathpoints.CGPath, (__bridge void *)points, getAllPointsFromBezier);
    
    float totalPointLength = 0.0f;
    for (int i = 1; i < points.count; i++){
        totalPointLength += distanceBetweenTwo_Points([((NSValue*) points[i]) CGPointValue], [((NSValue*) points[i-1]) CGPointValue]);
        if(totalPointLength>30.0)
            break;
    }
    
    return totalPointLength;
    
}



@end
