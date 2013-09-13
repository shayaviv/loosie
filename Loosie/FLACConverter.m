//
//  FlacConverter.m
//  Loosie
//
//  Created by Shay Aviv on 9/11/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import "FLACConverter.h"

#import <AudioToolbox/AudioToolbox.h>
#import <iTunesLibrary/ITLibMediaItem.h>
#import <iTunesLibrary/ITLibAlbum.h>
#import <iTunesLibrary/ITLibArtist.h>

#import "NSDateFormatter+ISO8601.h"
#import "ITLibMediaItem+SampleData.h"
#import "AudioToolboxUtils.h"

#include <FLAC/metadata.h>
#include <FLAC/stream_encoder.h>

@implementation FLACConverter

static const UInt32 kSamplesToBuffer = 2048;

static BOOL AddStringFieldToComment(FLAC__StreamMetadata *comment, const char *fieldName, NSString *value);
static BOOL AddNumberFieldToComment(FLAC__StreamMetadata *comment, const char *fieldName, NSUInteger value);
static NSError* TranslateEncoderInitError(FLAC__StreamEncoderInitStatus status);
static NSError* TranslateEncoderStateError(NSString *description, FLAC__StreamEncoder *encoder);

- (id)init
{
    self = [super init];
    if (self) {
        self.compressionLevel = 5;
        self.onlyBasicMetadata = YES;
    }
    return self;
}

