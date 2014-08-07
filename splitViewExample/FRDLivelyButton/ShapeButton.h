//
//  ShapeButton.h
//  AR Appstore
//
//  Created by CFA IT on 4/22/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/256.0f green:(g)/256.0f blue:(b)/256.0f alpha:1.0f]

@interface ShapeButton : UIButton{
    
}

-(void)InitializeWithframe:(CGRect)frame withButtonType:(NSString*)buttonType;

@end
