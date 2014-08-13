//
//	ReaderViewController.m
//	Reader v2.7.2
//
//	Created by Julius Oklamcak on 2011-07-01.
//	Copyright © 2011-2013 Julius Oklamcak. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//	of the Software, and to permit persons to whom the Software is furnished to
//	do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "ReaderConstants.h"
#import "ReaderViewController.h"
#import "ReaderContentView.h"
#import <MessageUI/MessageUI.h>
#import "DropboxDownloadFileViewControlller.h"
#import <DropboxSDK/DropboxSDK.h>
#import "DocumentChooseViewController.h"
#import "DetailViewController.h"
#import "DropboxManager.h"
#import "PDFRenderer.h"


static ReaderViewController *sharedInstance = nil;

@interface ReaderViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate,ReaderContentViewDelegate,ThumbsViewControllerDelegate>
@end

@implementation ReaderViewController
{
	ReaderDocument *document;

	UIScrollView *theScrollView;

	NSMutableDictionary *contentViews;

	UIPrintInteractionController *printInteraction;

	NSInteger currentPage;

	CGSize lastAppearSize;

	NSDate *lastHideTime;

	BOOL isVisible;
    
    /**********************NEW CODE***********************/

    
    UITableView *popDisplayTableView;

}
+(ReaderViewController*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        
    }
    return sharedInstance;
}

@synthesize pdfFilePath=_pdfFilePath,savedFolderPath,pdfName;

#pragma mark Constants

#define PAGING_VIEWS 4

#define STATUS_HEIGHT 20.0f

#define TOOLBAR_HEIGHT 44.0f
#define PAGEBAR_HEIGHT 48.0f

#define TAP_AREA_SIZE 48.0f

#pragma mark Properties

@synthesize delegate;

#pragma mark Support methods

- (void)updateScrollViewContentSize
{
	NSInteger count = [document.pageCount integerValue];


	CGFloat contentHeight = theScrollView.bounds.size.height;

	CGFloat contentWidth = (theScrollView.bounds.size.width * count);

	theScrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
}

- (void)updateScrollViewContentViews
{
	[self updateScrollViewContentSize]; // Update the content size

	NSMutableIndexSet *pageSet = [NSMutableIndexSet indexSet]; // Page set

	[contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
		^(id key, id object, BOOL *stop)
		{
			ReaderContentView *contentView = object; [pageSet addIndex:contentView.tag];
		}
	];

	__block CGRect viewRect = CGRectZero; viewRect.size = theScrollView.bounds.size;

	__block CGPoint contentOffset = CGPointZero; NSInteger page = [document.pageNumber integerValue];

	[pageSet enumerateIndexesUsingBlock: // Enumerate page number set
		^(NSUInteger number, BOOL *stop)
		{
			NSNumber *key = [NSNumber numberWithInteger:number]; // # key

			ReaderContentView *contentView = [contentViews objectForKey:key];

			contentView.frame = viewRect; if (page == number) contentOffset = viewRect.origin;

			viewRect.origin.x += viewRect.size.width; // Next view frame position
		}
	];

	if (CGPointEqualToPoint(theScrollView.contentOffset, contentOffset) == false)
	{
		theScrollView.contentOffset = contentOffset; // Update content offset
	}
}

- (void)updateToolbarBookmarkIcon
{
	

	

	
}



- (void)showDocumentPageNew:(NSInteger)page{
    if (page != currentPage) // Only if different
    {
        
        //Load data to array _collection
        
        [_collection removeAllObjects];
        _collection=nil;
        NSString *fileName=[commonFunction getFileNameFromPath:_pdfFilePath];
        _collection= [commonFunction loadDataFromDiskWithFilename:[NSString stringWithFormat:@"%@_%d",fileName,page]];
        
        
        NSInteger maxValue = [document.pageCount integerValue];
        NSInteger minValue = 1;
        
        
        NSMutableIndexSet *newPageSet = [NSMutableIndexSet new];
        
        CGRect viewRect = CGRectZero; viewRect.size = theScrollView.bounds.size;
        
    
        for (NSInteger number = minValue; number <= maxValue; number++)
        {
            NSNumber *key = [NSNumber numberWithInteger:number]; // # key
            
            ReaderContentView *contentView = [contentViews objectForKey:key];
            
            if (contentView == nil) // Create a brand new document content view
            {
                NSURL *fileURL = document.fileURL; NSString *phrase = document.password; // Document properties
                
                contentView = [[ReaderContentView alloc] initWithFrame:viewRect fileURL:fileURL page:number password:phrase];
                contentView.tag=number;
                
                
                [theScrollView addSubview:contentView]; [contentViews setObject:contentView forKey:key];
                
                contentView.message = (id)self; [newPageSet addIndex:number];
                
                //Loading shapes
                
                for(UIView *view in [contentView subviews]){
                    if([view isKindOfClass:[UIView class]] && ![view isKindOfClass:[SPUserResizableView class]]){
                        _drawingPad=view;
                    }
                    
                }
                
                
                [_collection removeAllObjects];
                _collection=nil;
                
                NSString *strFileName=[commonFunction getFileNameFromPath:_pdfFilePath];
                _collection= [commonFunction loadDataFromDiskWithFilename:[NSString stringWithFormat:@"%@_%d",strFileName, number]];
                
                int j=0;
                for(myShape *i in _collection){
                    [self drawShapesSubroutine:i inLayerName:@"Shape"];
                    if(i.shape==-2 || i.shape==-1 || i.shape==0)
                        [self addAllLabelsWithBoundingBox:i withDrawingPadView:[contentViews objectForKey:key]];
                    
                    j++;
                }
                if(number==maxValue){
                    [_collection removeAllObjects];
                    _collection=nil;
                    
                    NSString *strFileName=[commonFunction getFileNameFromPath:_pdfFilePath];
                    _collection= [commonFunction loadDataFromDiskWithFilename:[NSString stringWithFormat:@"%@_1",strFileName]];
                    
                }
                
                //end Loading shapes
                
                
                
            }
            else // Reposition the existing content view
            {
                
                contentView.frame = viewRect; [contentView zoomReset];
                
                //[unusedViews removeObjectForKey:key];
            }
            
            viewRect.origin.x += viewRect.size.width;
            
            //NSLog(@"theScrollView.bounds=%@",theScrollView.bounds);
        }
        
        
        if ([document.pageNumber integerValue] != page) // Only if different
        {
            document.pageNumber = [NSNumber numberWithInteger:page]; // Update page number
        }
        
        NSURL *fileURL = document.fileURL; NSString *phrase = document.password; NSString *guid = document.guid;
        
        
        
        if ([newPageSet containsIndex:page] == YES) // Preview visible page first
        {
            NSNumber *key = [NSNumber numberWithInteger:2]; // # key
            
            ReaderContentView *targetView = [contentViews objectForKey:key];
            
            [targetView showPageThumb:fileURL page:page password:phrase guid:guid];
            
            [newPageSet removeIndex:page]; // Remove visible page from set
        }
        
        [newPageSet enumerateIndexesWithOptions:NSEnumerationReverse usingBlock: // Show previews
         ^(NSUInteger number, BOOL *stop)
         {
             NSNumber *key = [NSNumber numberWithInteger:number]; // # key
             
             ReaderContentView *targetView = [contentViews objectForKey:key];
             
             [targetView showPageThumb:fileURL page:number password:phrase guid:guid];
         }
         ];
        
        
        newPageSet = nil; // Release new page set
        
        
        currentPage = page; // Track current page number
        
        
    }
    
}

- (void)showDocument:(id)object
{
    [self updateScrollViewContentSize]; // Set content size
    
    [self showDocumentPageNew:[document.pageNumber integerValue]];
    
    document.lastOpen = [NSDate date]; // Update last opened date
    
    isVisible = YES; // iOS present modal bodge
}

#pragma mark UIViewController methods

- (id)initWithReaderDocument:(ReaderDocument *)object
{
    id reader = nil; // ReaderViewController object
    
    if ((object != nil) && ([object isKindOfClass:[ReaderDocument class]]))
    {
        if ((self = [super initWithNibName:nil bundle:nil])) // Designated initializer
        {
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            
            [notificationCenter addObserver:self selector:@selector(applicationWill:) name:UIApplicationWillTerminateNotification object:nil];
            
            [notificationCenter addObserver:self selector:@selector(applicationWill:) name:UIApplicationWillResignActiveNotification object:nil];
            
            [object updateProperties]; document = object; // Retain the supplied ReaderDocument object for our use
            
            
            
            reader = self; // Return an initialized ReaderViewController object
        }
    }
    
    return reader;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveExportNotification:) name:@"UploadDocFolder" object:nil];
    
    
    /*********************Drawing Shape initialization setup*************************/
    
    _currentShape = [[myShape alloc] init];
    ///_currentShape.pencilBezierPath=[UIBezierPath bezierPath];
    _currentColor = 0;
    if(_collection == nil && _undo_collection==nil) {
        _collection = [[NSMutableArray alloc] init];
        _undo_collection = [[NSMutableArray alloc] init];
    }
    else{
        [_collection removeAllObjects];
        [_undo_collection removeAllObjects];
    }
    
    _currentShapeType=0;
    _currentLineWidth=1;
    shape_no=1;
    _currentColor=[UIColor blackColor];
    skipDrawingCurrentShape = FALSE;
    currentSaved = FALSE;
    selectedIndex = -1;
    savedShapeStartpoint = CGPointMake(0, 0);
    savedShapeEndpoint = CGPointMake(0, 0);
    selectedShapeStartpoint = CGPointMake(0, 0);
    selectedShapeEndpoint = CGPointMake(0, 0);
    rectangle=CGRectZero;
    
    /***************************End*************************************************/
    commonFunction=[[CommonFunction alloc]init];
    
    NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
    
    //NSArray *pdfs = [[NSBundle mainBundle] pathsForResourcesOfType:@"pdf" inDirectory:nil];
    
    //NSString *filePath = [pdfs lastObject]; assert(filePath != nil); // Path to last PDF file
    
    NSString *filePath=_pdfFilePath;
    
    folderPath = [commonFunction getFolderPathFromFullPath:filePath];
    [commonFunction setFolderPath:folderPath];
    document = [ReaderDocument withDocumentFilePath:filePath password:phrase];
    
    if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
    {
        
        
        assert(document != nil); // Must have a valid ReaderDocument
        
        self.view.backgroundColor = [UIColor grayColor]; // Neutral gray
        
        CGRect scrollViewRect = self.view.bounds; UIView *fakeStatusBar = nil;
        
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) // iOS 7+
        {
            if ([self prefersStatusBarHidden] == NO) // Visible status bar
            {
                CGRect statusBarRect = self.view.bounds; // Status bar frame
                statusBarRect.size.height = STATUS_HEIGHT; // Default status height
                fakeStatusBar = [[UIView alloc] initWithFrame:statusBarRect]; // UIView
                fakeStatusBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                fakeStatusBar.backgroundColor = [UIColor blackColor];
                fakeStatusBar.contentMode = UIViewContentModeRedraw;
                fakeStatusBar.userInteractionEnabled = NO;
                
                scrollViewRect.origin.y += STATUS_HEIGHT; scrollViewRect.size.height -= STATUS_HEIGHT;
            }
        }
        
        theScrollView = [[UIScrollView alloc] initWithFrame:scrollViewRect]; // UIScrollView
        theScrollView.autoresizesSubviews = NO; theScrollView.contentMode = UIViewContentModeRedraw;
        theScrollView.showsHorizontalScrollIndicator = NO; theScrollView.showsVerticalScrollIndicator = NO;
        theScrollView.scrollsToTop = NO; theScrollView.delaysContentTouches = NO; theScrollView.pagingEnabled = YES;
        theScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        theScrollView.backgroundColor = [UIColor clearColor]; theScrollView.delegate = self;
        [self.view addSubview:theScrollView];
        [self.view bringSubviewToFront:toolBar];
    }
    
    contentViews = [NSMutableDictionary new]; lastHideTime = [NSDate date];
    
    [self createNavigationBarItems];
    [self removeDeleteButton];
    toolBar.hidden=YES;
    
    
    
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(10.0f, CGRectGetHeight(buttonline.frame)-5.0f)];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(buttonline.frame)-14.0f, 2.0f)];
    
    //2. Create a shape layer for above created path.
    buttonLineLayer = [[CAShapeLayer alloc] initWithLayer:buttonline.layer];
    buttonLineLayer.strokeColor = RGBCOLOR(32, 122, 252).CGColor;;
    buttonLineLayer.lineWidth = 1.5f;
    //NSLog("shapeToBeDrawn.color=%@", myLayer);
    
    buttonLineLayer.fillColor = nil;
    //myLayer.lineJoin = kCALineJoinBevel;
    buttonLineLayer.path = path.CGPath;
    
    [buttonline.layer addSublayer:buttonLineLayer];
    
    
    
    // Pop Over
    // New Code For pop Over List .
    
    
    popOverListArray = [[NSMutableArray alloc ]initWithObjects:@"DropBox",@"Box",@"Sugar Sync",@"FTP",@"Google Drive", nil];
    
    
    
}


