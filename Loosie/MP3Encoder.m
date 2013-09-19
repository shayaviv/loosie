//
//  MP3Encoder.m
//  Loosie
//
//  Created by Shay Aviv on 9/17/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import "MP3Encoder.h"
#import <AudioToolbox/AudioToolbox.h>
#import <iTunesLibrary/ITLibMediaItem.h>
#import <iTunesLibrary/ITLibAlbum.h>
#import <iTunesLibrary/ITLibArtist.h>

#import "ITLibMediaItem+SampleData.h"
#import "AudioToolboxUtils.h"

#include <LAME/lame.h>

@implementation MP3Encoder

static const UInt32 kSamplesToBuffer = 2048;
static const UInt32 kMP3BufferSize = 1.25*kSamplesToBuffer + 7200;

static BOOL AddTextInfoToID3Tag(lame_global_flags *gfp, const char *field, NSString *text);
static BOOL AddFieldValueToID3Tag(lame_global_flags *gfp, const char *field, NSString *value);
static BOOL AddCommentToID3Tag(lame_global_flags *gfp, NSString *comment);

- (id)init {
    self = [super init];
    if (self) {
        self.setting = MP3EncoderSettingGoodQuality;
        self.includeAdvancedMetadata = YES;
    }
    return self;
}

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
    
    FILE *outfile = fopen([[outputURLWithoutExtension URLByAppendingPathExtension:@"mp3"].path UTF8String], "w+x");
    if (!outfile) {
        ExtAudioFileDispose(infile);
        return NO;
    }
    
    lame_global_flags *gfp;
    gfp = lame_init();
    
    lame_set_num_channels(gfp, item.channels);
    lame_set_in_samplerate(gfp, (int)item.sampleRate);
    
    switch (self.setting) {
        case MP3EncoderSettingHighestQuality:
            lame_set_brate(gfp, 320);
            lame_set_quality(gfp, 2);
            break;
        case MP3EncoderSettingVeryHighQuality:
            lame_set_VBR(gfp, vbr_default);
            lame_set_VBR_quality(gfp, 1);
            break;
        case MP3EncoderSettingGoodQuality:
            lame_set_VBR(gfp, vbr_default);
            lame_set_VBR_quality(gfp, 4);
            break;
        case MP3EncoderSettingAcceptableQuality:
            lame_set_VBR(gfp, vbr_default);
            lame_set_VBR_quality(gfp, 6);
            break;
    }

    
    id3tag_init(gfp);
    id3tag_v2_only(gfp);
    lame_set_write_id3tag_automatic(gfp, 0);
    
    AddTextInfoToID3Tag(gfp, "TIT2", item.title);
    AddTextInfoToID3Tag(gfp, "TPE1", item.artist.name);
    AddTextInfoToID3Tag(gfp, "TALB", item.album.title);
    AddTextInfoToID3Tag(gfp, "TCON", item.genre);
    AddTextInfoToID3Tag(gfp, "TCOM", item.composer);
    NSString *track = item.trackNumber ? (item.album.trackCount ? [NSString stringWithFormat:@"%ld/%ld", item.trackNumber, item.album.trackCount] : [NSString stringWithFormat:@"%ld", item.trackNumber]) : nil;
    if (track)
        id3tag_set_track(gfp, [track UTF8String]);
    AddFieldValueToID3Tag(gfp, "TPOS", item.album.discNumber ? (item.album.discCount ? [NSString stringWithFormat:@"%ld/%ld", item.album.discNumber, item.album.discCount] : [NSString stringWithFormat:@"%ld", item.album.discNumber]) : nil);
    if (item.year)
        id3tag_set_year(gfp, [[NSString stringWithFormat:@"%ld", item.year] UTF8String]);
    AddTextInfoToID3Tag(gfp, "TIT1", item.grouping);
    if (item.album.compilation)
        AddFieldValueToID3Tag(gfp, "TCMP", @"1");
    AddCommentToID3Tag(gfp, item.comments);
    if (self.includeAdvancedMetadata) {
        AddFieldValueToID3Tag(gfp, "TBPM", item.beatsPerMinute ? [NSString stringWithFormat:@"%ld", item.beatsPerMinute] : nil);
        AddTextInfoToID3Tag(gfp, "TPE2", item.album.albumArtist);
        AddTextInfoToID3Tag(gfp, "TSOT", item.sortTitle);
        AddTextInfoToID3Tag(gfp, "TSOP", item.artist.sortName);
        AddTextInfoToID3Tag(gfp, "TSOA", item.album.sortTitle);
        AddTextInfoToID3Tag(gfp, "TSOC", item.sortComposer);
    }
    
    if (lame_init_params(gfp) < 0) {
        ExtAudioFileDispose(infile);
        fclose(outfile);
        return NO;
    }

	size_t id3v2_size = lame_get_id3v2_tag(gfp, 0, 0);
	if (id3v2_size) {
		unsigned char *id3v2tag = malloc(id3v2_size);
		if(id3v2tag) {
			id3v2_size = lame_get_id3v2_tag(gfp, id3v2tag, id3v2_size);
			fwrite(id3v2tag, 1, id3v2_size, outfile);
			free(id3v2tag);
		}
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
    
    lame_mp3_tags_fid(gfp, outfile);
    lame_close(gfp);
    fclose(outfile);
    return ok;
}

static BOOL AddTextInfoToID3Tag(lame_global_flags *gfp, const char *field, NSString *text) {
    if (text) {
        NSData *data = [text dataUsingEncoding:NSUTF16StringEncoding];
        size_t charCount = data.length / sizeof(unsigned short);
        unsigned short nullTerminatedUTF16[charCount + 1];
        memcpy(nullTerminatedUTF16, data.bytes, data.length);
        nullTerminatedUTF16[charCount] = '\0';
        id3tag_set_textinfo_utf16(gfp, field, nullTerminatedUTF16);
        return YES;
    }
    return NO;
}

static BOOL AddFieldValueToID3Tag(lame_global_flags *gfp, const char *field, NSString *value) {
    if (value) {
        id3tag_set_fieldvalue(gfp, [[NSString stringWithFormat:@"%s=%@", field, value] UTF8String]);
        return YES;
    }
    return NO;
}

static BOOL AddCommentToID3Tag(lame_global_flags *gfp, NSString *comment) {
    if (comment) {
        static const unsigned short desc[] = { 0xfeff, 0 };
        NSData *data = [comment dataUsingEncoding:NSUTF16StringEncoding];
        size_t charCount = data.length / sizeof(unsigned short);
        unsigned short nullTerminatedUTF16[charCount + 1];
        memcpy(nullTerminatedUTF16, data.bytes, data.length);
        nullTerminatedUTF16[charCount] = '\0';
        id3tag_set_comment_utf16(gfp, "eng", desc, nullTerminatedUTF16);
        return YES;
    }
    return NO;
}

@end
