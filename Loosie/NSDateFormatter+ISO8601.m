//
//  NSDateFormatter+ISO8601.m
//  Loosie
//
//  Created by Shay Aviv on 9/12/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import "NSDateFormatter+ISO8601.h"

@implementation NSDateFormatter (ISO8601)

+ (NSDateFormatter *)iso8601 {
    static NSDateFormatter *formatter = nil;
    @synchronized (self) {
        if (!formatter) {
            formatter = [[NSDateFormatter alloc] init];
            formatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
            formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";            
        }
    }
    return formatter;
}

@end