-(void)createNavigationBarItems{
    // create three funky nav bar buttons
    
    editDoneBarButton = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editDoneBarButton_click:)];
    
    UIButton *thumbsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    thumbsButton.tag=102;
    thumbsButton.frame = CGRectMake(0, 0, 40, 40);
    [thumbsButton setImage:[UIImage imageNamed:@"icon_details@4x.png"] forState:UIControlStateNormal];
    [thumbsButton addTarget:self action:@selector(thumbNailDetails_click:) forControlEvents:UIControlEventTouchUpInside];
    thumbsButton.autoresizingMask = UIViewAutoresizingNone;
    thumbsButton.exclusiveTouch = YES;

    
    UIBarButtonItem *thumNailDetails = [[UIBarButtonItem alloc]initWithCustomView:thumbsButton];
    UIBarButtonItem *closeBarButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closeButton_click:)];
    UIBarButtonItem *exportBarButton = [[UIBarButtonItem alloc]initWithTitle:@"Export" style:UIBarButtonItemStylePlain target:self action:@selector(exportBarButton_click:)];
    
    
    // create a spacer
    UIBarButtonItem *space = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    space.width = 30;
   
    
    self.navigationItem.leftBarButtonItems = @[space, editDoneBarButton,space,thumNailDetails];
    self.navigationItem.rightBarButtonItems = @[closeBarButton,space,exportBarButton];
    
    
}

-(IBAction)thumbNailDetails_click:(id)sender{
    
    if (printInteraction != nil) [printInteraction dismissAnimated:NO]; // Dismiss
    
	ThumbsViewController *thumbsViewController = [[ThumbsViewController alloc] initWithReaderDocument:document];
    
    [thumbsViewController setFilePath:_pdfFilePath];
    
	thumbsViewController.delegate = self; thumbsViewController.title = self.title;
    
    UINavigationController *navController1 = [[UINavigationController alloc] initWithRootViewController:thumbsViewController];
    
    [self presentViewController:navController1 animated:YES completion:nil];

}


#pragma mark ThumbsViewControllerDelegate methods

- (void)dismissThumbsViewController:(ThumbsViewController *)viewController withDocument:(ReaderDocument *)readerDocument
{
	[self updateToolbarBookmarkIcon]; // Update bookmark icon
    
    document=readerDocument;
    currentPage=0;
    
    
    
     for(UIView *view in [theScrollView subviews])
     {
     [view removeFromSuperview];
     }
     [contentViews removeAllObjects];
    
    //[self updateScrollViewContentViews];
    
    [self performSelector:@selector(showDocument:) withObject:nil afterDelay:0.02];
    
    //[theScrollView setContentOffset:pt animated:YES];
    
    
    
    
	[self dismissViewControllerAnimated:YES completion:nil]; // Dismiss
}

- (void)thumbsViewController:(ThumbsViewController *)viewController gotoPage:(NSInteger)page withDocument:(ReaderDocument *)readerDocument
{
	
    theScrollView.contentOffset=CGPointMake(CGRectGetWidth(theScrollView.frame)*(page-1), theScrollView.contentOffset.y);
    [self showDocumentPageNew:page]; // Show the page
    
    //[viewController dismissViewControllerAnimated:YES completion:nil]; // Dismiss
}


-(IBAction)closeButton_click:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
-(IBAction)cameraBarButton_click:(id)sender{
    
    
   UIActionSheet * optionMenu = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil  destructiveButtonTitle:@"Take Photo" otherButtonTitles:@"Choose Existing", nil];
    [optionMenu showFromBarButtonItem:sender animated:YES];
 
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
    //UIView *navButton=(UIView*)actionSheet.superview;
	if (buttonIndex == 0) {
        
        // Create a bool variable "camera" and call isSourceTypeAvailable to see if camera exists on device
        BOOL camera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
        
        imagePicker =
        [[UIImagePickerController alloc] init];
        
        // If there is a camera, then display the world throught the viewfinder
        if(camera)
        {
            // Since I'm not actually taking a picture, is a delegate function necessary?
            imagePicker.delegate = self;
            
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            [self presentViewController:imagePicker animated:YES completion:nil];
            
            //NSLog(@"Camera is available");
        }
        
        // Otherwise, do nothing.
        else{
            //NSLog(@"No camera available");
        }
        
    }
    
    else if (buttonIndex == 1) {
        
        imagePicker =
        [[UIImagePickerController alloc] init];
        
        imagePicker.delegate = self;
        
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypePhotoLibrary;
        
        imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                  (NSString *) kUTTypeImage,
                                  (NSString *) kUTTypeMovie, nil];
        
        
        
        if(popoverController!=nil)
            [popoverController dismissPopoverAnimated:YES];
        
        popoverController = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        popoverController.delegate = self;
        
        [popoverController presentPopoverFromRect:actionSheet.frame inView:actionSheet permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        
        
    }
    
}


-(IBAction)imagePickerCancelPressed:(id)sender{
    [self clearPopupView];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo {
    
    
    
    if(imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera){
    
    }
    
    //saveImage = [[UIAlertView alloc] initWithTitle:@"Loading..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    
    
    NSData *dataForJPEGFile = [NSData dataWithData:UIImageJPEGRepresentation(img, 0.0001)];
    cameraImage=[UIImage imageWithData:dataForJPEGFile];
    
    [self loadPhotoToCrop:cameraImage inImage_no:-1];
    
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    
}




//load photo to crop
-(void)loadPhotoToCrop:(UIImage*)originalImage inImage_no:(int)image_no{
    //crop photo
    
    
    cameraImage=originalImage;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboardCrop_iPad" bundle:nil];
    
    BFViewController *bfviewController = [storyboard instantiateViewControllerWithIdentifier:@"BFViewController"];
    UINavigationController *bfNavController=[[UINavigationController alloc]initWithRootViewController:bfviewController];
    [bfviewController setOriginalImage:originalImage];
    [bfviewController setUseImage:originalImage];
    xCrop= 150;
    yCrop=150, widthCrop=520, heightCrop=600;
    
    bfviewController.view.frame=CGRectMake(xCrop, yCrop, widthCrop, heightCrop);
    bfviewController.delegate=self;
    popoverControllerCrop = [[UIPopoverController alloc]initWithContentViewController:bfNavController];
    
    [self CropViewPopOverDisplay];
    
    //end photo crop
    
    
}
//end load photo to crop



//crop window

-(void)CropViewPopOverDisplay

{
    if(TOCheckLoginViewAppearance==0)
	{
        [popoverControllerCrop setDelegate:self];
        [popoverControllerCrop setPopoverContentSize:CGSizeMake(widthCrop, heightCrop) animated:YES];
        
        [popoverControllerCrop presentPopoverFromRect:CGRectMake(xCrop, yCrop, widthCrop, heightCrop) inView:[[UIApplication sharedApplication] keyWindow] permittedArrowDirections:0  animated:YES];
        
        /*
         if([loginBarButtonItem.title isEqualToString:@"Logout"]){
         
         [loginBarButtonItem setTitle:@"Login"];
         
         
         }
         */
    }
    
}


-(void)CropViewPopOverHide
{
    
    [popoverControllerCrop dismissPopoverAnimated:YES];
    
    
    
}


//end crop window

-(SPUserResizableView *)getResizableImage:(UIImage*)smallImage withFrame:(CGRect)imageFrame{
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:smallImage];
    
    imageResizableView = [[SPUserResizableView alloc] initWithFrame:imageFrame];
    imageResizableView.contentView = imageView;
    imageResizableView.contentMode=UIViewContentModeScaleAspectFit;
    
    return imageResizableView;
}



//crop photo delegate
-(void)cropPhoto:(UIImage *)cropImage{
    
    
    
    cameraImage=cropImage;
    
    
    NSString *currentPDFPage=[[[_pdfFilePath stringByDeletingLastPathComponent] stringByDeletingPathExtension] stringByAppendingString:[NSString stringWithFormat:@"_%d",[document.pageNumber integerValue]]];
    [self loadPhoto:[document.pageNumber integerValue] withCurrentPage:currentPDFPage];
    
    //For Condition Report Front page
    
    
    
    
        
        //[_photodelegate photoLoaded:imageResizableView inPageName:currentPage];
    
    
    
    cameraImage=nil;
    [self clearPopupView];
    
    
    [popoverControllerCrop dismissPopoverAnimated:YES];
    
    [NSTimer scheduledTimerWithTimeInterval:0 target:self selector: @selector(didFinishSaving:) userInfo:nil repeats:NO];
    
}




-(IBAction)didFinishSaving:(id)sender{
    

    [popoverController dismissPopoverAnimated:YES];
    
    
    
}

//end crop photo delgate

//crop photo cancel delegate
-(void)cancelCropPhoto{
    [popoverControllerCrop dismissPopoverAnimated:YES];
    popoverControllerCrop=nil;
    [self clearPopupView];
}

//end crop photo delegate


//load Photo

-(void)loadPhoto:(NSInteger)pageIndex withCurrentPage:(NSString*)currentPageName{
    

    NSInteger image_no=1;
    
    
    CGFloat width=  cameraImage.size.width;
    CGFloat height=  cameraImage.size.height;
    
    
    CGRect imageFrame=CGRectNull;
    UIImage *smallImage=nil;
    
        if(abs(width-height)<=50)
            imageFrame = CGRectMake(140, 100, 400, 400);
        else if(width<height)
            imageFrame = CGRectMake(187.5, 100, (width/height)*400>=300?300:(width/height)*400, (height/width)*300>=400?400:(height/width)*300);
        else     if(width>height)
            imageFrame = CGRectMake(125.5, 143,  (width/height)*300>=400?400:(width/height)*300, (height/width)*400>=300?300:(height/width)*400);
    
    
    //saving image

    
    image_no=[commonFunction getNewImageFileNameIndex:_pdfFilePath inPageIndex:pageIndex];
    
    smallImage=[commonFunction writeImageWithPath:_pdfFilePath inImageName:@"" inImageno: image_no inImage:cameraImage inWidth:imageFrame.size.width inHeight:imageFrame.size.height];
    
    
    //saving frame
    imageResizableView=[self getResizableImage:smallImage withFrame:imageFrame];
    imageResizableView.tag=image_no;
    
    NSMutableArray *frameArr=[[NSMutableArray alloc]init];
    CGRect frame=imageResizableView.frame;
    
    
        frame=[commonFunction getimageFrame:image_no inWidth:imageFrame.size.width inHeight:imageFrame.size.height];
    
    
    
    NSData *frameObject;
    frameObject=[NSData dataWithBytes:&(frame) length:sizeof(CGRect)];
    [frameArr addObject:frameObject];
    [commonFunction saveAndGetImageFrame:frameArr inPageName:@"" inAppend:YES inDirectoryPath:_pdfFilePath inImageID:image_no];
    
    imageResizableView.tag=image_no;
}


//end load Photo



- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverCtrl {
    
    
    if(popoverController && popoverControllerCrop==nil){
        [popoverCtrl dismissPopoverAnimated:YES];
        popoverCtrl=nil;
        [self clearPopupView];
        return YES;
    }
    else
        return NO;
    
}






