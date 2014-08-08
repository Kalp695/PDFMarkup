//
//  SQLiteResult.h
//
//  Created by Sergo Beruashvili on 10/5/13.
//  Copyright (c) 2013 Sergo Beruashvili. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SQLiteRow;

@interface SQLiteResult : NSObject <NSFastEnumeration>

+(id)resultWithSuccess;
+(id)resultWithErrorMessage:(NSString *)error;


// SUCCESS/FAILURE
@property (nonatomic,readwrite) BOOL success;

// Error message in case of failure
@property (nonatomic,strong) NSString *errorMessage;

// Selected rows
@property (nonatomic,strong) NSMutableArray *rows;

// Selected column names
@property (nonatomic,strong) NSMutableArray *columnNames;


-(void)addSQLiteRow:(SQLiteRow *)row;
-(void)removeSQLiteRow:(SQLiteRow *)row;
-(SQLiteRow *)rowAtIndex:(NSUInteger)index;
-(NSUInteger)count;

-(void)addColumnName:(NSString *)columnName;
-(void)removeColumnName:(NSString *)columnName;

-(NSUInteger)indexForColumnName:(NSString *)columnName;
-(NSString *)columnNameForIndex:(NSUInteger)index;

@end
