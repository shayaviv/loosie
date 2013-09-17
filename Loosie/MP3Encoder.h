//
//  MP3Encoder.h
//  Loosie
//
//  Created by Shay Aviv on 9/17/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Encoder.h"

@interface MP3Encoder : NSObject <Encoder>

@property (assign, nonatomic) NSUInteger bitRate;
@property (assign, nonatomic) NSUInteger quality;
@property (assign, nonatomic) BOOL includeAdvancedMetadata;

@end
