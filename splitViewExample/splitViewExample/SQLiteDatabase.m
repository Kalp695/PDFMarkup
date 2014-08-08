//
//  SQLDatabase.m
//
//  Created by Sergo Beruashvili on 10/2/13.
//  Copyright (c) 2013 Sergo Beruashvili. All rights reserved.
//

#import "SQLiteDatabase.h"
#import "SQLiteResult.h"
#import "SQLiteRow.h"


@implementation SQLiteDatabase

static sqlite3 * _db;

+(sqlite3 *)getDBConnection {
    @synchronized([SQLiteDatabase class]) {
        
        if(_db == nil) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error;
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *sqliteDB = [documentsDirectory stringByAppendingPathComponent:DATABASE_FILE_NAME];
            
            if ([fileManager fileExistsAtPath:sqliteDB] == NO) {
                NSArray *parts = [DATABASE_FILE_NAME componentsSeparatedByString:@"."];
                if(parts.count != 2) {
                    NSLog(@"Database file name must be with format FILENAME.TYPE , for example mydatabase.sqlite , your is %@",DATABASE_FILE_NAME);
                    return nil;
                }
                NSString *resourcePath = [[NSBundle mainBundle] pathForResource:[parts objectAtIndex:0] ofType:[parts objectAtIndex:1]];
                if(resourcePath == nil) {
                    NSLog(@"Database file %@ Does not exist ",DATABASE_FILE_NAME);
                    return nil;
                }
                [fileManager copyItemAtPath:resourcePath toPath:sqliteDB error:&error];
                if(error != nil) {
                    NSLog(@"Error Copying Database File %@ ",error.localizedDescription);
                }
            }
            
            if(sqlite3_open_v2([sqliteDB UTF8String], &_db, SQLITE_OPEN_READWRITE, NULL) !=  SQLITE_OK) {
                NSLog(@"Failed to open the database %@ ",sqliteDB);
            }
        }
    }
    
    return _db;
}


