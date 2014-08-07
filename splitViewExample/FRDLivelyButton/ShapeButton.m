//
//  ShapeButton.m
//  AR Appstore
//
//  Created by CFA IT on 4/22/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import "ShapeButton.h"

@implementation ShapeButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.frame=CGRectMake(15, 15,46 , 30);
        [self InitializeWithframe:self.frame withButtonType:@"LeftArrow"];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


-(void)InitializeWithframe:(CGRect)frame withButtonType:(NSString*)buttonType{
    
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(10.0f, CGRectGetHeight(frame)-5.0f)];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(frame)-14.0f, 2.0f)];
    
    
    //2. Create a shape layer for above created path.
    CAShapeLayer *buttonLayer = [[CAShapeLayer alloc] initWithLayer:self.layer];
    buttonLayer.strokeColor = RGBCOLOR(32, 122, 252).CGColor;
    buttonLayer.lineWidth = 1.5f;
    //NSLog("shapeToBeDrawn.color=%@", myLayer);
    
    buttonLayer.fillColor = nil;
    //myLayer.lineJoin = kCALineJoinBevel;
    buttonLayer.path = path.CGPath;
    
    [self.layer addSublayer:buttonLayer];

   
    
}

@end
