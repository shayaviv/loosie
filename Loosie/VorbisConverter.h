//
//  VorbisConverter.h
//  Loosie
//
//  Created by Shay Aviv on 9/12/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Converter.h"

@interface VorbisConverter : NSObject <Converter>

@property (assign, nonatomic) float VBRQuality;
@property (assign, nonatomic) BOOL onlyBasicMetadata;

@end
