//
//  ConversionCenter.h
//  Loosie
//
//  Created by Shay Aviv on 9/10/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Encoder.h"

typedef enum {
    PassthroughEncoderType = 0,
    VorbisEncoderType = 1,
    FLACEncoderType = 2,
    WaveEncoderType = 3
} EncoderType;

@class ITLibMediaItem;

@interface ConversionCenter : NSObject

@property (readonly, nonatomic) NSDictionary *allEncoders;

- (id <Encoder>)encoderForMediaItem:(ITLibMediaItem *)item;

@end
