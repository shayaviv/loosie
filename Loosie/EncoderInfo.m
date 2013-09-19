//
//  EncoderInfo.m
//  Loosie
//
//  Created by Shay Aviv on 9/19/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import "EncoderInfo.h"

@implementation EncoderInfo

- (NSString *)description {
    switch (self.encoderType) {
        case PassthroughEncoderType:
            return @"Passthrough";
        case MP3EncoderType:
            return @"MP3 Encoder";
        case VorbisEncoderType:
            return @"Ogg Vorbis Encoder";
        case FLACEncoderType:
            return @"FLAC Encoder";
        case WaveEncoderType:
            return @"WAV Encoder";
        default:
            return @"Unknown Encoder";
    }
}

+ (id)encoderWithType:(EncoderType)encoderType andSettings:(NSArray *)settings {
    EncoderInfo *info = [[EncoderInfo alloc] init];
    if (info) {
        info->_encoderType = encoderType;
        info->_settings = settings;
    }
    return info;
}

@end
