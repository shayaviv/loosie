//
//  FlacConverter.m
//  Loosie
//
//  Created by Shay Aviv on 9/11/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import "WaveEncoder.h"

#import <AudioToolbox/AudioToolbox.h>
#import <iTunesLibrary/ITLibMediaItem.h>

#import "ITLibMediaItem+SampleData.h"
#import "AudioToolboxUtils.h"

@implementation WaveEncoder

static const UInt32 kBufferSize = 4096;

- (BOOL)encode:(ITLibMediaItem *)item outputURL:(NSURL *)outputURLWithoutExtension error:(NSError **)error {
    BOOL success = NO;
    
    ExtAudioFileRef infile;
    if (HasError(ExtAudioFileOpenURL((__bridge CFURLRef)item.location, &infile), error))
        return NO;
    
    AudioStreamBasicDescription streamDesc = {0};
    FillOutASBDForLPCM(&streamDesc, item.sampleRate, item.channels, item.bitsPerChannel, NO, NO);
    
    ExtAudioFileRef outfile;
    if (HasError(ExtAudioFileCreateWithURL(
            (__bridge CFURLRef)[outputURLWithoutExtension URLByAppendingPathExtension:@"wav"],
                                           kAudioFileWAVEType, &streamDesc, NULL, 0, &outfile), error)) {
        ExtAudioFileDispose(infile);
        return NO;
    }
	
    if (HasError(ExtAudioFileSetProperty(infile, kExtAudioFileProperty_ClientDataFormat,
                                         sizeof(AudioStreamBasicDescription), &streamDesc), error))
        goto error;
	
    if (HasError(ExtAudioFileSetProperty(outfile, kExtAudioFileProperty_ClientDataFormat,
                                         sizeof(AudioStreamBasicDescription), &streamDesc), error))
        goto error;
	
	char srcBuffer[kBufferSize];
    AudioBufferList bufferList = { 1, { streamDesc.mChannelsPerFrame, kBufferSize, srcBuffer }};
    const UInt32 framesToBuffer = kBufferSize / streamDesc.mBytesPerFrame;
    
	while (1) {              
        UInt32 numFrames = framesToBuffer;
        if (HasError(ExtAudioFileRead(infile, &numFrames, &bufferList), error))
            goto error;
        
		if (!numFrames) // this is our termination condition
			break;
		
        if (HasError(ExtAudioFileWrite(outfile, numFrames, &bufferList), error))
            goto error;
	}
    
    success = YES;
    
error:
    ExtAudioFileDispose(infile);
	ExtAudioFileDispose(outfile);
    
    return success;
}

@end
