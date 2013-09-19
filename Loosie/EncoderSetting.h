//
//  EncoderSetting.h
//  Loosie
//
//  Created by Shay Aviv on 9/19/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EncoderSetting : NSObject {
    NSString *_description;
}

@property (readonly, nonatomic) NSInteger value;

+ (id)settingWithValue:(NSInteger)value andDescription:(NSString *)description;

@end
