//
//  NAFacebookDataFetcher.m
//  NikolaysAssignment
//
//  Created by Nikolay Aleschenko on 4/14/14.
//  Copyright (c) 2014 Nikolay Aleshchenko. All rights reserved.
//

#import "NAFacebookDataFetcher.h"
#import <FacebookSDK/FacebookSDK.h>

static NSString *facebbokFeedRequest = @"SELECT post_id, created_time, type, attachment FROM stream WHERE filter_key in (SELECT filter_key FROM stream_filter WHERE uid=me() AND type='newsfeed') AND is_hidden = 0";

@implementation NAFacebookDataFetcher

+ (instancetype)sharedInstance {
    static dispatch_once_t token;
    static NAFacebookDataFetcher *sharedFetcher = nil;
    
    dispatch_once(&token, ^{
        sharedFetcher = [[NAFacebookDataFetcher alloc] init];
    });
    
    return sharedFetcher;
}

- (void)attemptDataFetch {
    [FBSession openActiveSessionWithReadPermissions:@[@"read_stream"]
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                      if (error || !session) {
                                          [self.delegate didFailDataFetchWithError:[NSError errorWithDomain:dataFetcherErrorDomain code:1 userInfo:nil]];
                                          
                                      }
                                      else {
                                          [FBRequestConnection startWithGraphPath:@"/fql"
                                                                       parameters:[NSDictionary dictionaryWithObjectsAndKeys: facebbokFeedRequest, @"q", nil]
                                                                       HTTPMethod:@"GET"
                                                                completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                                                    
                                                                    if (error) {
                                                                        [self.delegate didFailDataFetchWithError:[NSError errorWithDomain:dataFetcherErrorDomain code:2 userInfo:nil]];
                                                                    }
                                                                    else {
                                                                        [self parseResponse:(id)result];
                                                                    }
                                                                }];
                                      }
                                  }];
}

- (void)parseResponse:(id)response {
    NSDictionary *tempDictionary = [response objectForKey:@"data"];
    
    NSMutableArray *tempFeedData = [NSMutableArray arrayWithCapacity:0];
    
    for (NSDictionary *feedItem in tempDictionary) {
        NAFeedItem *item = [[NAFeedItem alloc] init];
        
        NSString *description = [feedItem valueForKeyPath:@"attachment.description"];
        if ([description length] < 1) {
            description = [[[feedItem valueForKeyPath:@"attachment.media"] objectAtIndex:0] valueForKey:@"alt"];
            
            if ([description length] < 1) {
                continue; // no readable data to show, skip this item
            }
        }
        item.bodyText = description;
        item.identifier = [feedItem valueForKey:@"post_id"];
        item.author = [feedItem valueForKeyPath:@"attachment.name"];
        
        [tempFeedData addObject:item];
    }
    
    [[NAFeedData sharedInstance] setFeedItemsArray:tempFeedData];
    [self.delegate fetchSucceeded];
}

@end
