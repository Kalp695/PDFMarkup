//
//  NRUtils.h
//  Riah
//
//  Created by Nithin Reddy on 09/02/13.
//
//

#import <Foundation/Foundation.h>

@interface CommonMethods : NSObject

//Check if the email is valid or not
+(BOOL) isValidEmail : (NSString *) email;

//Display an alert
+(void) showAlert : (NSString *)title MSG:(NSString *)message;

+(void) showAlert : (NSString *)title MSG:(NSString *)message TAG:(int)tag DELEGATE:(id)delegate;

@end
