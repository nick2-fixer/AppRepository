//
//  NAFeedTableViewController.m
//  NikolaysAssignment
//
//  Created by Nikolay Aleschenko on 4/14/14.
//  Copyright (c) 2014 Nikolay Aleshchenko. All rights reserved.
//

#import "NAFeedTableViewController.h"
#import "NAFeedCell.h"
#import "NAFeedData.h"

static const CGFloat rowHeight = 80.0f;

@implementation NAFeedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Feed";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self isMovingFromParentViewController]) {
        self.navigationController.navigationBar.hidden = YES;
        _dataFetcher = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[NAFeedData sharedInstance] setFeedItemsArray:[NSMutableArray arrayWithCapacity:0]];
}

#pragma mark - Fetch data

- (void)setDataFetcher:(id)dataFetcher
{
    if ((dataFetcher != _dataFetcher) && (dataFetcher != nil))
    {
        _dataFetcher = dataFetcher;
        _dataFetcher.delegate = self;
        [_dataFetcher attemptDataFetch];
    }
}

#pragma mark - NADataFetcherDelegate

- (void)didFailDataFetchWithError:(NSError *)error {
    //TODO: show alertView
}

- (void)fetchSucceeded {
    [self updateUI];
}

#pragma mark - Update UI

- (void)updateUI {
    
    BOOL feedArrayIsEmpty = [[[NAFeedData sharedInstance] feedItemsArray] count] < 1;
    self.tableView.hidden = feedArrayIsEmpty;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return rowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[NAFeedData sharedInstance] feedItemsArray] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NAFeedCell *cell = (NAFeedCell*)[tableView dequeueReusableCellWithIdentifier:@"FeedCell"];
    NAFeedItem *feedItem = [[NAFeedData sharedInstance].feedItemsArray objectAtIndex:indexPath.row];
    
    cell.feedItemAuthorLabel.text = feedItem.author;
    cell.feedItemText.text = feedItem.bodyText;
    
    return cell;
}

@end
