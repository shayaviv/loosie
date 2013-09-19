//
//  MP3Encoder.h
//  Loosie
//
//  Created by Shay Aviv on 9/17/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Encoder.h"

typedef enum {
    MP3EncoderSettingHighestQuality,
    MP3EncoderSettingVeryHighQuality,
    MP3EncoderSettingGoodQuality,
    MP3EncoderSettingAcceptableQuality
} MP3EncoderSetting;

@interface MP3Encoder : NSObject <Encoder>

@property (assign, nonatomic) MP3EncoderSetting setting;
@property (assign, nonatomic) BOOL includeAdvancedMetadata;

@end
