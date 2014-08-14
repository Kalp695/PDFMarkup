//
//  PDFFileName.h
//  PDFMarkUP
//
//  Created by CFA IT on 8/14/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDFFileName : NSObject{
    
    
}

@property NSString *name;
@property NSMutableArray *page;;


@end


@interface PDFPage : NSObject{
    

}

@property UIImage *image;
@property CGRect frame;


@end