-(IBAction)exportBarButton_click:(id)sender{
 
    DocumentChooseViewController *viewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"DocumentChooseViewController"];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewcontroller];

    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:nav animated:YES completion:nil];
    nav.view.superview.frame = CGRectMake(57,200,500,500);
    
    
    // Previous code for preview ;
    /*
    if(popoverController)
        [popoverController dismissPopoverAnimated:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    navHybridController = [storyboard instantiateViewControllerWithIdentifier:@"NavC_Preview"];
    previewViewController=(PreviewViewController*)[navHybridController.viewControllers objectAtIndex:0];
    [previewViewController setReportID:reportID];
    [previewViewController setPdfFilePath:_pdfFilePath];
    previewViewController.delegate=self;
    popoverController = [[UIPopoverController alloc] initWithContentViewController:navHybridController];
    
    popoverController.delegate=self;
    
    [popoverController setPopoverContentSize:CGSizeMake(700, 900) animated:NO];
    
    [popoverController presentPopoverFromRect:CGRectMake(10.0f, 500.0f, 740, 900) inView:self.view permittedArrowDirections:0  animated:YES];

    */
}
- (void)receiveExportNotification:(NSNotification *) notification
{
    
    //   NSString *filePath=_pdfFilePath;
    //   NSString* theFileName = [NSString stringWithFormat:@"%@.pdf",[[filePath lastPathComponent] stringByDeletingPathExtension]];
    NSString *filePath1=_pdfFilePath;
    //NSString* theFileName1 = [NSString stringWithFormat:@"%@.pdf",[[filePath1 lastPathComponent] stringByDeletingPathExtension]];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath1])
    {
        //NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath1];
        NSString* theFileName = [NSString stringWithFormat:@"%@.pdf",[ReaderViewController getSharedInstance].pdfName];
        
        
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        NSString *filePathh = [documentsPath stringByAppendingPathComponent:[ReaderViewController getSharedInstance].savedFolderPath];
        NSString *appFile = [filePathh stringByAppendingPathComponent:theFileName];
        
        PDFRenderer *pdfRenderer=[[PDFRenderer alloc]init];
        [pdfRenderer drawPDFWithReportID:reportID withPDFFilePath:_pdfFilePath withSavePDFFilePath:appFile];
        
    }
    
    
      //  [[NSFileManager defaultManager] createDirectoryAtPath:appFile withIntermediateDirectories:NO attributes:nil error:&error];
    
    //Add the file name

}
-(void)cancel_click{
    previewViewController.delegate=nil;
    popoverController.delegate=nil;
    [navHybridController.view.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    navHybridController=nil;
    [previewViewController.view.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    previewViewController=nil;
    [self clearPopupView];
    
    
}

-(IBAction)editDoneBarButton_click:(id)sender{
   editDoneBarButton =(UIBarButtonItem*)sender;

   
    NSInteger page = [document.pageNumber integerValue];
    
    NSMutableArray *rightNavIterms;
    if([editDoneBarButton.title isEqualToString:@"Edit"]){
        editDoneBarButton.title=@"Done";
        
        UIBarButtonItem *cameraBarButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraBarButton_click:)];
        
        // create a spacer
        UIBarButtonItem *space = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
        space.width = 30;
        
        rightNavIterms=(NSMutableArray*)[self.navigationItem.rightBarButtonItems mutableCopy];
        [rightNavIterms addObject:space];
        [rightNavIterms addObject:cameraBarButton];
        
        self.navigationItem.rightBarButtonItems=rightNavIterms;
        
        for(UIView *view in [theScrollView subviews]){
            if(view.tag==page && [view isKindOfClass:[ReaderContentView class]]){
               contentPageView = (ReaderContentView*)view;
                break;
            }
        }

        
        
        for(UIView *view in [contentPageView subviews]){
            if([view isKindOfClass:[UIView class]] && ![view isKindOfClass:[SPUserResizableView class]]){
            _drawingPad=view;
            }
            
           
            //NSLog(@"view=%@",_drawingPad);
            /*
            for(UIView *view1 in [view subviews]){
                NSLog(@"view1=%@",view1);
            }
             */
        }
        
        for(UIView *view in [contentPageView subviews]){
            if([view isKindOfClass:[SPUserResizableView class]]){
                SPUserResizableView *sPUserResizableViewNote=(SPUserResizableView*)view;
                [sPUserResizableViewNote hideEditingHandles];
                sPUserResizableViewNote.userInteractionEnabled=YES;
                //[contentPageView addSubview:view];
            }
        }
        
        savedPageContentFrame=contentPageView.frame;
        contentPageView.frame=CGRectMake(0, contentPageView.frame.origin.y, CGRectGetWidth(contentPageView.frame), CGRectGetHeight(contentPageView.frame));
        [self.view addSubview:contentPageView];
        theScrollView.hidden=YES;
        toolBar.hidden=NO;
        
    }
    else{
        
        rightNavIterms=(NSMutableArray*)[self.navigationItem.rightBarButtonItems mutableCopy];
        [rightNavIterms removeLastObject];
        [rightNavIterms removeLastObject];
        
        self.navigationItem.rightBarButtonItems=rightNavIterms;
        
        for(UIView *view in [self.view subviews]){
            if(view.tag==page && [view isKindOfClass:[ReaderContentView class]]){
                contentPageView=(ReaderContentView*)view;
                break;
            }
        }
        
        contentPageView.frame=savedPageContentFrame;
        [theScrollView addSubview:contentPageView];
        theScrollView.hidden=NO;
        editDoneBarButton.title=@"Edit";
        toolBar.hidden=YES;
        [self clearSelectedRectangleWithDotView];
        
        for(UIView *view in [contentPageView subviews]){
            if([view isKindOfClass:[UIView class]] && ![view isKindOfClass:[SPUserResizableView class]]){
                _drawingPad=view;
            }
            
            else if([view isKindOfClass:[SPUserResizableView class]]){
                SPUserResizableView *sPUserResizableViewNote=(SPUserResizableView*)view;
                [sPUserResizableViewNote hideEditingHandles];
                sPUserResizableViewNote.userInteractionEnabled=NO;
                
                //sPUserResizableViewNote.frame=[contentPageView convertRect:sPUserResizableViewNote.frame toView:_drawingPad];
                //[_drawingPad addSubview:sPUserResizableViewNote];
            }
        }

        
        
    }
    
    _currentShape.startPoint=CGPointZero;
    _currentShape.endPoint=CGPointZero;
   
   [self.view bringSubviewToFront:toolBar];
    
}


-(IBAction)reportBarButton_click:(id)sender{
    
}




- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if (CGSizeEqualToSize(lastAppearSize, CGSizeZero) == false)
	{
		if (CGSizeEqualToSize(lastAppearSize, self.view.bounds.size) == false)
		{
			[self updateScrollViewContentViews]; // Update content views
		}

		lastAppearSize = CGSizeZero; // Reset view size tracking
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	if (CGSizeEqualToSize(theScrollView.contentSize, CGSizeZero)) // First time
	{
		[self performSelector:@selector(showDocument:) withObject:nil afterDelay:0.02];
	}

#if (READER_DISABLE_IDLE == TRUE) // Option

	[UIApplication sharedApplication].idleTimerDisabled = YES;

#endif // end of READER_DISABLE_IDLE Option
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	lastAppearSize = self.view.bounds.size; // Track view size

#if (READER_DISABLE_IDLE == TRUE) // Option

	[UIApplication sharedApplication].idleTimerDisabled = NO;

#endif // end of READER_DISABLE_IDLE Option
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif



	theScrollView = nil; contentViews = nil; lastHideTime = nil;

	lastAppearSize = CGSizeZero; currentPage = 0;

	[super viewDidUnload];
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if (isVisible == NO) return; // iOS present modal bodge

	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
		if (printInteraction != nil) [printInteraction dismissAnimated:NO];
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	if (isVisible == NO) return; // iOS present modal bodge

	[self updateScrollViewContentViews]; // Update content views

	lastAppearSize = CGSizeZero; // Reset view size tracking
}

/*
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	//if (isVisible == NO) return; // iOS present modal bodge

	//if (fromInterfaceOrientation == self.interfaceOrientation) return;
}
*/

- (void)didReceiveMemoryWarning
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	[super didReceiveMemoryWarning];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
	__block NSInteger page = 0;

	CGFloat contentOffsetX = scrollView.contentOffset.x;

	[contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
		^(id key, id object, BOOL *stop)
		{
			ReaderContentView *contentView = object;

			if (contentView.frame.origin.x == contentOffsetX)
			{
				page = contentView.tag; *stop = YES;
			}
		}
	];

	if (page != 0) [self showDocumentPageNew:page]; // Show the page
     
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	[self showDocumentPageNew:theScrollView.tag]; // Show page

	theScrollView.tag = 0; // Clear page number tag
}

#pragma mark UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recognizer shouldReceiveTouch:(UITouch *)touch
{
	if ([touch.view isKindOfClass:[UIScrollView class]]) return YES;

	return NO;
}

#pragma mark UIGestureRecognizer action methods

- (void)decrementPageNumber
{
	if (theScrollView.tag == 0) // Scroll view did end
	{
		NSInteger page = [document.pageNumber integerValue];
		NSInteger maxPage = [document.pageCount integerValue];
		NSInteger minPage = 1; // Minimum

		if ((maxPage > minPage) && (page != minPage))
		{
			CGPoint contentOffset = theScrollView.contentOffset;

			contentOffset.x -= theScrollView.bounds.size.width; // -= 1

			[theScrollView setContentOffset:contentOffset animated:YES];

			theScrollView.tag = (page - 1); // Decrement page number
		}
	}
}

- (void)incrementPageNumber
{
	if (theScrollView.tag == 0) // Scroll view did end
	{
		NSInteger page = [document.pageNumber integerValue];
		NSInteger maxPage = [document.pageCount integerValue];
		NSInteger minPage = 1; // Minimum

		if ((maxPage > minPage) && (page != maxPage))
		{
			CGPoint contentOffset = theScrollView.contentOffset;

			contentOffset.x += theScrollView.bounds.size.width; // += 1

			[theScrollView setContentOffset:contentOffset animated:YES];

			theScrollView.tag = (page + 1); // Increment page number
		}
	}
}



#pragma mark - touch interface



-(CGPoint)getBoundingPoint:(CGPoint)tempPoint{
    
    CGPoint touchPoint=[_drawingPad convertPoint:tempPoint toView:_drawingPad];
    
    //NSLog(@"self.frame=%@,tempPoint=%@",NSStringFromCGRect(self.frame),NSStringFromCGPoint(tempPoint));
    
    
    CGFloat boundingMargin=10.0f;
    if(CGRectContainsPoint(self.view.frame, touchPoint)==NO){
        
        //right side and bottom
        if(tempPoint.x>= _drawingPad.frame.size.width && tempPoint.y>= _drawingPad.frame.size.height)
            tempPoint=CGPointMake(_drawingPad.frame.size.width-boundingMargin, _drawingPad.frame.size.height-boundingMargin);
        else if(tempPoint.x>= _drawingPad.frame.size.width)
            tempPoint=CGPointMake(_drawingPad.frame.size.width-boundingMargin, tempPoint.y);
        else if(tempPoint.y>= _drawingPad.frame.size.height)
            tempPoint=CGPointMake(tempPoint.x, _drawingPad.frame.size.height-boundingMargin);
        
        
        //left side and top
        if(tempPoint.x<= _drawingPad.frame.origin.x && tempPoint.y<= _drawingPad.frame.origin.y)
            tempPoint=CGPointMake( _drawingPad.frame.origin.x+boundingMargin, _drawingPad.frame.origin.y+boundingMargin);
        else if(tempPoint.x<= _drawingPad.frame.origin.x)
            tempPoint=CGPointMake(boundingMargin, tempPoint.y);
        else if(tempPoint.y<= _drawingPad.frame.origin.y)
            tempPoint=CGPointMake(tempPoint.x, boundingMargin);
        
    }
    
    return tempPoint;
    
}

-(void)clearSelectedRectangleWithDotView{
    
    
    CALayer *rectangleSelectLayer = [_drawingPad.layer valueForKey:@"rectangleSelection"];
    [rectangleSelectLayer removeFromSuperlayer];

    
    UIView *dotView=nil;
    for(int i=152;i<160;i++){
        dotView=[_drawingPad viewWithTag:i];
        [dotView removeFromSuperview];
    }
    
}


-(void)drawUsingPencil:(CGPoint)endPoint{
    
    if(!skipDrawingCurrentShape && (selectedIndex == -1)) {
        ctr++;
        pts[ctr] = endPoint;
        
        if (ctr == 4)
        {
            UIBezierPath *path = [UIBezierPath bezierPath];
            pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0); // move the endpoint to the middle of the line joining the second control point of the first Bezier segment and the first control point of the second Bezier segment
            
            [path moveToPoint:pts[0]];
            [path addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]]; // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
            
            CAShapeLayer *myLayer = [[CAShapeLayer alloc] init];
            myLayer.strokeColor = [_currentShape.color CGColor];
            myLayer.lineWidth = _currentShape.lineWidth;
            myLayer.fillColor = nil;
            myLayer.lineJoin = kCALineJoinBevel;
            myLayer.path = path.CGPath;
            myLayer.name=nil;
            [pencilBezierPath appendPath:path];
            
            [_drawingPad.layer addSublayer:myLayer];
            // replace points and get ready to handle the next segment
            pts[0] = pts[3];
            pts[1] = pts[4];
            ctr = 1;
            
        }
        
    }
}





-(void)clearDrawnLayersWithNoNameFromView{
    
    
    //NSLog(@"before [_drawingPad.layer sublayers] count]=%d",[[_drawingPad.layer sublayers] count]);
    
    //[_drawingPad.layer.sublayers makeObjectsPerformSelector: @selector(removeFromSuperlayer)];
    
    for(int i=0;i<[_drawingPad.layer.sublayers count];i++){
        CAShapeLayer *drawingLayer = [[_drawingPad.layer sublayers] objectAtIndex:i];
        if([drawingLayer isMemberOfClass:([CAShapeLayer class])]){
            if(drawingLayer.name==nil){
                [drawingLayer removeFromSuperlayer];
                drawingLayer.path=nil;
                i=0;
            }
        }
    }
    
    //NSLog(@"after [_drawingPad.layer sublayers] count]=%d",[[_drawingPad.layer sublayers] count]);
}




