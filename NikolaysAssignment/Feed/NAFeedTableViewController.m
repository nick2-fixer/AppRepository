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
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(reload) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
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

- (void)stopRefresh {
    [self.refreshControl endRefreshing];
}

- (void)reload {
    [self.dataFetcher attemptDataFetch];
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
        
        [self.refreshControl beginRefreshing];
    }
}

#pragma mark - NADataFetcherDelegate

- (void)didFailDataFetchWithError:(NSError *)error {
    //TODO: show alertView
    [self updateUI];
}

- (void)fetchSucceeded {
    [self updateUI];
}

#pragma mark - Update UI

- (void)updateUI {
    
    BOOL feedArrayIsEmpty = [[[NAFeedData sharedInstance] feedItemsArray] count] < 1;
    self.tableView.hidden = feedArrayIsEmpty;
    
    [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:0.0];
    
    [self.tableView reloadData];
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
    
    //load image asynchronously
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:feedItem.imageUrlString]];
        if (imgData) {
            UIImage *image = [UIImage imageWithData:imgData];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    __weak NAFeedCell *updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
                    if (updateCell)
                        cell.feedItemImageView.image = image;
                });
            }
        }
    });
    
    return cell;
}

- (void)loadImageWithUrlString:(NSString *)urlString forImageView:(UIImageView*)imageView withSuccessBlock:(void (^)(UIImage *image))successBlock {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         successBlock([UIImage imageWithData:data]);
     }];
}

@end
