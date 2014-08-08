//
//  TermsVC.h
//  TermTableDisc
//
//  Created by CFA IT on 6/10/14.
//  Copyright (c) 2014 CFA IT. All rights reserved.
//


#import "disclButton.h"

@protocol SelectedTerminologyDelegate
- (void)TerminologySelected:(NSString *)terms;
@end

@interface TermsVC : UIViewController<UITableViewDelegate,UITableViewDataSource,disclButtonDelegate>{
    
    NSArray *arrayMainTerms;
    NSArray *arraySubTerms1;
    NSArray *arraySubTerms2;
    NSArray *arraySubTerms3;
    NSArray *arraySubTerms4;
    NSArray *arraySubTerms5;
    IBOutlet UITableView *tblView;
    IBOutlet UITextView *textViewTerm;
    NSInteger no_Rows_Section;
    BOOL toggle;
    NSInteger buttonTag;
    
}

@property (nonatomic, retain) id<SelectedTerminologyDelegate> delegate;

@end
