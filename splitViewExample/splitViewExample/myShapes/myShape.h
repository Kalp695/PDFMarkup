//
//  myShape.h
//  DrawingApp
//
//  Created by Lion User on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPUserResizableView.h"

@interface myShape : NSObject <NSCoding, NSCopying>
-(id)init;
-(id)initCopy:(myShape *)input;

-(bool)pointContainedInShape:(CGPoint) point;
-(bool)pointOnLineCorner:(CGPoint) point;
-(bool)pointContainedInShapeCorner:(CGPoint) point inRectangle:(CGRect)selectedRectangle;

@property CGPoint startPoint;
@property CGPoint endPoint;
@property UIColor *color;
@property UILabel *noteLabel;
@property UIBezierPath *pencilBezierPath;
@property SPUserResizableView *noteSPUserResizableView;
@property int shape;
@property bool selected;
@property bool isDashed;
@property int lineWidth;
@property int shape_no;
@end
