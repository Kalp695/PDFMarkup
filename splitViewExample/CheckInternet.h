//
//  harpWebServices.h
//  Harp
//
//  Created by Sunil on 1/18/14.
//  Copyright (c) 2014 Sunil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CheckInternet : NSObject
{

}
+(CheckInternet *)sharedInstance;

/*! This method needs to be implemented by all cnntroller classses, before calling an API */
-(BOOL)checkForInternetConnectivity;

@end
