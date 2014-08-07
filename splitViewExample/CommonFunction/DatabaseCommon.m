//
//  DatabaseCommon.m
//  Shippers Report
//
//  Created by CFA IT on 5/9/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import "DatabaseCommon.h"
#import "SQLiteDatabase.h"

@implementation DatabaseCommon


-(id)getMaxRowID{
    id rowID=@"1";
    SQLiteResult *result = [SQLiteDatabase qin:@"SELECT  ID+1 as rowid FROM  tbl_report order by ID desc limit 1 " withParams:nil];
    if(result.success) {
        
        for(SQLiteRow *row in result) {
            for(NSString *columnName in row.columnNames) {
                NSLog(@"%@ => %@",columnName,[row objectForColumnName:columnName]);
                rowID=[row objectForColumnName:columnName];
            }
        }
        
    } else {
        NSLog(@"Error => %@",result.errorMessage);
    }
    
    return rowID;
}



-(void)InsertIntoShippersTableWithDict:(NSDictionary*)dict withClientName:(NSString*)clientName withRowID:(NSString*)rowID{

    /*********************check rowID exist to database or not ********************/
    NSString *tableRowID=@"";
    NSDictionary *params = @{
                             @"ID" : rowID
                             };

    
     SQLiteResult *result = [SQLiteDatabase qout:@"SELECT * FROM  tbl_shippers where ID=:ID" withParams:params];
    
    if(result.success) {
        NSLog(@"Done");
    } else {
        NSLog(@"Error => %@",result.errorMessage);
        [self UpdateShippersTableWithDict:dict withRowID:rowID];
        return;
    }
    
    
    for(SQLiteRow *row in result) {
        for(NSString *columnName in row.columnNames) {
            tableRowID=[row objectForColumnName:columnName];
            
        }
    
    }
    
    if([[NSString stringWithFormat:@"%@",rowID] isEqualToString:tableRowID]){
        [self UpdateShippersTableWithDict:dict withRowID:rowID];
        
        return;
    }
    
    
    /*********************end ******************************************************/
    
    
    /*********************Insert client field ********************/
    
    params = @{
                             @"ClientName" : clientName
                             };
    result = [SQLiteDatabase qout:@"Insert into tbl_client(ClientName) values(:ClientName)" withParams:params];
    if(result.success) {
        NSLog(@"Done");
    } else {
        NSLog(@"Error => %@",result.errorMessage);
    }
    
    /*********************end ********************/
    
    
    params = @{
                             @"Waybill_no" : [dict objectForKey:@"Waybill_no"],
                             @"Artist" : [dict objectForKey:@"Artist"],
                             @"Title" : [dict objectForKey:@"Title"],
                             @"ShippersNotes" : [dict objectForKey:@"ShippersNotes"],
                             @"SignOff_Release" : [dict objectForKey:@"SignOff_Release"],
                             @"SignOff_Receive" : [dict objectForKey:@"SignOff_Receive"],
                             @"ClientName" : clientName
                             };

    /*********************Insert into Shippers table ********************/
     result = [SQLiteDatabase qin:@"insert into tbl_shippers(Waybill_no,Artist,Title,ShippersNotes,SignOff_Release,SignOff_Receive,ClientName)values(:Waybill_no,:Artist,:Title,:ShippersNotes,:SignOff_Release,:SignOff_Receive,:ClientName) " withParams:params];
    if(result.success) {
        NSLog(@"Done");
    }
    else {
        NSLog(@"Error => %@",result.errorMessage);
    }
 
    /*********************end ********************/

}




-(void)UpdateShippersTableWithDict:(NSDictionary*)dict withRowID:(NSString*)rowID{
    
    
    
  NSDictionary  *params = @{
               @"Waybill_no" : [dict objectForKey:@"Waybill_no"],
               @"Artist" : [dict objectForKey:@"Artist"],
               @"Title" : [dict objectForKey:@"Title"],
               @"ShippersNotes" : [dict objectForKey:@"ShippersNotes"],
               @"SignOff_Release" : [dict objectForKey:@"SignOff_Release"],
               @"SignOff_Receive" : [dict objectForKey:@"SignOff_Receive"],
               @"ID" : rowID
               };
    
    /*********************Insert into Shippers table ********************/
   SQLiteResult *result = [SQLiteDatabase qin:@"update tbl_shippers set Waybill_no=:Waybill_no, Artist=:Artist,Title=:Title,ShippersNotes=:ShippersNotes,SignOff_Release=:SignOff_Release,SignOff_Receive=:SignOff_Receive where ID=:ID" withParams:params];
    if(result.success) {
        NSLog(@"Done");
    }
    else {
        NSLog(@"Error => %@",result.errorMessage);
    }
    
    /*********************end ********************/
    
}