-(void)addAllLabelsWithBoundingBox :(myShape*)shapeToBeDrawn withDrawingPadView:(ReaderContentView*)padView{
    
    
    _lastEditedView=shapeToBeDrawn.noteSPUserResizableView;
    _lastEditedView.delegate=self;
    UITapGestureRecognizer *doubleTap =
    [[UITapGestureRecognizer alloc]
     initWithTarget:self
     action:@selector(tapDetected:)];
    doubleTap.numberOfTapsRequired = 2;
    [_lastEditedView addGestureRecognizer:doubleTap];
    
    _lastEditedView.fixBorder=YES;
    [_lastEditedView hideEditingHandles];
    [self hideEditingHandles:nil];
    _lastEditedView.userInteractionEnabled=NO;
    
    //UILabel *noteLabel=[self getSPUerResizableText:shapeToBeDrawn.noteSPUserResizableView];
    //noteLabel.frame=[contentPageView convertRect:noteLabel.frame toView:padView];
    //noteLabel.font=markupLabelFont;
    
    if(shapeToBeDrawn.shape==-2){
        
        
        //[noteLabel setNuiClass:@"Label:SmallLabel"];
        
        
        
        
        
        
    }
    
    else if(shapeToBeDrawn.shape!=-2){
        
    }
    
    
    [padView addSubview:_lastEditedView];
    
    
    
}

- (void)drawShapes:(NSString*)layerName {
    
    int shape=0;
    
   
    if(selectedIndex!=-1){
        myShape *myShapeObbj = [_collection objectAtIndex:selectedIndex];
        shape=myShapeObbj.shape;
    }
    
    if(CGPointEqualToPoint(_currentShape.startPoint, CGPointZero) && CGPointEqualToPoint(_currentShape.endPoint, CGPointZero) && shape!=3){
        return;
    }
    
    
    
    
    for(UIView *view in[_drawingPad subviews]){
        if(view.tag==151 ||view.tag==152 ||view.tag==153||view.tag==154||view.tag==155||view.tag==156||view.tag==157||view.tag==158||view.tag==159){
            [view removeFromSuperview];
        }
    }
    
    //NSLog(@"[_drawingPad.layer sublayers] count]=%d",[[_drawingPad.layer sublayers] count]);
    
    rectangle=CGRectZero;
    
    CALayer *drawingLayer = [[_drawingPad.layer sublayers] objectAtIndex:[[_drawingPad.layer sublayers] count]-1];
    
    if([drawingLayer isMemberOfClass:([CAShapeLayer class])]){
        if(![drawingLayer.name isEqualToString:@"Shape"])
            [drawingLayer removeFromSuperlayer];
        
    }
    
    
    
    drawingLayer = [[_drawingPad.layer sublayers] objectAtIndex:[[_drawingPad.layer sublayers] count]-1];
    if([drawingLayer isMemberOfClass:([CAShapeLayer class])]){
        if(![drawingLayer.name isEqualToString:@"Shape"])
            [drawingLayer removeFromSuperlayer];
        
    }
    
    SPDotView *dotView;
    
    if(selectedIndex!=-1){
        myShape *i=[_collection objectAtIndex:selectedIndex];
        
        drawingLayer = [_drawingPad.layer valueForKey:[NSString stringWithFormat:(@"shape_%d"), i.shape_no]];
        
        
        if(drawingLayer==nil){
            //NSLog(@"drawingLayer is null=%@",drawingLayer);
            drawingLayer = [[_drawingPad.layer sublayers] objectAtIndex:[[_drawingPad.layer sublayers] count]-1];
        }
        
        
        if([drawingLayer isMemberOfClass:([CAShapeLayer class])]){
            if([drawingLayer.name isEqualToString:@"Shape"])
                [drawingLayer removeFromSuperlayer];
        }
        selectedShapeStartpoint=i.startPoint;
        selectedShapeEndpoint=i.endPoint;
        [self drawShapesSubroutine:i inLayerName:layerName];
        
        //X-Y coodrinate
        //XYBarButton.width=92.0f;
        XYLabel.hidden=NO;
        
        NSString *xyCoordinateStr=[NSString stringWithFormat:@"X:%d\nY:%d",(int)round(i.startPoint.x),(int)round(i.startPoint.y)];
        
        XYLabel.text=xyCoordinateStr;
        
        if(i.selected == true) {
            
            //adding dot
            
            //end adding dot
            float cornerImageWH=16.0f;
            CGRect cornerRect;
            UIImage *dotImg;
            UIImageView *dotImageView;
            if(shape!=3){
                [self drawShapeSelector:i selectorRect: &rectangle];
                UIBezierPath *aPath = [UIBezierPath bezierPathWithRoundedRect:rectangle cornerRadius:2.0];
                //[aPath fill];
                CAShapeLayer *myLayer = [[CAShapeLayer alloc] init];
                myLayer.strokeColor = [RGBCOLOR(32, 122, 252) CGColor];
                myLayer.lineWidth = 2.0f;
                myLayer.fillColor = nil;
                //myLayer.lineDashPattern=[NSArray arrayWithObjects:[NSNumber numberWithFloat:1], [NSNumber numberWithInt:2], nil];
                myLayer.lineJoin = kCALineJoinBevel;
                myLayer.path = aPath.CGPath;
                myLayer.name=@"rectangleSelection";
                [_drawingPad.layer setValue:myLayer forKey:@"rectangleSelection"];
                
                [_drawingPad.layer addSublayer:myLayer];
                
                
                
                //NSString *dotImageFileName=@"dot.png";
                
                
                cornerRect=CGRectMake(i.endPoint.x-cornerImageWH/2.0f, i.endPoint.y-cornerImageWH/2.0f, cornerImageWH, cornerImageWH);
                dotView = [[SPDotView alloc] initWithFrame:cornerRect];
                dotImg=[self getUIImageFromThisUIView:dotView];
            }
            
            
            if(i.shape==0){
                
                
                cornerRect=CGRectMake(i.endPoint.x-cornerImageWH/2.0f, i.endPoint.y-cornerImageWH/2.0f, cornerImageWH, cornerImageWH);
                
                if(abs(i.startPoint.y-i.endPoint.y)<=200)
                    cornerRect=CGRectMake(i.endPoint.x-cornerImageWH/2.0f, i.endPoint.y-cornerImageWH/2.0f, cornerImageWH, cornerImageWH);
                
                dotImageView = [[UIImageView alloc] initWithImage:dotImg];
                //dotView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:dotImageFileName]];
                dotImageView.frame=cornerRect;
                
                dotImageView.tag=152;
                [_drawingPad addSubview:dotImageView];
            }
            
            
            else if(i.shape==1 ||i.shape==2){
                dotView=nil;
                
                cornerRect=CGRectMake(rectangle.origin.x-cornerImageWH/2.0f, rectangle.origin.y-cornerImageWH/2.0f, cornerImageWH, cornerImageWH);
                
                dotImageView = [[UIImageView alloc] initWithImage:dotImg];
                dotImageView.frame=cornerRect;
                dotImageView.tag=152;
                [_drawingPad addSubview:dotImageView];
                
                
                cornerRect=CGRectMake((rectangle.origin.x+rectangle.size.width/2.0f)-cornerImageWH/2.0f, rectangle.origin.y-cornerImageWH/2.0f, cornerImageWH, cornerImageWH);
                //dotView = [[SPDotView alloc] initWithFrame:cornerRect];
                dotImageView = [[UIImageView alloc] initWithImage:dotImg];
                dotImageView.frame=cornerRect;
                dotImageView.tag=153;
                [_drawingPad addSubview:dotImageView];
                
                cornerRect=CGRectMake((rectangle.origin.x+rectangle.size.width)-cornerImageWH/2.0f, rectangle.origin.y-cornerImageWH/2.0f, cornerImageWH, cornerImageWH);
                //dotView = [[SPDotView alloc] initWithFrame:cornerRect];
                dotImageView = [[UIImageView alloc] initWithImage:dotImg];
                dotImageView.frame=cornerRect;
                dotImageView.tag=154;
                [_drawingPad addSubview:dotImageView];
                
                cornerRect=CGRectMake(rectangle.origin.x-cornerImageWH/2.0f, (rectangle.origin.y+rectangle.size.height/2.0f)-cornerImageWH/2.0f, cornerImageWH, cornerImageWH);
                //dotView = [[SPDotView alloc] initWithFrame:cornerRect];
                dotImageView = [[UIImageView alloc] initWithImage:dotImg];
                dotImageView.frame=cornerRect;
                dotImageView.tag=155;
                [_drawingPad addSubview:dotImageView];
                
                cornerRect=CGRectMake(rectangle.origin.x-cornerImageWH/2.0f, (rectangle.origin.y+rectangle.size.height)-cornerImageWH/2.0f, cornerImageWH, cornerImageWH);
                //dotView = [[SPDotView alloc] initWithFrame:cornerRect];
                dotImageView = [[UIImageView alloc] initWithImage:dotImg];
                dotImageView.frame=cornerRect;
                dotImageView.tag=156;
                [_drawingPad addSubview:dotImageView];
                
                
                cornerRect=CGRectMake((rectangle.origin.x+rectangle.size.width/2.0f)-cornerImageWH/2.0f, (rectangle.origin.y+rectangle.size.height)-cornerImageWH/2.0f, cornerImageWH, cornerImageWH);
                //dotView = [[SPDotView alloc] initWithFrame:cornerRect];
                dotImageView = [[UIImageView alloc] initWithImage:dotImg];
                dotImageView.frame=cornerRect;
                dotImageView.tag=157;
                [_drawingPad addSubview:dotImageView];
                
                cornerRect=CGRectMake((rectangle.origin.x+rectangle.size.width)-cornerImageWH/2.0f, (rectangle.origin.y+rectangle.size.height/2.0f)-cornerImageWH/2.0f, cornerImageWH, cornerImageWH);
                //dotView = [[SPDotView alloc] initWithFrame:cornerRect];
                dotImageView = [[UIImageView alloc] initWithImage:dotImg];
                dotImageView.frame=cornerRect;
                dotImageView.tag=158;
                [_drawingPad addSubview:dotImageView];
                
                cornerRect=CGRectMake((rectangle.origin.x+rectangle.size.width)-cornerImageWH/2.0f, (rectangle.origin.y+rectangle.size.height)-cornerImageWH/2.0f, cornerImageWH, cornerImageWH);
                //dotView = [[SPDotView alloc] initWithFrame:cornerRect];
                dotImageView = [[UIImageView alloc] initWithImage:dotImg];
                dotImageView.frame=cornerRect;
                dotImageView.tag=159;
                [_drawingPad addSubview:dotImageView];
                
                
            }
            
            else if(i.shape==3){
                
                CAShapeLayer *myLayer = [[CAShapeLayer alloc] init];
                myLayer.strokeColor = [RGBCOLOR(32, 122, 252) CGColor];
                myLayer.lineWidth = 1.0f;
                myLayer.fillColor = nil;
                myLayer.lineJoin = kCALineJoinBevel;
                myLayer.path = i.pencilBezierPath.CGPath;
                [_drawingPad.layer setValue:myLayer forKey:@"rectangleSelection"];
                [_drawingPad.layer addSublayer:myLayer];
                
                
            }
            
            
            
            
            
            //tapped = true;
            
        }
        
        
    }
    
    
    
    
    
    if(!skipDrawingCurrentShape && (selectedIndex == -1)) {
        
        
        [self drawShapesSubroutine:_currentShape inLayerName:layerName];
        
        [dotView removeFromSuperview];
        
        
    }
    
    
    
    
    
    
    
}

-(void)saveToDisk: (NSTimer *) theTimer {
    //NSLog(@"Me is here at 5 sec. delay");
    
    //NSString *pageName=@"";
    //NSLog(@"_drawingPad.image=%@",_drawingPad.image);
    
    
    //[self saveDataToDiskWithFilename:pageName];
    NSString *strFileName=[commonFunction getFileNameFromPath:_pdfFilePath];
    [commonFunction saveDataToDiskWithFilename:[NSString stringWithFormat:@"%@_%@",strFileName,document.pageNumber] withCollection:_collection];
    
}


