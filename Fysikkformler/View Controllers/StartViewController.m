//
//  ViewController.m
//  Fys1Formel
//
//  Created by Oscar Apeland on 04.12.13.
//  Copyright (c) 2013 Oscar Apeland. All rights reserved.
//

#import "StartViewController.h"
#import "FormelViewController.h"
#import "InfoViewViewController.h"
#import "MenuCell.h"
#import "Singleton.h"

@interface StartViewController () <UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate>

@property (strong) NSArray *menuObjects;
@property (strong, nonatomic) IBOutlet UITableView *menuTableView;
@end

@implementation StartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    /***STYLE NAV BAR***/
    self.navigationItem.title = @"Velg enhet";
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
        //iOS 6
        [self.navigationController.navigationBar setTintColor:RGB(6, 141, 253)];
    }else{
        //iOS 7
        self.navigationController.navigationBar.barTintColor = RGB(6, 141, 253);
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

    
    self.navigationController.delegate = self;
    
    //Infobutton
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(showInfo) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
   
    //Manuell JSON
    {self.menuObjects = @[
                         @{@"symbol": @"a",
                           @"name":@"Akselerasjon",
                           @"filepre":@"a"},
                         
                         @{@"symbol": @"W",
                           @"name":@"Arbeid",
                           @"filepre":@"W"},
                         
                         @{@"symbol":@"λ",
                           @"name":@"Bølgelengde",
                           @"filepre":@"b"},
                         
                         @{@"symbol":@"P",
                           @"name":@"Effekt",
                           @"filepre":@"P"},
                         
                         @{@"symbol":@"E",
                           @"name":@"Energi",
                           @"filepre":@"E"},
                         
                         @{@"symbol":@"v",
                           @"name":@"Fart",
                           @"filepre":@"v"},
                         
                         @{@"symbol":@"f",
                           @"name":@"Frekvens",
                           @"filepre":@"f"},
                         
                         @{@"symbol":@"R",
                           @"name":@"Friksjon",
                           @"filepre":@"R"},
                         
                         @{@"symbol":@"I",
                           @"name":@"Intensitet",
                           @"filepre":@"I"},
                         
                         @{@"symbol":@"Ek",
                           @"name":@"Kinetisk Energi",
                           @"filepre":@"Ek"},
                         
                         @{@"symbol":@"F",
                           @"name":@"Krefter",
                           @"filepre":@"Fs"},
                         
                         @{@"symbol":@"Q",
                           @"name":@"Ladning",
                           @"filepre":@"L"},
                         
                         @{@"symbol":@"m",
                           @"name":@"Masse",
                           @"filepre":@"m"},
                         
                         @{@"symbol":@"Ep",
                           @"name":@"Potensiell Energi",
                           @"filepre":@"Ep"},
                         
                         @{@"symbol":@"R",
                           @"name":@"Resistans",
                           @"filepre":@"Re"},
                         
                         @{@"symbol":@"U",
                           @"name":@"Spenning",
                           @"filepre":@"Us"},
                         
                         @{@"symbol":@"s",
                           @"name":@"Strekning",
                           @"filepre":@"s"},
                         
                         @{@"symbol":@"I",
                           @"name":@"Strøm",
                           @"filepre":@"Is"},
                         
                         @{@"symbol":@"T",
                           @"name":@"Temperatur",
                           @"filepre":@"Tm"},
                         
                         @{@"symbol":@"\u03C1",
                           @"name":@"Tetthet",
                           @"filepre":@"rho"},
                         
                         @{@"symbol":@"t",
                           @"name":@"Tid",
                           @"filepre":@"t"},
                         
                         @{@"symbol":@"p",
                           @"name":@"Trykk",
                           @"filepre":@"pp"},
                         
                         @{@"symbol":@"U",
                           @"name":@"Utstrålingstetthet",
                           @"filepre":@"U"},
                         
                         @{@"symbol":@"Q,q",
                           @"name":@"Varme",
                           @"filepre":@"Vm"},
                         
                         ];}
    
    [Singleton sharedData].menuObjects = self.menuObjects;
    
    [self.menuTableView registerNib:[UINib nibWithNibName:@"MenuCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MenuCell"];

    
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    //Hvis du kommer tilbake hit, de-select den du valgte i stad med animasjon
    if (viewController == self) {
        [self.menuTableView deselectRowAtIndexPath:[self.menuTableView indexPathForSelectedRow] animated:YES];
    }
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
-(void)showInfo{
    [self performSegueWithIdentifier:@"InfoViewSegue" sender:self];
    
}

#pragma mark - TableView

//Boilerplate tableview
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.menuObjects.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FormelViewController *formelVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FormelView"];
    formelVC.currentUnit = [self.menuObjects objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:formelVC animated:YES];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"MenuCell";
    MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[MenuCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    NSDictionary *dictionary = [self.menuObjects objectAtIndex:indexPath.row];

    cell.symbolLabel.text = [dictionary objectForKey:@"symbol"];
    cell.nameLabel.text = [dictionary objectForKey:@"name"];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){cell.symbolLabel.font = [UIFont fontWithName:LIGHT size:45.0f];}
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}

@end
