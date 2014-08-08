//
//  SQLDatabase.h
//
//  Created by Sergo Beruashvili on 10/2/13.
//  Copyright (c) 2013 Sergo Beruashvili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "SQLiteResult.h"
#import "SQLiteRow.h"

@class SQLiteResult;

@interface SQLiteDatabase : NSObject

#define DATABASE_FILE_NAME @"PDFMarkup.sqlite"

// Returns sqlite3 Struct
+(sqlite3 *)getDBConnection;

/**
    is used for SELECT something from database
    query => SQL statement string , may contain parameters params to bind
    params => Dictionary of parameters , if query contains any bind-able params , currently may contain NSString and NSNumber objects , might be nil
 
    returns SQLResult object
 
 */
+(SQLiteResult *)qin:(NSString *)query
          withParams:(NSDictionary *)params;


/**
 is used for INSERT/UPDATE/DELETE something from database
 query => SQL statement string , may contain parameters params to bind
 params => Dictionary of parameters , if query contains any bind-able params , currently may contain NSString and NSNumber objects , might be nil
 
 returns SQLResult object
 
 */
+(SQLiteResult *)qout:(NSString *)query
           withParams:(NSDictionary *)params;

@end



