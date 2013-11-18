//
//  ROKDashboardViewController.m
//  rokkasa
//
//  Created by Alexander Auer on 17.11.13.
//  Copyright (c) 2013 Alexander Auer. All rights reserved.
//

#import "ROKDashboardViewController.h"

@interface ROKDashboardViewController ()

@end

@implementation ROKDashboardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _menuButton.target = self.revealViewController;
    _menuButton.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
