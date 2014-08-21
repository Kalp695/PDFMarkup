//
//  BFViewController.m
//  CropDemo
//
//  Created by John Nichols on 2/28/13.
//  Copyright (c) 2013 John Nichols. All rights reserved.
//

#import "BFViewController.h"

@interface BFViewController ()

@end

@implementation BFViewController

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/256.0f green:(g)/256.0f blue:(b)/256.0f alpha:1.0f]

@synthesize delegate=_delegate;
@synthesize image_no;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    loadingView=nil;
    loadingView =
    [LoadingView loadingViewInView:self.view inLoadingText:@"Loading..."];
	
	[self
     performSelector:@selector(loadCropView)
     withObject:nil
     afterDelay:0.0];

    }

-(void)loadCropView{
    // make your image view content mode == aspect fit
    // yields best results
    self.displayImage.contentMode = UIViewContentModeScaleAspectFit;
    
    // must have user interaction enabled on view that will hold crop interface
    self.displayImage.userInteractionEnabled = YES;
    self.displayImage.image = self.originalImage;
    //self.displayImage.frame = CGRectMake(20, 20, 600, 750);
    //self.originalImage = [UIImage imageNamed:@"dumbo.jpg"];
    
    
    cropButton.layer.borderWidth=1.0f;
    cropButton.layer.borderColor=RGBCOLOR(214, 214, 214).CGColor;
    cropButton.layer.cornerRadius=7;
    
    useButton.layer.borderWidth=1.0f;
    useButton.layer.borderColor=RGBCOLOR(214, 214, 214).CGColor;
    useButton.layer.cornerRadius=7;
    
    originalButton.layer.borderWidth=1.0f;
    originalButton.layer.borderColor=RGBCOLOR(214, 214, 214).CGColor;
    originalButton.layer.cornerRadius=7;
    
    
    
    cropBarButton= [[UIBarButtonItem alloc] init];
    cropBarButton.title=@"Crop";
    [cropBarButton setTarget:self];
    [cropBarButton setAction:@selector(cropPressed:)];
    
    UIBarButtonItem *useBarButton= [[UIBarButtonItem alloc] init];
    useBarButton.title=@"Use";
    [useBarButton setTarget:self];
    [useBarButton setAction:@selector(usePressed:)];
    
    UIBarButtonItem *originalBarButton= [[UIBarButtonItem alloc] init];
    originalBarButton.title=@"Original";
    [originalBarButton setTarget:self];
    [originalBarButton setAction:@selector(originalPressed:)];
    
    
    UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target: self action:@selector(cancelPressed:)];
    
    
    
    //spacer
    UIBarButtonItem *spaceBarButton= [[UIBarButtonItem alloc] init];
    spaceBarButton.title=@" ";
    [spaceBarButton setTarget:nil];
    [spaceBarButton setAction:nil];
    
    
    
    self.navigationItem.leftBarButtonItems=[[NSArray alloc]initWithObjects:cropBarButton,spaceBarButton,useBarButton,spaceBarButton,originalBarButton, nil];
    
    self.navigationItem.rightBarButtonItem=cancelBarButton;
    
    // ** this is where the magic happens
    
    // allocate crop interface with frame and image being cropped
    
   

    
    CGFloat imageWidth=  self.originalImage.size.width;
    CGFloat imageHeight=  self.originalImage.size.height;
    
    
    CGRect rect=CGRectMake(0, 0, 500, 520);
    if(abs(imageWidth-imageHeight)<=50){
        
         rect=CGRectMake(0, 0, 500, 520);
        
    }

    else if(imageWidth>imageHeight){
        rect=CGRectMake(0, 0, 500, 520);
        
    }
    
    else if(imageHeight>imageWidth){
        rect=CGRectMake(0, 0, 500, 520);
        
    }

    self.cropper = [[BFCropInterface alloc]initWithFrame:rect andImage:self.displayImage];
    
    // this is the default color even if you don't set it
    self.cropper.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.60];
    // white is the default border color.
    self.cropper.borderColor = [UIColor whiteColor];
    // add interface to superview. here we are covering the main image view.
    //[self.displayImage addSubview:self.cropper];
    [self.view addSubview:self.cropper];
    
    self.useImage=self.originalImage;
    
    [loadingView
     performSelector:@selector(removeView)
     withObject:nil
     afterDelay:0.0];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelPressed:(id)sender {
    // crop image
    if(_delegate!=nil){
        [_delegate cancelCropPhoto];
        // remove crop interface from superview
        [self.cropper removeFromSuperview];
        self.cropper = nil;
        
    }
}

- (IBAction)cropPressed:(id)sender {
    loadingView=nil;
    loadingView =
    [LoadingView loadingViewInView:self.view inLoadingText:@"Cropping..."];
	
	[self
     performSelector:@selector(cropImage)
     withObject:nil
     afterDelay:0.0];
    
}

-(void)cropImage{
    
    // crop image
    UIImage *croppedImage = [self.cropper getCroppedImage];
    self.useImage=croppedImage;
    
    // remove crop interface from superview
    [self.cropper removeFromSuperview];
    self.cropper = nil;
    
    // display new cropped image
    self.displayImage.image = croppedImage;
    
    cropBarButton.enabled=NO;
    [loadingView
     performSelector:@selector(removeView)
     withObject:nil
     afterDelay:0.0];
    
}

- (IBAction)usePressed:(id)sender {
    loadingView=nil;
    loadingView =
    [LoadingView loadingViewInView:self.view inLoadingText:@"Loading..."];
    
    [self
     performSelector:@selector(useCropImage)
     withObject:nil
     afterDelay:0.0];
}

-(void)useCropImage{
    // use image
    

    
    [loadingView
     performSelector:@selector(removeView)
     withObject:nil
     afterDelay:0.0];
    
    
    [self
     performSelector:@selector(sendCropImage)
     withObject:nil
     afterDelay:0.0];


    
    
   

}

-(void)sendCropImage{
    if(_delegate!=nil){
        [_delegate cropPhoto:self.useImage withImageNo:image_no];
        // remove crop interface from superview
        [self.cropper removeFromSuperview];
        self.cropper = nil;
        
    }
}


- (IBAction)originalPressed:(id)sender {
    // set main image view to original image and add cropper if not already added
    self.displayImage.image = self.originalImage;
    self.useImage=self.originalImage;
    if (!self.cropper) {
        CGFloat imageWidth=  self.originalImage.size.width;
        CGFloat imageHeight=  self.originalImage.size.height;
        
        
        CGRect rect=CGRectMake(0, 0, 500, 520);
        if(abs(imageWidth-imageHeight)<=50){
            
            rect=CGRectMake(0, 0, 500, 520);
            
        }
        
        else if(imageWidth>imageHeight){
            rect=CGRectMake(0, 0, 500, 520);
            
        }
        
        else if(imageHeight>imageWidth){
            rect=CGRectMake(0, 0, 500, 520);
            
        }

        self.cropper = [[BFCropInterface alloc]initWithFrame:rect andImage:self.displayImage];
        [self.view addSubview:self.cropper];
        //[self.displayImage addSubview:self.cropper];
    }
    
    cropBarButton.enabled=YES;
}

@end
