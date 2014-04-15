//
//  NAViewController.m
//  NikolaysAssignment
//
//  Created by Nikolay Aleschenko on 4/14/14.
//  Copyright (c) 2014 Nikolay Aleshchenko. All rights reserved.
//

#import "NAViewController.h"
#import "NAFeedTableViewController.h"

typedef enum {
    NAFacebookButton,
    NATwitterButton,
    NAGooglePlusButton
} NASocialButtons;

@interface NAViewController ()

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;

@end

@implementation NAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didPressButton:(id)sender {
    if (_buttons) {
        NSUInteger index = [_buttons indexOfObject:sender];
    }
    
    NAFeedTableViewController *feedController = [[NAFeedTableViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:feedController animated:YES];
}

@end
