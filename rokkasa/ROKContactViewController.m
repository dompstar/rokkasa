//
//  ROKContactViewController.m
//  rokkasa
//
//  Created by Alexander Auer on 17.11.13.
//  Copyright (c) 2013 Alexander Auer. All rights reserved.
//

#import "ROKContactViewController.h"

@interface ROKContactViewController ()
@property (nonatomic, strong) NSArray *contacts;

@end

@implementation ROKContactViewController

dispatch_queue_t myQueue;

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
    myQueue = dispatch_queue_create("com.rokkstart.gdc", nil);
    
    ROKAppDelegate *appDelegate = (ROKAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //observer for project change
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"coreProjectId" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:nil];
    
    
    _menuButton.target = self.revealViewController;
    _menuButton.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    dispatch_async(myQueue, ^{
        [[RKObjectManager sharedManager] getObjectsAtPath:@"user" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSString *pid = appDelegate.currentProject.getProjectId;
            NSLog(@"%@", pid);
            _contacts = [self getContacts:pid];
            [_contactTable reloadData];
            NSLog(@"fetchting..");
        } failure:^(RKObjectRequestOperation *operation, NSError *error) { NSLog(@"Error: %@",error);}];
        });
    
    
    
	// Do any additional setup after loading the view.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    ROKAppDelegate *appDelegate = (ROKAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *pid = appDelegate.currentProject.getProjectId;
    _contacts = [self getContacts:pid];
    [_contactTable reloadData];
}

- (NSArray *)getContacts:(NSString*)pid {
    return [User MR_findAllSortedBy:@"lastname" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"ANY relUserProject == %@", pid]];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_contacts count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentitfier = @"ContactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentitfier forIndexPath:indexPath];
    
    
    User *user = [_contacts objectAtIndex:indexPath.row];
    
    UILabel *name = (UILabel *)[cell viewWithTag:1];
    name.text = [NSString stringWithFormat:@"%@ %@", user.firstname, user.lastname];
    
    UILabel *email = (UILabel *)[cell viewWithTag:2];
    email.text = [NSString stringWithFormat:@"%@", user.email];
    
    if (user.phone != nil) {
        UILabel *phone = (UILabel *)[cell viewWithTag:3];
        phone.text = [NSString stringWithFormat:@"%@", user.phone];
    }
    
    return cell;
}



@end
