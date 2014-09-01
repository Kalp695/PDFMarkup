//----------
//
//				BRRequestDelete.m
//
// filename:	BRRequestDelete.m
//
// author:		Created by Valentin Radu on 8/23/11.
//              Copyright 2011 Valentin Radu. All rights reserved.
//
//              Modified and/or redesigned by Lloyd Sargent to be ARC compliant.
//              Copyright 2012 Lloyd Sargent. All rights reserved.
//
// created:		Jul 04, 2012
//
// description:	
//
// notes:		none
//
// revisions:	
//
// license:     Permission is hereby granted, free of charge, to any person obtaining a copy
//              of this software and associated documentation files (the "Software"), to deal
//              in the Software without restriction, including without limitation the rights
//              to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//              copies of the Software, and to permit persons to whom the Software is
//              furnished to do so, subject to the following conditions:
//
//              The above copyright notice and this permission notice shall be included in
//              all copies or substantial portions of the Software.
//
//              THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//              IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//              FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//              AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//              LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//              OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//              THE SOFTWARE.
//



//---------- pragmas



//---------- include files
#import "BRRequestLogin.h"



//---------- enumerated data types



//---------- typedefs



//---------- definitions



//---------- structs



//---------- external functions



//---------- external variables



//---------- global functions



//---------- local functions



//---------- global variables



//---------- local variables



//---------- protocols



//---------- classes

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@implementation BRRequestLogin




- (void)start
{
    [self.streamInfo openRead: self];
}
- (void) stream: (NSStream *) theStream handleEvent: (NSStreamEvent) streamEvent
{
    NSData *data;
    
    switch (streamEvent)
    {
        case NSStreamEventOpenCompleted:
        {
			self.filesInfo = [NSMutableArray array];
            self.didOpenStream = YES;
            self.receivedData = [NSMutableData data];
        } break;
            
        case NSStreamEventHasBytesAvailable:
        {
            data = [self.streamInfo read: self];
            
            if (data)
            {
                [self.receivedData appendData: data];
            }
            
            else
            {
                InfoLog(@"Stream opened, but failed while trying to read from it.");
                [self.streamInfo streamError: self errorCode: kBRFTPClientCantReadStream];
            }
        }
            break;
            
        case NSStreamEventHasSpaceAvailable:
        {
            
        }
            break;
            
        case NSStreamEventErrorOccurred:
        {
            [self.streamInfo streamError: self errorCode: [BRRequestError errorCodeWithError: [theStream streamError]]];
            InfoLog(@"%@", self.error.message);
        }
            break;
            
            
        case NSStreamEventEndEncountered:
        {
            NSUInteger  offset = 0;
            CFIndex     parsedBytes;
            uint8_t *bytes = (uint8_t *)[self.receivedData bytes];
            int totalbytes = [self.receivedData length];
            
            //----- we have all the data for the directory listing. Now parse it.
            do
            {
                CFDictionaryRef listingEntity = NULL;
                
                parsedBytes = CFFTPCreateParsedResourceListing(NULL, &bytes[offset], totalbytes - offset, &listingEntity);
                
                if (parsedBytes > 0)
                {
                    if (listingEntity != NULL)
                    {
                        if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
                        {
                            //----- July 10, 2012: CFFTPCreateParsedResourceListing had a bug that had the date over retained
                            //----- in order to fix this, we release it once. However, just as a precaution, we check to see what
                            //----- the retain count might be (this isn't guaranteed to work).
                            id date = [(__bridge NSDictionary *) listingEntity objectForKey: (id) kCFFTPResourceModDate];
                            if (CFGetRetainCount((__bridge CFTypeRef) date) >= 2)
                                CFRelease((__bridge CFTypeRef) date);
                        }
                        //----- transfer the directory into an ARC maintained array
                        self.filesInfo = [self.filesInfo arrayByAddingObject: (__bridge_transfer NSDictionary *) listingEntity];
                    }
                    offset += parsedBytes;
                }
                
            } while (parsedBytes > 0);
            
            [self.streamInfo streamComplete: self];                             // perform callbacks and close out streams
        }
            break;
            
        default:
            break;
    }
}

@end
