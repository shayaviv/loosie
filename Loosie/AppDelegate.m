//
//  AppDelegate.m
//  Loosie
//
//  Created by Shay Aviv on 9/8/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import "AppDelegate.h"

#import <AppKit/NSOpenPanel.h>
#import <iTunesLibrary/ITLibrary.h>
#import <iTunesLibrary/ITLibPlaylist.h>
#import <iTunesLibrary/ITLibMediaItem.h>
#import <AudioToolbox/ExtendedAudioFile.h>
#import <libkern/OSAtomic.h>

#import "DefaultOutputFileNamer.h"
#import "ConversionCenter.h"

static const int kProgressSteps = 256;

@implementation AppDelegate
{
    double _progress;
}

- (id)init
{
    self = [super init];
    if (self) {       
        self.dockTile = [NSApp dockTile];
        NSImageView *imageView = [[NSImageView alloc] init];
        imageView.image = [NSApp applicationIconImage];
        self.dockTile.contentView = imageView;
        
        self.dockProgress = [[NSProgressIndicator alloc]
                             initWithFrame:NSMakeRect(0.0f, 0.0f, _dockTile.size.width, 10.)];
        self.dockProgress.style = NSProgressIndicatorBarStyle;
        self.dockProgress.indeterminate = NO;
        self.dockProgress.bezeled = YES;
        self.dockProgress.minValue = 0;
        self.dockProgress.maxValue = 1;
        self.dockProgress.hidden = YES;
        [imageView addSubview:self.dockProgress];
        
        ITLibrary *library = [ITLibrary libraryWithAPIVersion:@"1.0" error:nil];
        self.fileNamer = [[DefaultOutputFileNamer alloc] initWithLibrary:library];
        self.conversionCenter = [[ConversionCenter alloc] init];
        self.playlists = library.allPlaylists;
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.name = @"com.Loosie.SongsQueue";
        self.queue.maxConcurrentOperationCount = [[NSProcessInfo processInfo] activeProcessorCount] ?: 1;
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.playlistsController.filterPredicate = [NSPredicate predicateWithFormat:
                                                @"ANY items.mediaKind == %d", ITLibMediaItemMediaKindSong];
    self.panelProgress.usesThreadedAnimation = NO;
    self.progress = 1;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

- (IBAction)chooseDirectory:(id)sender {
    NSOpenPanel *panel = [[NSOpenPanel alloc] init];
    panel.canChooseFiles = false;
    panel.canChooseDirectories = true;
    panel.canCreateDirectories = true;
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton)
        {
            NSURL *selectedDirectory = panel.URL;
            self.fileNamer.outputDirectory = selectedDirectory;
            self.outputDirectoryField.stringValue = selectedDirectory.path;
        }
    }];
}

- (IBAction)convert:(id)sender {  
    if (!self.fileNamer.outputDirectory) {
        [[NSAlert alertWithMessageText:@"No Output Directory" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"You must choose an output directory first."] beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
        return;
    }
    
    ITLibPlaylist *selectedPlaylist = self.playlistsController.selectedObjects[0];
    const NSUInteger itemsCount = selectedPlaylist.items.count;
    __block volatile int32_t convertedCount = 0, errorCount = 0, enumeratedCount = 0;
    self.progress = 0;
    
    for (ITLibMediaItem *item in selectedPlaylist.items)
        [self.queue addOperationWithBlock:^{
            id <Converter> converter = [self.conversionCenter converterForMediaItem:item];
            if (converter) {
                NSURL* outputURL = [self.fileNamer URLWithoutExtensionForMediaItem:item];
                if ([[NSFileManager defaultManager] createDirectoryAtURL:[outputURL URLByDeletingLastPathComponent]
                                             withIntermediateDirectories:YES attributes:nil error:nil]
                    && [converter convert:item outputURL:outputURL error:nil])
                    OSAtomicIncrement32(&convertedCount);
                else
                    OSAtomicIncrement32(&errorCount);
            }
            
            int32_t localEnumeratedCount = OSAtomicIncrement32(&enumeratedCount);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.progress = (double)localEnumeratedCount / itemsCount;
                if (localEnumeratedCount == itemsCount)
                    [[NSAlert alertWithMessageText:@"Put Back That Loosie!" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%d/%d songs have been successfully converted.", convertedCount, convertedCount + errorCount] beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
            });
        }];
}

- (IBAction)stop:(id)sender {
    [self.queue cancelAllOperations];
    [self.queue waitUntilAllOperationsAreFinished];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.progress != 1) {
            self.progress = 1;
            [[NSAlert alertWithMessageText:@"Conversion Stopped" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Some songs may have been converted."] beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
        }
    });
}

- (double)progress {
    return _progress;
}

- (void)setProgress:(double)fraction {
    double newProgress = ceil(fraction * kProgressSteps) / kProgressSteps;
    if (_progress == newProgress)
        return;
    
    self.panelProgress.doubleValue = newProgress;
    if (_progress == 1)
        [NSApp beginSheet:self.conversionPanel
           modalForWindow:self.window modalDelegate:self
           didEndSelector:nil
              contextInfo:nil];
    else if (newProgress == 1) {
        [self.conversionPanel orderOut: self];
        [NSApp endSheet: self.conversionPanel];
    }
    
    _dockProgress.doubleValue = newProgress;
    _dockProgress.hidden = (newProgress == 1);
    [_dockTile display];
    
    _progress = newProgress;
}

@end
