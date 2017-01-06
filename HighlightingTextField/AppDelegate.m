//
//  AppDelegate.m
//  HighlightingTextField
//
//  Created by Ethan Vaughan on 1/5/17.
//  Copyright © 2017 Ethan James Vaughan. All rights reserved.
//

#import "AppDelegate.h"
#import "EJVHighlightingTextField.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *searchField;
@property (weak) IBOutlet EJVHighlightingTextField *label;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.label.underlineMatches = YES;
    
    [self.searchField bind:NSValueBinding
                toObject:self.label
             withKeyPath:@"searchString"
                 options:@{
                           NSContinuouslyUpdatesValueBindingOption: @YES
                           }];
}


@end
