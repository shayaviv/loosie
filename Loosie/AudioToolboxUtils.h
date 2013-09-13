//
//  AudioToolboxUtils.h
//  Loosie
//
//  Created by Shay Aviv on 9/12/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

BOOL HasError(OSStatus status, NSError **error);

AudioStreamBasicDescription MakeLinearPCMStreamDescription(UInt32 sampleRate, UInt32 channels, UInt32 bitsPerChannel);
