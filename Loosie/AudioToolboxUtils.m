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

AudioStreamBasicDescription MakeLinearPCMStreamDescription(UInt32 sampleRate, UInt32 channels, UInt32 bitsPerChannel) {
    AudioStreamBasicDescription desc;
    desc.mSampleRate = sampleRate;
    desc.mFormatID = kAudioFormatLinearPCM;
    desc.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    desc.mBytesPerPacket = 1 * channels * bitsPerChannel / 8;
    desc.mFramesPerPacket = 1;
    desc.mBytesPerFrame = channels * bitsPerChannel / 8;
    desc.mChannelsPerFrame = channels;
    desc.mBitsPerChannel = bitsPerChannel;
    desc.mReserved = 0;
    return desc;
}
