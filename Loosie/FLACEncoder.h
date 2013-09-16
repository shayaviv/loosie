//
//  FlacConverter.h
//  Loosie
//
//  Created by Shay Aviv on 9/11/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Encoder.h"

@interface FLACEncoder : NSObject <Encoder>

@property (assign, nonatomic) UInt32 compressionLevel;
@property (assign, nonatomic) BOOL onlyBasicMetadata;

@end
