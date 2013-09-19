//
//  PreferencesWindowController.m
//  Loosie
//
//  Created by Shay Aviv on 9/16/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import "PreferencesWindowController.h"

#import "EncoderInfo.h"

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
    self.losslessEncoders.selectionIndex = [self.conversionCenter.losslessEncoders indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj encoderType] == [self.defaultsController.defaults integerForKey:@"LosslessTargetEncoder"];
    }];
    self.aacEncoders.selectionIndex = [self.conversionCenter.aacEncoders indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj encoderType] == [self.defaultsController.defaults integerForKey:@"AACTargetEncoder"];
    }];
    self.mp3Encoders.selectionIndex = [self.conversionCenter.mp3Encoders indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj encoderType] == [self.defaultsController.defaults integerForKey:@"MP3TargetEncoder"];
    }];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    self.defaultsController.appliesImmediately = false;
    
}

- (IBAction)ok:(id)sender {
    if (self.defaultsController.hasUnappliedChanges) {
        ;
        [self.defaultsController.defaults setInteger:[self.losslessEncoders.selectedObjects[0] encoderType] forKey:@"LosslessTargetEncoder"];
        [self.defaultsController.defaults setInteger:[self.aacEncoders.selectedObjects[0] encoderType] forKey:@"AACTargetEncoder"];
        [self.defaultsController.defaults setInteger:[self.mp3Encoders.selectedObjects[0] encoderType] forKey:@"MP3TargetEncoder"];
        [self.defaultsController save:self];
    }
    [self close];
}

- (IBAction)cancel:(id)sender {
    [self.defaultsController revert:self];
    [self close];
}

@end
