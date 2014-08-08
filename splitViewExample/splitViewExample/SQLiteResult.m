//
//  SQLiteResult.m
//
//  Created by Sergo Beruashvili on 10/5/13.
//  Copyright (c) 2013 Sergo Beruashvili. All rights reserved.
//

#import "SQLiteResult.h"
#import "SQLiteRow.h"

@implementation SQLiteResult

@synthesize rows = _rows;
@synthesize columnNames = _columnNames;

+(id)resultWithSuccess {
    SQLiteResult *result = [[SQLiteResult alloc] init];
    result.success = YES;
    return result;
}


+(id)resultWithErrorMessage:(NSString *)error {
    SQLiteResult *result = [[SQLiteResult alloc] init];
    result.success = NO;
    result.errorMessage = error;
    return result;
}

#pragma mark -

-(NSMutableArray *)rows {
    if(_rows == nil) {
        _rows = [[NSMutableArray alloc] init];
    }
    return _rows;
}

-(NSMutableArray *)columnNames {
    if(_columnNames == nil) {
        _columnNames = [[NSMutableArray alloc] init];
    }
    return _columnNames;
}

#pragma mark Instance Methods

-(void)addSQLiteRow:(SQLiteRow *)row {
    [self.rows addObject:row];
}

-(void)removeSQLiteRow:(SQLiteRow *)row {
    [self.rows removeObject:row];
}

-(SQLiteRow *)rowAtIndex:(NSUInteger)index {
    if(self.rows.count > index) {
        return [self.rows objectAtIndex:index];
    }
    return nil;
}

-(NSUInteger)count {
    return self.rows.count;
}

-(void)addColumnName:(NSString *)columnName {
    [self.columnNames addObject:columnName];
}

-(void)removeColumnName:(NSString *)columnName {
    [self.columnNames removeObject:columnName];
}

-(NSUInteger)indexForColumnName:(NSString *)columnName {
    return [self.columnNames indexOfObject:columnName];
}

-(NSString *)columnNameForIndex:(NSUInteger)index {
    if(self.columnNames.count > index) {
        return [self.columnNames objectAtIndex:index];
    }
    return nil;
}

#pragma mark Fast Enumeration
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len {
    return [self.rows countByEnumeratingWithState:state objects:buffer count:len];
}

@end
