//
//  SQLiteRow.m
//
//  Created by Sergo Beruashvili on 10/5/13.
//  Copyright (c) 2013 Sergo Beruashvili. All rights reserved.
//

#import "SQLiteRow.h"

@implementation SQLiteRow

+(NSDate *)dateWithString:(NSString *)dateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; // THIS IS DEFAULT DATE FORMAT FOR SQLITE , YOU CAN CHANGE IF YOU WISH
    return [formatter dateFromString:dateString];
}

+(id)rowWithRawData:(NSDictionary *)dictionary {
    SQLiteRow *row = [[SQLiteRow alloc] init];
    row.rawData = dictionary;
    return row;
}

@synthesize rawData = _rawData;

-(NSDictionary *)rawData {
    if(_rawData == nil) {
        _rawData = [[NSDictionary alloc] init];
    }
    return _rawData;
}

-(id)objectForColumnName:(NSString *)columnName {
    return [self.rawData objectForKey:columnName];
}

-(id)objectForColumnIndex:(NSUInteger)index {
    if(self.columnNames.count > index) {
        return [self objectForColumnName:[self.columnNames objectAtIndex:index]];
    }
    return nil;
}

-(NSString *)stringForColumnName:(NSString *)columnName {
    id object = [self.rawData objectForKey:columnName];
    if(object == nil) {
        return nil;
    }
    
    if([object isKindOfClass:[NSString class]]) {
        return object;
    }
    
    if([object respondsToSelector:@selector(stringValue)]) {
        return [object stringValue];
    }
    
    return nil;
}
-(NSString *)stringForColumnIndex:(NSUInteger)index {
    if(self.columnNames.count > index) {
        return [self stringForColumnName:[self.columnNames objectAtIndex:index]];
    }
    return nil;
}

-(NSNumber *)numberForColumnName:(NSString *)columnName {
    id object = [self.rawData objectForKey:columnName];
    if(object == nil) {
        return nil;
    }
    if([object isKindOfClass:[NSNumber class]]) {
        return object;
    }
    return nil;
}
-(NSNumber *)numberForColumnIndex:(NSUInteger)index {
    if(self.columnNames.count > index) {
        return [self numberForColumnName:[self.columnNames objectAtIndex:index]];
    }
    return nil;
}


-(NSData *)dataForColumnName:(NSString *)columnName {
    id object = [self.rawData objectForKey:columnName];
    if(object == nil) {
        return nil;
    }
    
    if([object isKindOfClass:[NSData class]]) {
        return object;
    }
    return nil;
}
-(NSData *)dataForColumnIndex:(NSUInteger)index {
    if(self.columnNames.count > index) {
        return [self dataForColumnName:[self.columnNames objectAtIndex:index]];
    }
    return nil;
}

-(NSDate *)dateForColumnName:(NSString *)columnName {
    id object = [self.rawData objectForKey:columnName];
    if(object == nil) {
        return nil;
    }
    
    if([object isKindOfClass:[NSNumber class]]) {
        return [NSDate dateWithTimeIntervalSince1970:[object doubleValue]];
    }
    
    if([object isKindOfClass:[NSString class]]) {
        return [SQLiteRow dateWithString:object];
    }
    return nil;
}
-(NSDate *)dateForColumnIndex:(NSUInteger)index {
    if(self.columnNames.count > index) {
        return [self dateForColumnName:[self.columnNames objectAtIndex:index]];
    }
    return nil;
}

@end
