//
//  ConversionCenter.m
//  Loosie
//
//  Created by Shay Aviv on 9/10/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import "ConversionCenter.h"

#import <iTunesLibrary/ITLibMediaItem.h>

#import "EncoderSetting.h"

#import "Passthrough.h"
#import "VorbisEncoder.h"
#import "MP3Encoder.h"
#import "FLACEncoder.h"
#import "WaveEncoder.h"

@implementation ConversionCenter {
    NSDictionary *defaultsKeyByKind;
}

- (id)init {
    self = [super init];
    if (self) {
        EncoderSetting *automatic = [EncoderSetting settingWithTag:0 andDescription:@"Automatic"];
        EncoderInfo *passthrough = [EncoderInfo encoderWithType:PassthroughEncoderType
                                                    andSettings:[NSArray arrayWithObject:automatic]];
        EncoderInfo *mp3 = [EncoderInfo encoderWithType:MP3EncoderType andSettings:
                            [NSArray arrayWithObjects:
                             [EncoderSetting settingWithTag:MP3EncoderSettingHighestQuality andDescription:@"Highest Quality (320kbps)"],
                             [EncoderSetting settingWithTag:MP3EncoderSettingVeryHighQuality andDescription:@"Very High Quality (~225 kbps)"],
                             [EncoderSetting settingWithTag:MP3EncoderSettingGoodQuality andDescription:@"Good Quality (~165 kbps)"],
                             [EncoderSetting settingWithTag:MP3EncoderSettingAcceptableQuality andDescription:@"Acceptable Quality (~115 kbps)"], nil]];
        EncoderInfo *vorbis = [EncoderInfo encoderWithType:VorbisEncoderType andSettings:
                               [NSArray arrayWithObjects:
                                [EncoderSetting settingWithTag:VorbisEncoderSettingVeryHighQuality andDescription:@"Very High Quality (~160 kbps)"],
                                [EncoderSetting settingWithTag:VorbisEncoderSettingGoodQuality andDescription:@"Good Quality (~112 kbps)"],
                                [EncoderSetting settingWithTag:VorbisEncoderSettingAcceptableQuality andDescription:@"Acceptable Quality (~80 kbps)"], nil]];
        EncoderInfo *flac = [EncoderInfo encoderWithType:FLACEncoderType
                                             andSettings:[NSArray arrayWithObject:automatic]];
        EncoderInfo *wave = [EncoderInfo encoderWithType:WaveEncoderType
                                             andSettings:[NSArray arrayWithObject:automatic]];
        
        _losslessEncoders = [NSArray arrayWithObjects:passthrough, mp3, vorbis, flac, wave, nil];
        _aacEncoders = [NSArray arrayWithObjects:passthrough, mp3, vorbis, wave, nil];
        _mp3Encoders = [NSArray arrayWithObjects:passthrough, vorbis, wave, nil];
        
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

MP3Encoder *CreateMP3Encoder(NSInteger setting) {
    MP3Encoder *mp3Encoder = [[MP3Encoder alloc] init];
    mp3Encoder.setting = setting;
    mp3Encoder.includeAdvancedMetadata = [[NSUserDefaults standardUserDefaults] boolForKey:@"IncludeAdvancedMetadata"];
    return mp3Encoder;
}

VorbisEncoder *CreateVorbisEncoder(NSInteger setting) {
    VorbisEncoder *vorbisEncoder = [[VorbisEncoder alloc] init];
    vorbisEncoder.setting = setting;
    vorbisEncoder.includeAdvancedMetadata = [[NSUserDefaults standardUserDefaults] boolForKey:@"IncludeAdvancedMetadata"];
    return vorbisEncoder;
}

FLACEncoder *CreateFLACEncoder() {
    FLACEncoder *flacEncoder = [[FLACEncoder alloc] init];
    flacEncoder.includeAdvancedMetadata = [[NSUserDefaults standardUserDefaults] boolForKey:@"IncludeAdvancedMetadata"];
    return flacEncoder;
}

- (id <Encoder>)encoderForMediaItem:(ITLibMediaItem *)item {
    if (item.mediaKind == ITLibMediaItemMediaKindSong && !item.isDRMProtected) {
        NSString *encoderTypeKey = defaultsKeyByKind[item.kind];
        NSInteger encoderType = [[NSUserDefaults standardUserDefaults] integerForKey:encoderTypeKey];
        
        NSString *encoderSettingKey = [encoderTypeKey stringByAppendingString:@"Setting"];
        NSInteger encoderSetting = [[NSUserDefaults standardUserDefaults] integerForKey:encoderSettingKey];
        
        switch(encoderType) {
            case PassthroughEncoderType:
                return [[Passthrough alloc] init];
            case MP3EncoderType:
                return CreateMP3Encoder(encoderSetting);
            case VorbisEncoderType:
                return CreateVorbisEncoder(encoderSetting);
            case FLACEncoderType:
                return CreateFLACEncoder();
            case WaveEncoderType:
                return [[WaveEncoder alloc] init];
        }
    }
    return nil;
}

@end
