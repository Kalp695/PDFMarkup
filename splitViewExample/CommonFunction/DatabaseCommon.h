//
//  DatabaseCommon.h
//  Shippers Report
//
//  Created by CFA IT on 5/9/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatabaseCommon : NSObject


-(NSString*)getMaxRowID;
-(void)InsertIntoShippersTableWithDict:(NSDictionary*)dict withClientName:(NSString*)clientName withRowID:(NSString*)rowID;
-(void)UpdateShippersTableWithDict:(NSDictionary*)dict withRowID:(NSString*)rowID;
-(NSMutableArray*)getAllClientReport;
-(NSMutableArray*)getShippersInfoWithClientName:(NSString*)ClientName;
-(NSDictionary*)getShippersInfoWithRowId:(NSString*)rowID;
-(NSMutableArray*)getAllClientName;
-(NSDictionary*)deleteShippersInfoWithRowId:(NSString*)rowID;
@end