- (BOOL)convert:(ITLibMediaItem *)item outputURL:(NSURL *)outputURLWithoutExtension error:(NSError **)error {
    ExtAudioFileRef infile;
    if (HasError(ExtAudioFileOpenURL((__bridge CFURLRef)item.location, &infile), error))
        return NO;
    
    // Force reading as 16 bits per channel
    AudioStreamBasicDescription streamDesc = MakeLinearPCMStreamDescription((UInt32)item.sampleRate, item.channels, 16);
    if (HasError(ExtAudioFileSetProperty(infile, kExtAudioFileProperty_ClientDataFormat,
                                         sizeof(AudioStreamBasicDescription), &streamDesc), error)) {
        ExtAudioFileDispose(infile);
        return NO;
    }
       
	/* allocate the encoder */
    FLAC__StreamEncoder *encoder = FLAC__stream_encoder_new();
	FLAC__stream_encoder_set_channels(encoder, streamDesc.mChannelsPerFrame);
	FLAC__stream_encoder_set_bits_per_sample(encoder, streamDesc.mBitsPerChannel);
	FLAC__stream_encoder_set_sample_rate(encoder, streamDesc.mSampleRate);
    FLAC__stream_encoder_set_compression_level(encoder, self.compressionLevel);
    
	/* now add some metadata; we'll add some tags and a padding block */
    FLAC__StreamMetadata *metadata[2];
	
    metadata[0] = FLAC__metadata_object_new(FLAC__METADATA_TYPE_VORBIS_COMMENT);
    AddStringFieldToComment(metadata[0], "ENCODER", [NSString stringWithFormat:@"%@ %@",
                                                     [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleName"],
                                                     [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"]]);
    AddStringFieldToComment(metadata[0], "TITLE",           item.title);
    AddStringFieldToComment(metadata[0], "ARTIST",          item.artist.name);
    AddStringFieldToComment(metadata[0], "ALBUM",           item.album.title);
    AddStringFieldToComment(metadata[0], "GENRE",           item.genre);
    AddStringFieldToComment(metadata[0], "COMPOSER",        item.composer);
    AddNumberFieldToComment(metadata[0], "TRACKNUMBER",     item.trackNumber);
    AddNumberFieldToComment(metadata[0], "TRACKTOTAL",      item.album.trackCount);
    AddNumberFieldToComment(metadata[0], "DISCNUMBER",      item.album.discNumber);
    AddNumberFieldToComment(metadata[0], "DISCTOTAL",       item.album.discCount);
    AddStringFieldToComment(metadata[0], "CONTENTGROUP",    item.grouping);
    AddStringFieldToComment(metadata[0], "COMMENT",         item.comments);
    AddNumberFieldToComment(metadata[0], "COMPILATION",     item.album.isCompilation);
    if (!self.onlyBasicMetadata) {
        AddStringFieldToComment(metadata[0], "ALBUMARTIST",     item.album.albumArtist);
        AddStringFieldToComment(metadata[0], "TITLESORT",       item.sortTitle);
        AddStringFieldToComment(metadata[0], "ARTISTSORT",      item.artist.sortName);
        AddStringFieldToComment(metadata[0], "ALBUMSORT",       item.album.sortTitle);
        AddStringFieldToComment(metadata[0], "ALBUMARTISTSORT", item.album.sortAlbumArtist);
        AddStringFieldToComment(metadata[0], "COMPOSERSORT",    item.sortComposer);
    }
    if (item.releaseDate)
        AddStringFieldToComment(metadata[0], "DATE", [[NSDateFormatter iso8601] stringFromDate:item.releaseDate]);
    else
        AddNumberFieldToComment(metadata[0], "DATE", item.year);
    
    metadata[1] = FLAC__metadata_object_new(FLAC__METADATA_TYPE_PADDING);
    metadata[1]->length = 4096; /* set the padding length */
    
    FLAC__stream_encoder_set_metadata(encoder, metadata, 2);
    
	/* initialize encoder */
    FLAC__StreamEncoderInitStatus initStatus = FLAC__stream_encoder_init_file(encoder,
        [[outputURLWithoutExtension URLByAppendingPathExtension:@"flac"].path UTF8String], NULL, NULL);
    if (initStatus != FLAC__STREAM_ENCODER_INIT_STATUS_OK) {
        if (error)
            *error = TranslateEncoderInitError(initStatus);
        FLAC__metadata_object_delete(metadata[0]);
        FLAC__metadata_object_delete(metadata[1]);
        ExtAudioFileDispose(infile);
        return NO;
    }
    
    FLAC__int16 srcBuffer[kSamplesToBuffer];
    FLAC__int32 buffer[kSamplesToBuffer];
    
    const UInt32 framesToBuffer = kSamplesToBuffer / streamDesc.mChannelsPerFrame;
    AudioBufferList fillBufList = { 1, { streamDesc.mChannelsPerFrame, framesToBuffer*streamDesc.mBytesPerFrame, srcBuffer }};
    
    BOOL ok = YES;
    do {
        UInt32 numFrames = framesToBuffer;
        if (HasError(ExtAudioFileRead(infile, &numFrames, &fillBufList), error)) {
            ok = NO;
            break;
        }
        
        if (!numFrames) // this is our termination condition
            break;
        
        for (uint32_t i = 0; i < kSamplesToBuffer; ++i)
            buffer[i] = srcBuffer[i];

        if (!FLAC__stream_encoder_process_interleaved(encoder, buffer, numFrames)) {
            if (error)
                *error = TranslateEncoderStateError(@"Error while processing interleaved data", encoder);
            ok = NO;
        }
    } while (ok);
    
    if (ok && !FLAC__stream_encoder_finish(encoder)) {
        if (error)
            *error = TranslateEncoderStateError(@"Error while processing the last frame", encoder);
        ok = NO;
    }
    
	/* now that encoding is finished, the metadata can be freed */
	FLAC__metadata_object_delete(metadata[0]);
	FLAC__metadata_object_delete(metadata[1]);
    
	FLAC__stream_encoder_delete(encoder);
	ExtAudioFileDispose(infile);
    
	return ok;
}

static BOOL AddStringFieldToComment(FLAC__StreamMetadata *comment, const char *fieldName, NSString *value) {
    if (value) {
        FLAC__StreamMetadata_VorbisComment_Entry entry;
        FLAC__metadata_object_vorbiscomment_entry_from_name_value_pair(&entry, fieldName, [value UTF8String]);
        FLAC__metadata_object_vorbiscomment_append_comment(comment, entry, true);
        return YES;
    }
    return NO;
}

static BOOL AddNumberFieldToComment(FLAC__StreamMetadata *comment, const char *fieldName, NSUInteger value) {
    return AddStringFieldToComment(comment, fieldName, value ? [NSString stringWithFormat:@"%ld", value] : nil);
}

static NSError* TranslateEncoderInitError(FLAC__StreamEncoderInitStatus status) {
    return [NSError errorWithDomain:@"FLACEncoder" code:0
                           userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                     @"Error while initializing FLAC encoder", NSLocalizedDescriptionKey,
                                     [NSString stringWithUTF8String:FLAC__StreamEncoderInitStatusString[status]], NSUnderlyingErrorKey, nil]];
}

static NSError* TranslateEncoderStateError(NSString *description, FLAC__StreamEncoder *encoder) {
    return [NSError errorWithDomain:@"FLACEncoder" code:0
                           userInfo:[NSDictionary dictionaryWithObjectsAndKeys: description, NSLocalizedDescriptionKey,
                                     [NSString stringWithUTF8String:FLAC__stream_encoder_get_resolved_state_string(encoder)], NSUnderlyingErrorKey, nil]];
}

@end
