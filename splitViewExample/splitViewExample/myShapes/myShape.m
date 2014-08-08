//
//  myShape.m
//  DrawingApp
//
//  Created by Lion User on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//  Class to describe the shapes I use

#import "myShape.h"
#import "ECS189VectorMath.h"

@interface myShape() {
    
}
-(bool)pointOnLine:(CGPoint) point;
-(bool)pointContainedInCircle:(CGPoint) point;
@end

@implementation myShape
@synthesize startPoint = _startPoint;
@synthesize endPoint = _endPoint;
@synthesize color = _color;
@synthesize selected = _selected;
@synthesize lineWidth = _lineWidth;
@synthesize isDashed = _isDashed;
@synthesize shape = _shape;
@synthesize noteLabel = _noteLabel;
@synthesize noteSPUserResizableView=_noteSPUserResizableView;
@synthesize shape_no=_shape_no;
@synthesize pencilBezierPath=_pencilBezierPath;


#pragma mark - Init codes
-(id)init {
    self = [super init];
    if(self) {
        _selected = false;
        _shape_no=0;
    }
    return self;
}


-(id)initCopy:(myShape *)input {
    self = [[myShape alloc] init];
    
    if(self) {
        _startPoint.x = input.startPoint.x;
        _startPoint.y = input.startPoint.y;
        _endPoint.x = input.endPoint.x;
        _endPoint.y = input.endPoint.y;
        _color = input.color;
        _selected = input.selected;
        _lineWidth = input.lineWidth;
        _shape = input.shape;
        _isDashed = input.isDashed;
        _noteLabel=input.noteLabel;
        _noteSPUserResizableView=input.noteSPUserResizableView;
        _shape_no=input.shape_no;
        _pencilBezierPath=input.pencilBezierPath;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    myShape *c = [[myShape alloc] initCopy:self];
    return c;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [[myShape alloc] init];
    if(self) {
        _startPoint = [aDecoder decodeCGPointForKey:@"startPoint"];
        _endPoint = [aDecoder decodeCGPointForKey:@"endPoint"];
        _color = [aDecoder decodeObjectForKey:@"color"];
        _selected = [aDecoder decodeBoolForKey:@"selected"];
        _isDashed = [aDecoder decodeBoolForKey:@"isDashed"];
        _lineWidth = [aDecoder decodeIntForKey:@"lineWidth"];
        _shape = [aDecoder decodeIntForKey:@"shape"];
        _noteLabel = [aDecoder decodeObjectForKey:@"noteLabel"];
        _noteSPUserResizableView = [aDecoder decodeObjectForKey:@"noteSPUserResizableView"];
        _shape_no = [aDecoder decodeIntForKey:@"shape_no"];
         _pencilBezierPath = [aDecoder decodeObjectForKey:@"pencilBezierPath"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeCGPoint:_startPoint forKey:@"startPoint"];
    [aCoder encodeCGPoint:_endPoint forKey:@"endPoint"];
    [aCoder encodeObject:_color  forKey:@"color"];
    [aCoder encodeBool:_selected forKey:@"selected"];
    [aCoder encodeBool:_isDashed forKey:@"isDashed"];
    [aCoder encodeInt:_lineWidth forKey:@"lineWidth"];
    [aCoder encodeInt:_shape forKey:@"shape"];
    [aCoder encodeObject:_noteLabel forKey:@"noteLabel"];
    [aCoder encodeObject:_noteSPUserResizableView forKey:@"noteSPUserResizableView"];
    [aCoder encodeInt:_shape_no forKey:@"shape_no"];
    [aCoder encodeObject:(id)_pencilBezierPath forKey:@"pencilBezierPath"];
}

#pragma mark - Select Shapes

-(bool)pointContainedInShape:(CGPoint) point {
    if(_shape == 0) {    // Line
        return [self pointOnLine:point];
    }
    else if(_shape == 1) {   // Rectangle
        CGRect rectangle = CGRectMake(_startPoint.x,
                                      _startPoint.y,
                                      abs(_endPoint.x - _startPoint.x),
                                      abs(_endPoint.y - _startPoint.y));
        
        if((_endPoint.x - _startPoint.x)<0)
            rectangle.origin.x=_startPoint.x-abs(_endPoint.x-_startPoint.x);
        if((_endPoint.y - _startPoint.y)<0)
            rectangle.origin.y=_startPoint.y-abs(_endPoint.y-_startPoint.y);
        
        
        return CGRectContainsPoint(rectangle, point);
    }
    else if(_shape == 2) {   // Circle
        return [self pointContainedInCircle:point];
    }
    
    else if(_shape == 3) {   // Pencil
        //NSLog(@"_pencilBezierPath.CGpath=%@",_pencilBezierPath.CGPath);
        return [self pointOnPencilLine:_pencilBezierPath withPoint:point];
    }

    else {
        //NSLog(@"Error! Shouldn't be here!");
        return false;
    }
}

-(bool)pointContainedInShapeCorner:(CGPoint) point inRectangle:(CGRect)selectedRectangle {
    if(_shape == 0) {    // Line
        return [self pointOnLineCorner:point];
    }
    
    else if(_shape == 1) {   // Rectangle
        CGRect rectangle = CGRectMake(_startPoint.x,
                                      _startPoint.y,
                                      abs(_endPoint.x - _startPoint.x),
                                      abs(_endPoint.y - _startPoint.y));
        
        
        if((_endPoint.x - _startPoint.x)<0)
            rectangle.origin.x=_startPoint.x-abs(_endPoint.x-_startPoint.x);
        if((_endPoint.y - _startPoint.y)<0)
            rectangle.origin.y=_startPoint.y-abs(_endPoint.y-_startPoint.y);
        
        
        selectedRectangle=CGRectMake(selectedRectangle.origin.x-20, selectedRectangle.origin.y-20, selectedRectangle.size.width+40, selectedRectangle.size.height+40);
        if(CGRectContainsPoint(selectedRectangle, point) && !CGRectContainsPoint(rectangle, point)){
        
            return true;
        }
        else
            return false;
        
        
    }
    else if(_shape == 2) {   // Circle
        selectedRectangle=CGRectMake(selectedRectangle.origin.x-20, selectedRectangle.origin.y-20, selectedRectangle.size.width+40, selectedRectangle.size.height+40);
        if( CGRectContainsPoint(selectedRectangle, point) && ![self pointContainedInCircle:point]){
            return true;
        }
        
        else
            return false;
        
    }
    
    
    
    else {
        //NSLog(@"Error! Shouldn't be here!");
        return false;
    }
}


-(bool)pointOnLine:(CGPoint) point {
    
    //float d=distanceFromPointToLineSegment(_startPoint, _endPoint, point);
    //NSLog(@"d=%f",d);
    return distanceFromPointToLineSegment(_startPoint, _endPoint, point) < 13.0f;
}


-(bool)pointOnPencilLine:(UIBezierPath*)pencilPath withPoint:(CGPoint) point {
    
    //float d=distanceFromPointToLineSegment(_startPoint, _endPoint, point);
    //NSLog(@"d=%f",d);
    return distanceFromPointToPencilLineSegment(pencilPath, point) < 13.0f;
}

-(bool)pointOnLineCorner:(CGPoint) point {
    
    float d=distanceFromPointToLineSegment(_startPoint, _endPoint, point);
    CGRect rectCorner=CGRectMake(_endPoint.x-10.00f, _endPoint.y-50.00f, 80.00f, 80.00f);
    return (CGRectContainsPoint(rectCorner, point) && d<13.0f);
    
}

-(bool)pointContainedInCircle:(CGPoint) point {
    float r0, r, dx0, dy0, dx, dy;
    dx0 = _endPoint.x - _startPoint.x;
    dy0 = _endPoint.y - _startPoint.y;
    dx = point.x - _startPoint.x;
    dy = point.y - _startPoint.y;
    
    r0 = sqrtf(dx0*dx0 + dy0*dy0);  // Radius of our shape
    r = sqrtf(dx*dx + dy*dy);   // Radius of touch to center
    
    r0 = r0 < 0.0f ? (r0 * -1.0f) : r0;
    r = r < 0.0f ? (r * -1.0f) : r;
    
    if(r <= r0)
        return true;
    else
        return false;
}


@end
