//
//  TopViewController.m
//  BrassSimulator
//
//  Created by KenjiArai on 2012/12/17.
//  Copyright (c) 2012年 KenjiArai. All rights reserved.
//

#import "TopViewController.h"
#import "MasterViewController.h"

@interface TopViewController ()

@end

@implementation TopViewController

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
	// Do any additional setup after loading the view.
}

- (void)pushBuuton:(UIButton *)sender{
    MasterViewController *masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:masterViewController];
    [self presentViewController:navi animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