-(UIImage*)getUIImageFromThisUIView:(UIView*)aUIView
{
    UIGraphicsBeginImageContext(aUIView.bounds.size);
    [aUIView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}





- (void)drawShapesSubroutine:(myShape *)shapeToBeDrawn inLayerName :(NSString*)layerName {
    
    
    
    // Setting the dashed parameter
    
    
    
    UIBezierPath *path;
    
    
    
    
    if(shapeToBeDrawn.shape == 0) { //line
        
        
        //1. Create bezier path from first point to second.
        
        path = [UIBezierPath bezierPath];
        
        [path moveToPoint:shapeToBeDrawn.startPoint];
        [path addLineToPoint:shapeToBeDrawn.endPoint];
        
        
        //2. Create a shape layer for above created path.
        CAShapeLayer *myLayer = [[CAShapeLayer alloc] init];
        myLayer.strokeColor = [shapeToBeDrawn.color CGColor];
        //NSLog("shapeToBeDrawn.color=%@", myLayer);
        myLayer.lineWidth = shapeToBeDrawn.lineWidth;
        myLayer.fillColor = nil;
        myLayer.lineJoin = kCALineJoinBevel;
        myLayer.path = path.CGPath;
        myLayer.name=layerName;
        if(layerName!=nil){
            [_drawingPad.layer setValue:myLayer forKey:[NSString stringWithFormat:(@"shape_%d"), shapeToBeDrawn.shape_no]];
            //CALayer *drawingLayer1 = [self.layer valueForKey:[NSString stringWithFormat:(@"shape_%d"), shapeToBeDrawn.shape_no]];
            //NSLog(@"drawingLayer while adding=%@,shape_=%d",drawingLayer1, shapeToBeDrawn.shape_no);
            
            
        }
        
        [_drawingPad.layer addSublayer:myLayer];
        
        
    }
    else if(shapeToBeDrawn.shape == 1) {    //Rectangle
        CGRect rect = CGRectMake(shapeToBeDrawn.startPoint.x,
                                 shapeToBeDrawn.startPoint.y,
                                 abs(shapeToBeDrawn.endPoint.x - shapeToBeDrawn.startPoint.x),
                                 abs(shapeToBeDrawn.endPoint.y - shapeToBeDrawn.startPoint.y));
        
        
        if((shapeToBeDrawn.endPoint.x - shapeToBeDrawn.startPoint.x)<0)
            rect.origin.x=shapeToBeDrawn.startPoint.x-abs(shapeToBeDrawn.endPoint.x-shapeToBeDrawn.startPoint.x);
        if((shapeToBeDrawn.endPoint.y - shapeToBeDrawn.startPoint.y)<0)
            rect.origin.y=shapeToBeDrawn.startPoint.y-abs(shapeToBeDrawn.endPoint.y-shapeToBeDrawn.startPoint.y);
        
        path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:0.0];
        CAShapeLayer *myLayer = [[CAShapeLayer alloc] init];
        myLayer.strokeColor = [shapeToBeDrawn.color CGColor];
        myLayer.lineWidth = shapeToBeDrawn.lineWidth;
        myLayer.fillColor = nil;
        myLayer.lineJoin = kCALineJoinBevel;
        myLayer.path = path.CGPath;
        myLayer.name=layerName;
        
        if(layerName!=nil){
            [_drawingPad.layer setValue:myLayer forKey:[NSString stringWithFormat:(@"shape_%d"), shapeToBeDrawn.shape_no]];
            //CALayer *drawingLayer1 = [self.layer valueForKey:[NSString stringWithFormat:(@"shape_%d"), shapeToBeDrawn.shape_no]];
            //NSLog(@"drawingLayer while adding=%@,shape_=%d",drawingLayer1, shapeToBeDrawn.shape_no);
            
            
        }
         [_drawingPad.layer addSublayer:myLayer];
    }
    else if(shapeToBeDrawn.shape == 2) {    //Circle
        float X = shapeToBeDrawn.endPoint.x - shapeToBeDrawn.startPoint.x;
        float Y = shapeToBeDrawn.endPoint.y - shapeToBeDrawn.startPoint.y;
        float radius = sqrtf(X*X + Y*Y);
        
        //path = [UIBezierPath
        //      bezierPathWithOvalInRect:CGRectMake(shapeToBeDrawn.startPoint.x, shapeToBeDrawn.startPoint.y, radius, radius)];
        
        CGPoint center= CGPointMake(shapeToBeDrawn.startPoint.x, shapeToBeDrawn.startPoint.y);
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path addArcWithCenter:center
                        radius:radius
                    startAngle:0.0
                      endAngle:2.0 * M_PI
                     clockwise:NO];
        
        CAShapeLayer *myLayer = [[CAShapeLayer alloc] init];
        myLayer.strokeColor = [shapeToBeDrawn.color CGColor];
        myLayer.lineWidth = shapeToBeDrawn.lineWidth;
        myLayer.fillColor = nil;
        myLayer.lineJoin = kCALineJoinBevel;
        myLayer.path = path.CGPath;
        myLayer.name=layerName;
        
        if(layerName!=nil){
            [_drawingPad.layer setValue:myLayer forKey:[NSString stringWithFormat:(@"shape_%d"), shapeToBeDrawn.shape_no]];
            //CALayer *drawingLayer1 = [self.layer valueForKey:[NSString stringWithFormat:(@"shape_%d"), shapeToBeDrawn.shape_no]];
            //NSLog(@"drawingLayer while adding=%@,shape_=%d",drawingLayer1, shapeToBeDrawn.shape_no);
            
            
        }
        
        [_drawingPad.layer addSublayer:myLayer];
    }
    
    
    else if(shapeToBeDrawn.shape == 3) {    //pencil draw
        
        UIBezierPath *pencilCurve=shapeToBeDrawn.pencilBezierPath;
        
        CAShapeLayer *myLayer = [[CAShapeLayer alloc] init];
        myLayer.strokeColor = [shapeToBeDrawn.color CGColor];
        myLayer.lineWidth = shapeToBeDrawn.lineWidth;
        myLayer.fillColor = nil;
        myLayer.lineJoin = kCALineJoinBevel;
        myLayer.path = pencilCurve.CGPath;
        myLayer.name=layerName;
        
        if(layerName!=nil){
            [_drawingPad.layer setValue:myLayer forKey:[NSString stringWithFormat:(@"shape_%d"), shapeToBeDrawn.shape_no]];
            //CALayer *drawingLayer1 = [self.layer valueForKey:[NSString stringWithFormat:(@"shape_%d"), shapeToBeDrawn.shape_no]];
            //NSLog(@"drawingLayer while adding=%@,shape_=%d",drawingLayer1, shapeToBeDrawn.shape_no);
            
        }
        else if(layerName==nil){
            [self clearDrawnLayersWithNoNameFromView];
        }
        [_drawingPad.layer addSublayer:myLayer];
        //NSLog(@"pencilCurve.CGPath=%@,myLayer=%@,layerName=%@",pencilCurve.CGPath,myLayer,layerName);
        _currentShape.startPoint=CGPointZero;
        _currentShape.endPoint=CGPointZero;
        
        
    }
    
    
    
    
    
}

-(void)drawShapeSelector:(myShape *)shapeToBeDrawn selectorRect:(CGRect *) rect {
    float x=0.0, y=0.0, width=0.0, height=0.0;
    float selectShapeMargin=SELECTMARGIN;
    
    if(shapeToBeDrawn.shape == 0 || shapeToBeDrawn.shape == 1) { //Line & rectangle
        if(shapeToBeDrawn.shape==1)
            selectShapeMargin=SELECTMARGIN*2.0f;
        
        if(shapeToBeDrawn.startPoint.x < shapeToBeDrawn.endPoint.x) {
            x = shapeToBeDrawn.startPoint.x - selectShapeMargin;
            width = shapeToBeDrawn.endPoint.x - shapeToBeDrawn.startPoint.x + 2*selectShapeMargin;
        }
        else {
            x = shapeToBeDrawn.endPoint.x - selectShapeMargin;
            width = shapeToBeDrawn.startPoint.x - shapeToBeDrawn.endPoint.x + 2*selectShapeMargin;
        }
        
        if(shapeToBeDrawn.startPoint.y < shapeToBeDrawn.endPoint.y) {
            y = shapeToBeDrawn.startPoint.y - selectShapeMargin;
            height = shapeToBeDrawn.endPoint.y - shapeToBeDrawn.startPoint.y + 2*selectShapeMargin;
        }
        else {
            y = shapeToBeDrawn.endPoint.y - selectShapeMargin;
            height = shapeToBeDrawn.startPoint.y - shapeToBeDrawn.endPoint.y + 2*selectShapeMargin;
        }
        
    }
    if(shapeToBeDrawn.shape == 2) {    // Circle
        float r, dx, dy;
        dx = shapeToBeDrawn.endPoint.x - shapeToBeDrawn.startPoint.x;
        dy = shapeToBeDrawn.endPoint.y - shapeToBeDrawn.startPoint.y;
        r = sqrtf(dx*dx + dy*dy);   // Radius of our shape
        
        x = shapeToBeDrawn.startPoint.x - r - SELECTMARGIN;
        y = shapeToBeDrawn.startPoint.y - r - SELECTMARGIN;
        
        width = height = 2*(r+SELECTMARGIN);
    }
    else {
        //NSLog(@"drawShapeSelector, shouldn't be here!");
    }
    
    x -= shapeToBeDrawn.lineWidth/2.0f;
    y -= shapeToBeDrawn.lineWidth/2.0f;
    width += shapeToBeDrawn.lineWidth;
    height += shapeToBeDrawn.lineWidth;
    
    *rect = CGRectMake(x, y, width, height);
}


#pragma mark ReaderContentViewDelegate methods



- (void)contentView:(ReaderContentView *)contentView touchesBegan:(NSSet *)touches
{
    if([editDoneBarButton.title isEqualToString:@"Edit"])
        return;
		
    // Receiving the touch event
    UITouch *touch = [touches anyObject];
    CGPoint tempPoint = [touch locationInView:_drawingPad];
    pts[0]=tempPoint;
    //xyToolView.hidden=YES;
   

    
    if(_currentShape.shape==3){
        
        //[pencilBezierPath removeAllPoints];
        pencilBezierPath=[[UIBezierPath alloc]init];
    }
    else{
        pencilBezierPath=nil;
    }
    
    
    //_currentShape.pencilBezierPath=[UIBezierPath bezierPath];
    
    _currentShape.startPoint = CGPointMake(tempPoint.x, tempPoint.y);   // storing the point
    
    NSInteger touchesBeganSelectedIndex = -1;   // Checking to see if the new point still selectes the right shape.
    
    // Code checking to see if we need to move an object
    drag=NO;
    
    CGRect selectedRectangle=CGRectMake(rectangle.origin.x-20, rectangle.origin.y-20, rectangle.size.width+40, rectangle.size.height+40);
    
    for(myShape* i in [_collection reverseObjectEnumerator]) {
        if([i pointContainedInShape:tempPoint] || (CGRectContainsPoint(selectedRectangle, tempPoint) && CGRectContainsPoint(selectedRectangle, i.startPoint) && CGRectContainsPoint(selectedRectangle, i.endPoint)&&(CGPointEqualToPoint(selectedShapeStartpoint, i.startPoint))&& (CGPointEqualToPoint(selectedShapeEndpoint, i.endPoint)))) {
            touchesBeganSelectedIndex = [_collection indexOfObject:i];
            pencilPath=i.pencilBezierPath;
            drag=YES;
            break;
            
        }
    }
    
    if(drag==YES){
        
        for(myShape* i in [_collection reverseObjectEnumerator]) {
            if(selectedIndex==[_collection indexOfObject:i] && [i pointContainedInShapeCorner:tempPoint inRectangle:rectangle]) {
                touchesBeganSelectedIndex = [_collection indexOfObject:i];
                cornerDrag=YES;
                //touchesBeganSelectedIndex=-1;
                _currentShape.startPoint=i.startPoint;
                //[self clearSelectShapeOnScreen];
                return;
                
            }
        }
        
    }
    
    
    if(((cornerDrag==NO) && (drag==NO))){
        
        [self clearSelectedRectangleWithDotView];
        
        
        [self ShapeSelected:YES];
        //[_lastEditedView hideEditingHandles];
        rectangle=CGRectZero;
        XYLabel.hidden=YES;
        //xyToolView.hidden=YES;
        //UIView *view=[self.view.superview viewWithTag:5000];
        //view.hidden=YES;
        
        selectedIndex = -1;
        //[self clearSelectShapeOnScreen];
        [magnifierView setNeedsDisplay];
        
        
        return;
        
    }
     
    
    
    
    //NSLog(@"cornerDrag=%d",cornerDrag);
    
    if(((touchesBeganSelectedIndex == -1) || (touchesBeganSelectedIndex != selectedIndex))) {    // If the newly touched area isn't previously tapped shape, then don't move
        selectedIndex = -1;
        [self clearSelectShapeOnScreen];
        
    }
    else  {  // Newly touched point is within the previously selected shape, store the original points.
        myShape *obj = [_collection objectAtIndex:selectedIndex];
        savedShapeStartpoint = obj.startPoint;
        savedShapeEndpoint = obj.endPoint;
        pencilPath=obj.pencilBezierPath;
        //NSLog(@"shape_no=%d",obj.shape_no);
        
    }
    
}


