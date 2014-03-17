//
//  FormelCell.h
//  Fys1Formel
//
//  Created by Oscar Apeland on 18.12.13.
//  Copyright (c) 2013 Oscar Apeland. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FormelCell : UITableViewCell
@property IBOutlet UILabel *noteLabel;
@property IBOutlet UIImageView *mainFormulaImageView;
@property IBOutlet UIImageView *flipFormulaImageView;
@property NSDictionary *formula;
@end
