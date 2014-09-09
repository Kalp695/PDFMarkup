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
    
    CGRect savedPageContentFrame;
    
    CAShapeLayer *buttonLineLayer;
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
   __weak SPUserResizableView *imageResizableView;
    
    
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
    PDFFileName *pdfFileNameObject;
    PDFPage *pdfPageObject;
    NSMutableArray *imageCollection;
    
    
    
    
    
    TermsVC *termsSubController;
    /**********************End***********************/
    
    
     ReaderContentView *contentPageView;
    UIBarButtonItem *pdfEditDoneBarButton;
   IBOutlet UIBarButtonItem *photoEditDoneBarButton;
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
@property (strong, nonatomic) IBOutlet UIView *drawingPad;
@property (weak, nonatomic) IBOutlet UISlider *lineWidthSlider;
@property (weak, nonatomic) IBOutlet UISegmentedControl *shapeSelector;
@property (weak, nonatomic) IBOutlet UISegmentedControl *lineWidthSegment;
@property (nonatomic, weak) SPUserResizableView *currentlyEditingView;
@property (nonatomic, weak) SPUserResizableView *lastEditedView;


@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIButton *colorBlackButton;
@property (weak, nonatomic) IBOutlet UIButton *colorRedButton;
@property (weak, nonatomic) IBOutlet UIButton *colorYellowButton;
@property (weak, nonatomic) IBOutlet UIButton *colorWhiteButton;
//end color


@property (weak, nonatomic) IBOutlet UIButton *buttonline;
@property (weak, nonatomic) IBOutlet UIButton *buttoncircle;
@property (weak, nonatomic) IBOutlet UIButton *buttonrectangle;
@property (weak, nonatomic)IBOutlet UIBarButtonItem *barButtonpencil;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonmagnifier;

@property (weak, nonatomic) IBOutlet UIButton *button1xWidth;
@property (weak, nonatomic) IBOutlet UIButton *button2xWidth;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *buttonDeleteShape;



@property (nonatomic, weak, readwrite) id <ReaderViewControllerDelegate> delegate;
@property(nonatomic,weak) id<SelectedDelegate> _delegate;;

@property (strong, nonatomic) NSString *pdfFilePath;
@property (strong, nonatomic) NSString *savedFolderPath;
@property (strong, nonatomic) NSString *pdfName;

-(IBAction)photoEditDoneBarButton_click:(id)sender;
- (id)initWithReaderDocument:(ReaderDocument *)object;


@end
