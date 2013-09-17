//
//  VorbisConverter.m
//  Loosie
//
//  Created by Shay Aviv on 9/12/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import "VorbisEncoder.h"

#import <AudioToolbox/AudioToolbox.h>
#import <iTunesLibrary/ITLibMediaItem.h>
#import <iTunesLibrary/ITLibAlbum.h>
#import <iTunesLibrary/ITLibArtist.h>

#import "NSDateFormatter+ISO8601.h"
#import "ITLibMediaItem+SampleData.h"
#import "AudioToolboxUtils.h"

#include <vorbis/vorbisenc.h>

@implementation VorbisEncoder

static const UInt32 kSamplesToBuffer = 2048;

static BOOL AddStringFieldToComment(vorbis_comment *comment, const char *fieldName, NSString *value);
static BOOL AddNumberFieldToComment(vorbis_comment *comment, const char *fieldName, NSUInteger value);

- (id)init {
    self = [super init];
    if (self) {
        self.VBRQuality = 0.4;
        self.includeAdvancedMetadata = YES;
    }
    return self;
}

- (BOOL)encode:(ITLibMediaItem *)item outputURL:(NSURL *)outputURLWithoutExtension error:(NSError **)error {
    ExtAudioFileRef infile;
    if (HasError(ExtAudioFileOpenURL((__bridge CFURLRef)item.location, &infile), error))
        return NO;
    
    AudioStreamBasicDescription clientFormat = {0};
    clientFormat.mFormatID          = kAudioFormatLinearPCM;
    clientFormat.mFormatFlags       = kAudioFormatFlagsAudioUnitCanonical;
    clientFormat.mBytesPerPacket    = sizeof (AudioUnitSampleType);
    clientFormat.mFramesPerPacket   = 1;
    clientFormat.mBytesPerFrame     = sizeof (AudioUnitSampleType);
    clientFormat.mChannelsPerFrame  = item.channels;
    clientFormat.mBitsPerChannel    = 8 * sizeof (AudioUnitSampleType);
    clientFormat.mSampleRate        = item.sampleRate;
    clientFormat.mFormatFlags = kAudioFormatFlagsAudioUnitCanonical;
    
    if (HasError(ExtAudioFileSetProperty(infile, kExtAudioFileProperty_ClientDataFormat,
                                         sizeof(AudioStreamBasicDescription), &clientFormat), error)) {
        ExtAudioFileDispose(infile);
        return NO;
    }
    
    FILE *outfile = fopen([[outputURLWithoutExtension URLByAppendingPathExtension:@"ogg"].path UTF8String], "wx");
    if (!outfile) {
        ExtAudioFileDispose(infile);
        return NO;
    }
    
    ogg_stream_state os; /* take physical pages, weld into a logical
                          stream of packets */
    ogg_page         og; /* one Ogg bitstream page.  Vorbis packets are inside */
    ogg_packet       op; /* one raw packet of data for decode */
    
    vorbis_info      vi; /* struct that stores all the static vorbis bitstream
                          settings */
    vorbis_comment   vc; /* struct that stores all the user comments */
    
    vorbis_dsp_state vd; /* central working state for the packet->PCM decoder */
    vorbis_block     vb; /* local working space for packet->PCM decode */
    
    /********** Encode setup ************/
    
    vorbis_info_init(&vi);
    
    /* choose an encoding mode.  A few possibilities commented out, one
     actually used: */
    
    /*********************************************************************
     Encoding using a VBR quality mode.  The usable range is -.1
     (lowest quality, smallest file) to 1. (highest quality, largest file).
     Example quality mode .4: 44kHz stereo coupled, roughly 128kbps VBR
     
     ret = vorbis_encode_init_vbr(&vi,2,44100,.4);
     
     ---------------------------------------------------------------------
     
     Encoding using an average bitrate mode (ABR).
     example: 44kHz stereo coupled, average 128kbps VBR
     
     ret = vorbis_encode_init(&vi,2,44100,-1,128000,-1);
     
     ---------------------------------------------------------------------
     
     Encode using a quality mode, but select that quality mode by asking for
     an approximate bitrate.  This is not ABR, it is true VBR, but selected
     using the bitrate interface, and then turning bitrate management off:
     
     ret = ( vorbis_encode_setup_managed(&vi,2,44100,-1,128000,-1) ||
     vorbis_encode_ctl(&vi,OV_ECTL_RATEMANAGE2_SET,NULL) ||
     vorbis_encode_setup_init(&vi));
     
     *********************************************************************/
    
    int ret = vorbis_encode_init_vbr(&vi, clientFormat.mChannelsPerFrame, clientFormat.mSampleRate, self.VBRQuality);
    
    /* do not continue if setup failed; this can happen if we ask for a
     mode that libVorbis does not support (eg, too low a bitrate, etc,
     will return 'OV_EIMPL') */
    
    if (ret) exit(1);
    
    /* add a comment */
    vorbis_comment_init(&vc);
    AddStringFieldToComment(&vc, "ENCODER", [NSString stringWithFormat:@"%@ %@",
                                             [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleName"],
                                             [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"]]);
    AddStringFieldToComment(&vc, "TITLE",           item.title);
    AddStringFieldToComment(&vc, "ARTIST",          item.artist.name);
    AddStringFieldToComment(&vc, "ALBUM",           item.album.title);
    AddStringFieldToComment(&vc, "GENRE",           item.genre);
    AddStringFieldToComment(&vc, "COMPOSER",        item.composer);
    AddNumberFieldToComment(&vc, "TRACKNUMBER",     item.trackNumber);
    AddNumberFieldToComment(&vc, "TRACKTOTAL",      item.album.trackCount);
    AddNumberFieldToComment(&vc, "DISCNUMBER",      item.album.discNumber);
    AddNumberFieldToComment(&vc, "DISCTOTAL",       item.album.discCount);
    AddStringFieldToComment(&vc, "CONTENTGROUP",    item.grouping);
    AddStringFieldToComment(&vc, "COMMENT",         item.comments);
    AddNumberFieldToComment(&vc, "COMPILATION",     item.album.isCompilation);
    if (self.includeAdvancedMetadata) {
        AddStringFieldToComment(&vc, "ALBUMARTIST",     item.album.albumArtist);
        AddStringFieldToComment(&vc, "TITLESORT",       item.sortTitle);
        AddStringFieldToComment(&vc, "ARTISTSORT",      item.artist.sortName);
        AddStringFieldToComment(&vc, "ALBUMSORT",       item.album.sortTitle);
        AddStringFieldToComment(&vc, "ALBUMARTISTSORT", item.album.sortAlbumArtist);
        AddStringFieldToComment(&vc, "COMPOSERSORT",    item.sortComposer);
        if (item.releaseDate)
            AddStringFieldToComment(&vc, "DATE", [[NSDateFormatter iso8601] stringFromDate:item.releaseDate]);
        else
            AddNumberFieldToComment(&vc, "DATE", item.year);
    }
    
    /* set up the analysis state and auxiliary encoding storage */
    vorbis_analysis_init(&vd, &vi);
    vorbis_block_init(&vd, &vb);
    
    /* set up our packet->stream encoder */
    /* pick a random serial number; that way we can more likely build
     chained streams just by concatenation */
    srand((unsigned int) time(NULL));
    ogg_stream_init(&os, rand());
    
    /* Vorbis streams begin with three headers; the initial header (with
     most of the codec setup parameters) which is mandated by the Ogg
     bitstream spec.  The second header holds any comment fields.  The
     third header holds the bitstream codebook.  We merely need to
     make the headers, then pass them to libvorbis one at a time;
     libvorbis handles the additional Ogg bitstream constraints */
    
    {
        ogg_packet header;
        ogg_packet header_comm;
        ogg_packet header_code;
        
        vorbis_analysis_headerout(&vd, &vc, &header, &header_comm, &header_code);
        ogg_stream_packetin(&os, &header);	/* automatically placed in its own
                                             page */
        ogg_stream_packetin(&os, &header_comm);
        ogg_stream_packetin(&os, &header_code);
        
        /* This ensures the actual
         * audio data will start on a new page, as per spec
         */
        while (true) {
            int result = ogg_stream_flush(&os, &og);
            if (result == 0)
                break;
            fwrite(og.header, 1, og.header_len, outfile);
            fwrite(og.body, 1, og.body_len, outfile);
        }
        
    }
    
    const UInt32 framesToBuffer = kSamplesToBuffer / clientFormat.mChannelsPerFrame;
    
    AudioBufferList *bufferList = malloc(sizeof(AudioBufferList) + sizeof(AudioBuffer)*clientFormat.mChannelsPerFrame);
    bufferList->mNumberBuffers = clientFormat.mChannelsPerFrame;
    for (size_t channel = 0; channel < clientFormat.mChannelsPerFrame; ++channel) {
        bufferList->mBuffers[channel].mNumberChannels = 1;
        bufferList->mBuffers[channel].mDataByteSize = framesToBuffer*clientFormat.mBytesPerFrame;
    }
    
    while (true) {
        /* expose the buffer to submit data */
        float **buffer = vorbis_analysis_buffer(&vd, framesToBuffer);
        
        for (size_t channel = 0; channel < clientFormat.mChannelsPerFrame; ++channel)
            bufferList->mBuffers[channel].mData = buffer[channel];
    
        UInt32 numFrames = framesToBuffer;
        if (HasError(ExtAudioFileRead(infile, &numFrames, bufferList), error)) {
            //ok = NO;
            break;
        }
    
        /* tell the library how much we actually submitted */
        vorbis_analysis_wrote(&vd, numFrames);
        if (numFrames == 0)
            break;
        
        /* vorbis does some data preanalysis, then divvies up blocks for
         more involved (potentially parallel) processing.  Get a single
         block for encoding now */
        while (vorbis_analysis_blockout(&vd, &vb) == 1) {
            
            /* analysis, assume we want to use bitrate management */
            vorbis_analysis(&vb, NULL);
            vorbis_bitrate_addblock(&vb);
            
            while (vorbis_bitrate_flushpacket(&vd, &op)) {
                
                /* weld the packet into the bitstream */
                ogg_stream_packetin(&os, &op);
                
                /* write out pages (if any) */
                while (true) {
                    int result = ogg_stream_pageout(&os, &og);
                    if (result == 0)
                        break;
                    fwrite(og.header, 1, og.header_len, outfile);
                    fwrite(og.body, 1, og.body_len, outfile);
                    
                    /* this could be set above, but for illustrative purposes, I do
                     it here (to show that vorbis does know where the stream ends) */
                    
                    if (ogg_page_eos(&og))
                        break;
                }
            }
        }
    }
    
    free(bufferList);
    
    /* clean up and exit.  vorbis_info_clear() must be called last */
    
    ogg_stream_clear(&os);
    vorbis_block_clear(&vb);
    vorbis_dsp_clear(&vd);
    vorbis_comment_clear(&vc);
    vorbis_info_clear(&vi);
    
    /* ogg_page and ogg_packet structs always point to storage in
     libvorbis.  They're never freed or manipulated directly */
    
    ExtAudioFileDispose(infile);
    fclose(outfile);
    return YES;
}

static BOOL AddStringFieldToComment(vorbis_comment *comment, const char *fieldName, NSString *value) {
    if (value) {
        vorbis_comment_add_tag(comment, fieldName, [value UTF8String]);
        return YES;
    }
    return NO;
}

static BOOL AddNumberFieldToComment(vorbis_comment *comment, const char *fieldName, NSUInteger value) {
    return AddStringFieldToComment(comment, fieldName, value ? [NSString stringWithFormat:@"%ld", value] : nil);
}

@end
