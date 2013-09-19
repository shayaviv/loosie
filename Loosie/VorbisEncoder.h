//
//  VorbisConverter.h
//  Loosie
//
//  Created by Shay Aviv on 9/12/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Encoder.h"

typedef enum {
    VorbisEncoderSettingVeryHighQuality,
    VorbisEncoderSettingGoodQuality,
    VorbisEncoderSettingAcceptableQuality
} VorbisEncoderSetting;

@interface VorbisEncoder : NSObject <Encoder>

@property (assign, nonatomic) VorbisEncoderSetting setting;
@property (assign, nonatomic) BOOL includeAdvancedMetadata;

@end
