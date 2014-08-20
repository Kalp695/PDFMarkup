//
//  BoxHelperClass.h
//  PDFMarkUP
//
//  Created by ravi on 20/08/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BoxHelperClass : NSObject

+(BoxHelperClass*)getSharedInstance;
-(BOOL)checkExpiredBoxToken;
@end
