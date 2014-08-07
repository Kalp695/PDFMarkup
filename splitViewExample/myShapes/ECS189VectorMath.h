//
//  ECS189VectorMath.h
//  DrawingApp
//
//  Created by Lion User on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#ifndef DrawingApp_ECS189VectorMath_h
#define DrawingApp_ECS189VectorMath_h

CGPoint subtractVector(CGPoint, CGPoint);
CGPoint addVector(CGPoint, CGPoint);
CGPoint multiplyVectorByScalar(CGPoint, float);
float distanceBetweenTwoPoints(CGPoint, CGPoint);
float dotProductOfTwoPoints(CGPoint, CGPoint);
float lengthSquared(CGPoint, CGPoint);
float distanceFromPointToLineSegment(CGPoint, CGPoint, CGPoint);


// Algebraic manupulations between two points
CGPoint subtractVector(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

CGPoint addVector(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

CGPoint multiplyVectorByScalar(CGPoint a, float f) {
    return CGPointMake(f * a.x, f* a.y);
}

// Calculates distance between two points
float distanceBetweenTwoPoints(CGPoint a, CGPoint b) {
    float dx = b.x - a.x;
    float dy = b.y - a.y;
    
    return sqrtf(dx * dx + dy * dy);
}

// calculates the dot prodoct between two vectors, represented by CGPoints
float dotProductOfTwoPoints(CGPoint a, CGPoint b) {
    return a.x * b.x + a.y * b.y;
}

// Something...
float lengthSquared(CGPoint a, CGPoint b) {
    return distanceBetweenTwoPoints(a, b) * distanceBetweenTwoPoints(a, b);
}

// calculates the point to line segment distance
float distanceFromPointToLineSegment(CGPoint a, CGPoint b, CGPoint p) {
    float l2 = lengthSquared(a, b);
    
    if(l2 == 0.0f)
        return distanceBetweenTwoPoints(p, a);
    
    float t = dotProductOfTwoPoints(subtractVector(p, a), subtractVector(b, a)) / l2;
    
    if(t < 0.0f)
        return distanceBetweenTwoPoints(p, a);
    else if(t > 1.0f)
        return distanceBetweenTwoPoints(p, b);
        
    CGPoint projection = addVector(a, multiplyVectorByScalar(subtractVector(b, a), t));
    
    return distanceBetweenTwoPoints(p, projection);
}


void getPointsFromBezier(void *info, const CGPathElement *element)
{
    NSMutableArray *bezierPoints = (__bridge NSMutableArray *)info;
    CGPathElementType type = element->type;
    CGPoint *points = element->points;
    if (type != kCGPathElementCloseSubpath)
    {
        if ((type == kCGPathElementAddLineToPoint) ||
            (type == kCGPathElementMoveToPoint))
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[0]]];
        else if (type == kCGPathElementAddQuadCurveToPoint)
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[1]]];
        else if (type == kCGPathElementAddCurveToPoint){
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[0]]];
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[1]]];
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[2]]];
        }
       
        
    }
}


// calculates the point to line segment distance
float distanceFromPointToPencilLineSegment(UIBezierPath *pencilPath, CGPoint p) {
   
    NSMutableArray *points = [NSMutableArray array];
    CGPathApply(pencilPath.CGPath, (__bridge void *)points, getPointsFromBezier);
    float d=1000.0f;
    for (int i = 1; i < points.count; i++){
        NSValue *val = ((NSValue*) points[i]);
        d=distanceBetweenTwoPoints([val CGPointValue], p);
        if(d<13.0f)
            break;
    }
    
    return d;
}


#endif
