//
//  PreferencesWindowController.m
//  Loosie
//
//  Created by Shay Aviv on 9/16/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import "PreferencesWindowController.h"

#import "EncoderInfo.h"
#import "EncoderSetting.h"

@interface PreferencesWindowController ()

@end

@implementation PreferencesWindowController

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    NSUInteger losslessEncoderIndex = [self.conversionCenter.losslessEncoders indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj encoderType] == [self.defaultsController.defaults integerForKey:@"LosslessTargetEncoder"];
    }];
    self.losslessEncoders.selectionIndex = losslessEncoderIndex;
    self.losslessEncoderSettings.selectionIndex = [[self.conversionCenter.losslessEncoders[losslessEncoderIndex] settings] indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj tag] == [self.defaultsController.defaults integerForKey:@"LosslessTargetEncoderSetting"];
    }];
    
    NSUInteger aacEncoderIndex = [self.conversionCenter.aacEncoders indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj encoderType] == [self.defaultsController.defaults integerForKey:@"AACTargetEncoder"];
    }];
    self.aacEncoders.selectionIndex = aacEncoderIndex;
    self.aacEncoderSettings.selectionIndex = [[self.conversionCenter.aacEncoders[aacEncoderIndex] settings] indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj tag] == [self.defaultsController.defaults integerForKey:@"AACTargetEncoderSetting"];
    }];
    
    NSUInteger mp3EncoderIndex = [self.conversionCenter.mp3Encoders indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj encoderType] == [self.defaultsController.defaults integerForKey:@"MP3TargetEncoder"];
    }];
    self.mp3Encoders.selectionIndex = mp3EncoderIndex;
    self.mp3EncoderSettings.selectionIndex = [[self.conversionCenter.mp3Encoders[mp3EncoderIndex] settings] indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj tag] == [self.defaultsController.defaults integerForKey:@"MP3TargetEncoderSetting"];
    }];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    self.defaultsController.appliesImmediately = false;
    
}

- (IBAction)ok:(id)sender {
    [self.defaultsController.defaults setInteger:[self.losslessEncoders.selectedObjects[0] encoderType] forKey:@"LosslessTargetEncoder"];
    [self.defaultsController.defaults setInteger:[self.losslessEncoderSettings.selectedObjects[0] tag] forKey:@"LosslessTargetEncoderSetting"];
    
    [self.defaultsController.defaults setInteger:[self.aacEncoders.selectedObjects[0] encoderType] forKey:@"AACTargetEncoder"];
    [self.defaultsController.defaults setInteger:[self.aacEncoderSettings.selectedObjects[0] tag] forKey:@"AACTargetEncoderSetting"];
    
    [self.defaultsController.defaults setInteger:[self.mp3Encoders.selectedObjects[0] encoderType] forKey:@"MP3TargetEncoder"];
    [self.defaultsController.defaults setInteger:[self.mp3EncoderSettings.selectedObjects[0] tag] forKey:@"MP3TargetEncoderSetting"];
    
    [self.defaultsController save:self];
    [self close];
}

- (IBAction)cancel:(id)sender {
    [self.defaultsController revert:self];
    [self close];
}

@end
