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
    
    /***ALLOC***/
    self.actionSheetOptions = [[NSMutableArray alloc]init];
    self.allFormulas = [[NSMutableArray alloc]init];
    self.currentFormulas = [[NSMutableArray alloc]init];
    
    /***SETUP***/
    NSString *headerString = [[NSString alloc]initWithFormat:@"%@",self.currentUnit[@"name"]];
    self.navigationItem.title = headerString;
    
    //Longpress for å få opp contains
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.3f; //seconds
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    
    [self.view addGestureRecognizer:lpgr];
    
    
    //Infobutton øverst til høyre
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(showInfo) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    
    
    /***DATA LOADING***/
    
    
    
    if (![Singleton sharedData].JSONDict) { //Hvis Formulas.json ikke er loadet fra minnet
        NSString* pathToFile = [[NSBundle mainBundle] pathForResource:@"formulas" ofType:@"json"];
        
        NSData *data = [[NSData alloc]initWithContentsOfFile:pathToFile]; //Hent det
        NSError *error;
        NSDictionary * JSONDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error]; //Les det til JSON
        
        if(error){NSLog(@"%@",error);}
        [Singleton sharedData].JSONDict = JSONDict; //Og lagre referansen i Singleton
    }
    
    NSDictionary *currentDictionary = [Singleton sharedData].JSONDict[self.currentUnit[@"filepre"]]; //Hent info fra json basert på filepre
    self.currentInfo = [currentDictionary objectForKey:@"info"];                                     //Lagre info
    
    
    
    /***CALCULATING WIDEST PDF***/
    
    NSMutableArray *formulasForCurrentUnit = currentDictionary[@"formulas"]; //Listen med formler fra JSON
    NSMutableArray *biggestPDFArray = [[NSMutableArray alloc]init];
    
    
    for (int i = 0; i<= formulasForCurrentUnit.count; i++) {//Gå gjennom alle filene til formlene i json
        
        int num = i+1;
        
        {
            //Vanlig
            NSString *imageString = [[NSString alloc]initWithFormat:@"%@%i",self.currentUnit[@"filepre"],num];
            if ([[NSBundle mainBundle]pathForResource:imageString ofType:@"pdf"]) { //Hvis filen finnes
                NSURL *pdfURL = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:imageString ofType:@"pdf"]];
                NSLog(@"%@",pdfURL.pathComponents.lastObject);
                CGPDFDocumentRef doc = CGPDFDocumentCreateWithURL((__bridge CFURLRef)pdfURL);
                CGPDFPageRef page = CGPDFDocumentGetPage(doc, 1);
                CGRect mediaBox = CGPDFPageGetBoxRect(page, kCGPDFMediaBox); //Les bredden av PDFen
                CGPDFDocumentRelease(doc);
                
                NSNumber *width = [NSNumber numberWithInt:mediaBox.size.width]; //Lagre det til listen over størrelsen
                [biggestPDFArray addObject:width];
            }
        }
        {
            //Snudd
            NSString *imageString = [[NSString alloc]initWithFormat:@"%@%iSnudd",self.currentUnit[@"filepre"],num];
            if ([[NSBundle mainBundle]pathForResource:imageString ofType:@"pdf"]) { //Samme som vanlig over
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
    
    NSNumber *max = [biggestPDFArray valueForKeyPath:@"@max.self"]; //Velg det største objectet i listen over alle pdf-breddene, for scaling
    float scaleBy = 310/max.floatValue;
    
    
    /***MAKING EACH FORMULA***/
    
    for (int i = 0; i<formulasForCurrentUnit.count; i++) {//For hver formel
        NSDictionary *formulaInDict = [formulasForCurrentUnit objectAtIndex:i];
        //Generer formelobjectet som holder alle propertiene til en formel
        Formel *formel = [[Formel alloc]initWithDict:formulaInDict forChar:self.currentUnit[@"filepre"] andNumber:i+1 scaleBy:scaleBy];
        [self.allFormulas addObject:formel]; //Legg det til i lista over alle formlene for symbolet, til tableviewet.
    }
        
    /***CREATE TABLEVIEW***/
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //Registrer FormelCell.xib til tableviewen.
    [self.tableView registerNib:[UINib nibWithNibName:@"FormelCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"FormelCell"];
    
    
}

-(void)showInfo{
    //Vis "info" fra manuell JSON.
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Info" message:self.currentInfo delegate:nil cancelButtonTitle:@"Ferdig" otherButtonTitles:nil];
    [alertView show];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    //Få kun riktig type taps
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    CGPoint point = [gestureRecognizer locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    NSArray *contains = [(FormelCell*)[self.tableView cellForRowAtIndexPath:indexPath] formula].contains;//Finn hvilken celle de tappa på
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Løs for..."
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    for (NSString *filepre in contains) { //Legg til options på actionsheet
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
    
    [actionSheet showInView:self.view]; //Vis actionsheet med contains.
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"self.options: %@ \n clickedIndex: %ld \n buttonTitle: %@",self.actionSheetOptions,(long)buttonIndex,[actionSheet buttonTitleAtIndex:buttonIndex]);
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        [self.actionSheetOptions removeAllObjects];
        return;
    }
    
    NSDictionary *newFormula = [self.actionSheetOptions objectAtIndex:buttonIndex];
    
    //Lag ny instance av formelview med det valgte symbolet
    FormelViewController *formelView = [self.storyboard instantiateViewControllerWithIdentifier:@"FormelView"];
    formelView.currentUnit = newFormula;
    [self.navigationController pushViewController:formelView animated:YES];//Push det til navcontroller stacken
    
}

#pragma mark - tableview

//Bare boilerplate tableview
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
    
    
    //Boilerplate tableview. Lager ny celle hvis nil, setter bilde og formelproperty til tablecell.
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
    
    
    FormelCell *formelCell = (FormelCell*)[tableView cellForRowAtIndexPath:indexPath]; //Finn cellen man tappet
    
    //Bytt til det andre bildet
    if (formelCell.mainFormulaImageView.hidden) {
        formelCell.mainFormulaImageView.hidden = NO;
        formelCell.flipFormulaImageView.hidden = YES;
    }
    else {
        formelCell.mainFormulaImageView.hidden = YES;
        formelCell.flipFormulaImageView.hidden = NO;
    }
    //Deselect
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
