//
//	ReaderViewController.h
//	Reader v2.7.1
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

#import <UIKit/UIKit.h>

#import "ReaderDocument.h"
#import "Declare.h"
#import "CommonFunction.h"
#import "myShape.h"
#import "ReaderContentView.h"
#import  "SPUserResizableView.h"
#import "TermsVC.h"
#import "MagnifierView.h"
#import "PreviewViewController.h"
#import "ThumbsViewController.h"
#import "ReaderThumbCache.h"
#import "ReaderThumbQueue.h"
#import "BFViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <DropboxSDK/DropboxSDK.h>
@class DBRestClient;

@class ReaderViewController;

@protocol SelectedDelegate
- (void)ShapeSelected:(bool)selected;
@end


@protocol ReaderViewControllerDelegate <NSObject>

@optional // Delegate protocols

- (void)dismissReaderViewController:(ReaderViewController *)viewController;

@end

@interface ReaderViewController : UIViewController<UITextViewDelegate,UIPopoverControllerDelegate,UIGestureRecognizerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,SelectedTerminologyDelegate,SPUserResizableViewDelegate,closeMagnifierDelegate,ExportDelegate,DBRestClientDelegate,cropPhotoDelegate>{
    IBOutlet UIToolbar *toolBar;
    CGRect savedPageContentFrame;
    
    IBOutlet UIButton *colorBlackButton;
    IBOutlet UIButton *colorRedButton;
    IBOutlet UIButton *colorYellowButton;
    IBOutlet UIButton *colorWhiteButton;
    //end color
    
    
    IBOutlet UIButton *buttonline;
    IBOutlet UIButton *buttoncircle;
    IBOutlet UIButton *buttonrectangle;
    IBOutlet UIBarButtonItem *barButtonpencil;
    IBOutlet UIBarButtonItem *barButtonmagnifier;
    
    IBOutlet UIButton *button1xWidth;
    IBOutlet UIButton *button2xWidth;
    CAShapeLayer *buttonLineLayer;
    IBOutlet UIBarButtonItem *buttonDeleteShape;
    CommonFunction *commonFunction;
    
    /*******************Drwaing Shape*********************/
    bool skipDrawingCurrentShape;
    bool savedColorPickerHiddenState;
    bool currentSaved;
    NSInteger selectedIndex;
    NSInteger savedLineWidthValue;
    BOOL savedDashedState;
    CGPoint savedShapeStartpoint;
    CGPoint savedShapeEndpoint;
    CGPoint selectedShapeStartpoint;
    CGPoint selectedShapeEndpoint;
    int shape_no;
    BOOL drag;
    BOOL cornerDrag;
    IBOutlet UIButton *deleteButton;
    CGRect rectangle;
    UIBezierPath *bPath;
    MagnifierView *magnifierView;
    
    
    UITextView *txtNoteView;
    UINavigationController *navHybridController;
    UIBarButtonItem *saveActionBarButton;
    UIPopoverController *popoverController;
    UIPopoverController *popoverControllerCrop;
    PreviewViewController *previewViewController;
    UIImagePickerController*imagePicker;
    UIImage *cameraImage;
    NSInteger TOCheckLoginViewAppearance;
    CGFloat xCrop,yCrop, widthCrop, heightCrop;
    SPUserResizableView *imageResizableView;
    
    
    UILabel *XYLabel;
    
    UIImage *incrementalImage;
    CGPoint pts[5]; // we now need to keep track of the four points of a Bezier segment and the first control point of the next segment
    uint ctr;
    
    //Signature
    
    
    
    UIBezierPath *pencilPath;
    UIBezierPath *pencilBezierPath;
    NSTimer *holdTimer;
    UIBarButtonItem *magnifierBarButton;
    NSString *folderPath;
    
    
    
    
    id<SelectedDelegate> _delegate;
    
    TermsVC *termsSubController;
    /**********************End***********************/
    
    
     ReaderContentView *contentPageView;
    UIBarButtonItem *editDoneBarButton;
    NSString *reportID;
    
    
    /**********************NEW CODE***********************/
    // POP Over
    
    NSMutableArray * popOverListArray;
   // DBRestClient* restClient;


}
+(ReaderViewController*)getSharedInstance;

@property (strong, atomic) myShape *currentShape;
@property UIColor *currentColor;
@property NSInteger currentShapeType;
@property CGFloat currentLineWidth;
//@property NSInteger currentColor;


@property (assign, nonatomic, getter = isRotating) BOOL rotating;
@property (strong, nonatomic) NSMutableArray *collection;
@property (strong, nonatomic) NSMutableArray *undo_collection;
@property (strong, nonatomic) NSMutableArray *pickerArray;
@property (strong, nonatomic) NSMutableArray *fileSaveArray;
@property (strong, nonatomic) NSString *fileExtension;
@property (weak, nonatomic) IBOutlet UISwitch *dashedLineSelector;


//drawing pad
@property (weak, nonatomic) IBOutlet UIView *drawingPad;
@property (weak, nonatomic) IBOutlet UISlider *lineWidthSlider;
@property (weak, nonatomic) IBOutlet UISegmentedControl *shapeSelector;
@property (weak, nonatomic) IBOutlet UISegmentedControl *lineWidthSegment;
@property (nonatomic, retain) SPUserResizableView *currentlyEditingView;
@property (nonatomic, retain) SPUserResizableView *lastEditedView;


@property (nonatomic, weak, readwrite) id <ReaderViewControllerDelegate> delegate;

@property (strong, nonatomic) NSString *pdfFilePath;
@property (strong, nonatomic) NSString *savedFolderPath;
@property (strong, nonatomic) NSString *pdfName;

- (id)initWithReaderDocument:(ReaderDocument *)object;

@end
