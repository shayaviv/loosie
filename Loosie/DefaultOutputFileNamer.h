//
//  OutputSongFileNamer.h
//  Loosie
//
//  Created by Shay Aviv on 9/9/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OutputFileNamer.h"

@class ITLibrary;
@class ITLibMediaItem;

@interface DefaultOutputFileNamer : NSObject <OutputFileNamer>

@property (strong, nonatomic) NSURL *outputDirectory;

- (id)initWithLibrary:(ITLibrary *)library;

- (NSURL *)libraryBasedURLWithoutExtensionForMediaItem:(ITLibMediaItem *)item;
- (NSURL *)iTunesStyleURLWithoutExtensionForMediaItem:(ITLibMediaItem *)item;

@end
