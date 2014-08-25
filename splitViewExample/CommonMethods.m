//
//  NRUtils.m
//  Riah
//
//  Created by Nithin Reddy on 09/02/13.
//
//

#import "CommonMethods.h"


@implementation CommonMethods

+(BOOL) isValidEmail : (NSString *) email
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+(void) showAlert : (NSString *)title MSG:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

+(void) showAlert : (NSString *)title MSG:(NSString *)message TAG:(int)tag DELEGATE:(id)delegate
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert setTag:tag];
    [alert show];
}


@end
