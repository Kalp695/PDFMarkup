//
//  MagnifierView.m
//  SimplerMaskTest
//

#import "MagnifierView.h"
#import <QuartzCore/QuartzCore.h>
#import "CommonFunction.h"

@implementation MagnifierView
@synthesize viewToMagnify, touchPoint,markupView;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:CGRectMake(0, 0, 300, 150)]) {
		// make the circle-shape outline with a nice border.
        CommonFunction *commonFunction =[[CommonFunction alloc]init];
		self.layer.borderColor = [[commonFunction defaultSystemTintColor] CGColor];
		self.layer.borderWidth = 2.0f;
		self.layer.cornerRadius = 5;
		self.layer.masksToBounds = YES;
        
        
        //magnification=sharedSingleton.magnification==0?1.5f:2.5f;
        magnification=1.5f;
        widthOffset=0.0f;
        heightOffset=0.0f;

        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(addMagnifierCrossButton) userInfo:nil repeats:NO];

        
	}
	return self;
}




-(void)addMagnifierCrossButton{
    
    CommonFunction *commonFunction =[[CommonFunction alloc]init];
    crossButton  = [[FRDLivelyButton alloc] initWithFrame:CGRectMake(160,40,26,26)];
    
    [crossButton setOptions:@{ kFRDLivelyButtonLineWidth: @(2.0f),
                               kFRDLivelyButtonHighlightedColor: [commonFunction defaultSystemTintColor],
                               kFRDLivelyButtonColor: [commonFunction defaultSystemTintColor],
                               }];
    [crossButton setStyle:kFRDLivelyButtonStyleCircleClose animated:NO];
    [crossButton setBackgroundColor:[UIColor whiteColor]];
    crossButton.layer.borderColor = [[commonFunction defaultSystemTintColor] CGColor];
    //crossButton.layer.borderWidth = 2;
    crossButton.layer.cornerRadius = 10.0f;
    //crossButton.layer.masksToBounds = YES;
    [crossButton addTarget:self action:@selector(magnifierCloseButton_click:) forControlEvents:UIControlEventTouchUpInside];
    crossButton.tag=101;
    //NSLog(@"magnifierView.frame=%@",NSStringFromCGRect(magnifierView.frame));
    [viewToMagnify addSubview:crossButton];
    crossButton.frame=CGRectMake(touchPoint.x+(CGRectGetWidth(self.frame)/2.0)-(CGRectGetWidth(crossButton.frame)/2.0)+6.0f, touchPoint.y-((CGRectGetHeight(self.frame)/2.0)+17.0f), CGRectGetWidth(crossButton.frame), (CGRectGetHeight(crossButton.frame)));
    
    
}


-(IBAction)magnifierCloseButton_click:(id)sender{
    
    [self removeFromSuperview];
    [crossButton removeFromSuperview];
    crossButton=nil;
    if(_delegate)
        [_delegate closeMagnifier];
}


- (void)setMagnifierPoint:(CGPoint)pt {
	touchPoint = pt;
	// whenever touchPoint is set,
	// update the position of the magnifier (to just above what's being magnified)
    [self translateUsingTouchLocation:tStartPoint];
    //NSLog(@"before self.center=%@",NSStringFromCGPoint(self.center));

	self.center = CGPointMake(pt.x-widthOffset, pt.y-heightOffset);
   // NSLog(@"after self.center=%@",NSStringFromCGPoint(self.center));
    //self.frame=CGRectMake(pt.x, pt.y, self.frame.size.width, self.frame.size.height);
    
    
}

- (void)drawRect:(CGRect)rect {
	// here we're just doing some transforms on the view we're magnifying,
	// and rendering that view directly into this view,
	// rather than the previous method of copying an image.
    
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context,1*(self.frame.size.width*0.5),1*(self.frame.size.height*0.5));
	CGContextScaleCTM(context, magnification, magnification);
	CGContextTranslateCTM(context,-1*(touchPoint.x-widthOffset),-1*(touchPoint.y-heightOffset));
	[self.viewToMagnify.layer renderInContext:context];
    
    crossButton.frame=CGRectMake(self.center.x+(CGRectGetWidth(self.frame)/2.0)-(CGRectGetWidth(crossButton.frame)/2.0)+6.0f, self.center.y-((CGRectGetHeight(self.frame)/2.0)+17.0f), CGRectGetWidth(crossButton.frame), (CGRectGetHeight(crossButton.frame)));

    
    
    
}



