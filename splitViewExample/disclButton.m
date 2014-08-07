//
//  disclButton.m
//  TermTableDisc
//
//  Created by CFA IT on 6/9/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import "disclButton.h"

#define blueColor [UIColor colorWithRed:(32)/256.0f green:(122)/256.0f blue:(252)/256.0f alpha:1.0f]

@implementation disclButton
@synthesize delegate=_delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    //[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(createCircle) userInfo:nil repeats:NO];
    
    [self addTarget:self action:@selector(highlight_UnHighlight:) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(highlight_OnTouch:) forControlEvents:UIControlEventTouchDown];

    if(self.tag>=1 && self.tag<=5)
        [self createCircleAndNumber];
    else
        [self createCircleArrow];
}

-(void)createCircleArrow{
    float X = CGRectGetWidth(self.frame) - 0;
    float Y = CGRectGetHeight(self.frame) - 0;
    float radius = CGRectGetWidth(self.frame)/2.0f;
    //radius=radius-2;
    
    CGPoint center= CGPointMake(X/2.0f, Y/2.0f);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:center
                    radius:radius
                startAngle:0.0
                  endAngle:2.0 * M_PI
                 clockwise:NO];
    
    CAShapeLayer *myLayer = [[CAShapeLayer alloc] init];
    myLayer.strokeColor = [blueColor CGColor];
    myLayer.lineWidth = 1.0f;
    myLayer.fillColor = blueColor.CGColor;
    myLayer.lineJoin = kCALineJoinBevel;
    myLayer.path = path.CGPath;
    [self.layer addSublayer:myLayer];
    
    
    myLayer = [[CAShapeLayer alloc] init];
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(radius*(3.0f/4.0f), radius*(3.0f/4.0f)-5.0f)];
    [linePath addLineToPoint:CGPointMake(radius*(3.0f/2.0f), radius)];
    [linePath addLineToPoint:CGPointMake(radius*(3.0f/4.0f), radius*(5.0f/4.0f)+5.0f)];
    
    [linePath addLineToPoint:CGPointMake(radius*(3.0f/4.0f)-1.0f, radius*(5.0f/4.0f)+5.0f-1.0f)];
    [linePath addLineToPoint:CGPointMake(radius*(3.0f/2.0f)-2.0f, radius)];
    [linePath addLineToPoint:CGPointMake(radius*(3.0f/4.0f)-1.0f, radius*(3.0f/4.0f)-5.0f+1.0f)];
    
    myLayer.fillColor = [UIColor whiteColor].CGColor;
    myLayer.strokeColor = [[UIColor whiteColor] CGColor];
    myLayer.lineWidth = 1.0f;
    
    myLayer.lineJoin = kCALineJoinBevel;
    myLayer.path = linePath.CGPath;
    [self.layer addSublayer:myLayer];
    //self.transform = CGAffineTransformMakeRotation(M_PI/2);
    
    //UIImage *image= [self imageFromLayer:myLayer withButton:self];
    //[self setBackgroundImage:image forState:UIControlStateNormal];
    //[self setTitle:@"hi" forState:UIControlStateNormal];
    //self.backgroundColor=blueColor;
}

-(void)createCircleAndNumber{
    
    
    
    float X = CGRectGetWidth(self.frame) - 0;
    float Y = CGRectGetHeight(self.frame) - 0;
    float radius = CGRectGetWidth(self.frame)/2.0f;
    //radius=radius-2;
    
    CGPoint center= CGPointMake(X/2.0f, Y/2.0f);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:center
                    radius:radius
                startAngle:0.0
                  endAngle:2.0 * M_PI
                 clockwise:NO];
    
    CAShapeLayer *myLayer = [[CAShapeLayer alloc] init];
    myLayer.strokeColor = [[UIColor blackColor] CGColor];
    myLayer.fillColor=[UIColor clearColor].CGColor;
    myLayer.lineWidth = 1.0f;
    myLayer.lineJoin = kCALineJoinBevel;
    myLayer.path = path.CGPath;
    [self.layer addSublayer:myLayer];
    [self setTitle:[NSString stringWithFormat:@"%d",self.tag] forState:UIControlStateNormal];
    
    
}



- (UIImage *)imageFromLayer:(CALayer *)layer withButton:(UIButton*)button
{
    UIImage *snapshotImage = nil;
    UIGraphicsBeginImageContextWithOptions(button.bounds.size, NO, button.layer.contentsScale);
    {
        CGContextRef imageContext = UIGraphicsGetCurrentContext();
        
        if (imageContext != NULL) {
            UIGraphicsPushContext(imageContext);
            {
                [layer renderInContext:imageContext];
            }
            UIGraphicsPopContext();
        }
        
        snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return  snapshotImage;
}


-(IBAction)highlight_UnHighlight:(id)sender{
}


-(IBAction)highlight_OnTouch:(id)sender{
    NSInteger tag_no=self.tag>5?self.tag-5:self.tag;
    if(_delegate)
        [_delegate buttonTappedWithTag:tag_no];
    
}

@end
