//
//  DocumentManager.h
//  splitViewExample
//
//  Created by mahesh babu on 06/08/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DocumentManager : NSObject


+(DocumentManager*)getSharedInstance;
-(NSString *)getUserAccountpath;
@end
