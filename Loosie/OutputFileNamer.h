//
//  OutputFileNamer.h
//  Loosie
//
//  Created by Shay Aviv on 9/11/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ITLibMediaItem;

@protocol OutputFileNamer <NSObject>

@property (strong, nonatomic) NSURL *outputDirectory;
- (NSURL *)URLWithoutExtensionForMediaItem:(ITLibMediaItem *)item;

@end
