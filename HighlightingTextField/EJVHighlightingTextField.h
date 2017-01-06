//
//  EJVHighlightingTextField.h
//  FilterDialog
//
//  Created by Ethan Vaughan on 1/5/17.
//  Copyright © 2017 Ethan James Vaughan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface EJVHighlightingTextField : NSTextField

// Key-value observable, bindable
@property (nullable, nonatomic, strong) NSString *searchString;

// Defaults to yellow
@property (nonatomic, strong) NSColor *matchesHighlightColor;

// Applied when the text field's cell has a background style of NSBackgroundStyleDark. Defaults to whitish
@property (nonatomic, strong) NSColor *matchesHighlightColorForHighlightedBackground;

// Default value: NO
@property (nonatomic) BOOL underlineMatches;

@end

NS_ASSUME_NONNULL_END
