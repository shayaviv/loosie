//
//  ConversionCenter.m
//  Loosie
//
//  Created by Shay Aviv on 9/10/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import "ConversionCenter.h"

#import <iTunesLibrary/ITLibMediaItem.h>

#import "Passthrough.h"
#import "WaveEncoder.h"
#import "FLACEncoder.h"
#import "VorbisEncoder.h"

@interface ConversionCenter ()
@property (strong, nonatomic) NSDictionary *encoderByKind;
@end

@implementation ConversionCenter

- (id)init {
    self = [super init];
    if (self) {
        Passthrough *passthrough = [[Passthrough alloc] init];
        //WaveConverter *wave = [[WaveConverter alloc] init];
        FLACEncoder *flac = [[FLACEncoder alloc] init];
        VorbisEncoder *vorbis = [[VorbisEncoder alloc] init];
        
        id <Encoder> lossless = flac;
        id <Encoder> mp3 = passthrough;
        id <Encoder> aac = vorbis;
        
        self.encoderByKind = [NSDictionary dictionaryWithObjectsAndKeys:
                                lossless, @"Apple Lossless audio file",
                                lossless, @"WAV audio file",
                                lossless, @"AIFF audio file",
                                mp3, @"MPEG audio file",
                                aac, @"AAC audio file",
                                aac, @"Purchased AAC audio file", nil];
    }
    return self;
}

- (id <Encoder>)encoderForMediaItem:(ITLibMediaItem *)item {
    if (item.mediaKind == ITLibMediaItemMediaKindSong && !item.isDRMProtected)
        return self.encoderByKind[item.kind];
    else
        return nil;
}

@end
