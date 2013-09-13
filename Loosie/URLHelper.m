//
//  URLHelper.m
//  Loosie
//
//  Created by Shay Aviv on 9/11/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import "URLHelper.h"

@implementation URLHelper

+ (NSURL *)makeURL:(NSURL *)url startWith:(NSURL *)newBase insteadOf:(NSURL *)base {
    if (![url.path hasPrefix:base.path])
        return nil;
    
    NSArray *baseComponents = base.pathComponents;
    NSArray *urlComponents = url.pathComponents;
    
    NSRange range = NSMakeRange(baseComponents.count, urlComponents.count - baseComponents.count);
    return [NSURL fileURLWithPathComponents:[newBase.pathComponents arrayByAddingObjectsFromArray:
                                             [urlComponents subarrayWithRange:range]]];
}

@end
