//
//  DriveHelperClass.h
//  GD
//
//  Created by ravi on 23/08/14.
//  Copyright (c) 2014 Teapoy Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"
@interface DriveHelperClass : NSObject
{
    
}
+(DriveHelperClass*)getSharedInstance;

@property (nonatomic, retain) GTLServiceDrive *driveService;

@end
