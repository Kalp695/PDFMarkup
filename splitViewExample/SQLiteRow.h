//
//  SQLiteRow.h
//
//  Created by Sergo Beruashvili on 10/5/13.
//  Copyright (c) 2013 Sergo Beruashvili. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQLiteRow : NSObject

+(id)rowWithRawData:(NSDictionary *)dictionary;

@property (nonatomic,strong) NSDictionary *rawData;
@property (nonatomic,strong) NSArray *columnNames;

// Returns object if exists or nil
-(id)objectForColumnName:(NSString *)columnName;
-(id)objectForColumnIndex:(NSUInteger)index;

// Returns stringvalue of object , if object does not exists or it does not have string value returns nil
-(NSString *)stringForColumnName:(NSString *)columnName;
-(NSString *)stringForColumnIndex:(NSUInteger)index;

// Returns NSNumber object , if object does not exists returns nil
-(NSNumber *)numberForColumnName:(NSString *)columnName;
-(NSNumber *)numberForColumnIndex:(NSUInteger)index;

// Returns NSData object , if object does not exists returns nil
-(NSData *)dataForColumnName:(NSString *)columnName;
-(NSData *)dataForColumnIndex:(NSUInteger)index;

// Returns NSNumber object , if object does not exists returns nil
-(NSDate *)dateForColumnName:(NSString *)columnName;
-(NSDate *)dateForColumnIndex:(NSUInteger)index;

@end
