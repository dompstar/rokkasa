//
//  ROKMenuViewController.m
//  rokkasa
//
//  Created by Alexander Auer on 17.11.13.
//  Copyright (c) 2013 Alexander Auer. All rights reserved.
//

#import "ROKMenuViewController.h"

@interface ROKMenuViewController ()

@end

@implementation ROKMenuViewController

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
    _appDelegate = (ROKAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // Setting menu item array
    _menuItems = @[@"overview", @"time", @"todo", @"contacts", @"docs", @"placeholder", @"logout"];
    
    // Setting projects
    User *uid = [[User MR_findByAttribute:@"objectId" withValue:[defaults objectForKey:@"userId"]] firstObject];
    NSString *stringId = [[[uid objectID] URIRepresentation] absoluteString];
    NSArray *components = [stringId componentsSeparatedByString:@"/p"];


    
    _projects = [Project MR_findAllSortedBy:@"projectName" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"ANY relUserProject == %@", [components lastObject]]];
    
    
    NSLog(@"API %@", [defaults objectForKey:@"apiKey"]);
    NSLog(@"UID %@", [defaults objectForKey:@"userId"]);
    NSLog(@"CUID %@", [defaults objectForKey:@"coreUserId"]);
    NSLog(@"CPID %@", [defaults objectForKey:@"coreProjectId"]);
    NSLog(@"PID %@", [defaults objectForKey:@"projectId"]);


}

- (void)viewDidAppear:(BOOL)animated
{
    
    if (_appDelegate.currentProject != nil) {
        [_projectButton setTitle:[NSString stringWithFormat:@"%@", _appDelegate.currentProject.projectName] forState:UIControlStateNormal];
    } else {
        [_projectButton setTitle:[NSString stringWithFormat:@"Bitte Projekt auswählen"] forState:UIControlStateNormal];
    }
    
    [_projectPicker reloadAllComponents];
//    NSString *pid = _appDelegate.currentProject.objectId;
//    NSLog(@"%@", pid);
//    if (pid != nil) {
//        NSUInteger index = [_projects indexOfObject:[[_projects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.objectId == %@",  pid]] objectAtIndex:0]];
//        [_projectPicker selectRow:index inComponent:0 animated:NO];
//    }


    
    // Setting starting picker values
    _isActive = NO;
    [_projectButton setAlpha:1.0];
    [_projectPicker setAlpha:0.0];
    _projectButton.enabled = YES;
    _projectButton.hidden = NO;
    _projectPicker.hidden = YES;
    
    if(_isActive) {        [UIView animateWithDuration:0 animations:^{
            _menu.frame = CGRectMake(_menu.frame.origin.x, 108+118, _menu.frame.size.width, _menu.frame.size.height);
        }];
    }


    
}

- (IBAction)showButton:(id)sender {
    _isActive = YES;
    _projectButton.enabled = NO;
    _projectPicker.hidden = NO;
    
    [UIView animateWithDuration:0.2 animations:^{
        [_projectButton setAlpha:0.0];
        _menu.frame = CGRectMake(_menu.frame.origin.x, 108+118, _menu.frame.size.width, _menu.frame.size.height);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            [_projectPicker setAlpha:1.0];
        }];
    }];
    
    [_projectButton setTitle:@"" forState:UIControlStateNormal];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*) segue;
        
        swSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc) {
            
            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            [navController setViewControllers: @[dvc] animated: NO ];
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
        };
        
    }
    
    if ([[segue identifier] isEqualToString:@"segue_logout"]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"apiKey"];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [[[RKObjectManager sharedManager] HTTPClient] setDefaultHeader:@"api-key" value:nil];
        [[[RKObjectManager sharedManager] HTTPClient] setDefaultHeader:@"user-id" value:nil];
        [defaults synchronize];
    }
}


#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.menuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [self.menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - Picker View Data Source
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [_projects count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    Project *project = [_projects objectAtIndex:row];
    return [NSString stringWithFormat:@"%@", project.projectName];

}


#pragma mark - Picker View Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [UIView animateWithDuration:0.2 animations:^{
        [_projectPicker setAlpha:0.0];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            [_projectButton setAlpha:1.0];
            _menu.frame = CGRectMake(_menu.frame.origin.x, 108, _menu.frame.size.width, _menu.frame.size.height);
        }];
    }];
    _projectButton.enabled = YES;
    _projectPicker.hidden = YES;
    _isActive = NO;
    Project *u = [_projects objectAtIndex:row];
    
    _appDelegate.currentProject = u;
    
    
    [_projectButton setTitle:[NSString stringWithFormat:@"%@", u.projectName] forState:UIControlStateNormal];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *idString = [[[u objectID ]URIRepresentation] absoluteString];
    NSArray *comp = [idString componentsSeparatedByString:@"/p"];
    NSString *projId = [comp lastObject];
    [defaults setObject:u.projectName forKey:@"projectName"];
    [defaults setObject:projId forKey:@"coreProjectId"];
    [defaults setObject:u.objectId forKey:@"projectId"];
    
    [defaults synchronize];

}





@end
