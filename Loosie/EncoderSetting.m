//
//  EncoderSetting.m
//  Loosie
//
//  Created by Shay Aviv on 9/19/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import "EncoderSetting.h"

@implementation EncoderSetting

- (NSString *)description {
    return _description;
}

+ (id)settingWithTag:(NSInteger)tag andDescription:(NSString *)description {
    EncoderSetting *setting = [[EncoderSetting alloc] init];
    if (setting) {
        setting->_tag = tag;
        setting->_description = description;
    }
    return setting;
}

@end
