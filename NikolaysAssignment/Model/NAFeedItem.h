//
//  NAFeedItem.h
//  NikolaysAssignment
//
//  Created by Nikolay Aleschenko on 4/14/14.
//  Copyright (c) 2014 Nikolay Aleshchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NAFeedItem : NSObject

@property (nonatomic, strong) NSString *bodyText;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *timestamp;
@property (nonatomic, strong) NSString *author;

@end
