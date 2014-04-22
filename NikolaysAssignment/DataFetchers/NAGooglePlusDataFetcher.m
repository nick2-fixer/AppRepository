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
@property (nonatomic) NSArray *peopleArray;

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
        [self attemptDataFetch];
    }
    else {
        [self.delegate didFailDataFetchWithError:[NSError errorWithDomain:dataFetcherErrorDomain code:5 userInfo:nil]];
    }
}

-(void)attemptDataFetch {
    if (!_signInData.authentication) {
        [self signIn];
    }
    else {
        GTLQueryPlus *query = [GTLQueryPlus queryForPeopleListWithUserId:@"me" collection:kGTLPlusCollectionVisible];
        
        [[[GPPSignIn sharedInstance] plusService] executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLPlusPeopleFeed *peopleFeed, NSError *error) {
            
            if (error) {
                [self.delegate didFailDataFetchWithError:[NSError errorWithDomain:dataFetcherErrorDomain code:4 userInfo:nil]];
            }
            else {
                // Get an array of people from GTLPlusPeopleFeed
                _peopleArray = peopleFeed.items;
                
                NAFeedData *feedData = [NAFeedData sharedInstance];
                NSMutableArray *tempFeedData = [NSMutableArray arrayWithCapacity:0];
                
                for (GTLPlusPerson *person in _peopleArray) {
                    
                    NSString *userImageUrl = person.image.url;
                    
                    //Given list of uers, get their activities
                    GTLQueryPlus *query = [GTLQueryPlus queryForActivitiesListWithUserId:person.identifier collection:kGTLPlusCollectionPublic];
                    
                    [[[GPPSignIn sharedInstance] plusService]
                     executeQuery:query
                     completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
                         if (error) {
                             [self.delegate didFailDataFetchWithError:[NSError errorWithDomain:dataFetcherErrorDomain code:4 userInfo:nil]];
                         }
                         else {
                             GTLPlusActivityFeed *userActivities = (GTLPlusActivityFeed *)object;
                             
                             for (GTLPlusActivityObject *activity in userActivities) {
                                 
                                 if ([[activity valueForKey:@"title"] length] < 1) {
                                     continue;
                                 }
                                 
                                 NAFeedItem *activityItem = [[NAFeedItem alloc] init];
                                 activityItem.author = person.displayName;
                                 activityItem.bodyText = [activity valueForKey:@"title"];
                                 activityItem.imageUrlString = userImageUrl;
                                 
                                 [tempFeedData addObject:activityItem];
                             }

                             feedData.feedItemsArray = tempFeedData;
                             [self.delegate fetchSucceeded];
                         }
                     }];
                }
            }
        }];
    }
}

@end
