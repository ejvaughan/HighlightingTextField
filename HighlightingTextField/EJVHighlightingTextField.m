//
//  EJVHighlightingTextField.m
//  FilterDialog
//
//  Created by Ethan Vaughan on 1/5/17.
//  Copyright © 2017 Ethan James Vaughan. All rights reserved.
//

#import "EJVHighlightingTextField.h"

@interface EJVHighlightingTextField ()

- (void)updateHighlights;

@end

@interface EJVHighlightingTextFieldCell: NSTextFieldCell

@end

@implementation EJVHighlightingTextFieldCell

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle
{
    [super setBackgroundStyle:backgroundStyle];
    [((EJVHighlightingTextField *)self.controlView) updateHighlights];
}

@end

@implementation EJVHighlightingTextField

+ (void)initialize
{
    if (self == [EJVHighlightingTextField self]) {
        [self exposeBinding:@"searchString"];
    }
}

+ (Class)cellClass
{
    return [EJVHighlightingTextFieldCell class];
}

#pragma mark - Initialization

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    _matchesHighlightColor = [NSColor yellowColor];
    _matchesHighlightColorForHighlightedBackground = [NSColor colorWithWhite:1.0 alpha:0.5];
}

- (void)setSearchString:(NSString *)searchString
{
    _searchString = searchString;
    [self updateHighlights];
}

- (void)setMatchesHighlightColor:(NSColor *)color
{
    _matchesHighlightColor = color;
    [self updateHighlights];
}

- (void)setMatchesHighlightColorForHighlightedBackground:(NSColor *)color
{
    _matchesHighlightColorForHighlightedBackground = color;
    [self updateHighlights];
}

- (void)setObjectValue:(id)objectValue
{
    [super setObjectValue:objectValue];
    [self updateHighlights];
}

- (void)setStringValue:(NSString *)stringValue
{
    [super setStringValue:stringValue];
    [self updateHighlights];
}

- (void)setFloatValue:(float)floatValue
{
    [super setFloatValue:floatValue];
    [self updateHighlights];
}

- (void)setDoubleValue:(double)doubleValue
{
    [super setDoubleValue:doubleValue];
    [self updateHighlights];
}

- (void)setIntValue:(int)intValue
{
    [super setIntValue:intValue];
    [self updateHighlights];
}

- (void)setIntegerValue:(NSInteger)integerValue
{
    [super setIntegerValue:integerValue];
    [self updateHighlights];
}

- (void)setAttributedStringValue:(NSAttributedString *)attributedStringValue
{
    [super setAttributedStringValue:[self highlightedStringForString:attributedStringValue]];
}

- (NSAttributedString *)highlightedStringForString:(NSAttributedString *)input
{
    NSMutableAttributedString *updated = [[NSMutableAttributedString alloc] initWithAttributedString:input];
    
    __block NSRange searchRange = NSMakeRange(0, [updated length]);
    
    // Remove old highlights
    [updated removeAttribute:NSBackgroundColorAttributeName range:searchRange];
    
    [updated addAttribute:NSForegroundColorAttributeName value:(self.cell.backgroundStyle == NSBackgroundStyleDark) ? [NSColor whiteColor] : self.textColor range:searchRange];
    
    if ([self.searchString length] == 0) {
        return updated;
    }
    
    // Apply the highlights
    [self.searchString enumerateSubstringsInRange:NSMakeRange(0, [self.searchString length])
                                          options:NSStringEnumerationByComposedCharacterSequences
                                       usingBlock:
     ^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
         NSRange foundRange = { 0 };
         if (searchRange.location < [updated length] && (foundRange = [updated.string rangeOfString:substring options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch range:searchRange]).location != NSNotFound) {
             [updated addAttribute:NSBackgroundColorAttributeName
                             value:
              (self.cell.backgroundStyle == NSBackgroundStyleDark) ? self.matchesHighlightColorForHighlightedBackground : self.matchesHighlightColor
                             range:foundRange];
             
             searchRange.location = NSMaxRange(foundRange);
             searchRange.length = [updated length] - searchRange.location;
         } else {
             // Clear any highlights we've already applied, because we don't have a match
             [updated removeAttribute:NSBackgroundColorAttributeName range:NSMakeRange(0, [updated length])];
             *stop = YES;
         }
    }];
    
    return updated;
}

- (void)updateHighlights
{
    self.attributedStringValue = self.attributedStringValue;
}

- (BOOL)isEditable
{
    return NO;
}

@end
