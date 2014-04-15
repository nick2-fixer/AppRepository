//
//  NAFeedTableViewController.h
//  NikolaysAssignment
//
//  Created by Nikolay Aleschenko on 4/14/14.
//  Copyright (c) 2014 Nikolay Aleshchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NADataFetcher.h"

@interface NAFeedTableViewController : UITableViewController

@property (strong, nonatomic) id dataFetcher;

@end
