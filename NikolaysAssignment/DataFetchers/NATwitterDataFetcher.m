//
//  NATwitterDataFetcher.m
//  NikolaysAssignment
//
//  Created by Nikolay Aleschenko on 4/14/14.
//  Copyright (c) 2014 Nikolay Aleshchenko. All rights reserved.
//

#import "NATwitterDataFetcher.h"

@implementation NATwitterDataFetcher

+ (instancetype)sharedInstance {
    static dispatch_once_t token;
    static NATwitterDataFetcher *sharedFetcher = nil;
    
    dispatch_once(&token, ^{
        sharedFetcher = [[NATwitterDataFetcher alloc] init];
    });
    
    return sharedFetcher;
}


@end
