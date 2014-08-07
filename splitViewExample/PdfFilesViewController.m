//
//  PdfFilesViewController.m
//  splitViewExample
//
//  Created by ravi on 23/07/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import "PdfFilesViewController.h"
#import "FileItemTableCell.h"
#import "AppDelegate.h"
#import "DocumentViewController.h"
#import "CommonFunction/CommonFunction.h"

static PdfFilesViewController *sharedInstance = nil;

@interface PdfFilesViewController ()

@end

@implementation PdfFilesViewController
{
    AppDelegate * appDel;

}
+(PdfFilesViewController*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        
    }
    return sharedInstance;
}

@synthesize documentsGridButton,documentsTableView,pdfFiles;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDel.documentStatus isEqualToString:@"GridView"])
    {
        [self.view bringSubviewToFront:documentScrollView];
        documentScrollView.hidden = NO;
        documentsTableView.hidden = YES;
        [self gridViewButton_click:appDel.documentStatus ];
    }
    else if([appDel.documentStatus isEqualToString:@"TableView"])
    {
        [self.view bringSubviewToFront:documentsTableView];
        documentsTableView.hidden = NO;
        documentScrollView.hidden = YES;
        
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    /////// **** Code For Documents View ***** ////////
    
    
    documentsTableView.delegate = self;
    documentsTableView.dataSource = self;
    documentsTableView.hidden = YES;
    documenmtsArray = [[NSArray alloc ]init];
    [self getFilesFromDatabase ];

}
#pragma mark - Documents View

//////  **** Code For Documents **** /////
-(void)getFilesFromDatabase
{
    NSLog(@"pdf files is %@",[PdfFilesViewController getSharedInstance].pdfFiles);
    
   documenmtsArray =  [PdfFilesViewController getSharedInstance].pdfFiles ;

    NSLog(@"pdf names is %@",documenmtsArray);
    
}

-(IBAction)gridViewButton_click:(id)sender
{
    documentsTableView.hidden = YES;
    documentScrollView.hidden = NO;
    CGRect frame;
    for (int ij=0; ij<[documenmtsArray count]; ij++)
    {
        
        UIButton *btn_image = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn_image addTarget:self
                      action:@selector(viewPDF)
            forControlEvents:UIControlEventTouchUpInside];
        btn_image.tag = ij+100;
        
        thumbnailPdf = [documenmtsArray objectAtIndex:ij];
        
       // UIImageView *thumbnailImageView = [[UIImageView alloc] initWithImage:[self buildThumbnailImage]];
        [btn_image setImage:[UIImage imageNamed:@"pdf_Large.png" ]forState:UIControlStateNormal ];
        //[btn_image setImage:[UIImage imageNamed:@"pdf_Large.png"] forState:UIControlStateNormal];
        frame =CGRectMake(ij%3*170+20,ij/3*250+0,180,180);
        [ btn_image setFrame: frame];
        [documentScrollView addSubview:btn_image];
        
        thumbnailPdf = [[NSArray alloc ]init];
        
        UILabel * titleLabel = [[UILabel alloc ]init];
        titleLabel.text = [documenmtsArray objectAtIndex:ij];
        titleLabel.textColor = [UIColor blackColor ];
        titleLabel.font =[UIFont fontWithName:@"Helvetica" size:22];
        titleLabel.numberOfLines = 0;
        frame =CGRectMake(ij%3*170+62,ij/3*210+180,135,80);
        [ titleLabel setFrame: frame];
        [documentScrollView addSubview:titleLabel];
        
        
//        UILabel * itemCountLabel = [[UILabel alloc ]init];
//        itemCountLabel.text = [NSString stringWithFormat:@"%d items",[[[DBManager getSharedInstance ]getPdfList]count]];
//        itemCountLabel.textColor = [UIColor blackColor ];
//        itemCountLabel.font =[UIFont fontWithName:@"Helvetica" size:15];
//        itemCountLabel.numberOfLines = 0;
//        frame =CGRectMake(ij%3*170+75,ij/3*170+190,135,80);
//        [ itemCountLabel setFrame: frame];
//        [documentScrollView addSubview:itemCountLabel];
        
    }
    
}

-(IBAction)tableViewButton_click:(id)sender
{
    documentsTableView.hidden = NO;
    [documentsTableView reloadData];
    documentScrollView.hidden = YES;
}
-(void)viewPDF
{
    
    
}

//////   get pdf screenshot  /////////////////


