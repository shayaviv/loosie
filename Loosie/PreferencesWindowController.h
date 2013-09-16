//
//  PreferencesWindowController.h
//  Loosie
//
//  Created by Shay Aviv on 9/16/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesWindowController : NSWindowController

@property (weak) IBOutlet NSUserDefaultsController *defaultsController;

- (IBAction)ok:(id)sender;
- (IBAction)cancel:(id)sender;

@end
