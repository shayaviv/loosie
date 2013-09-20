//
//  AppDelegate.h
//  Loosie
//
//  Created by Shay Aviv on 9/8/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol OutputFileNamer;
@class ConversionCenter;
@class PreferencesWindowController;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign, nonatomic) NSDockTile *dockTile;
@property (strong, nonatomic) NSProgressIndicator *dockProgress;
@property (strong, nonatomic) PreferencesWindowController *preferencesWindowController;

@property (assign, nonatomic) IBOutlet NSWindow *window;
@property (weak, nonatomic) IBOutlet NSArrayController *playlistsController;
@property (weak, nonatomic) IBOutlet NSTextField *outputDirectoryField;

@property (assign, nonatomic) IBOutlet NSPanel *conversionPanel;
@property (weak, nonatomic) IBOutlet NSProgressIndicator *panelProgress;

@property (strong, nonatomic) id <OutputFileNamer> fileNamer;
@property (strong, nonatomic) ConversionCenter *conversionCenter;
@property (strong, nonatomic) NSArray *playlists;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (assign, nonatomic) double progress;

- (IBAction)openPreferences:(id)sender;
- (IBAction)chooseDirectory:(id)sender;
- (IBAction)convert:(id)sender;
- (IBAction)stop:(id)sender;

- (void)modalAlertWithTitle:(NSString *)title andDescription:(NSString *)description;

@end
