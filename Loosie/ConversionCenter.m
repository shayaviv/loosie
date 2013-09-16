//
//  ConversionCenter.m
//  Loosie
//
//  Created by Shay Aviv on 9/10/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import "ConversionCenter.h"

#import <iTunesLibrary/ITLibMediaItem.h>

#import "PassthroughConverter.h"
#import "WaveConverter.h"
#import "FLACConverter.h"
#import "VorbisConverter.h"

@interface ConversionCenter ()
@property (strong, nonatomic) NSDictionary *converterByKind;
@end

@implementation ConversionCenter

- (id)init {
    self = [super init];
    if (self) {
        PassthroughConverter *passthrough = [[PassthroughConverter alloc] init];
        //WaveConverter *wave = [[WaveConverter alloc] init];
        FLACConverter *flac = [[FLACConverter alloc] init];
        VorbisConverter *vorbis = [[VorbisConverter alloc] init];
        
        id <Converter> lossless = flac;
        id <Converter> mp3 = passthrough;
        id <Converter> aac = vorbis;
        
        self.converterByKind = [NSDictionary dictionaryWithObjectsAndKeys:
                                lossless, @"Apple Lossless audio file",
                                lossless, @"WAV audio file",
                                lossless, @"AIFF audio file",
                                mp3, @"MPEG audio file",
                                aac, @"AAC audio file",
                                aac, @"Purchased AAC audio file", nil];
    }
    return self;
}

- (id <Converter>)converterForMediaItem:(ITLibMediaItem *)item {
    if (item.mediaKind == ITLibMediaItemMediaKindSong && !item.isDRMProtected)
        return self.converterByKind[item.kind];
    else
        return nil;
}

@end
