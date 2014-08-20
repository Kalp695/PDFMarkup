//
//  disclButton.h
//  TermTableDisc
//
//  Created by CFA IT on 6/9/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>



@protocol disclButtonDelegate
-(void)buttonTappedWithTag:(NSInteger)tag;

@end
@interface disclButton : UIButton

@property(nonatomic,weak) id<disclButtonDelegate>delegate;

@end
