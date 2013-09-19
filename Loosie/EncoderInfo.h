//
//  EncoderInfo.h
//  Loosie
//
//  Created by Shay Aviv on 9/19/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    PassthroughEncoderType = 0,
    MP3EncoderType = 1,
    VorbisEncoderType = 2,
    FLACEncoderType = 3,
    WaveEncoderType = 4
} EncoderType;

@interface EncoderInfo : NSObject

@property (readonly, nonatomic) EncoderType encoderType;
@property (readonly, nonatomic) NSArray *settings;

+ (id)encoderWithType:(EncoderType)encoderType andSettings:(NSArray *)settings;

@end