+(SQLiteResult *)qin:(NSString *)query
          withParams:(NSDictionary *)params {
    
    SQLiteResult *result = [SQLiteResult resultWithSuccess];
    
    sqlite3_stmt *statement;
    
    if(sqlite3_prepare_v2([self getDBConnection], [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        int bindParamsCount = sqlite3_bind_parameter_count(statement);
        if(bindParamsCount > 0 && (params == nil || params.count != bindParamsCount) ) {
            return [SQLiteResult resultWithErrorMessage:[NSString stringWithFormat:@"Query needs %d parameters to bind",bindParamsCount]];
        }
        
        SQLiteResult *bindResult = [self bindParams:params toStatement:statement];
        if(!bindResult.success) {
            return bindResult;
        }
        
        int columnCount = sqlite3_column_count(statement);
        for(int i = 0; i < columnCount; i++) {
            if(sqlite3_column_name(statement,i) != NULL) {
                [result addColumnName:[NSString stringWithUTF8String:sqlite3_column_name(statement,i)]];
            } else {
                [result addColumnName:[NSString stringWithFormat:@"%d", i]];
            }
        }
        
        while(sqlite3_step(statement) == SQLITE_ROW) {
            SQLiteRow *row = [self getSqliteRowWithStatement:statement andColumnCount:columnCount];
            row.columnNames = result.columnNames;
            [result addSQLiteRow:row];
        }
        
        sqlite3_finalize(statement);
        
    } else {
        return [SQLiteResult resultWithErrorMessage:[NSString stringWithFormat:@"Incorrect query %@",query]];
    }
    
    return result;
}



+(SQLiteResult *)qout:(NSString *)query
           withParams:(NSDictionary *)params {

    sqlite3_stmt *statement;
    
    if(sqlite3_prepare_v2([self getDBConnection], [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        int bindParamsCount = sqlite3_bind_parameter_count(statement);
        if(bindParamsCount > 0 && (params == nil || params.count != bindParamsCount) ) {
            return [SQLiteResult resultWithErrorMessage:[NSString stringWithFormat:@"Query needs %d parameters to bind",bindParamsCount]];
        }
        
        SQLiteResult *bindResult = [self bindParams:params toStatement:statement];
        if(!bindResult.success) {
            return bindResult;
        }
        
        if(sqlite3_step(statement) != SQLITE_DONE) {
            const char* error = sqlite3_errmsg([self getDBConnection]);
            return [SQLiteResult resultWithErrorMessage:[NSString stringWithFormat:@"Error => %@",[[NSString alloc] initWithUTF8String:error]]];
        }
        
        sqlite3_finalize(statement);
    } else {
        return [SQLiteResult resultWithErrorMessage:[NSString stringWithFormat:@"Incorrect query %@",query]];
    }
    return [SQLiteResult resultWithSuccess];
}

+(SQLiteResult *)bindParams:(NSDictionary *)params toStatement:(sqlite3_stmt *)statement {
    
    if(params != nil) {
        for(NSString *key in params) {
            NSString *paramName = [key hasPrefix:@":"] ? key : [NSString stringWithFormat:@":%@",key];
            
            int columnIndex = sqlite3_bind_parameter_index(statement,[paramName UTF8String]);
            if(columnIndex == 0) {
                return [SQLiteResult resultWithErrorMessage:[NSString stringWithFormat:@"Can`t bind parameter %@",key]];
            }
            
            id parameter = [params objectForKey:key];
            if([parameter isKindOfClass:[NSString class]]) {
                sqlite3_bind_text(statement, columnIndex,[((NSString *)parameter) UTF8String], -1, SQLITE_TRANSIENT);
            } else if([parameter isKindOfClass:[NSNull class]]) {
                sqlite3_bind_null(statement, columnIndex);
            } else if([parameter isKindOfClass:[NSNumber class]]) {
                sqlite3_bind_double(statement, columnIndex, ([(NSNumber *)parameter doubleValue]));
            } else if([parameter isKindOfClass:[NSData class]]) {
                sqlite3_bind_blob(statement, columnIndex, [parameter bytes], [parameter length], SQLITE_TRANSIENT);
            } else if([parameter isKindOfClass:[NSDate class]]) {
                sqlite3_bind_double(statement, columnIndex, [((NSDate *)parameter) timeIntervalSince1970]);
            }
            else {
                return [SQLiteResult resultWithErrorMessage:[NSString stringWithFormat:@"Can`t bind parameter with type %@",[parameter class]]];
            }
        }
    }
    
    return [SQLiteResult resultWithSuccess];
}

+(SQLiteRow *)getSqliteRowWithStatement:(sqlite3_stmt *)statement andColumnCount:(NSUInteger)columnCount {
    NSMutableDictionary *row = [[NSMutableDictionary alloc] initWithCapacity:columnCount];
    
    for(int i = 0;i < columnCount;i++) {
        NSString *name = nil;
        if(sqlite3_column_name(statement,i) != NULL) {
            name = [NSString stringWithUTF8String:sqlite3_column_name(statement,i)];
        } else {
            name = [NSString stringWithFormat:@"%d", i];
        }

        id value = [NSNull null];
        
        int type = sqlite3_column_type(statement, i);
        
        switch (type) {
            case SQLITE_INTEGER:
            case SQLITE_FLOAT:
                value = [NSNumber numberWithDouble:sqlite3_column_double(statement, i)];
                break;
                
            case SQLITE_TEXT:
                value = [self stringWithCString:(char *) sqlite3_column_text(statement, i)];
                break;
                
            case SQLITE_BLOB:
                value = [[NSData alloc] initWithBytes:sqlite3_column_blob(statement, i) length: sqlite3_column_bytes(statement, i)];
                break;
                
            default:
                value = [NSNull null];
                break;
        }
        
        [row setObject:value forKey:name];
    }
    return [SQLiteRow rowWithRawData:row];
}

+(NSString *)stringWithCString:(char *)str {
    if(str) {
        return [[NSString alloc] initWithUTF8String:str];
    }
    return @"";
}


@end


