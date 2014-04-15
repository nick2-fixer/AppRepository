//
//  NAFacebookDataFetcher.m
//  NikolaysAssignment
//
//  Created by Nikolay Aleschenko on 4/14/14.
//  Copyright (c) 2014 Nikolay Aleshchenko. All rights reserved.
//

#import "NAFacebookDataFetcher.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation NAFacebookDataFetcher

+ (instancetype)sharedInstance {
    static dispatch_once_t token;
    static NAFacebookDataFetcher *sharedFetcher = nil;
    
    dispatch_once(&token, ^{
        sharedFetcher = [[NAFacebookDataFetcher alloc] init];
        
        [FBSession openActiveSessionWithReadPermissions:@[@"read_stream"]
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          
                                      }];
    });
    
    return sharedFetcher;
}

- (void)fetchDataWithFinishBlock:(void (^)(NSData *data, NSError *error, BOOL))finishBlock {
    
    NSString *fqlQuery = @"SELECT post_id, created_time, type, attachment FROM stream WHERE filter_key in (SELECT filter_key FROM stream_filter WHERE uid=me() AND type='newsfeed') AND is_hidden = 0 LIMIT 20";
    
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:[NSDictionary dictionaryWithObjectsAndKeys: fqlQuery, @"q", nil]
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error)
     {
         if (error)
             NSLog(@"Error: %@", [error localizedDescription]);
         else
             NSLog(@"Result: %@", result);
     }];
}

@end
