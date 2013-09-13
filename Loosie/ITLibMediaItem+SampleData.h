//
//  ITLibMediaItem+SampleData.h
//  Loosie
//
//  Created by Shay Aviv on 9/12/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import <iTunesLibrary/ITLibMediaItem.h>

@interface ITLibMediaItem (SampleData)

@property (readonly, atomic) UInt32 channels;
@property (readonly, atomic) UInt32 bitsPerChannel;

@end
