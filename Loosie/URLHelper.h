//
//  URLHelper.h
//  Loosie
//
//  Created by Shay Aviv on 9/11/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLHelper : NSObject

+ (NSURL *)makeURL:(NSURL *)url startWith:(NSURL *)newBase insteadOf:(NSURL *)base;

@end
