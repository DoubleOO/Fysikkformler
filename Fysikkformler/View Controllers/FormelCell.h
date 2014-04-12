//
//  FormelCell.h
//  Fys1Formel
//
//  Created by Oscar Apeland on 18.12.13.
//  Copyright (c) 2013 Oscar Apeland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Formel.h"
@interface FormelCell : UITableViewCell

/*Cellen i hver formelview som displayer formlene*/
@property IBOutlet UILabel *noteLabel;                  //Label for {"note"}
@property IBOutlet UIImageView *mainFormulaImageView;   //ImageView for main
@property IBOutlet UIImageView *flipFormulaImageView;   //ImageView for formelbokversjonen
@property (strong, retain) Formel *formula;             //Formelen cellen inneholder
@end
