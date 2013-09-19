//
//  ConversionCenter.h
//  Loosie
//
//  Created by Shay Aviv on 9/10/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Encoder.h"
#import "EncoderInfo.h"

@class ITLibMediaItem;

@interface ConversionCenter : NSObject

@property (readonly, nonatomic) NSArray *losslessEncoders;
@property (readonly, nonatomic) NSArray *aacEncoders;
@property (readonly, nonatomic) NSArray *mp3Encoders;

- (id <Encoder>)encoderForMediaItem:(ITLibMediaItem *)item;

@end