- (void)translateUsingTouchLocation:(CGPoint)touchPoint1 {
    
    //if (self.preventsPositionOutsideSuperview) {
    // Ensure the translation won't cause the view to move offscreen.
    
    CGFloat midPointX = CGRectGetMidX(self.bounds);
    
    CGFloat midPointY = CGRectGetMidY(self.bounds);
    
    if (touchPoint1.x > midPointX) {
        widthOffset=(CGRectGetWidth(self.frame)/2.0)-(self.frame.size.width-touchPoint1.x);
        
        if (touchPoint1.y > midPointY) {
            heightOffset= (CGRectGetHeight(self.frame)/2.0)-(self.frame.size.height-touchPoint1.y);
        }
        if (touchPoint1.y < midPointY) {
            heightOffset=-(CGRectGetHeight(self.frame)/2.0-touchPoint1.y);
        }
    }
    if (touchPoint1.x < midPointX) {
        widthOffset=-((CGRectGetWidth(self.frame)/2.0)-touchPoint1.x);
        
        if (touchPoint1.y > midPointY) {
            heightOffset= (CGRectGetHeight(self.frame)/2.0)-(self.frame.size.height-touchPoint1.y);
        }
        if (touchPoint1.y < midPointY) {
            heightOffset=-((CGRectGetHeight(self.frame)/2.0)-touchPoint1.y);
        }
    }
    
    
    //}
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
    
    //NSLog(@"In touchesBegan!");
    UITouch *touch = [touches anyObject];
    
    tStartPoint=[touch locationInView:self];
   
    CGRect magnifierFrame=CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    CGRect innerBounding=CGRectMake(Margin, Margin, CGRectGetWidth(self.frame)-2*Margin, CGRectGetHeight(self.frame)-2*Margin);
    
    if(CGRectContainsPoint(magnifierFrame, tStartPoint) && !CGRectContainsPoint(innerBounding, tStartPoint)){
        
        touchStart = [touch locationInView:self.superview];
        touchPoint=touchStart;
        [self setMagnifierPoint:touchPoint];
        [self setNeedsDisplay];
    }
    else{
        [self.markupView touchesBegan:touches withEvent: event];
    }
    
    //[self setNeedsDisplay];
    
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //NSLog(@"In touchesMoved!");
    
    UITouch *touch = [touches anyObject];
    
    touchStart = [touch locationInView:self.superview];
    
    CGRect magnifierFrame=CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    CGRect innerBounding=CGRectMake(Margin, Margin, CGRectGetWidth(self.frame)-2*Margin, CGRectGetHeight(self.frame)-2*Margin);
    
    if(CGRectContainsPoint(magnifierFrame, tStartPoint) && !CGRectContainsPoint(innerBounding, tStartPoint)){
        //[self translateUsingTouchLocation:[[touches anyObject] locationInView:self]];
        touchPoint=touchStart;
        [self setMagnifierPoint:touchPoint];
        [self setNeedsDisplay];
    }
    else{
        [self.markupView touchesMoved:touches withEvent: event];
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
    UITouch *touch = [touches anyObject];
    touchStart = [touch locationInView:self.superview];
    
    
    CGRect magnifierFrame=CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    CGRect innerBounding=CGRectMake(Margin, Margin, CGRectGetWidth(self.frame)-2*Margin, CGRectGetHeight(self.frame)-2*Margin);
    
    if(CGRectContainsPoint(magnifierFrame, tStartPoint) && !CGRectContainsPoint(innerBounding, tStartPoint)){
        touchPoint=touchStart;
        [self setMagnifierPoint:touchPoint];
        //NSLog(@"In touchesEnded!");
        [self setNeedsDisplay];
    }
    else{
        [self.markupView touchesEnded:touches withEvent: event];
        [self setNeedsDisplay];
    }
}





@end
