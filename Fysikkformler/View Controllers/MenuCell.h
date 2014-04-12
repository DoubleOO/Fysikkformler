//
//  MenuCell.h
//  Fysikkformler
//
//  Created by Oscar Apeland on 17.03.14.
//  Copyright (c) 2014 Oscar Apeland. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuCell : UITableViewCell
/*Cellen i menyen som viser symbolene*/
@property (strong, nonatomic) IBOutlet UILabel *symbolLabel;    //Venstre, LIGHT 45pt, symbol
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;      //Høyre, navnet til symbolet

@end
