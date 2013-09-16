//
//  ConversionCenter.h
//  Loosie
//
//  Created by Shay Aviv on 9/10/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Encoder.h"

@class ITLibMediaItem;

@interface ConversionCenter : NSObject

@property (readonly, nonatomic) NSDictionary *allEncoders;

- (id <Encoder>)encoderForMediaItem:(ITLibMediaItem *)item;

@end
