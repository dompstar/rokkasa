//
//  ROKLoginViewController.m
//  rokkasa
//
//  Created by Alexander Auer on 17.11.13.
//  Copyright (c) 2013 Alexander Auer. All rights reserved.
//

#import "ROKLoginViewController.h"

@interface ROKLoginViewController ()

@end

@implementation ROKLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)checkLogin:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:[NSString stringWithFormat:@"%@/login", BASE_URL] parameters:nil];
    [request addValue:self.tfEmail.text forHTTPHeaderField:@"email"];
    [request addValue:self.tfPassword.text forHTTPHeaderField:@"password"];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Print the response body in text
        NSError *e;
        NSString *json = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData: [json dataUsingEncoding:NSUTF8StringEncoding]  options:NSJSONReadingMutableContainers error:&e];
        
        
        /*
         check if lastuser is the newly logged in user, if not erase everything, else keep setting
         */

        if ([dict objectForKey:@"id"] == [defaults objectForKey:@"userId"]) {
            NSArray *user = [User MR_findAll];
            NSLog(@"USER: %@", [user firstObject]);
        } else {
            [defaults setObject:nil forKey:@"apiKey"];
            [defaults setObject:nil forKey:@"userId"];
            [defaults setObject:nil forKey:@"coreUserId"];
            [defaults setObject:nil forKey:@"coreProjectId"];
            [defaults setObject:nil forKey:@"projectId"];
        }
        
        // Setting defaults
        [defaults setValue:[dict objectForKey:@"id"] forKey:@"userId"];
        [defaults setValue:[dict objectForKey:@"api_key"] forKey:@"apiKey"];

        
        // Setting defaults headers
        [[[RKObjectManager sharedManager] HTTPClient] setDefaultHeader:@"api-key" value:[defaults objectForKey:@"apiKey"]];
        [[[RKObjectManager sharedManager] HTTPClient] setDefaultHeader:@"user-id" value:[[defaults objectForKey:@"userId"] stringValue]];
        
        // Getting AppDelegate Object for setting current objects
        ROKAppDelegate *appDelegate = (ROKAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        // Setting current user
        [[RKObjectManager sharedManager] getObjectsAtPath:@"user" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSArray *user = [User MR_findByAttribute:@"objectId" withValue:[[dict objectForKey:@"id"]stringValue]];
            appDelegate.currentUser = [user firstObject];
            [defaults setObject:appDelegate.currentUser.getUserId forKey:@"coreUserId"];
            NSLog(@"%@", appDelegate.currentUser.getUserId);
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@",error);
        }];
        
        NSString *projectId = [defaults objectForKey:@"projectId"];

        // Setting current project if given
        [[RKObjectManager sharedManager] getObjectsAtPath:@"projects" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            if (projectId != nil) {
                NSArray *project = [Project MR_findByAttribute:@"objectId" withValue:projectId];
                appDelegate.currentProject = [project firstObject];
            }            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@",error);
        }];

        // Synchronize default data
        [defaults synchronize];
        
        
        // segue to mainview
        [self performSegueWithIdentifier:@"segue_login" sender:sender];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Fehler"
                                                                                        message: @"Ihr Loginvorgang ist fehlgeschlagen. Bitte versuchen sie es erneut."
                                                                                       delegate: self
                                                                              cancelButtonTitle: @"Cancel"
                                                                              otherButtonTitles: @"OK",nil];
                                         [alert show];
                                     }];
    [operation start];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.tfEmail resignFirstResponder];
    [self.tfPassword resignFirstResponder];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
