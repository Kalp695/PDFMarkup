//
//  PDFRenderer.m
//  PDFRenderer
//
//  Created by Ray Wenderlich on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PDFRenderer.h"
#import "myShape.h"
#import "SPUserResizableView.h"
#import "db.h"
#import "Declare.h"
#import "CommonFunction.h"
#import <QuartzCore/QuartzCore.h>





@implementation PDFRenderer


CGSize pageSize;
NSMutableArray *_collection;
UIView *viewNew;
UIView *view;
UIView *imgView;

-(void)drawLineFromPoint:(CGPoint)from toPoint:(CGPoint)to inColor:(UIColor *)color inLineWidth:(float)lineWidth
{
    if(context==nil)
    context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, lineWidth);
    
    //CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    //CGFloat components[] = {0.2, 0.2, 0.2, 0.3};
    
    //CGColorRef color = CGColorCreate(colorspace, components);
    
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    
    CGContextMoveToPoint(context, roundf(from.x),roundf(from.y));
    CGContextAddLineToPoint(context, roundf(to.x), roundf(to.y));
    
    
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
    
}


-(void)drawRectangleFromPoint:(CGRect)frame inColor:(UIColor*)color inLineWidth:(float)lineWidth
{
    if(context==nil)
    context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, lineWidth);
    
    //CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    //CGFloat components[] = {0.2, 0.2, 0.2, 0.3};
    
    //CGColorRef color = CGColorCreate(colorspace, components);
    
    
    
    
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    
    
    CGContextStrokeRect(context, frame);
    
    
    //CGContextFillRect(context, frame);
    
    CGContextDrawPath(context, kCGPathFillStroke);
    
    
    
}


-(void)drawDottedRectangleFromPoint:(CGRect)frame inColor:(UIColor*)color inLineWidth:(float)lineWidth
{
    if(context==nil)
    context = UIGraphicsGetCurrentContext();
    
    CGFloat num[] = {6.0, 6.0};
    CGContextSetLineDash(context, 0.0, num, 2);
    
    //CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    //CGFloat components[] = {0.2, 0.2, 0.2, 0.3};
    
    //CGColorRef color = CGColorCreate(colorspace, components);
    
    
    
    CGContextAddRect(context, frame);
    CGContextStrokePath(context);
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    
    
    CGContextStrokeRect(context, frame);
    
    
    //CGContextFillRect(context, frame);
    
    
    
    CGContextDrawPath(context, kCGPathFillStroke);
    
    
    
}





-(void)drawText:(NSString*)textToDraw inFrame:(CGRect)frameRect inFrameRect:(UIFont*)font
{
    if(context==nil)
    context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
    
    //textToDraw=[textToDraw uppercaseString];
    //textToDraw = @"Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Nam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Typi non habent claritatem insitam; est usus legentis in iis qui facit eorum claritatem. Investigationes demonstraverunt lectores legere me lius quod ii legunt saepius. Claritas est etiam processus dynamicus, qui sequitur mutationem consuetudium lectorum. Mirum est notare quam littera gothica, quam nunc putamus parum claram, anteposuerit litterarum formas humanitatis per seacula quarta decima et quinta decima. Eodem modo typi, qui nunc nobis videntur parum clari, fiant sollemnes in futurum.";
    
    //UIFont *font = [UIFont systemFontOfSize:14.0];
    
    //CGSize stringSize = [textToDraw sizeWithFont:font
    //                             constrainedToSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset)
    //                               lineBreakMode:UILineBreakModeWordWrap];
    
    //CGRect renderingRect = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset + 50.0, pageSize.width - 2*kBorderInset - 2*kMarginInset, stringSize.height);
    
    NSMutableParagraphStyle *styleLineBreakWordWrap = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [styleLineBreakWordWrap setLineBreakMode:NSLineBreakByWordWrapping];
    [styleLineBreakWordWrap setAlignment:NSTextAlignmentLeft];
    CGRect renderingRect = frameRect;
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSParagraphStyleAttributeName:styleLineBreakWordWrap};
    
    [textToDraw drawInRect:renderingRect withAttributes:attributes];
    
}







-(UILabel*)getSPUerResizableText:(SPUserResizableView*)spUserResizableView{
    
    for(UIView *spView in [spUserResizableView subviews]){
        if([spView isMemberOfClass:[UIImageView class]]){
            
            for(UIView *spLabelView in [spView subviews]){
                if([spLabelView isMemberOfClass:[UILabel class]]){
                    UILabel *label=(UILabel*)spLabelView;
                    return label;
                }

            
        }
        
    }
    
 }
    return nil;
}


#pragma mark - File Saving

