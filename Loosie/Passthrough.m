//
//  PassthroughConverter.m
//  Loosie
//
//  Created by Shay Aviv on 9/11/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import "Passthrough.h"

#import <iTunesLibrary/ITLibMediaItem.h>

@implementation Passthrough

- (BOOL)encode:(ITLibMediaItem *)item outputURL:(NSURL *)outputURLWithoutExtension error:(NSError **)error {
    NSURL *destination = [outputURLWithoutExtension URLByAppendingPathExtension:item.location.pathExtension];
    return [[NSFileManager defaultManager] copyItemAtURL:item.location toURL:destination error:error];
}

@end
