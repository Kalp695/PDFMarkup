//
//  TermsVC.m
//  TermTableDisc
//
//  Created by CFA IT on 6/10/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//

#import "TermsVC.h"
#import "CommonFunction.h"

@implementation TermsVC


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CommonFunction *commonFunction=[[CommonFunction alloc]init];
    NSDictionary *termsDictionary=[commonFunction getTermsDictionary];
    //arrayMainTerms=[[NSArray alloc]initWithObjects:@"Impact",@"Surface Condition",@"Discoloration",@"Weathering",@"Infestation", nil];
    
    //arraySubTerms1=[[NSArray alloc]initWithObjects:@"Abrasion",@"Chip",@"Crackle, Impact",@"Crease",@"Crushed",@"Cut",@"Dent",@"Dig",@"Dog-Ear",@"Element Broken",@"Element Missing",@"Fold",@"Gouge",@"Grinding/Rubbin",@"Puncture",@"Scratch",@"Scuff",@"Shellmark",@"Slipped Hinge",@"Support Failure",@"Tear",@"Mechanical Malfunction", nil];
    
    //arraySubTerms2=[[NSArray alloc]initWithObjects:@"Buckling / Cockleing/Dishing/Warping",@"Burnishing",@"Cockleing",@"Crack",@"Cracking",@"Crackle/Drying/Rift",@"Dishing",@"Edge Damage",@"Element Separated",@"Embrittlement",@"Flaking",@"Fraying",@"Hinge Damage",@"Hole",@"Lacuna",@"Lifting/Loose Paint",@"Split",@"Stretcher Marks",@"Wear/worn",@"Inherent to the manufacturing process of the object",@"Normal Wear & Tear", nil];
    
    //arraySubTerms3=[[NSArray alloc]initWithObjects:@"Adhesive Residue",@"Blanching",@"Bleeding",@"Burn Mark",@"Dirt/Grime/Accretion",@"Dust",@"Faded",@"Fingerprint/Handling Marks",@"Foxing",@"Smear/Smudge",@"Smoke Deposit",@"Spatter",@"Stain/Liquid/Run",@"Water Damage", nil];
    
    //arraySubTerms4=[[NSArray alloc]initWithObjects:@"Bleaching",@"Erosion",@"Oxidation",@"Photo Oxidation",@"Rust", nil];
    
    //arraySubTerms5=[[NSArray alloc]initWithObjects:@"Flight Hole",@"Frass",@"Insect Damage",@"Insect Detritus",@"Insect Infestation",@"Mold/Mildew", nil];
    
    
    arrayMainTerms=[[NSArray alloc]initWithArray:[termsDictionary allKeys]];
    
    arraySubTerms1=[[NSArray alloc]initWithArray:[termsDictionary objectForKey:@"Impact"]];
    
    arraySubTerms2=[[NSArray alloc]initWithArray:[termsDictionary objectForKey:@"Surface Condition"]];
    
    arraySubTerms3=[[NSArray alloc]initWithArray:[termsDictionary objectForKey:@"Discoloration"]];
    
    arraySubTerms4=[[NSArray alloc]initWithArray:[termsDictionary objectForKey:@"Weathering"]];
    
    arraySubTerms5=[[NSArray alloc]initWithArray:[termsDictionary objectForKey:@"Infestation"]];

    
    [self addLine];
  }


-(void)addLine{
   CAShapeLayer *myLayer = [[CAShapeLayer alloc] init];
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(0.0f, CGRectGetHeight(textViewTerm.frame)+61.5f)];
    [linePath addLineToPoint:CGPointMake(CGRectGetWidth(textViewTerm.frame)+3.0f, CGRectGetHeight(textViewTerm.frame)+61.5f)];
    
    myLayer.fillColor = nil;
    myLayer.strokeColor = [[UIColor lightGrayColor] CGColor];
    myLayer.lineWidth = 1.0f;
    
    myLayer.lineJoin = kCALineJoinBevel;
    myLayer.path = linePath.CGPath;
    [self.view.layer addSublayer:myLayer];
    
    [textViewTerm addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UITextView *tv = object;
    //Center vertical alignment
    //CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
    //topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    //tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
    
    //Bottom vertical alignment
    CGFloat topCorrect = ([tv bounds].size.height - 6*[tv contentSize].height);
    topCorrect = (topCorrect <0.0 ? 0.0 : topCorrect);
    tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
}