- (void)drawShapes {
    //NSLog(@"In drawShapes!");
    
    for(myShape *i in _collection) {
        
        //i.startPoint=[viewNew convertPoint:i.startPoint toView:view];
        //i.startPoint=CGPointMake(i.startPoint.x-1, i.startPoint.y-1);
        //i.endPoint=[viewNew convertPoint:i.endPoint toView:view];
        
        //i.endPoint=CGPointMake(i.endPoint.x+1, i.endPoint.y+1);
        //i.startPoint=CGPointMake(216.99998, 417);

        [self drawShapesSubroutine:i contextRef:context];
        
        //NSLog(@"i.noteLabel=%@",i.noteLabel);
        
        if(![i.noteLabel.text isEqualToString:@""] && i.noteLabel.text!=nil){
            [imgView addSubview:i.noteLabel];
            i.noteLabel.frame= [view convertRect:i.noteLabel.frame toView:viewNew];
            if(![i.noteLabel.text isEqualToString:@"doubletap"])
                [self drawText:i.noteLabel.text inFrame: i.noteLabel.frame inFrameRect:i.noteLabel.font];
        }
        else if(i.noteSPUserResizableView!=nil){
            
            UILabel *labelText=[self getSPUerResizableText: i.noteSPUserResizableView];
            CGRect frame=i.noteSPUserResizableView.frame;
            frame= [viewNew convertRect:frame toView:view];
            frame=CGRectMake(frame.origin.x+15.0f, frame.origin.y-33.0f,frame.size.width, frame.size.height);
            [self drawText:labelText.text inFrame: frame inFrameRect:labelText.font];
        }
        
    }
    
    //load hybrid note view after drawing line
    
    
    
}

+(UILabel*)getSPUerResizableText:(SPUserResizableView*)spUserResizableView{
    
    for(UIView *spView in [spUserResizableView subviews]){
        if([spView isMemberOfClass:[UIImageView class]]){
            
            for(UIView *spLabelView in [spView subviews]){
                if([spLabelView isMemberOfClass:[UILabel class]]){
                    UILabel *label=(UILabel*)spLabelView;
                    return label;
                }
                
                
            }
            
        }
        
    }
    return nil;
}


- (void)drawShapesSubroutine:(myShape *)shapeToBeDrawn contextRef:(CGContextRef)contextLocal {
    CGContextSetLineWidth(contextLocal, shapeToBeDrawn.lineWidth);
    CGContextSetStrokeColorWithColor(contextLocal, [shapeToBeDrawn.color CGColor]);
    //NSLog(@"shapeToBeDrawn.color=%ld",(long)shapeToBeDrawn.color);
    // Setting the dashed parameter
    if(shapeToBeDrawn.isDashed == true){
        //float num[] = {10.0f, 10.0f};
        //CGContextSetLineDash(context, 0.0, num, 2);
    }
    else {
        //CGContextSetLineDash(context, 0.0, NULL, 0);
    }
    
    
    if(shapeToBeDrawn.shape == 0) { //line
        //[self drawLineFromPoint:shapeToBeDrawn.startPoint toPoints:shapeToBeDrawn.endPoint inColor:shapeToBeDrawn.color inLineWidth:(float)shapeToBeDrawn.lineWidth];
        [self drawLineFromPoint:shapeToBeDrawn.startPoint toPoint:shapeToBeDrawn.endPoint inColor:shapeToBeDrawn.color inLineWidth:(float)shapeToBeDrawn.lineWidth];
        
    }
    else if(shapeToBeDrawn.shape == 1) {    //Rectangle
        
        CGRect rectangle = CGRectMake(shapeToBeDrawn.startPoint.x,
                                      shapeToBeDrawn.startPoint.y,
                                      (shapeToBeDrawn.endPoint.x) - (shapeToBeDrawn.startPoint.x),
                                      (shapeToBeDrawn.endPoint.y) - (shapeToBeDrawn.startPoint.y));
        
        [self drawRectangleFromPoint:rectangle inColor:shapeToBeDrawn.color inLineWidth:shapeToBeDrawn.lineWidth];
    }
    else if(shapeToBeDrawn.shape == 2) {    //Circle
        if(contextLocal==nil)
        context=UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(contextLocal, [shapeToBeDrawn.color CGColor]);
        CGContextSetLineWidth(contextLocal, shapeToBeDrawn.lineWidth);
        
        float X = shapeToBeDrawn.endPoint.x - shapeToBeDrawn.startPoint.x;
        float Y = shapeToBeDrawn.endPoint.y - shapeToBeDrawn.startPoint.y;
        float radius = sqrtf(X*X + Y*Y);
        
        /*
         path = [UIBezierPath
         bezierPathWithOvalInRect:CGRectMake(shapeToBeDrawn.startPoint.x, shapeToBeDrawn.startPoint.y, radius, radius)];
         
         
         CGContextSetStrokeColorWithColor(context, shapeToBeDrawn.color.CGColor);
         float X = shapeToBeDrawn.endPoint.x - shapeToBeDrawn.startPoint.x;
         float Y = shapeToBeDrawn.endPoint.y - shapeToBeDrawn.startPoint.y;
         float radius = sqrtf(X*X + Y*Y);
         */
        
        CGContextAddArc(contextLocal, shapeToBeDrawn.startPoint.x, shapeToBeDrawn.startPoint.y, radius, 0, M_PI * 2.0, 1);
        CGContextStrokePath(contextLocal);
    }
    
    else if(shapeToBeDrawn.shape == 3) {    //Circle
            if(contextLocal==nil)
                contextLocal=UIGraphicsGetCurrentContext();
        //CommonFunction *commonFunction=[[CommonFunction alloc]init];
        // Create an oval shape to draw.
        UIBezierPath *aPath = shapeToBeDrawn.pencilBezierPath;
        //aPath=[commonFunction markupViewWithPoints:aPath withmarkupView: view withparentView:viewNew];
        // Set the render colors.
        [shapeToBeDrawn.color setStroke];
        
        // If you have content to draw after the shape,
        // save the current state before changing the transform.
        //CGContextSaveGState(aRef);
        
        // Adjust the view's origin temporarily. The oval is
        // now drawn relative to the new origin point.
        //CGContextTranslateCTM(contextLocal, 50, 50);
        
        // Adjust the drawing options as needed.
        aPath.lineWidth = shapeToBeDrawn.lineWidth;
        
        // Fill the path before stroking it so that the fill
        // color does not obscure the stroked line.
        //[aPath fill];
        [aPath stroke];
        
        // Restore the graphics state before drawing any other content.
        //CGContextRestoreGState(aRef);    }
    

    }
}




