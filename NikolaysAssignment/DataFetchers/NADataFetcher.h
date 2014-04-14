//
//  NADataFetcher.h
//  NikolaysAssignment
//
//  Created by Nikolay Aleschenko on 4/14/14.
//  Copyright (c) 2014 Nikolay Aleshchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

static const NSString *dataFetcherErrorDomain = @"DataFetcherErrorDomain";

@interface NADataFetcher : NSObject

/*!
 @method sharedInstance
 @abstract singleton initialization method
 @result Returns shared instance of data fetcher
 */
+ (instancetype)sharedInstance;

/*!
 @method fetchDataWithFinishBlock
 @abstract A Stub for any actual fetching
 @result A completion block with fetched data, error data and 'cancelled' status of fetch job
 */
- (void)fetchDataWithFinishBlock:(void(^)(NSData *fetchedData, NSError *error, BOOL cancelled))finishBlock;

@end
