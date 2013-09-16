//
//  VorbisConverter.h
//  Loosie
//
//  Created by Shay Aviv on 9/12/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Encoder.h"

@interface VorbisEncoder : NSObject <Encoder>

@property (assign, nonatomic) float VBRQuality;
@property (assign, nonatomic) BOOL includeAdvancedMetadata;

@end