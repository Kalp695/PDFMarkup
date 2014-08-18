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

@property(nonatomic,retain) NSString *name;
@property(nonatomic,strong) NSMutableArray *page;;
-(id)initCopy:(PDFFileName *)input;


@end


@interface PDFPage : NSObject{
    

}


@property(nonatomic,strong) UIImage *image;
@property(nonatomic,assign) CGRect frame;
-(id)initCopy:(PDFPage *)input;


@end