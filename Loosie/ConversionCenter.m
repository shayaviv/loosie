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

@implementation ConversionCenter {
    NSDictionary *defaultsKeyByKind;
}

- (id)init {
    self = [super init];
    if (self) {
        defaultsKeyByKind = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"LosslessTargetEncoder", @"Apple Lossless audio file",
                             @"LosslessTargetEncoder", @"WAV audio file",
                             @"LosslessTargetEncoder", @"AIFF audio file",
                             @"AACTargetEncoder", @"AAC audio file",
                             @"AACTargetEncoder", @"Purchased AAC audio file",
                             @"MP3TargetEncoder", @"MPEG audio file", nil];
    }
    return self;
}

- (id <Encoder>)encoderForMediaItem:(ITLibMediaItem *)item {
    if (item.mediaKind == ITLibMediaItemMediaKindSong && !item.isDRMProtected) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        switch([defaults integerForKey:defaultsKeyByKind[item.kind]]) {
            case PassthroughEncoderType:
                return [[Passthrough alloc] init];
            case VorbisEncoderType:
            {
                VorbisEncoder *vorbisEncoder = [[VorbisEncoder alloc] init];
                vorbisEncoder.includeAdvancedMetadata = [defaults boolForKey:@"IncludeAdvancedMetadata"];
                return vorbisEncoder;
            }
            case FLACEncoderType:
            {
                FLACEncoder *flacEncoder = [[FLACEncoder alloc] init];
                flacEncoder.includeAdvancedMetadata = [defaults boolForKey:@"IncludeAdvancedMetadata"];
                return flacEncoder;
            }
            case WaveEncoderType:
                return [[WaveEncoder alloc] init];
        }
    }
    return nil;
}

@end