- (void)contentView:(ReaderContentView *)contentView touchesMoved:(NSSet *)touches{
    
    if([editDoneBarButton.title isEqualToString:@"Edit"])
        return;
    
    
    UITouch *touch = [touches anyObject];
    CGPoint tempPoint = [touch locationInView:_drawingPad];
    int shape=0;
    
    if(selectedIndex!=-1){
        myShape *myShapeObbj = [_collection objectAtIndex:selectedIndex];
        shape=myShapeObbj.shape;
        
    }
    
    //NSLog(@"shape=%d",shape);
    if(CGPointEqualToPoint(_currentShape.startPoint,CGPointZero) && shape!=3)
        return;
    
    //tempPoint=[self getBoundingPoint:tempPoint];
    
    
    // Setting properties
    _currentShape.endPoint = CGPointMake(tempPoint.x, tempPoint.y);
    
    if(selectedIndex == -1 && cornerDrag==NO){    // If we aren't dragging a shape
        [self setCurrentShapeProperties];
        drag=NO;
    }
    else if(selectedIndex != -1 && cornerDrag==YES){    // If we aren't dragging a shape
        [self setCurrentShapeProperties];
        //cornerDrag=NO;
        //selectedIndex=0;
        myShape *obj = [_collection objectAtIndex:selectedIndex];
        //obj.startPoint=_currentShape.startPoint;
        obj.endPoint=_currentShape.endPoint;
        
    }
    else if(shape!=3 && selectedIndex !=-1) {  // If we are dragging a shape
        float dx = _currentShape.endPoint.x - _currentShape.startPoint.x,
        dy = _currentShape.endPoint.y - _currentShape.startPoint.y;
        //NSLog(@"(%f,%f)", dx, dy);
        myShape *obj = [_collection objectAtIndex:selectedIndex];
        obj.startPoint = CGPointMake(savedShapeStartpoint.x + dx, savedShapeStartpoint.y + dy);
        obj.endPoint = CGPointMake(savedShapeEndpoint.x + dx, savedShapeEndpoint.y + dy);
        
        obj.startPoint=[self getBoundingPoint: obj.startPoint];
        obj.endPoint=[self getBoundingPoint: obj.endPoint];
        
    }
    else if(shape==3 && selectedIndex !=-1) {  // If we are dragging a shape
        float dx = tempPoint.x - pts[0].x,
        dy = tempPoint.y - pts[0].y;
        
        //NSLog(@"(%f,%f)", dx, dy);
        //dx=1.0;
        //dy=0.0;
        
        
        myShape *obj = [_collection objectAtIndex:selectedIndex];
        CGPoint startPoint;
        obj.pencilBezierPath = [commonFunction pathWithPoints:pencilPath withX:dx withY:dy receiveStartPoint:&startPoint];
        //NSLog(@"startPoint=%@",NSStringFromCGPoint(startPoint));
        obj.startPoint=startPoint;
        
    }
    
    if(_currentShape.shape==3 & selectedIndex==-1)
        [self drawUsingPencil:tempPoint];
    else
        [self drawShapes:nil];
    
     [magnifierView setNeedsDisplay];

    
}

-(void)contentView:(ReaderContentView *)contentView touchesEnded:(NSSet *)touches{
    
    if([editDoneBarButton.title isEqualToString:@"Edit"])
        return;
    
    
    // Receiving the touch event
    UITouch *touch = [touches anyObject];
    CGPoint tempPoint = [touch locationInView:_drawingPad];
    
    
    int shape=0;
    
    if(selectedIndex!=-1){
        myShape *myShapeObbj = [_collection objectAtIndex:selectedIndex];
        shape=myShapeObbj.shape;
        
    }
    
    //NSLog(@"shape=%d",shape);
    if(CGPointEqualToPoint(_currentShape.startPoint,CGPointZero) && shape!=3)
        return;
    
    
    tempPoint=[self getBoundingPoint:tempPoint];
    
    //NSLog(@"%f,%f",tempPoint.x,tempPoint.y);
    //NSLog(@"%@s",[_colorPicker pointInside:tempPoint withEvent:event] ? @"Yes": @"No");
    
    // Check to see if it's a tap
    //  if(CGPointEqualToPoint(tempPoint, _currentShape.startPoint) == NO) {    // Drag
    if(cornerDrag)
        cornerDrag=NO;
    
    if(!drag){
        //NSLog(@"You dragged!");
        
        // Setting properties
        _currentShape.endPoint = CGPointMake(tempPoint.x, tempPoint.y);
        drag=NO;
        
        if(selectedIndex == -1){    // New shape object!
            [self setCurrentShapeProperties];
            _currentShape.shape_no=shape_no;
            _currentShape.pencilBezierPath=pencilBezierPath;
            shape_no++;
            
            
            float d=0.0f;
            if(_currentShape.shape!=3)
                d=distanceBetweenTwo_Points(_currentShape.startPoint,_currentShape.endPoint);
            else
                d=distanceBezierPoints(pencilBezierPath);
            if(d<30.0f && _currentShape.shape!=2){
                [self clearDrawnLayersWithNoNameFromView];
                
                return;
            }
            else if(d<10.0f && _currentShape.shape==2){
                [self clearDrawnLayersWithNoNameFromView];
                
                return;
            }
            
            [_collection addObject: [[myShape alloc] initCopy:_currentShape]];
            
        }
        else {  // Dragged an already made shape
            float dx = _currentShape.endPoint.x - _currentShape.startPoint.x,
            dy = _currentShape.endPoint.y - _currentShape.startPoint.y;
            //NSLog(@"(%f,%f)", dx, dy);
            myShape *obj = [_collection objectAtIndex:selectedIndex];
            obj.startPoint = CGPointMake(savedShapeStartpoint.x + dx, savedShapeStartpoint.y + dy);
            obj.endPoint = CGPointMake(savedShapeEndpoint.x + dx, savedShapeEndpoint.y + dy);
            
            obj.startPoint=[self getBoundingPoint: obj.startPoint];
            obj.endPoint=[self getBoundingPoint: obj.endPoint];
        }
        
        if(_currentShape.shape==3)
            [self clearDrawnLayersWithNoNameFromView];
        [self drawShapes:@"Shape"];
        
        if(_currentShape.shape==0)
            [self loadHybridViewWithPoint:tempPoint];
        
        [NSTimer scheduledTimerWithTimeInterval:0.1
                                         target:self
                                       selector:@selector(saveToDisk:)
                                       userInfo:nil
                                        repeats:NO];
        
        
    }
    else {  // Tap
        skipDrawingCurrentShape = TRUE;
        if(selectedIndex==-1)
            [self selectShapeOnScreen:(CGPoint) tempPoint];
        else
            [self drawShapes:@"Shape"];
        
        skipDrawingCurrentShape = FALSE;
        
        if(selectedIndex!=-1){
            [self ShapeSelected:NO];
        }
        else{
            [self ShapeSelected:YES];
        }
        
        [NSTimer scheduledTimerWithTimeInterval:0.1
                                         target:self
                                       selector:@selector(saveToDisk:)
                                       userInfo:nil
                                        repeats:NO];
        
        
    }
    
    if(selectedIndex!=-1){
        
    }
    
    ctr = 0;
    
     [magnifierView setNeedsDisplay];
    
    
    
}


// Sets the current shape's properties
- (void)setCurrentShapeProperties {

    _currentShape.shape = _currentShapeType;
    _currentShape.lineWidth = _currentLineWidth;
    _currentShape.isDashed = _dashedLineSelector.on;
    _currentShape.color =_currentColor ;
}



#pragma mark - Working...

- (void)selectShapeOnScreen:(CGPoint) tapPoint {
    //NSLog(@"You tapped!");
    
    bool hidden = TRUE;
    
    selectedIndex = -1;
    
    // Checks to see if the tapped point is in range of any shapes
    for(myShape* i in [_collection reverseObjectEnumerator]) {
        if([i pointContainedInShape:tapPoint] || (CGRectContainsPoint(rectangle, tapPoint) && CGRectContainsPoint(rectangle, i.startPoint) && CGRectContainsPoint(rectangle, i.endPoint)&&(CGPointEqualToPoint(selectedShapeStartpoint, i.startPoint))&& (CGPointEqualToPoint(selectedShapeEndpoint, i.endPoint)))) {
            //NSLog(@"Selected!");
            i.selected = TRUE;  // Sets the shape's select parameter to TRUE
            _lineWidthSegment.selectedSegmentIndex = i.lineWidth-1;   // Sets the line width slider to the shape's line width
            _dashedLineSelector.on = i.isDashed;    // Sets the dashed line selector to shape's dashed state
            //[_colorPicker selectRow:i.color inComponent:0 animated:YES];    // Sets the color picker to the color of the selected shape
            hidden = FALSE; // Show the color picker
            selectedIndex = [_collection indexOfObject:i];  // Store the selected index for dragging :)
            
            
            //CALayer *drawingLayer1 = [self.layer valueForKey:[NSString stringWithFormat:(@"shape_%d"), selectedIndex]];
            //NSLog(@"drawingLayer1=%@",drawingLayer1);
            
            
            break;
        }
    }
    
    
    
    [self drawShapes:@"Shape"];
    
    
    
}

- (void)clearSelectShapeOnScreen {
    for(myShape *i in _collection) {
        i.selected = FALSE;
        rectangle=CGRectZero;
    }
}



#pragma mark ReaderMainPagebarDelegate methods




- (void)applicationWill:(NSNotification *)notification
{
	[document saveReaderDocument]; // Save any ReaderDocument object changes

	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
		if (printInteraction != nil) [printInteraction dismissAnimated:NO];
	}
}


#pragma set shape and color selection



//tool bar





-(IBAction)buttonline_click:(id)sender{
    
    
    
    buttonLineLayer.strokeColor=RGBCOLOR(32, 122, 252).CGColor;
    [buttoncircle setBackgroundImage:[UIImage imageNamed:@"icon_drawcircle@4x.png"] forState:UIControlStateNormal];
    [buttonrectangle setBackgroundImage:[UIImage imageNamed:@"icon_drawsquare@4x.png"] forState:UIControlStateNormal];
    barButtonpencil.tintColor=[UIColor blackColor];
    
    _currentShapeType=0;
    [self setCurrentShapeProperties];
}
-(IBAction)buttoncircle_click:(id)sender{
    
    
    buttonLineLayer.strokeColor=[UIColor blackColor].CGColor;
    //[buttonline setBackgroundColor:[UIColor blackColor]];
    buttonline.tintColor=[UIColor blackColor];
    
    [buttoncircle setBackgroundImage:[UIImage imageNamed:@"icon_drawcircle_active@4x.png"] forState:UIControlStateNormal];
    [buttonrectangle setBackgroundImage:[UIImage imageNamed:@"icon_drawsquare@4x.png"] forState:UIControlStateNormal];
    barButtonpencil.tintColor=[UIColor blackColor];
    
    _currentShapeType=2;
    [self setCurrentShapeProperties];
    
}
-(IBAction)buttonrectangle_click:(id)sender{
    
    
    buttonLineLayer.strokeColor=[UIColor blackColor].CGColor;
    [buttoncircle setBackgroundImage:[UIImage imageNamed:@"icon_drawcircle@4x.png"] forState:UIControlStateNormal];
    [buttonrectangle setBackgroundImage:[UIImage imageNamed:@"icon_drawsquare_active@4x.png"] forState:UIControlStateNormal];
    barButtonpencil.tintColor=[UIColor blackColor];
    
    _currentShapeType=1;
    [self setCurrentShapeProperties];
}

-(IBAction)pencilBarButton_clicked:(id)sender{
    
    buttonLineLayer.strokeColor=[UIColor blackColor].CGColor;
    [buttoncircle setBackgroundImage:[UIImage imageNamed:@"icon_drawcircle@4x.png"] forState:UIControlStateNormal];
    [buttonrectangle setBackgroundImage:[UIImage imageNamed:@"icon_drawsquare@4x.png"] forState:UIControlStateNormal];
    [barButtonpencil setImage:[UIImage imageNamed:@"pencil_blue.png"]];
    barButtonpencil.tintColor=[commonFunction defaultSystemTintColor];
    _currentShapeType=3;
    [self setCurrentShapeProperties];
}


