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
@interface StartViewController () <UIScrollViewDelegate>

@property (strong) NSDictionary *allTypes;

@end

@implementation StartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"Velg enhet";
    self.navigationController.navigationBar.barTintColor = RGB(6, 141, 253);
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [btn addTarget:self action:@selector(showInfo) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.allTypes = @{@"a":@"Akselerasjon",
                      @"W":@"Arbeid",
                      @"\u03BB":@"Bølgelengde",
                      @"P":@"Effekt",
                      @"E":@"Energi",
                      @"v":@"Fart",
                      @"f":@"Frekvens",
                      @"R":@"Friksjon",
                      @"Ek":@"Kinetisk energi",
                      @"m":@"Masse",
                      @"Ep":@"Potensiell energi",
                      @"s":@"Strekning",
                      @"\u03C1":@"Massetetthet",
                      @"t":@"Tid",
                      @"p":@"Trykk",
                      //@"F":@"Krefter",
                      @"V":@"Volum", //vi har ingen vei videre ennå
                      //@"Q":@"Varme",
                      };
    
    int spacing = 2;
    NSArray *sortedKeys = [self.allTypes.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 65, 320, 503)];
    scrollView.contentSize = CGSizeMake(320, ((self.allTypes.allValues.count*80)+sortedKeys.count*spacing));
    scrollView.delegate = self;
    
    for (int i = 0; i<sortedKeys.count; i++) {
        
        UIControl *unitControl = [[UIControl alloc]init];
        [unitControl setFrame:CGRectMake(2, (i*80+2)+i*spacing, self.view.frame.size.width-4, 80)];
       
        
        UILabel *unitLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,0, 80, 80)];
        unitLabel.font = [UIFont fontWithName:THIN size:60.0f];
        unitLabel.textColor = [UIColor colorWithWhite:0.4f alpha:1];
        unitLabel.textAlignment = NSTextAlignmentCenter;
        unitLabel.text = [sortedKeys objectAtIndex:i];
        
        UILabel *unitTextLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 30, 200, 25)];
        unitTextLabel.font = [UIFont fontWithName:LIGHT size:20.0f];
        unitTextLabel.text = [self.allTypes objectForKey:unitLabel.text];
        unitTextLabel.textAlignment = NSTextAlignmentLeft;
        unitTextLabel.backgroundColor = [UIColor clearColor];
       
        
        [unitControl setBackgroundColor:[UIColor colorWithWhite:0.98f alpha:1]];
        [unitControl addSubview:unitTextLabel];
        [unitControl addSubview:unitLabel];
        [unitControl addTarget:self action:@selector(unitTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:unitControl];

    }
    
    UIView *whiteBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height)];
    whiteBackView.backgroundColor = [UIColor whiteColor];
    
    [scrollView addSubview:whiteBackView];
    [scrollView sendSubviewToBack:whiteBackView];
    
    [self.view addSubview:scrollView];
    [self.view bringSubviewToFront:scrollView];
   
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
-(void)showInfo{
    [self performSegueWithIdentifier:@"InfoViewSegue" sender:self];
    
}
-(void)unitTouchedUpInside:(id)sender{
    UIControl *touchedControl = (UIControl*)sender;
    
    NSString *unitString = [(UILabel*)[touchedControl.subviews objectAtIndex:1] text];
    
    FormelViewController *formelView = [self.storyboard instantiateViewControllerWithIdentifier:@"FormelView"];
    formelView.currentUnit = unitString;
    formelView.allTypes = self.allTypes;
    
    [self.navigationController pushViewController:formelView animated:YES];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}

@end
