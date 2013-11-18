//
//  ROKMenuViewController.h
//  rokkasa
//
//  Created by Alexander Auer on 17.11.13.
//  Copyright (c) 2013 Alexander Auer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ROKMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) ROKAppDelegate *appDelegate;
@property (nonatomic, strong) NSArray *projects;

@property (nonatomic) BOOL isActive;

@property (nonatomic, weak) IBOutlet UITableView *menu;
@property (nonatomic, weak) IBOutlet UIPickerView *projectPicker;
@property (nonatomic, weak) IBOutlet UIButton *projectButton;


- (IBAction)showButton:(id)sender;

@end