-(void)drawImage:(UIImage*)image inRect:(CGRect)rect
{
    
    [image drawInRect:rect];
    
}





-(void)drawPDFWithReportID:(NSString*)reportID withPDFFilePath:(NSString*)pdfFilePath withSavePDFFilePath:(NSString*)savepdfFilePath
{
    
    
    viewNew=[[UIView alloc]initWithFrame:CGRectMake(2.40694e-05, 16.2353, 760, 983.529)];
    view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 612, 792)];
    
    
    // Create the PDF context using the default page size of 612 x 792.
    
    CommonFunction *commonFunction=[[CommonFunction alloc]init];
    NSString *folderPath = [commonFunction getFolderPathFromFullPath:pdfFilePath];
    [commonFunction setFolderPath:folderPath];
    
    //NSArray *pdfs = [[NSBundle mainBundle] pathsForResourcesOfType:@"pdf" inDirectory:nil];
    
    //NSString *pdfPathTemp = [pdfs lastObject]; assert(pdfPathTemp != nil); // Path t
    NSString * pdfPathTemp=pdfFilePath;
    
    if(_collection == nil) {
        _collection = [[NSMutableArray alloc] init];
    }
    
    
    
    
    
    
    
    //page no to pdf
    
    NSString *newFilePath = savepdfFilePath ;
    
    NSString *templatePath =pdfPathTemp;
    
    //create empty pdf file;
    UIGraphicsBeginPDFContextToFile(newFilePath, CGRectMake(0, 0, 768, 1024), nil);
    
    CFURLRef url = CFURLCreateWithFileSystemPath (NULL, (CFStringRef)templatePath, kCFURLPOSIXPathStyle, 0);
    
    //open template file
    CGPDFDocumentRef templateDocument = CGPDFDocumentCreateWithURL(url);
    CFRelease(url);
    
    //get amount of pages in template
    size_t count = CGPDFDocumentGetNumberOfPages(templateDocument);
    
    //for each page in template
    for (size_t pageNumber = 1; pageNumber <= count; pageNumber++) {
        //get bounds of template page
        CGPDFPageRef templatePage = CGPDFDocumentGetPage(templateDocument, pageNumber);
        CGRect templatePageBounds = CGPDFPageGetBoxRect(templatePage, kCGPDFCropBox);
        
        //create empty page with corresponding bounds in new document
        UIGraphicsBeginPDFPageWithInfo(templatePageBounds, nil);
        context = UIGraphicsGetCurrentContext();
        
        //flip context due to different origins
        CGContextTranslateCTM(context, 0.0, templatePageBounds.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        //copy content of template page on the corresponding page in new file
        CGContextDrawPDFPage(context, templatePage);
        
        //flip context back
        CGContextTranslateCTM(context, 0.0, templatePageBounds.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        /* Here you can do any drawings */
        
        [_collection removeAllObjects];
        _collection=nil;
        
        NSString *fileName=[commonFunction getFileNameFromPath:pdfFilePath];
        _collection= [commonFunction loadDataFromDiskWithFilename:[NSString stringWithFormat:@"%@_%zd",fileName, pageNumber]];
        
        [self drawShapes];
        
       
    }
    CGPDFDocumentRelease(templateDocument);
    UIGraphicsEndPDFContext();
    
    
    //remove

    
    
    
    
    
    
    
    
}



-(void)drawPage3Text{
    
}

-(void)drawPage4Text{
    
}



- (void)viewWillDisappear:(BOOL)animated{
    
}



-(void)PDFRenderInitialize{
 
}

@end
