//
//  NATwitterDataFetcher.m
//  NikolaysAssignment
//
//  Created by Nikolay Aleschenko on 4/14/14.
//  Copyright (c) 2014 Nikolay Aleshchenko. All rights reserved.
//

#import "NATwitterDataFetcher.h"
#import "SA_OAuthTwitterEngine.h"
#import "SA_OAuthTwitterController.h"

static NSString *consumerKey = @"XzXRNM5ogp2kdFHQtpz8hlvTR";
static NSString *consumerSecret = @"NyE32ws2i1dfZHFvr5J4daDlUSsjrd8Bxi5NxENTiiM7fXfF4Z";

@interface NATwitterDataFetcher () <SA_OAuthTwitterControllerDelegate>

@property (strong, nonatomic) SA_OAuthTwitterEngine *twitterEngine;

@end

@implementation NATwitterDataFetcher

+ (instancetype)sharedInstance {
    static dispatch_once_t token;
    static NATwitterDataFetcher *sharedFetcher = nil;
    
    dispatch_once(&token, ^{
        sharedFetcher = [[NATwitterDataFetcher alloc] init];
    });

    return sharedFetcher;
}

- (void)signIn {
    _twitterEngine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
    _twitterEngine.consumerKey = consumerKey;
    _twitterEngine.consumerSecret = consumerSecret;

    if (!_twitterEngine.isAuthorized) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIViewController *rootViewController = window.rootViewController;
        UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_twitterEngine delegate:self];
        
        if (controller){
            [rootViewController presentViewController:controller animated:YES completion:nil];
        }
    }
    else {
        [self attemptDataFetch];
    }
}

- (void)attemptDataFetch {
    if (_twitterEngine) {
        [_twitterEngine getFollowedTimelineSinceID:0 startingAtPage:0 count:0];
    }
    else {
        [self signIn];
    }
}

#pragma mark -
#pragma mark SA_OAuthTwitterControllerDelegate

- (void)OAuthTwitterController:(SA_OAuthTwitterController *)controller authenticatedWithUsername:(NSString *)username {
    DLog(@"Authenicated for %@", username);
    [self attemptDataFetch];
}

- (void)OAuthTwitterControllerFailed:(SA_OAuthTwitterController *)controller {
    DLog(@"Authentication Failed!");
    [self.delegate didFailDataFetchWithError:[NSError errorWithDomain:dataFetcherErrorDomain code:0 userInfo:nil]];
}

- (void)OAuthTwitterControllerCanceled:(SA_OAuthTwitterController *)controller {
    DLog(@"Authentication Canceled.");
    [self.delegate didFailDataFetchWithError:[NSError errorWithDomain:dataFetcherErrorDomain code:1 userInfo:nil]];
}

#pragma mark SA_OAuthTwitterEngineDelegate

- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier {
    NAFeedData *feedData = [NAFeedData sharedInstance];
    NSMutableArray *tempFeedData = [NSMutableArray arrayWithCapacity:0];

    for (NSDictionary *tweet in statuses) {
        NAFeedItem *feedItem = [[NAFeedItem alloc] init];
        feedItem.bodyText = [tweet valueForKey:@"text"];
        feedItem.identifier = [tweet valueForKey:@"id"];
        feedItem.author = [tweet valueForKeyPath:@"user.screen_name"];
        feedItem.imageUrlString = [tweet valueForKeyPath:@"user.profile_image_url"];
        
        [tempFeedData addObject:feedItem];
    }
    
    feedData.feedItemsArray = tempFeedData;
    [self.delegate fetchSucceeded];
}

- (void) storeCachedTwitterOAuthData:(NSString *)data forUsername: (NSString *) username {
	NSUserDefaults*defaults = [NSUserDefaults standardUserDefaults];
    
	[defaults setObject: data forKey: @"authData"];
	[defaults synchronize];
}

- (NSString *) cachedTwitterOAuthDataForUsername:(NSString *)username {
	return [[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
}

#pragma mark TwitterEngineDelegate
- (void) requestSucceeded:(NSString *)requestIdentifier {
	DLog(@"Request %@ succeeded", requestIdentifier);
}

- (void) requestFailed:(NSString *)requestIdentifier withError: (NSError *) error {
	DLog(@"Request %@ failed with error: %@", requestIdentifier, error);
}

@end
