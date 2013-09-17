//
//  MP3Encoder.m
//  Loosie
//
//  Created by Shay Aviv on 9/17/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import "MP3Encoder.h"
#import <AudioToolbox/AudioToolbox.h>

#import "ITLibMediaItem+SampleData.h"
#import "AudioToolboxUtils.h"

#include <LAME/lame.h>

static const UInt32 kSamplesToBuffer = 2048;
static const UInt32 kMP3BufferSize = 1.25*kSamplesToBuffer + 7200;

@implementation MP3Encoder

- (BOOL)encode:(ITLibMediaItem *)item outputURL:(NSURL *)outputURLWithoutExtension error:(NSError **)error {
    ExtAudioFileRef infile;
    if (HasError(ExtAudioFileOpenURL((__bridge CFURLRef)item.location, &infile), error))
        return NO;
    
    // Force reading as 2 channels, 16 bits per channel
    AudioStreamBasicDescription clientFormat = {0};
    FillOutASBDForLPCM(&clientFormat, item.sampleRate, 2, 16, NO, NO);
    
    if (HasError(ExtAudioFileSetProperty(infile, kExtAudioFileProperty_ClientDataFormat,
                                         sizeof(AudioStreamBasicDescription), &clientFormat), error)) {
        ExtAudioFileDispose(infile);
        return NO;
    }
    
    FILE *outfile = fopen([[outputURLWithoutExtension URLByAppendingPathExtension:@"mp3"].path UTF8String], "wx");
    if (!outfile) {
        ExtAudioFileDispose(infile);
        return NO;
    }
    
    lame_global_flags *gfp;
    gfp = lame_init();
    lame_set_in_samplerate(gfp,(int)item.sampleRate);
    if (lame_init_params(gfp) < 0) {
        ExtAudioFileDispose(infile);
        fclose(outfile);
        return NO;
    }
    
    int16_t srcBuffer[kSamplesToBuffer];
    uint8_t mp3Buffer[kMP3BufferSize];
    const UInt32 framesToBuffer = kSamplesToBuffer / clientFormat.mChannelsPerFrame;
    AudioBufferList bufferList = { 1, { clientFormat.mChannelsPerFrame, framesToBuffer*clientFormat.mBytesPerFrame, srcBuffer } };
    int bytesWritten;
    
    BOOL ok = YES;
    do {
        UInt32 numFrames = framesToBuffer;
        if (HasError(ExtAudioFileRead(infile, &numFrames, &bufferList), error)) {
            ok = NO;
            break;
        }
        
        if (!numFrames) // this is our termination condition
            break;
        
        bytesWritten = lame_encode_buffer_interleaved(gfp, srcBuffer, framesToBuffer, mp3Buffer, kMP3BufferSize);
        if (bytesWritten >= 0) {
            fwrite(mp3Buffer, bytesWritten, 1, outfile);
        } else {
            ok = NO;
            break;
        }
        
    } while (ok);
    
    bytesWritten = lame_encode_flush(gfp, mp3Buffer, kMP3BufferSize);
    if (bytesWritten >= 0)
        fwrite(mp3Buffer, bytesWritten, 1, outfile);
    else
        ok = NO;
    
    lame_close(gfp);
    fclose(outfile);
    return ok;
}

@end
