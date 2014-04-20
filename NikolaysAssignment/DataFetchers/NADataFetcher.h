//
//  NADataFetcher.h
//  NikolaysAssignment
//
//  Created by Nikolay Aleschenko on 4/14/14.
//  Copyright (c) 2014 Nikolay Aleshchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NAFeedData.h"

static const NSString *dataFetcherErrorDomain = @"DataFetcherErrorDomain";

/*!
 @protocol
 @abstract    Implement this protocol to get callbacks from data fetcher
 @discussion  Get 'success' and 'failure' callbacks from data fetcher
 */
@protocol NADataFetcherDelegate <NSObject>

/*!
@method     didFailDataFetchWithError:
@abstract   returns an error occured during feed fetching
@discussion A delegate can show error message taken from error returned
*/
- (void)didFailDataFetchWithError:(NSError*)error;

/*!
@method     fetchSucceeded
@abstract   notify a fetcher delegate that fedd has been successfully fetched
@discussion upon receiving a callback from data fetcher a delegate can get feed items from NAFeedData
*/
- (void)fetchSucceeded;

@end


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
- (void)attemptDataFetch;

@property (weak, nonatomic) id<NADataFetcherDelegate> delegate;

@end
