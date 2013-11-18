//
//  ROKLoginViewController.h
//  rokkasa
//
//  Created by Alexander Auer on 17.11.13.
//  Copyright (c) 2013 Alexander Auer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ROKLoginViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextField *tfEmail;
@property (nonatomic, weak) IBOutlet UITextField *tfPassword;
@property (nonatomic, weak) IBOutlet UIButton *btLogin;

- (IBAction)checkLogin:(id)sender;

@end
