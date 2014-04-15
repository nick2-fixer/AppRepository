//
//  NATwitterDataFetcher.m
//  NikolaysAssignment
//
//  Created by Nikolay Aleschenko on 4/14/14.
//  Copyright (c) 2014 Nikolay Aleshchenko. All rights reserved.
//

#import "NATwitterDataFetcher.h"
#import "SA_OAuthTwitterEngine.h"

static NSString *userName = @"nick130586";
static NSString *consumerKey = @"XzXRNM5ogp2kdFHQtpz8hlvTR";
static NSString *consumerSecret = @"NyE32ws2i1dfZHFvr5J4daDlUSsjrd8Bxi5NxENTiiM7fXfF4Z";

@implementation NATwitterDataFetcher

+ (instancetype)sharedInstance {
    static dispatch_once_t token;
    static NATwitterDataFetcher *sharedFetcher = nil;
    
    dispatch_once(&token, ^{
        sharedFetcher = [[NATwitterDataFetcher alloc] init];
    });
    
    return sharedFetcher;
}

- (void)fetchDataWithFinishBlock:(void (^)(NSData *, NSError *, BOOL))finishBlock {
    SA_OAuthTwitterEngine *engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
    engine.consumerKey = consumerKey;
    engine.consumerSecret = consumerSecret;
    
    [engine getUserTimelineFor:@"nick130586" sinceID:0 startingAtPage:0 count:20];
}

- (void)requestSucceeded:(NSString *)connectionIdentifier {
    
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error {
    
}

- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier {
    NSLog(@"%@", statuses);
}

@end
