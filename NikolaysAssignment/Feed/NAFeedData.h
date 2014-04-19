//
//  NAFeedData.h
//  NikolaysAssignment
//
//  Created by Nikolay Aleschenko on 4/16/14.
//  Copyright (c) 2014 Nikolay Aleshchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NAFeedItem.h"

@interface NAFeedData : NSObject

/*!
 @method sharedInstance
 @abstract singleton initialization method
 @result Returns shared instance of temporary feed data holder
 */
+ (instancetype)sharedInstance;

@property (strong, nonatomic) NSArray *feedItemsArray;

@end
