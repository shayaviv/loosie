//
//  PreferencesWindowController.m
//  Loosie
//
//  Created by Shay Aviv on 9/16/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import "PreferencesWindowController.h"

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

- (void)windowDidLoad {
    [super windowDidLoad];
    self.defaultsController.appliesImmediately = false;
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)ok:(id)sender {
    if (self.defaultsController.hasUnappliedChanges) {
        [self.defaultsController save:self];
    }
    [self close];
}

- (IBAction)cancel:(id)sender {
    [self.defaultsController revert:self];
    [self close];
}

@end