- (UIImage *)buildThumbnailImage
{
    BOOL hasRetinaDisplay = FALSE;  // by default
    CGFloat pixelsPerPoint = 1.0;  // by default (pixelsPerPoint is just the "scale" property of the screen)
    
    if ([UIScreen instancesRespondToSelector:@selector(scale)])  // the "scale" property is only present in iOS 4.0 and later
    {
        // we are running iOS 4.0 or later, so we may be on a Retina display;  we need to check further...
        if ((pixelsPerPoint = [[UIScreen mainScreen] scale]) == 1.0)
            hasRetinaDisplay = FALSE;
        else
            hasRetinaDisplay = TRUE;
    }
    else
    {
        // we are NOT running iOS 4.0 or later, so we can be sure that we are NOT on a Retina display
        pixelsPerPoint = 1.0;
        hasRetinaDisplay = FALSE;
    }
    
    size_t imageWidth = 320;  // width of thumbnail in points
    size_t imageHeight = 460;  // height of thumbnail in points
    
    if (hasRetinaDisplay)
    {
        imageWidth *= pixelsPerPoint;
        imageHeight *= pixelsPerPoint;
    }
    
    size_t bytesPerPixel = 4;  // RGBA
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = bytesPerPixel * imageWidth;
    
    void *bitmapData = malloc(imageWidth * imageHeight * bytesPerPixel);
    
    // in the event that we were unable to mallocate the heap memory for the bitmap,
    // we just abort and preemptively return nil:
    if (bitmapData == NULL)
        return nil;
    
    // remember to zero the buffer before handing it off to the bitmap context:
    bzero(bitmapData, imageWidth * imageHeight * bytesPerPixel);
    
    CGContextRef theContext = CGBitmapContextCreate(bitmapData, imageWidth, imageHeight, bitsPerComponent, bytesPerRow,
                                                    CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
    
    CGPDFDocumentRef pdfDocument = MyGetPDFDocumentRef();  // NOTE: you will need to modify this line to supply the CGPDFDocumentRef for your file here...
    CGPDFPageRef pdfPage = CGPDFDocumentGetPage(pdfDocument, 1);  // get the first page for your thumbnail
    
    CGAffineTransform shrinkingTransform =
    CGPDFPageGetDrawingTransform(pdfPage, kCGPDFMediaBox, CGRectMake(0, 0, imageWidth, imageHeight), 0, YES);
    
    CGContextConcatCTM(theContext, shrinkingTransform);
    
    CGContextDrawPDFPage(theContext, pdfPage);  // draw the pdfPage into the bitmap context
    CGPDFDocumentRelease(pdfDocument);
    
    //
    // create the CGImageRef (and thence the UIImage) from the context (with its bitmap of the pdf page):
    //
    CGImageRef theCGImageRef = CGBitmapContextCreateImage(theContext);
    free(CGBitmapContextGetData(theContext));  // this frees the bitmapData we malloc'ed earlier
    CGContextRelease(theContext);
    
    UIImage *theUIImage;
    
    // CAUTION: the method imageWithCGImage:scale:orientation: only exists on iOS 4.0 or later!!!
    if ([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)])
    {
        theUIImage = [UIImage imageWithCGImage:theCGImageRef scale:pixelsPerPoint orientation:UIImageOrientationUp];
    }
    else
    {
        theUIImage = [UIImage imageWithCGImage:theCGImageRef];
    }
    
    CFRelease(theCGImageRef);
    return theUIImage;
}

CGPDFDocumentRef MyGetPDFDocumentRef()
{
    NSString *inputPDFFile = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"test.pdf"];
    const char *inputPDFFileAsCString = [inputPDFFile cStringUsingEncoding:NSASCIIStringEncoding];
    //NSLog(@"expecting pdf file to exist at this pathname: \"%s\"", inputPDFFileAsCString);
    
    CFStringRef path = CFStringCreateWithCString(NULL, inputPDFFileAsCString, kCFStringEncodingUTF8);
    
    CFURLRef url = CFURLCreateWithFileSystemPath(NULL, path, kCFURLPOSIXPathStyle, 0);
    CFRelease (path);
    
    CGPDFDocumentRef document = CGPDFDocumentCreateWithURL(url);
    CFRelease(url);
    
    if (CGPDFDocumentGetNumberOfPages(document) == 0)
    {
        printf("Warning: No pages in pdf file \"%s\" or pdf file does not exist at this path\n", inputPDFFileAsCString);
        return NULL;
    }
    
    return document;
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == documentsTableView)
    {
        return 1;
    }
    else
    {
        return 1;
        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [documenmtsArray count ];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    FileItemTableCell *cell;
    cell = (FileItemTableCell*)[documentsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
    {
        NSArray *nib;
        nib = [[NSBundle mainBundle] loadNibNamed:@"FileItemCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSLog(@"Printed data is %@",[documenmtsArray objectAtIndex:indexPath.row]);
    
    cell.label.text = [documenmtsArray objectAtIndex:indexPath.row];
    
    
//    UIImageView *thumbnailImageView = [[UIImageView alloc] initWithImage:[self buildThumbnailImage]];
//
//    cell.folderImage.image = thumbnailImageView.image;
    
    cell.folderImage.image = [UIImage imageNamed:@"pdf.png" ];
    
    
    UIImageView *dot =[[UIImageView alloc] initWithFrame:CGRectMake(390,15,25,25)];
    dot.image=[UIImage imageNamed:@"normalDisclosure.png"];
    [cell addSubview:dot];
    
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    return cell;
    
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommonFunction *commonFunction=[[CommonFunction alloc]init];
    
    NSString *pdfFilePath=[[commonFunction getDoumentPath] stringByAppendingPathComponent:[documenmtsArray objectAtIndex:indexPath.row]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"Nav_reader"];
    ReaderViewController *readerViewController=(ReaderViewController*)[navController.viewControllers objectAtIndex:0];
    [readerViewController setPdfFilePath:pdfFilePath];
    
    [self.navigationController presentViewController:navController animated:YES completion:nil];
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