-(NSMutableArray*)getAllClientName{
    NSString *ClientName;
    NSMutableDictionary *dict;
    dict=[[NSMutableDictionary alloc]init];
    NSMutableArray *array=[[NSMutableArray alloc]init];
    SQLiteResult *result = [SQLiteDatabase qin:@"SELECT ClientName FROM  tbl_client " withParams:nil];
    if(result.success) {
        
        for(SQLiteRow *row in result) {
            for(NSString *columnName in row.columnNames) {
                ClientName=[row objectForColumnName:columnName];
                NSLog(@"%@ => %@",columnName,ClientName);
                
                
            }
            [array addObject:ClientName];
        }
        
    } else {
        NSLog(@"Error => %@",result.errorMessage);
    }
    
    return array;
}



-(NSMutableArray*)getAllClientReport{
    NSMutableDictionary *dict;
    NSMutableArray *array=[[NSMutableArray alloc]init];
    NSMutableArray *arrayShippersInfo;
    NSString *ClientName;
    SQLiteResult *result = [SQLiteDatabase qin:@"SELECT ClientName FROM  tbl_client" withParams:nil];
    if(result.success) {
        
        for(SQLiteRow *row in result) {
            for(NSString *columnName in row.columnNames) {
                ClientName=[row objectForColumnName:columnName];
               
                NSLog(@"%@ => %@",columnName,ClientName);
                
            }
            
            arrayShippersInfo=[self getShippersInfoWithClientName:ClientName];
            dict=[[NSMutableDictionary alloc]init];
            [dict setObject:ClientName forKey:@"ClientName"];
            [dict setObject:arrayShippersInfo forKey:@"ShippersReport"];
            [array addObject:dict];
        }
        
    } else {
        NSLog(@"Error => %@",result.errorMessage);
    }
    
    return array;
}







-(NSMutableArray*)getShippersInfoWithClientName:(NSString*)ClientName{
    NSMutableDictionary *dict;
    NSMutableArray *array=[[NSMutableArray alloc]init];
    NSDictionary *params = @{
                             @"ClientName" : ClientName
                             };
    
    SQLiteResult *result = [SQLiteDatabase qin:@"SELECT ID,  Waybill_no,Artist,Title,ShippersNotes,SignOff_Release,SignOff_Receive,ClientName FROM  tbl_shippers where ClientName=:ClientName" withParams:params];
    if(result.success) {
        
        for(SQLiteRow *row in result) {
            dict=[[NSMutableDictionary alloc]init];
            for(NSString *columnName in row.columnNames) {
                NSLog(@"%@ => %@",columnName,[row objectForColumnName:columnName]);
                [dict setObject: [row objectForColumnName:columnName]forKey:columnName];
            }
            [array addObject:dict];
        }
        
    } else {
        NSLog(@"Error => %@",result.errorMessage);
    }
    
    return array;
}



-(NSDictionary*)getShippersInfoWithRowId:(NSString*)rowID{
    NSMutableDictionary *dict;
    dict=[[NSMutableDictionary alloc]init];
    NSDictionary *params = @{
                             @"ID" : rowID
                             };
    
    SQLiteResult *result = [SQLiteDatabase qin:@"SELECT ID,  Waybill_no,Artist,Title,ShippersNotes,SignOff_Release,SignOff_Receive FROM  tbl_shippers where ID=:ID" withParams:params];
    if(result.success) {
        for(SQLiteRow *row in result) {
            for(NSString *columnName in row.columnNames) {
                NSLog(@"%@ => %@",columnName,[row objectForColumnName:columnName]);
                [dict setObject: [row objectForColumnName:columnName] forKey:columnName];
            }
            
        }
        
    } else {
        NSLog(@"Error => %@",result.errorMessage);
    }
    
    return dict;
}

-(NSDictionary*)deleteShippersInfoWithRowId:(NSString*)rowID{
    NSMutableDictionary *dict;
    dict=[[NSMutableDictionary alloc]init];
    NSDictionary *params = @{
                             @"ID" : rowID
                             };
    
    SQLiteResult *result = [SQLiteDatabase qin:@"DELETE FROM  tbl_shippers where ID=:ID" withParams:params];
    if(result.success) {
        
    } else {
        NSLog(@"Error => %@",result.errorMessage);
    }
    
    return dict;
}



@end
