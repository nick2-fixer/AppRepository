//
//  NAFeedCell.h
//  NikolaysAssignment
//
//  Created by Nikolay Aleschenko on 4/20/14.
//  Copyright (c) 2014 Nikolay Aleshchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NAFeedCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *feedItemText;
@property (nonatomic, weak) IBOutlet UILabel *feedItemAuthorLabel;
@property (nonatomic, strong) IBOutlet UIImageView *feedItemImageView;

@end
