//
//  ArtworkExtractor.h
//  Loosie
//
//  Created by Shay Aviv on 9/29/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ITLibArtwork;

@interface ArtworkExtractor : NSObject

+ (BOOL)saveJPEGofArtwork:(ITLibArtwork *)artwork atURL:(NSURL *)url maxPixelsWide:(size_t)maxWidth;

+ (BOOL)saveJPEGForImage:(NSImage*)image atURL:(NSURL *)url withWidth:(size_t)width andHeight:(size_t)height;

@end
