//
//  NAGooglePlusDataFetcher.m
//  NikolaysAssignment
//
//  Created by Nikolay Aleschenko on 4/14/14.
//  Copyright (c) 2014 Nikolay Aleshchenko. All rights reserved.
//

#import "NAGooglePlusDataFetcher.h"

@implementation NAGooglePlusDataFetcher

+ (instancetype)sharedInstance {
    static dispatch_once_t token;
    static NAGooglePlusDataFetcher *sharedFetcher = nil;
    
    dispatch_once(&token, ^{
        sharedFetcher = [[NAGooglePlusDataFetcher alloc] init];
    });
    
    return sharedFetcher;
}

@end
