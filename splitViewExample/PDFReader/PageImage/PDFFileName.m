//
//  PDFFileName.m
//  PDFMarkUP
//
//  Created by CFA IT on 8/14/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import "PDFFileName.h"

@implementation PDFFileName

@synthesize name=_name;
@synthesize page=_page;
#pragma mark - Init codes
-(id)init {
    self = [super init];
    if(self) {
        
        
    }
    return self;
}


-(id)initCopy:(PDFFileName *)input {
    self = [[PDFFileName alloc] init];
    
    if(self) {
        _name=input.name;
        _page=input.page;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    PDFFileName *c = [[PDFFileName alloc] initCopy:self];
    return c;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [[PDFFileName alloc] init];
    if(self) {
        _name= [aDecoder decodeObjectForKey:@"name"];
        _page=[aDecoder decodeObjectForKey:@"page"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_page forKey:@"page"];
}

@end




/**************************** PDF Page ******************************/



@implementation PDFPage

@synthesize image=_image;
@synthesize frame=_frame;
@synthesize image_no=_image_no;
#pragma mark - Init codes
-(id)init {
    self = [super init];
    if(self) {
        
        
    }
    return self;
}


-(id)initCopy:(PDFPage *)input {
    self = [[PDFPage alloc] init];
    
    if(self) {
        _image=input.image;
        _frame=input.frame;
        _image_no=input.image_no;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    PDFPage *c = [[PDFPage alloc] initCopy:self];
    return c;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [[PDFPage alloc] init];
    if(self) {
        _image= [aDecoder decodeObjectForKey:@"image"];
        _image_no= [aDecoder decodeIntForKey:@"image_no"];
        NSValue *frameValue=[aDecoder decodeObjectForKey:@"frame"] ;
        _frame=[frameValue CGRectValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt:_image_no forKey:@"image_no"];
    [aCoder encodeObject:_image forKey:@"image"];
    [aCoder encodeObject:[NSValue valueWithCGRect:_frame] forKey:@"frame"];
}

@end

/***************************PDF Page End ******************************/

