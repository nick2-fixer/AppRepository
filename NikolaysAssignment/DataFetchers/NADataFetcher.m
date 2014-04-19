//
//  NADataFetcher.m
//  NikolaysAssignment
//
//  Created by Nikolay Aleschenko on 4/14/14.
//  Copyright (c) 2014 Nikolay Aleshchenko. All rights reserved.
//

#import "NADataFetcher.h"

@implementation NADataFetcher

+ (instancetype)sharedInstance {
    static dispatch_once_t token;
    static NADataFetcher *sharedFetcher = nil;
    
    dispatch_once(&token, ^{
        sharedFetcher = [[NADataFetcher alloc] init];
    });
    
    return sharedFetcher;
}

- (void)fetchDataWithFinishBlock:(void(^)(NSArray *fetchedData, NSError *error, BOOL cancelled))finishBlock {
        //is overriden in subclasses
}

@end
