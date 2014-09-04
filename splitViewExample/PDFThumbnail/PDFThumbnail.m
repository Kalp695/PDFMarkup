//
//  PDFThumbnail.m
//  PDFMarkUP
//
//  Created by CFA IT on 9/2/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import "PDFThumbnail.h"

@implementation PDFThumbnail



-(void)createThumbnailFromPDFFilePath:(NSString*)PDFFilePath
{

    
    CFURLRef url = CFURLCreateWithFileSystemPath (NULL, (CFStringRef)PDFFilePath, kCFURLPOSIXPathStyle, 0);
    CGPDFPageRef templatePage;
    //open template file
    CGPDFDocumentRef templateDocument = CGPDFDocumentCreateWithURL(url);
    CFRelease(url);
    
        NSInteger pageNumber=1;
        //get bounds of template page
        templatePage = CGPDFDocumentGetPage(templateDocument, pageNumber);
        UIImage *thumbnail=[self convertPDFPageToImage:templatePage];
        thumbnail=[self generatePhotoThumbnail:thumbnail];
        CGPDFDocumentRelease(templateDocument);
    
        NSString *pngFfilePath=[[PDFFilePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"];
    
        [UIImagePNGRepresentation(thumbnail) writeToFile:pngFfilePath atomically:YES];
}




- (UIImage *) convertPDFPageToImage: (CGPDFPageRef) page
{
	
	CGRect cropBox = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
    //CGRect cropBox= CGRectMake(shapePoint.x-50.0f, shapePoint.y-50.0f, 100, 100);
	int pageRotation = CGPDFPageGetRotationAngle(page);
	
	if ((pageRotation == 0) || (pageRotation == 180) ||(pageRotation == -180)) {
		//UIGraphicsBeginImageContextWithOptions(cropBox.size, NO, resolution / 72);
        UIGraphicsBeginImageContext(cropBox.size);
	}
	else {
		//UIGraphicsBeginImageContextWithOptions(CGSizeMake(cropBox.size.height, cropBox.size.width), NO, resolution / 72);
        UIGraphicsBeginImageContext(cropBox.size);
	}
	
	CGContextRef imageContext = UIGraphicsGetCurrentContext();
	
    [self renderPage:page inContext:imageContext];
    
    
	
    __weak UIImage *pageImage = UIGraphicsGetImageFromCurrentImageContext();
	
    UIGraphicsEndImageContext();
	
	return pageImage;
}


- (void) renderPage: (CGPDFPageRef) page inContext: (CGContextRef) pageContext{
	[self renderPage:page inContext:pageContext atPoint:CGPointMake(0, 0)];
}

- (void) renderPage: (CGPDFPageRef) page inContext: (CGContextRef) pageContext atPoint:(CGPoint) point{
	[self renderPage:page inContext:pageContext atPoint:point withZoom:100];
}

- (void) renderPage: (CGPDFPageRef) page inContext: (CGContextRef) pageContext atPoint: (CGPoint) point withZoom: (float) zoom{
	
	CGRect cropBox = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
    //CGRect cropBox= CGRectMake(shapePoint.x-50.0f, shapePoint.y-50.0f, 100, 100);
	int rotate = CGPDFPageGetRotationAngle(page);
	
	CGContextSaveGState(pageContext);
	
	// Setup the coordinate system.
	// Top left corner of the displayed page must be located at the point specified by the 'point' parameter.
	CGContextTranslateCTM(pageContext, point.x, point.y);
	
	// Scale the page to desired zoom level.
	CGContextScaleCTM(pageContext, zoom / 100, zoom / 100);
	
	// The coordinate system must be set to match the PDF coordinate system.
	switch (rotate) {
		case 0:
			CGContextTranslateCTM(pageContext, 0, cropBox.size.height);
			CGContextScaleCTM(pageContext, 1, -1);
			break;
		case 90:
			CGContextScaleCTM(pageContext, 1, -1);
			CGContextRotateCTM(pageContext, -M_PI / 2);
			break;
		case 180:
		case -180:
			CGContextScaleCTM(pageContext, 1, -1);
			CGContextTranslateCTM(pageContext, cropBox.size.width, 0);
			CGContextRotateCTM(pageContext, M_PI);
			break;
		case 270:
		case -90:
			CGContextTranslateCTM(pageContext, cropBox.size.height, cropBox.size.width);
			CGContextRotateCTM(pageContext, M_PI / 2);
			CGContextScaleCTM(pageContext, -1, 1);
			break;
	}
	
	// The CropBox defines the page visible area, clip everything outside it.
	CGRect clipRect = CGRectMake(0, 0, cropBox.size.width, cropBox.size.height);
	CGContextAddRect(pageContext, clipRect);
	CGContextClip(pageContext);
	
	CGContextSetRGBFillColor(pageContext, 1.0, 1.0, 1.0, 1.0);
	CGContextFillRect(pageContext, clipRect);
	
	CGContextTranslateCTM(pageContext, -cropBox.origin.x, -cropBox.origin.y);
	
	CGContextDrawPDFPage(pageContext, page);
	
	CGContextRestoreGState(pageContext);
}

- (void) renderPage: (CGPDFPageRef) page inContext: (CGContextRef) pageContext inRectangle: (CGRect) displayRectangle {
    if ((displayRectangle.size.width == 0) || (displayRectangle.size.height == 0)) {
        return;
    }
    
    CGRect cropBox = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
	int pageRotation = CGPDFPageGetRotationAngle(page);
	
	CGSize pageVisibleSize = CGSizeMake(cropBox.size.width, cropBox.size.height);
	if ((pageRotation == 90) || (pageRotation == 270) ||(pageRotation == -90)) {
		pageVisibleSize = CGSizeMake(cropBox.size.height, cropBox.size.width);
	}
    
    float scaleX = displayRectangle.size.width / pageVisibleSize.width;
    float scaleY = displayRectangle.size.height / pageVisibleSize.height;
    float scale = scaleX < scaleY ? scaleX : scaleY;
    
    // Offset relative to top left corner of rectangle where the page will be displayed
    float offsetX = 0;
    float offsetY = 0;
    
    float rectangleAspectRatio = displayRectangle.size.width / displayRectangle.size.height;
    float pageAspectRatio = pageVisibleSize.width / pageVisibleSize.height;
    
    if (pageAspectRatio < rectangleAspectRatio) {
        // The page is narrower than the rectangle, we place it at center on the horizontal
        offsetX = (displayRectangle.size.width - pageVisibleSize.width * scale) / 2;
    }
    else {
        // The page is wider than the rectangle, we place it at center on the vertical
        offsetY = (displayRectangle.size.height - pageVisibleSize.height * scale) / 2;
    }
    
    CGPoint topLeftPage = CGPointMake(displayRectangle.origin.x + offsetX, displayRectangle.origin.y + offsetY);
    
    [self renderPage:page inContext:pageContext atPoint:topLeftPage withZoom:scale * 100];
}


- (UIImage *)generatePhotoThumbnail:(UIImage *)image {
	// Create a thumbnail version of the image for the event object.
	CGSize size = image.size;
	CGSize croppedSize;
	//CGFloat ratio = 64.0;
	CGFloat offsetX = 0.0;
	CGFloat offsetY = 0.0;
	
	// check the size of the image, we want to make it
	// a square with sides the size of the smallest dimension
	if (size.width > size.height) {
		offsetX = (size.height - size.width) / 2;
        offsetX+=5;
		croppedSize = CGSizeMake(size.height, size.height);
	} else {
		offsetY = (size.width - size.height) / 2;
		croppedSize = CGSizeMake(size.width, size.width);
	}
	
	// Crop the image before resize
	CGRect clippedRect = CGRectMake(offsetX * -1, offsetY * -1, croppedSize.width+10, croppedSize.height);
	CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], clippedRect);
	// Done cropping
	
	// Resize the image
	CGRect rect = CGRectMake(0.0, 0.0, 101, 108);
	
	UIGraphicsBeginImageContext(rect.size);
	[[UIImage imageWithCGImage:imageRef] drawInRect:rect];
	UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRelease(imageRef);
	UIGraphicsEndImageContext();
	// Done Resizing
	
	return thumbnail;
}



@end
