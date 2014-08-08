//
//  MagnifierView.h
//  SimplerMaskTest
//

#import <UIKit/UIKit.h>
#import "FRDLivelyButton.h"

#define Margin 40.0f 

@protocol closeMagnifierDelegate
- (void)closeMagnifier;
@end

@interface MagnifierView : UIView {
	UIView *viewToMagnify;
    UIView *markupView;
	CGPoint touchPoint;
    CGPoint touchStart;
    CGPoint touchEnd;
    CGPoint tStartPoint;
    FRDLivelyButton *crossButton;
    float widthOffset;
    float heightOffset;
    float magnification;

}

@property (nonatomic, retain) UIView *viewToMagnify;
@property (nonatomic, retain) UIView *markupView;
@property (assign) CGPoint touchPoint;

@property (nonatomic, retain) id<closeMagnifierDelegate> delegate;


@end
