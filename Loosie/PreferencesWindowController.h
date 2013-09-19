//
//  PreferencesWindowController.h
//  Loosie
//
//  Created by Shay Aviv on 9/16/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ConversionCenter.h"

@interface PreferencesWindowController : NSWindowController

@property (strong, nonatomic) ConversionCenter *conversionCenter;

@property (weak) IBOutlet NSArrayController *losslessEncoders;
@property (weak) IBOutlet NSArrayController *losslessEncoderSettings;

@property (weak) IBOutlet NSArrayController *aacEncoders;
@property (weak) IBOutlet NSArrayController *aacEncoderSettings;

@property (weak) IBOutlet NSArrayController *mp3Encoders;
@property (weak) IBOutlet NSArrayController *mp3EncoderSettings;

@property (weak, nonatomic) IBOutlet NSUserDefaultsController *defaultsController;

- (IBAction)ok:(id)sender;
- (IBAction)cancel:(id)sender;

@end
