//
//  AudioToolboxUtils.c
//  Loosie
//
//  Created by Shay Aviv on 9/12/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import "AudioToolboxUtils.h"

BOOL HasError(OSStatus status, NSError **error) {
    if (status != noErr) {
        if (error)
            *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        return YES;
    }
    return NO;
}

static UInt32 CalculateLPCMFlags(UInt32 bitsPerChannel,
                                 BOOL isFloat,
                                 BOOL isNonInterleaved) {
    return
    (isFloat ? kAudioFormatFlagIsFloat : kAudioFormatFlagIsSignedInteger) |
    (isFloat ? kAudioFormatFlagIsAlignedHigh : kAudioFormatFlagIsPacked)  |
    (isNonInterleaved ? ((UInt32)kAudioFormatFlagIsNonInterleaved) : 0);
}

void FillOutASBDForLPCM(AudioStreamBasicDescription *ABSD,
                        Float64 sampleRate,
                        UInt32 channelsPerFrame,
                        UInt32 bitsPerChannel,
                        BOOL isFloat,
                        BOOL isNonInterleaved) {
    ABSD->mSampleRate = sampleRate;
    ABSD->mFormatID = kAudioFormatLinearPCM;
    ABSD->mFormatFlags =    CalculateLPCMFlags(bitsPerChannel,
                                               isFloat,
                                               isNonInterleaved);
    ABSD->mBytesPerPacket =
    (isNonInterleaved ? 1 : channelsPerFrame) * (bitsPerChannel/8);
    ABSD->mFramesPerPacket = 1;
    ABSD->mBytesPerFrame =
    (isNonInterleaved ? 1 : channelsPerFrame) * (bitsPerChannel/8);
    ABSD->mChannelsPerFrame = channelsPerFrame;
    ABSD->mBitsPerChannel = bitsPerChannel;
}
