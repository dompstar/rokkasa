//
//  ROKContactViewController.h
//  rokkasa
//
//  Created by Alexander Auer on 17.11.13.
//  Copyright (c) 2013 Alexander Auer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ROKContactViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UIBarButtonItem *menuButton;
@property (nonatomic, weak) IBOutlet UITableView *contactTable;

- (NSArray *)getContacts:(NSString*)pid;

@end
