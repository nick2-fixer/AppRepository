//
//  NAFeedData.m
//  NikolaysAssignment
//
//  Created by Nikolay Aleschenko on 4/16/14.
//  Copyright (c) 2014 Nikolay Aleshchenko. All rights reserved.
//

#import "NAFeedData.h"

@implementation NAFeedData

+ (instancetype)sharedInstance
{
    static dispatch_once_t token;
    static NAFeedData *sharedInstance = nil;
    
    dispatch_once(&token, ^{
        sharedInstance = [[NAFeedData alloc] init];
    });
    
    return sharedInstance;
}

- (void)setFeedItemsArray:(NSArray *)array
{
    if (_feedItemsArray != array ) {
        _feedItemsArray = array;
    }
}

@end
