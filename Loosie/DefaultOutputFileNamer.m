//
//  OutputSongFileNamer.m
//  Loosie
//
//  Created by Shay Aviv on 9/9/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import "DefaultOutputFileNamer.h"

#import <iTunesLibrary/ITLibrary.h>
#import <iTunesLibrary/ITLibMediaItem.h>
#import <iTunesLibrary/ITLibAlbum.h>
#import <iTunesLibrary/ITLibArtist.h>

#import "URLHelper.h"

@interface DefaultOutputFileNamer ()
@property (strong, nonatomic) ITLibrary *library;
@property (strong, nonatomic) NSRegularExpression *unsafeURLcharactersRegex;
@end

@implementation DefaultOutputFileNamer

- (id)init {
    return [self initWithLibrary:[ITLibrary libraryWithAPIVersion:@"1.0" error:nil]];
}

- (id)initWithLibrary:(ITLibrary *)library {
    self = [super init];
    if (self) {
        if (library)
            self.library = library;
        else
            return nil;
        self.unsafeURLcharactersRegex = [NSRegularExpression regularExpressionWithPattern:@"[\\\\/\\.\\?:]+" options:0 error:nil];
    }
    return self;
}

- (NSURL *)URLWithoutExtensionForMediaItem:(ITLibMediaItem *)item {
    return [self libraryBasedURLWithoutExtensionForMediaItem:item]
        ?: [self iTunesStyleURLWithoutExtensionForMediaItem:item];
}

// Returns nil if the song is outside the library
- (NSURL *)libraryBasedURLWithoutExtensionForMediaItem:(ITLibMediaItem *)item {
    return [URLHelper makeURL:[item.location URLByDeletingPathExtension]
                    startWith:self.outputDirectory
                    insteadOf:[self.library.musicFolderLocation URLByAppendingPathComponent:@"Music"
                                                                                isDirectory:YES]];
}

- (NSURL *)iTunesStyleURLWithoutExtensionForMediaItem:(ITLibMediaItem *)item {
    NSMutableString *artistFolderName = [NSMutableString stringWithString:item.album.compilation
                                            ? @"Compilations" : item.album.albumArtist
                                         ?: item.artist.name
                                         ?: @"Unknown Artist"];
    [self.unsafeURLcharactersRegex replaceMatchesInString:artistFolderName
                                                  options:0
                                                    range:NSMakeRange(0, artistFolderName.length)
                                             withTemplate:@"_"];
    
    NSMutableString *albumFolderName = [NSMutableString stringWithString:item.album.title ?: @"Unknown Album"];
    [self.unsafeURLcharactersRegex replaceMatchesInString:albumFolderName
                                                  options:0
                                                    range:NSMakeRange(0, albumFolderName.length)
                                             withTemplate:@"_"];
    
    NSMutableString *songFileName = [[NSMutableString alloc] init];
    if (item.album.discNumber && (item.album.discNumber != 1 || item.album.discCount != 1))
        [songFileName appendFormat:@"%ld-", (unsigned long)item.album.discNumber];
    if (item.trackNumber)
        [songFileName appendFormat:@"%02ld ", (unsigned long)item.trackNumber];
    [songFileName appendString:item.title ?: @"Unknown"];
    [self.unsafeURLcharactersRegex replaceMatchesInString:songFileName
                                                  options:0
                                                    range:NSMakeRange(0, songFileName.length)
                                             withTemplate:@"_"];
    
    return [[[self.outputDirectory URLByAppendingPathComponent:artistFolderName]
             URLByAppendingPathComponent:albumFolderName]
            URLByAppendingPathComponent:songFileName];
}

@end