-(void)remove_AddSectionRows:(NSInteger)section{
    
        NSArray *paths = [self indexPathsInSection:section];
        if(toggle)
            [tblView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
        else
            [tblView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{              // Default is 1 if not implemented
    
    return [arrayMainTerms count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if([arrayMainTerms count]==1)
        return [self numberOfRowsInSection:section];
    
    return ((toggle && buttonTag==section+1)?[self numberOfRowsInSection:section]:0);
}


- (NSArray*)indexPathsInSection:(NSInteger)section
{
    NSMutableArray *paths = [NSMutableArray array];
    NSInteger row;
    for ( row = 0; row < [self numberOfRowsInSection:section]; row++ ) {
        [paths addObject:[NSIndexPath indexPathForRow:row inSection:section]];
    }
    return [NSArray arrayWithArray:paths];
}


- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowsCount=0.0;
    switch (section) {
        case 0:
            rowsCount=[arraySubTerms1 count];
            break;
        case 1:
            rowsCount=[arraySubTerms2 count];
            break;
        case 2:
            rowsCount=[arraySubTerms3 count];
            break;
        case 3:
            rowsCount=[arraySubTerms4 count];
            break;
        case 4:
            rowsCount=[arraySubTerms5 count];
            break;
            
        default:
            break;
    }
    
    return  rowsCount;
}


- (NSArray*)arrayOfRowsInSection:(NSInteger)section
{
    NSArray *rowsArray=nil;
    switch (section) {
        case 0:
            rowsArray=arraySubTerms1;
            break;
        case 1:
            rowsArray=arraySubTerms2;
            break;
        case 2:
            rowsArray=arraySubTerms3;
            break;
        case 3:
            rowsArray=arraySubTerms4;
            break;
        case 4:
            rowsArray=arraySubTerms5;
            break;
            
        default:
            break;
    }
    
    return  rowsArray;
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    CGRect sectionFrame = CGRectMake(0.0, 0.0, 450.0, 44.0);
    UIView *sectionView = [[UIView alloc] initWithFrame:sectionFrame];
    sectionView.tag=section+1;
    sectionView.alpha = 1.0;
    
    UITapGestureRecognizer *touchOnView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(releaseSectionAction:)];
    
    // Set required taps and number of touches
    [touchOnView setNumberOfTapsRequired:1];
    [touchOnView setNumberOfTouchesRequired:1];
    
    // Add the gesture to the view
    [sectionView addGestureRecognizer:touchOnView];
    //sectionView.layer.borderWidth=1.0;
    //sectionView.layer.borderColor=[UIColor lightGrayColor].CGColor;
    
    UIImage *buttonImageNormal = [UIImage imageNamed:@"sectionbkg.jpg"];
    UIImage *stretchableButtonImageNormal = [buttonImageNormal stretchableImageWithLeftCapWidth:12 topCapHeight:10];
    sectionView.backgroundColor = [UIColor colorWithPatternImage:stretchableButtonImageNormal];
    //sectionView.backgroundColor=[UIColor whiteColor];
    
    //Create number button
    CGRect frame = CGRectMake(13.0, 7.0, 30.0, 30.0);
    disclButton *disclButtonNumber=[disclButton buttonWithType:(UIButtonTypeSystem)];
    disclButtonNumber.delegate=self;
    disclButtonNumber.frame=frame;
                                    
    disclButtonNumber.tag=section+1;
    disclButtonNumber.tintColor=[UIColor blackColor];
    [sectionView addSubview:disclButtonNumber];
    
    
    // Create the label
    frame = CGRectMake(89.0, 10.0, 200.0, 21.0);
    UILabel *sectionLabel = [[UILabel alloc] initWithFrame:frame];
    sectionLabel.text =  [arrayMainTerms objectAtIndex:section];
    sectionLabel.font = [UIFont systemFontOfSize:15.0];
    sectionLabel.textColor = [UIColor blackColor];
    sectionLabel.shadowColor = [UIColor grayColor];
    sectionLabel.shadowOffset = CGSizeMake(0, 1);
    sectionLabel.backgroundColor = [UIColor clearColor];
    [sectionView addSubview:sectionLabel];
    
    
    //Create chevron button
    frame = CGRectMake(265.0, 7.0, 30.0, 30.0);
    disclButton *disclButtonChevron=[[disclButton alloc]initWithFrame:frame];
    disclButtonChevron.tag=section+5+1;
    disclButtonChevron.delegate=self;
    [sectionView addSubview:disclButtonChevron];
    
    return sectionView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if([arrayMainTerms count]==1)
        return 0.0;
    else
        return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 30;
}


// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)


 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
     
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
     cell.textLabel.text=[[self arrayOfRowsInSection:indexPath.section] objectAtIndex:indexPath.row];
     cell.textLabel.font=[UIFont systemFontOfSize:13.0f];
     
 // Configure the cell...
 
 return cell;
 }
 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    textViewTerm.text= [NSString stringWithFormat:@"%@ %@",textViewTerm.text,cell.textLabel.text];
    
    if(_delegate){
        NSString *strTerms=cell.textLabel.text;
        [_delegate TerminologySelected:strTerms];
    }

    /*
     UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
     UIViewController *subTerms_VC = [storyboard instantiateViewControllerWithIdentifier:@"subTerms_VC"];
     subTerms_VC.view.frame= CGRectMake(200, 200, 300, 400);
     UIView *mainView=self.view.superview.superview;
     [mainView addSubview:subTerms_VC.view];
     */
    // UIPopoverController *popOverController=[[UIPopoverController alloc]initWithContentViewController:subTerms_VC];
    //[popOverController presentPopoverFromRect:CGRectMake(200, 200, 300, 400) inView:cell permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}


-(void)buttonTappedWithTag:(NSInteger)tag{
    toggle=toggle==NO?YES:NO;
    if(toggle==NO && buttonTag!=tag){
        [self remove_AddSectionRows:buttonTag-1];
        toggle=YES;
    }
    buttonTag=tag;
    
    [self remove_AddSectionRows:buttonTag-1];
    
    if(toggle==YES){
        //[tblView scrollRectToVisible:CGRectMake(0, tblView.contentSize.height - tblView.bounds.size.height, tblView.bounds.size.width, tblView.bounds.size.height) animated:YES];
        
        NSIndexPath* ipath = [NSIndexPath indexPathForRow: 0 inSection: buttonTag-1];
        [tblView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];

    }
    
}


-(IBAction)releaseSectionAction:(UITapGestureRecognizer *)recognizer{
    UIView *sectionView=(UIView*)[recognizer view];
    
    [self buttonTappedWithTag:sectionView.tag];
    
}
@end
