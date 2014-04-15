//
//  NAGooglePlusDataFetcher.m
//  NikolaysAssignment
//
//  Created by Nikolay Aleschenko on 4/14/14.
//  Copyright (c) 2014 Nikolay Aleshchenko. All rights reserved.
//

#import "NAGooglePlusDataFetcher.h"
#import "GTLPlus.h"
#import <GooglePlus/GooglePlus.h>

static NSString *clientId = @"1016578238765.apps.googleusercontent.com";

@interface NAGooglePlusDataFetcher () <GPPSignInDelegate>

@property (nonatomic) GPPSignIn *signInData;

@end

@implementation NAGooglePlusDataFetcher

+ (instancetype)sharedInstance {
    static dispatch_once_t token;
    static NAGooglePlusDataFetcher *sharedFetcher = nil;
    
    dispatch_once(&token, ^{
        sharedFetcher = [[NAGooglePlusDataFetcher alloc] init];
    });
    
    return sharedFetcher;
}

- (void)signIn
{
    _signInData = [GPPSignIn sharedInstance];
    _signInData.scopes = @[@"https://www.googleapis.com/auth/plus.login"];
    [_signInData setDelegate:self];
    _signInData.shouldFetchGooglePlusUser = YES;
    _signInData.clientID = clientId;
    [_signInData attemptSSO];
    [_signInData authenticate];
}

- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error {
    if (auth && !error) {
        [self fetchDataWithFinishBlock:nil];
    }
}

-(void)fetchDataWithFinishBlock:(void (^)(NSData *data, NSError *error, BOOL cancelled))finishBlock {
    if (!_signInData.authentication)
        [self signIn];
    
    else {
        GTLQueryPlus *query = [GTLQueryPlus queryForActivitiesListWithUserId:@"me" collection:kGTLPlusCollectionPublic];
        
        [[[GPPSignIn sharedInstance] plusService] executeQuery:query
                                             completionHandler:^(GTLServiceTicket *ticket,
                                                                 GTLPlusActivityFeed *feed,
                                                                 NSError *error) {
                                                 for (GTLPlusActivity *activity in feed.items) {
                                                     NSLog(@"%@", activity);
                                                 }
                                             }];
    }
}

@end