-(IBAction)button1xWidth_click:(id)sender{
    
    [button1xWidth setBackgroundImage:[UIImage imageNamed:@"icon_thickness_thin_active@4x.png"] forState:UIControlStateNormal];
    [button2xWidth setBackgroundImage:[UIImage imageNamed:@"icon_thickness_thick@4x.png"] forState:UIControlStateNormal];
    _currentLineWidth=1.0f;
    [self setCurrentShapeProperties];
    [self shapeChangeWidthAndColor];
    
}
-(IBAction)button2xWidth_click:(id)sender{
    
    [button1xWidth setBackgroundImage:[UIImage imageNamed:@"icon_thickness_thin@4x.png"] forState:UIControlStateNormal];
    [button2xWidth setBackgroundImage:[UIImage imageNamed:@"icon_thickness_thick_active@4x.png"] forState:UIControlStateNormal];
    _currentLineWidth=2.0f;
    [self setCurrentShapeProperties];
    
    [self shapeChangeWidthAndColor];
    
}





-(IBAction)buttonundo_click:(id)sender{
    
    myShape *i=[_collection lastObject];
    if(i!=nil && i.shape!=-2){
        [_undo_collection addObject:i];
        [_collection removeLastObject];
        
        CALayer *drawingLayer = [_drawingPad.layer valueForKey:[NSString stringWithFormat:(@"shape_%d"), i.shape_no]];
        [drawingLayer removeFromSuperlayer];
        CALayer *rectangleSelectLayer = [_drawingPad.layer valueForKey:@"rectangleSelection"];
        if(rectangleSelectLayer!=nil)
            [rectangleSelectLayer removeFromSuperlayer];
        [self clearSelectedRectangleWithDotView];
        SPUserResizableView *noteLabelSPUserResizableView=(SPUserResizableView*)[contentPageView viewWithTag:(i.shape_no+1000)];
        [noteLabelSPUserResizableView removeFromSuperview];
        
    }
    selectedIndex=-1;
    
    [self ShapeSelected:YES];
    
    
}
-(IBAction)buttonredo_click:(id)sender{
    
    myShape *i=[_undo_collection lastObject];
    if(i!=nil){
        [_collection addObject: [[myShape alloc] initCopy:i]];
        [_undo_collection removeLastObject];
        
        
        selectedIndex=-1;
        skipDrawingCurrentShape = FALSE;
        _currentShape=i;
        [self drawShapesSubroutine:i inLayerName: @"Shape"];
        if(i.shape==-1 || i.shape==0){
            _lastEditedView=i.noteSPUserResizableView;
            _lastEditedView.delegate=self;
            _lastEditedView.fixBorder=YES;
            [_lastEditedView hideEditingHandles];
            
            [contentPageView addSubview:_lastEditedView];
            
        }
        
        
    }
    
    
    skipDrawingCurrentShape = FALSE;
    currentSaved = FALSE;
    selectedIndex = -1;
    [self ShapeSelected:YES];

}

-(IBAction)buttonDeleteShape_click:(id)sender{
    
    if(selectedIndex!=-1){
        myShape *i=[_collection objectAtIndex:selectedIndex];
        if(i!=nil){
            [_collection removeObjectAtIndex:selectedIndex];
            
            CALayer *drawingLayer = [_drawingPad.layer valueForKey:[NSString stringWithFormat:(@"shape_%d"), i.shape_no]];
            [drawingLayer removeFromSuperlayer];
            CALayer *rectangleSelectLayer = [_drawingPad.layer valueForKey:@"rectangleSelection"];
            if(rectangleSelectLayer!=nil)
                [rectangleSelectLayer removeFromSuperlayer];
            [self clearSelectedRectangleWithDotView];
            SPUserResizableView *noteLabelSPUserResizableView=(SPUserResizableView*)[contentPageView viewWithTag:(i.shape_no+1000)];
            [noteLabelSPUserResizableView removeFromSuperview];
        }
        
        
        selectedIndex=-1;
        
        [self ShapeSelected:YES];
        
    }

    
  
}

-(void)ShapeSelected:(bool)selected{
    [self removeDeleteButton];
    if(!selected){
        
        NSMutableArray *items=[toolBar.items mutableCopy];
        [items addObject:buttonDeleteShape];
        
        toolBar.items=items;
        
        items=nil;
    }
}



-(void)removeDeleteButton{
    NSMutableArray *items=[toolBar.items mutableCopy];
    [items removeObject:buttonDeleteShape];
    
    toolBar.items=items;
    
    items=nil;
}


//end tool bar

//color slection

-(IBAction)selectBlackColor:(id)sender{
    
    
    [colorBlackButton setBackgroundImage:[UIImage imageNamed:@"black_blue.png"] forState:UIControlStateNormal];
    [colorRedButton setBackgroundImage:[UIImage imageNamed:@"red1.png"] forState:UIControlStateNormal];
    [colorWhiteButton setBackgroundImage:[UIImage imageNamed:@"white1.png"] forState:UIControlStateNormal];
    [colorYellowButton setBackgroundImage:[UIImage imageNamed:@"yellow1.png"] forState:UIControlStateNormal];
    
    _currentColor=[UIColor blackColor];
    
    [self shapeChangeWidthAndColor];
}



-(IBAction)selectRedColor:(id)sender{
    
    [colorBlackButton setBackgroundImage:[UIImage imageNamed:@"black1.png"] forState:UIControlStateNormal];
    [colorRedButton setBackgroundImage:[UIImage imageNamed:@"red_blue.png"] forState:UIControlStateNormal];
    [colorWhiteButton setBackgroundImage:[UIImage imageNamed:@"white1.png"] forState:UIControlStateNormal];
    [colorYellowButton setBackgroundImage:[UIImage imageNamed:@"yellow1.png"] forState:UIControlStateNormal];
    
    _currentColor=[UIColor redColor];
    
    [self shapeChangeWidthAndColor];
}

-(IBAction)selectWhiteColor:(id)sender{
    
    [colorBlackButton setBackgroundImage:[UIImage imageNamed:@"black1.png"] forState:UIControlStateNormal];
    [colorRedButton setBackgroundImage:[UIImage imageNamed:@"red1.png"] forState:UIControlStateNormal];
    [colorWhiteButton setBackgroundImage:[UIImage imageNamed:@"white_blue.png"] forState:UIControlStateNormal];
    [colorYellowButton setBackgroundImage:[UIImage imageNamed:@"yellow1.png"] forState:UIControlStateNormal];
    
    _currentColor=[UIColor whiteColor];
    
    [self shapeChangeWidthAndColor];
}

-(IBAction)selectYellowColor:(id)sender{
    
    [colorBlackButton setBackgroundImage:[UIImage imageNamed:@"black1.png"] forState:UIControlStateNormal];
    [colorRedButton setBackgroundImage:[UIImage imageNamed:@"red1.png"] forState:UIControlStateNormal];
    [colorWhiteButton setBackgroundImage:[UIImage imageNamed:@"white1.png"] forState:UIControlStateNormal];
    [colorYellowButton setBackgroundImage:[UIImage imageNamed:@"yellow_blue.png"] forState:UIControlStateNormal];
    
    _currentColor=[UIColor yellowColor];
    
    [self shapeChangeWidthAndColor];
}

-(void)shapeChangeWidthAndColor{
        if(selectedIndex!=-1){
            myShape *i=[_collection objectAtIndex:selectedIndex];
    
            i.color =_currentColor;
            i.lineWidth = _currentLineWidth;
            
            [self drawShapes:@"Shape"];
        }
}


//end color selection


//magnifier

-(IBAction)barButtonmagnifier_click:(id)sender{
    
    [self addMagnifier];
}



- (void)addLoop {
	// add the loop to the superview.  if we add it to the view it magnifies, it'll magnify itself!
    magnifierView.center=contentPageView.center;
	[self.view addSubview:magnifierView];
	// here, we could do some nice animation instead of just adding the subview...
}


-(void)addMagnifier{
    
    if(magnifierView == nil){
        
        
        [magnifierBarButton setTintColor:[commonFunction defaultSystemTintColor]];
        
		magnifierView = [[MagnifierView alloc] init];
		magnifierView.viewToMagnify = contentPageView;
        magnifierView.markupView=contentPageView;
        magnifierView.touchPoint = contentPageView.center;
        magnifierView.delegate=self;
        magnifierView.tag=100;
        
        // add the loop to the superview.  if we add it to the view it magnifies, it'll magnify itself!
        magnifierView.center=contentPageView.center;
        [self.view addSubview:magnifierView];
        // here, we could do some nice animation instead of just adding the subview...
        [magnifierView setNeedsDisplay];
        
        
	}
}


-(void)closeMagnifier{
    
    UIView *view=[self.view.superview viewWithTag:100];
    
    [view removeFromSuperview];
    
    view=[self.view.superview.superview viewWithTag:101];
    
    [view removeFromSuperview];
    
    [magnifierBarButton setTintColor:[UIColor blackColor]];
    [magnifierView removeFromSuperview];
    magnifierView=nil;
}




//end magnifier




#pragma terms


#pragma mark - Hybrid box

//Load Note View


-(UITextView *)loadNoteView{
    
    txtNoteView=[[UITextView alloc]init];
    txtNoteView.frame=MarkupTextBoxFrame;
    
    // For the border and rounded corners
    [[txtNoteView layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [[txtNoteView layer] setBorderWidth:1];
    //[[txtNoteView layer] setCornerRadius:15];
    //[txtNoteView setClipsToBounds: YES];
    txtNoteView.delegate=self;
    txtNoteView.tag=101;
    
    
    return txtNoteView;
    
}
-(void)loadHybridViewWithPoint:(CGPoint) point{
    
    [self ShapeSelected:YES];
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    termsSubController = [storyboard instantiateViewControllerWithIdentifier:@"termVC"];
    
    
    txtNoteView=[self loadNoteView];
    
    
    [termsSubController.view addSubview:txtNoteView];
    
    
    termsSubController.view.frame=TermFrame;
    termsSubController.delegate=self;
    
    
    //[termsSubController.view setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.78]];
    
    
    navHybridController = [[UINavigationController alloc] initWithRootViewController:termsSubController];
    navHybridController.view.tag=100;
    
    navHybridController.view.frame=HybridPopupFrame;
    
    //navHybridController.view.backgroundColor=[UIColor blueColor];
    [navHybridController.view setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.1]];
    //navHybridController.view.frame=TermFrame;
    
    
    saveActionBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                           style:UIBarButtonItemStyleBordered
                                                          target:self
                                                          action:@selector(SaveAction:)];
    [termsSubController.navigationItem setLeftBarButtonItem:saveActionBarButton animated:NO];
    
    
    UIBarButtonItem *barButtonCancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:self
                                                                       action:@selector(cancelAction:)];
    
    [termsSubController.navigationItem setRightBarButtonItem:barButtonCancel animated:NO];
    
    
    
    termsSubController.title=@"Select or write terms";
    
    
    
    /*/
     [parentView addSubview:navHybridController.view];
     
     self.userInteractionEnabled=NO;
     return;
     */
    
    popoverController = [[UIPopoverController alloc]initWithContentViewController:navHybridController];
    popoverController.delegate=self;
    
    [popoverController setPopoverContentSize:HybridPopupFrame.size animated:YES];
    
    popoverController.backgroundColor =[UIColor colorWithWhite:1.0 alpha:0.9];
    
    [popoverController presentPopoverFromRect:HybridPopupFrame inView:_drawingPad permittedArrowDirections:0  animated:YES];
    
    
    //[popoverController presentPopoverFromRect:CGRectMake(point.x-50, point.y, 230, 340) inView:self permittedArrowDirections:0  animated:YES];
    
}



