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
#import "Singleton.h"
#import <ImageIO/ImageIO.h>

@interface FormelViewController ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,UIActionSheetDelegate>
@property IBOutlet UITableView *tableView;
@property NSMutableArray *allFormulas;
@property NSMutableArray *currentFormulas;
@property NSString *currentInfo;
@property NSMutableArray *actionSheetOptions;
@end

@implementation FormelViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Viewing %@",self.currentUnit);
    self.actionSheetOptions = [[NSMutableArray alloc]init];
    
    /***SETUP***/
    NSString *headerString = [[NSString alloc]initWithFormat:@"%@",self.currentUnit[@"name"]];
    self.navigationItem.title = headerString;
    
    self.allFormulas = [[NSMutableArray alloc]init];
    self.currentFormulas = [[NSMutableArray alloc]init];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.3f; //seconds
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    
    [self.view addGestureRecognizer:lpgr];
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(showInfo) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    
    
    /***DATA LOADING***/
    
    if (![Singleton sharedData].JSONDict) {
        NSString* pathToFile = [[NSBundle mainBundle] pathForResource:@"formulas" ofType:@"json"];
        
        NSData *data = [[NSData alloc]initWithContentsOfFile:pathToFile];
        NSError *error;
        NSDictionary * JSONDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if(error){NSLog(@"%@",error);}
        [Singleton sharedData].JSONDict = JSONDict;
    }
    
    NSDictionary *currentDictionary = [Singleton sharedData].JSONDict[self.currentUnit[@"filepre"]];
    self.currentInfo = [currentDictionary objectForKey:@"info"];
    
    NSMutableArray *formulasForCurrentUnit = currentDictionary[@"formulas"];
    
    
    /***CALCULATING WIDEST PDF***/
    NSMutableArray *biggestPDFArray = [[NSMutableArray alloc]init];
    
    for (int i = 0; i<= formulasForCurrentUnit.count; i++) {
        
        int num = i+1;
        
        {
            //Vanlig
            NSString *imageString = [[NSString alloc]initWithFormat:@"%@%i",self.currentUnit[@"filepre"],num];
            if ([[NSBundle mainBundle]pathForResource:imageString ofType:@"pdf"]) {
                NSURL *pdfURL = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:imageString ofType:@"pdf"]];
                NSLog(@"%@",pdfURL.pathComponents.lastObject);
                CGPDFDocumentRef doc = CGPDFDocumentCreateWithURL((__bridge CFURLRef)pdfURL);
                CGPDFPageRef page = CGPDFDocumentGetPage(doc, 1);
                CGRect mediaBox = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
                CGPDFDocumentRelease(doc);
                
                NSNumber *width = [NSNumber numberWithInt:mediaBox.size.width];
                [biggestPDFArray addObject:width];
            }
        }
        {
            //Snudd
            NSString *imageString = [[NSString alloc]initWithFormat:@"%@%iSnudd",self.currentUnit[@"filepre"],num];
            if ([[NSBundle mainBundle]pathForResource:imageString ofType:@"pdf"]) {
                NSURL *pdfURL = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:imageString ofType:@"pdf"]];
                NSLog(@"%@",pdfURL.pathComponents.lastObject);
                CGPDFDocumentRef doc = CGPDFDocumentCreateWithURL((__bridge CFURLRef)pdfURL);
                CGPDFPageRef page = CGPDFDocumentGetPage(doc, 1);
                CGRect mediaBox = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
                CGPDFDocumentRelease(doc);
                
                NSNumber *width = [NSNumber numberWithInt:mediaBox.size.width];
                [biggestPDFArray addObject:width];
                
            }
        }
    }
    
    NSNumber *max = [biggestPDFArray valueForKeyPath:@"@max.self"];
    float scaleBy = 310/max.floatValue;
    
    
    /***MAKING EACH FORMULA***/
    for (int i = 0; i<formulasForCurrentUnit.count; i++) {
        NSDictionary *formulaInDict = [formulasForCurrentUnit objectAtIndex:i];
        Formel *formel = [[Formel alloc]initWithDict:formulaInDict forChar:self.currentUnit[@"filepre"] andNumber:i+1 scaleBy:scaleBy];
        [self.allFormulas addObject:formel];
    }
        
    /***CREATE TABLEVIEW***/
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"FormelCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"FormelCell"];
    
    
}

-(void)showInfo{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Info" message:self.currentInfo delegate:nil cancelButtonTitle:@"Ferdig" otherButtonTitles:nil];
    [alertView show];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    CGPoint point = [gestureRecognizer locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    NSArray *contains = [(FormelCell*)[self.tableView cellForRowAtIndexPath:indexPath] formula].contains;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Løs for..."
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    for (NSString *filepre in contains) {
        for (NSDictionary *menuObject in [Singleton sharedData].menuObjects) {
            if ([filepre isEqualToString:menuObject[@"filepre"]]) {
                NSString *buttonTitle = menuObject[@"symbol"];
                [actionSheet addButtonWithTitle:buttonTitle];
                [self.actionSheetOptions addObject:menuObject];
            }
        }
    }
    
    [actionSheet addButtonWithTitle:@"Avbryt"];
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons-1;
    
    [actionSheet showInView:self.view];
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"self.options: %@ \n clickedIndex: %ld \n buttonTitle: %@",self.actionSheetOptions,(long)buttonIndex,[actionSheet buttonTitleAtIndex:buttonIndex]);
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        [self.actionSheetOptions removeAllObjects];
        return;
    }
    
    NSDictionary *newFormula = [self.actionSheetOptions objectAtIndex:buttonIndex];
    
    FormelViewController *formelView = [self.storyboard instantiateViewControllerWithIdentifier:@"FormelView"];
    formelView.currentUnit = newFormula;
    [self.navigationController pushViewController:formelView animated:YES];
    
}

#pragma mark - tableview
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
    cell.mainFormulaImageView.contentMode = UIViewContentModeCenter;
    cell.flipFormulaImageView.contentMode = UIViewContentModeCenter;
    [cell setContentMode:UIViewContentModeCenter];
    
    Formel *formel = [self.allFormulas objectAtIndex:indexPath.row];
    
    cell.formula = formel;
    cell.noteLabel.text = formel.note;
    cell.mainFormulaImageView.image = formel.mainFormelImage;
    cell.flipFormulaImageView.image = formel.flipFormelImage;
    
    
    if (!cell.mainFormulaImageView.hidden && !cell.flipFormulaImageView.hidden) {
        cell.flipFormulaImageView.hidden = YES;
    }
    if (cell.mainFormulaImageView.hidden && cell.flipFormulaImageView.hidden) {
        cell.flipFormulaImageView.hidden = YES;
        cell.mainFormulaImageView.hidden = NO;
    }
    
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
