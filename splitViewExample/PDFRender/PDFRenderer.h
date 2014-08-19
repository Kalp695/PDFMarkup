//
//  PDFRenderer.h
//  PDFRenderer
//
//  Created by Ray Wenderlich on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import "PDFFileName.h"




#define kBorderInset            20.0
#define kBorderWidth            1.0
#define kMarginInset            10.0

//Line drawing
#define kLineWidth              1.0
@interface PDFRenderer : UIView
{

    CGSize pageSize;
    int abc;
    CGContextRef context;

}
-(void)drawPDFWithReportID:(NSString*)reportID withPDFFilePath:(NSString*)pdfFilePath withSavePDFFilePath:(NSString*)savepdfFilePath;


@end