-(IBAction)SaveAction:(id)sender{
    
    saveActionBarButton=(UIBarButtonItem*)sender;
    
    if(_currentShape.shape==-1 || _currentShape.shape==-2){
        
        _currentShape.shape_no=shape_no;
        shape_no++;
        
        
        [_collection addObject: [[myShape alloc] initCopy:_currentShape]];
        
        
    
       if(_currentShape.shape==-1)
            _currentShape.endPoint=CGPointMake(70, 90);
    }
    
    CGPoint point = _currentShape.endPoint;
    
    UILabel *noteLabel=[[UILabel alloc]initWithFrame:CGRectMake(point.x, point.y, 100.0f, 100.0f)];
    UIFont *font=markupLabelFont;
    noteLabel.text=txtNoteView.text;
    [noteLabel setNumberOfLines:0];
    
    
    CGSize maximumLabelSize;
    if(_currentShape.shape==0)
        maximumLabelSize = CGSizeMake(230,9999);
    else
        maximumLabelSize = CGSizeMake(700,9999);
    
    
    NSMutableParagraphStyle *styleLineBreakWordWrap = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [styleLineBreakWordWrap setLineBreakMode:NSLineBreakByWordWrapping];
    [styleLineBreakWordWrap setAlignment:NSTextAlignmentLeft];
    
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSParagraphStyleAttributeName:styleLineBreakWordWrap};
    
    [txtNoteView.text sizeWithAttributes:attributes];
    
    
    
    
    CGRect textRect = [txtNoteView.text boundingRectWithSize:maximumLabelSize
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName:font}
                                                     context:nil];
    
    CGSize expectedLabelSize = textRect.size;
    
    //CGSize expectedLabelSize = [txtNoteView.text sizeWithFont:font
    //                                        constrainedToSize:maximumLabelSize
    //                                          lineBreakMode:noteLabel.lineBreakMode];
    
    
    
    //adjust the label the the new height.
    CGRect newFrame = noteLabel.frame;
    newFrame.size.height = expectedLabelSize.height;
    newFrame.size.width=expectedLabelSize.width;
    noteLabel.frame = newFrame;
    [noteLabel setFont:font];
    
      noteLabel.frame=[_drawingPad convertRect:noteLabel.frame toView:contentPageView];
    
    
    SPUserResizableView *noteSPUserResizableView=[self getResizableLabel:noteLabel withFrame:noteLabel.frame];
    noteSPUserResizableView.fixBorder=YES;
    noteSPUserResizableView.tag=_currentShape.shape_no+1000;
    
    myShape *i=[_collection objectAtIndex:[_collection count]-1];
    if(i!=nil){
        i.noteSPUserResizableView=noteSPUserResizableView;
    }
    
    
    noteLabel.text = [noteLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(noteLabel!=nil && noteLabel.text!=nil && ![noteLabel.text isEqualToString:@""]){
        [contentPageView addSubview:noteSPUserResizableView];
        
      
        
        [NSTimer scheduledTimerWithTimeInterval:0.0
                                         target:self
                                       selector:@selector(saveToDisk:)
                                       userInfo:nil
                                        repeats:NO];
    }
    
    [self clearPopupView];
    
    
}

-(IBAction)cancelAction:(id)sender{
    
    myShape *i=[_collection objectAtIndex:[_collection count]-1];
    if(i!=nil & i.shape==0){
        [_collection removeObjectAtIndex:[_collection count]-1];
        
        CALayer *drawingLayer = [_drawingPad.layer valueForKey:[NSString stringWithFormat:(@"shape_%d"), i.shape_no]];
        [drawingLayer removeFromSuperlayer];
        CALayer *rectangleSelectLayer = [_drawingPad.layer valueForKey:@"rectangleSelection"];
        if(rectangleSelectLayer!=nil)
            [rectangleSelectLayer removeFromSuperlayer];
        UIView *dotView=[_drawingPad viewWithTag:152];
        [dotView removeFromSuperview];
        
        SPUserResizableView *noteLabelSPUserResizableView=(SPUserResizableView*)[_drawingPad viewWithTag:(i.shape_no+1000)];
        [noteLabelSPUserResizableView removeFromSuperview];
        
        [NSTimer scheduledTimerWithTimeInterval:0.0
                                         target:self
                                       selector:@selector(saveToDisk:)
                                       userInfo:nil
                                        repeats:NO];
        
    }
    
    [magnifierView setNeedsDisplay];
    
    [self clearPopupView];
    
}

-(void)clearPopupView{
    [popoverController dismissPopoverAnimated:YES];
    [txtNoteView removeFromSuperview];
    [navHybridController removeFromParentViewController];
    [termsSubController removeFromParentViewController];
    [navHybridController.view removeFromSuperview];
    [termsSubController.view removeFromSuperview];
    navHybridController=nil;
    saveActionBarButton=nil;
    termsSubController=nil;
    popoverController=nil;
    txtNoteView=nil;
    
    [self ShapeSelected:YES];
    
}

-(void)TerminologySelected:(NSString *)terms{
    
    txtNoteView.text=[NSString stringWithFormat:@"%@%@ ",txtNoteView.text,terms];
}



#pragma mark - Draggable label

//draggable UILabel

-(SPUserResizableView *)getResizableLabel:(UILabel*)label withFrame:(CGRect)labelFrame{
    
    
    SPUserResizableView *imageResizableView = [[SPUserResizableView alloc] initWithFrame:CGRectMake(labelFrame.origin.x-18.00, labelFrame.origin.y-18.00, labelFrame.size.width+25, labelFrame.size.height+25)];
    [imageResizableView setFixBorder:YES];
    UIImageView *imageView = [[UIImageView alloc] init];
    label.frame=CGRectMake(5, 5, labelFrame.size.width, labelFrame.size.height);
    [imageView addSubview:label];
    imageResizableView.contentView = imageView;
    imageResizableView.delegate = self;
    [imageResizableView setFixBorder:YES];
    
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideEditingHandles:)];
    [gestureRecognizer setDelegate:self];
    
    //[photoView addGestureRecognizer:gestureRecognizer];
    
    
    UITapGestureRecognizer *doubleTap =
    [[UITapGestureRecognizer alloc]
     initWithTarget:self
     action:@selector(tapDetected:)];
    doubleTap.numberOfTapsRequired = 2;
    [imageResizableView addGestureRecognizer:doubleTap];
    
    [_lastEditedView hideEditingHandles];
    
    // Notify the delegate we've ended our editing session.
    [self respondsToSelector:@selector(userResizableViewDidEndEditing:)];
    [self userResizableViewDidEndEditing:imageResizableView];
    
    
    return imageResizableView;
}



- (void)userResizableViewDidBeginEditing:(SPUserResizableView *)userResizableView {
    [_lastEditedView hideEditingHandles];
    if(_lastEditedView.tag==1000)
        [self hideEditingHandles:nil];
    //[currentlyEditingView hideEditingHandles];
    _currentlyEditingView = userResizableView;
    
}

- (void)userResizableViewDidEndEditing:(SPUserResizableView *)userResizableView {
    _lastEditedView = userResizableView;
    
    myShape *i;
    for(i in _collection){
        if([_lastEditedView isEqual:i.noteSPUserResizableView]|| _lastEditedView.tag == i.noteSPUserResizableView.tag){
            i.noteSPUserResizableView=_lastEditedView;
            //NSLog(@"lastEditedView.frame=%@",NSStringFromCGRect(lastEditedView.frame));
            break;
        }
    }
    
    
    [NSTimer scheduledTimerWithTimeInterval:0.0
                                     target:self
                                   selector:@selector(saveToDisk:)
                                   userInfo:nil
                                    repeats:NO];
    
    
    
    
    
}


- (IBAction)hideEditingHandles:(id)sender{
    // We only want the gesture recognizer to end the editing session on the last
    // edited view. We wouldn't want to dismiss an editing session in progress.
    for(UIView *view in [_lastEditedView subviews])
        if([view isKindOfClass:[SPGripViewBorderView class]] && [[_lastEditedView subviews] count]>2)
            [view removeFromSuperview];
    
    /*
     UIView *borderView=[lastEditedView viewWithTag:1];
     borderView.hidden=YES;
     [borderView removeFromSuperview];
     */
    [_lastEditedView hideEditingHandles];
    
}


- (IBAction)tapDetected:(UIGestureRecognizer *)gesture {
    
    _lastEditedView = (SPUserResizableView *)gesture.view;
    CGPoint point;
    myShape *i;
    for(i in _collection){
        if([_lastEditedView isEqual:i.noteSPUserResizableView]){
            point=i.endPoint;
            break;
        }
    }
    
    UILabel *label=[self getSPUerResizableText:_lastEditedView];
    if(i.shape==0)
        [self loadHybridViewWithPoint:point];
    else if(i.shape==-2 || i.shape==-1)
        [self loadNoteViewFromNavBar];
    
    if(i.shape==-2){
        _lastEditedView.delegate=self;
        /*
         UIView *borderView=[lastEditedView viewWithTag:1];
         
         borderView.hidden=YES;
         [borderView removeFromSuperview];
         */
        
        
    }
    saveActionBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                           style:UIBarButtonItemStyleBordered
                                                          target:self
                                                          action:@selector(SaveActionOnDoubleTap:)];
    
    UIBarButtonItem *barButtonCancel= [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(CancelActionOnDoubleTap:)];
    [termsSubController.navigationItem setLeftBarButtonItem:saveActionBarButton animated:NO];
    [termsSubController.navigationItem setRightBarButtonItem:barButtonCancel animated:NO];
    
    
    txtNoteView.text=label.text;
    
}

-(IBAction)CancelActionOnDoubleTap:(id)sender{
    [self clearPopupView];
}

-(IBAction)SaveActionOnDoubleTap:(id)sender{
    
    
    UILabel *noteLabel=[self getSPUerResizableText:_lastEditedView];
    
    
    
    myShape *i;
    for(i in _collection){
        if([_lastEditedView isEqual:i.noteSPUserResizableView]){
            
            break;
        }
    }
    
    //CGPoint point = i.endPoint;
    
    //noteLabel.frame = CGRectMake(point.x, point.y, 100.0f, 100.0f);
    
    
    noteLabel.text=txtNoteView.text;
    [noteLabel setNumberOfLines:0];
    
    //adjust the label the the new height.
    
    
    CGRect newFrame = noteLabel.frame;
    
    UIFont *font=[UIFont fontWithName:@"HelveticaNeue" size:12];
    CGSize maximumLabelSize = CGSizeMake(230,9999);
    
    if(i.shape==0)
        maximumLabelSize = CGSizeMake(230,9999);
    else
        maximumLabelSize = CGSizeMake(700,9999);
    
    NSMutableParagraphStyle *styleLineBreakWordWrap = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [styleLineBreakWordWrap setLineBreakMode:NSLineBreakByWordWrapping];
    [styleLineBreakWordWrap setAlignment:NSTextAlignmentLeft];
    
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSParagraphStyleAttributeName:styleLineBreakWordWrap};
    
    [txtNoteView.text sizeWithAttributes:attributes];
    
    
    
    
    CGRect textRect = [txtNoteView.text boundingRectWithSize:maximumLabelSize
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName:font}
                                                     context:nil];
    
    CGSize expectedLabelSize = textRect.size;
    newFrame.size.height = expectedLabelSize.height;
    newFrame.size.width=expectedLabelSize.width;
    noteLabel.frame = newFrame;
    
    //NSLog(@"newFrame=%@",NSStringFromCGRect(newFrame));
    
    _lastEditedView.frame = CGRectMake(_lastEditedView.frame.origin.x, _lastEditedView.frame.origin.y, newFrame.size.width+25, newFrame.size.height+25);
    
    [NSTimer scheduledTimerWithTimeInterval:0.0
                                     target:self
                                   selector:@selector(saveToDisk:)
                                   userInfo:nil
                                    repeats:NO];
    [self clearPopupView];
    
    
    
}


-(void)loadNoteViewFromNavBar{
    
    _currentShape.shape=-1;
    
    
    txtNoteView=[self loadNoteView];
    [txtNoteView becomeFirstResponder];
    
    
    
        txtNoteView.text=@"General Note:\n";
    
    txtNoteView.frame=GeneralNoteTextFrame;
    
    termsSubController = [[TermsVC alloc] init];
    termsSubController.view = [[UIView alloc]initWithFrame:txtNoteView.frame];
    [termsSubController.view addSubview:txtNoteView];
    termsSubController.view.frame=CGRectMake(0, 0, 230, 155);
    
    navHybridController = [[UINavigationController alloc] initWithRootViewController:termsSubController];
    navHybridController.view.tag=100;
    
    navHybridController.view.frame=CGRectMake(0, 0, 230, 155);
    
    
    saveActionBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                           style:UIBarButtonItemStyleBordered
                                                          target:self
                                                          action:@selector(SaveAction:)];
    [termsSubController.navigationItem setLeftBarButtonItem:saveActionBarButton animated:NO];
    
    
    UIBarButtonItem *barButtonCancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:self
                                                                       action:@selector(CancelActionOnDoubleTap:)];
    
    
    
    [termsSubController.navigationItem setRightBarButtonItem:barButtonCancel animated:NO];
    
    termsSubController.title=@"Note";
    
    popoverController = [[UIPopoverController alloc]initWithContentViewController:navHybridController];
    popoverController.delegate=self;
    [popoverController setPopoverContentSize:CGSizeMake(230, 155) animated:YES];
    
    [popoverController presentPopoverFromRect:CGRectMake(HybridPopupFrame.origin.x, HybridPopupFrame.origin.y, 230, 155) inView:_drawingPad permittedArrowDirections:0  animated:YES];
    
    
}



-(UILabel*)getSPUerResizableText:(SPUserResizableView*)spUserResizableView{
    
    for(UIView *spView in [spUserResizableView subviews]){
        if([spView isMemberOfClass:[UIImageView class]]){
            
            for(UIView *spLabelView in [spView subviews]){
                if([spLabelView isMemberOfClass:[UILabel class]]){
                    UILabel *label=(UILabel*)spLabelView;
                    return label;
                }
                
                
            }
            
        }
        
    }
    return nil;
}





@end
