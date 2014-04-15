//
//  NAViewController.m
//  NikolaysAssignment
//
//  Created by Nikolay Aleschenko on 4/14/14.
//  Copyright (c) 2014 Nikolay Aleshchenko. All rights reserved.
//

#import "NAViewController.h"
#import "NAFeedTableViewController.h"
#import "NAFacebookDataFetcher.h"
#import "NATwitterDataFetcher.h"
#import "NAGooglePlusDataFetcher.h"

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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (_buttons) {
        NSUInteger buttonIndex = [_buttons indexOfObject:sender];
        
        NAFeedTableViewController *feedController = [segue destinationViewController];
        
        id specificDataFetcher = nil;
        
        switch (buttonIndex) {
            case NAFacebookButton:
                specificDataFetcher = [NAFacebookDataFetcher sharedInstance];
                break;
                
            case NATwitterButton:
                specificDataFetcher = [NATwitterDataFetcher sharedInstance];
                break;
                
            case NAGooglePlusButton:
                specificDataFetcher = [NAGooglePlusDataFetcher sharedInstance];
                break;
                
            default:
                break;
                
        }
        
        feedController.dataFetcher = specificDataFetcher;
    }
}

@end
