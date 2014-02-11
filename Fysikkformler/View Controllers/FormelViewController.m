//
//  FormelViewController.m
//  Fys1Formel
//
//  Created by Oscar Apeland on 18.12.13.
//  Copyright (c) 2013 Oscar Apeland. All rights reserved.
//

#import "FormelViewController.h"
#import "FormelCell.h"
#import "Formel.h"
#import "UIImage+PDF.h"


@interface FormelViewController ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,UIActionSheetDelegate>
@property UITableView *tableView;
@property NSMutableArray *allFormulas;
@property NSMutableArray *currentFormulas;
@end

@implementation FormelViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Unit %@",self.currentUnit);
    NSString *headerString = [[NSString alloc]initWithFormat:@"%@",[self.allTypes objectForKey:self.currentUnit]];
    self.navigationItem.title = headerString;

    self.allFormulas = [[NSMutableArray alloc]init];
    self.currentFormulas = [[NSMutableArray alloc]init];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.3f; //seconds
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;

    [self.view addGestureRecognizer:lpgr];
    
    
    NSString* pathToFile = [[NSBundle mainBundle] pathForResource:@"finito" ofType:@"json"];
    
    NSData *data = [[NSData alloc]initWithContentsOfFile:pathToFile];
    NSError *error;
    NSDictionary * JSONDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if (error) {
        NSLog(@"%@",error);
    }
    
    NSDictionary *currentDictionary = [JSONDict objectForKey:self.currentUnit];
    
    NSMutableArray *formulasForCurrentUnit = [[NSMutableArray alloc]init];
    formulasForCurrentUnit = [currentDictionary objectForKey:@"formulas"];
    
    
    
    
    /***CALCULATING WIDEST PDF***/
    NSMutableArray *biggestPDFArray = [[NSMutableArray alloc]init];
    
    for (int i = 0; i<=formulasForCurrentUnit.count; i++) {
        int num = i+1;
        NSString *imageString = [[NSString alloc]initWithFormat:@"%@%i.pdf",self.currentUnit,num];
        UIImage *originalImage = [UIImage originalSizeImageWithPDFNamed:imageString];
        NSNumber *size = [NSNumber numberWithInt:originalImage.size.width];
        
        [biggestPDFArray addObject:size];
        
        NSString *flipImageString = [[NSString alloc]initWithFormat:@"%@%iSnudd.pdf",self.currentUnit,num];
        UIImage *flipImage = [UIImage originalSizeImageWithPDFNamed:flipImageString];
        NSNumber *flipSize = [NSNumber numberWithInt:flipImage.size.width];
        NSLog(@"%@ %@",flipImageString,imageString);
        [biggestPDFArray addObject:flipSize];

    }
    
    NSNumber * max = [biggestPDFArray valueForKeyPath:@"@max.self"];
    float scaleBy = 310/max.floatValue;
    
    
    /***MAKING EACH FORMULA***/
    for (int i = 0; i<formulasForCurrentUnit.count; i++) {
        NSDictionary *formulaInDict = [formulasForCurrentUnit objectAtIndex:i];
        Formel *formel = [[Formel alloc]initWithDict:formulaInDict forChar:self.currentUnit andNumber:i+1 scaleBy:scaleBy];
        [self.allFormulas addObject:formel];
    }
    
    
    /***CREATE TABLEVIEW***/
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 65, 320, self.view.frame.size.height-65)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"FormelCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"FormelCell"];
    [self.view addSubview:self.tableView];
   
    
    
    
    

}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (indexPath == nil){
        NSLog(@"couldn't find index path");
    } else {
        //FormelCell* cell = (FormelCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        NSInteger cellRow = indexPath.row;
        Formel *selectedFormel = [self.allFormulas objectAtIndex:cellRow];
        [self presentActionSheetWithUnits:selectedFormel.contains];
        // do stuff with the cell
    }
}
-(void)presentActionSheetWithUnits:(NSArray *)units{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Solve for.."
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    for (NSString *title in units) {
        [actionSheet addButtonWithTitle:title];
    }
    
    [actionSheet addButtonWithTitle:@"Avbryt"];
    actionSheet.cancelButtonIndex = units.count;
    
    [actionSheet showInView:self.view];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *buttonTitle =  [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Avbryt"]) {
        return;
    }
    FormelViewController *formelView = [self.storyboard instantiateViewControllerWithIdentifier:@"FormelView"];
    formelView.currentUnit = buttonTitle;
    formelView.allTypes = self.allTypes;
    [self.navigationController pushViewController:formelView animated:YES];

}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150.0f;
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150.0f;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.allFormulas.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellID = @"FormelCell";
    
    FormelCell *cell = (FormelCell*)[tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[FormelCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        
    }
    [cell setupGestures];
    
    cell.mainFormulaImageView.contentMode = UIViewContentModeCenter;
    cell.flipFormulaImageView.contentMode = UIViewContentModeCenter;
    [cell setContentMode:UIViewContentModeCenter];
    
    Formel *formel = [self.allFormulas objectAtIndex:indexPath.row];
    cell.noteLabel.text = formel.note;
    cell.mainFormulaImageView.image = formel.mainFormelImage;
    cell.flipFormulaImageView.image = formel.flipFormelImage;
    cell.flipFormulaImageView.hidden = YES;
    return cell;

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    FormelCell *formelCell = (FormelCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    if (formelCell.mainFormulaImageView.hidden) {
        formelCell.mainFormulaImageView.hidden = NO;
        formelCell.flipFormulaImageView.hidden = YES;
    }
    else {
        formelCell.mainFormulaImageView.hidden = YES;
        formelCell.flipFormulaImageView.hidden = NO;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
