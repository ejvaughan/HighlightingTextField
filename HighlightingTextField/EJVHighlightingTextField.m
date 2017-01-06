//
//  EJVHighlightingTextField.m
//  FilterDialog
//
//  Created by Ethan Vaughan on 1/5/17.
//  Copyright © 2017 Ethan James Vaughan. All rights reserved.
//

#import "EJVHighlightingTextField.h"

@interface NSColor (HighlightingTextFieldAdditions)

- (NSColor *)darkened;

@end

@implementation NSColor (HighlightingTextFieldAdditions)

- (NSColor *)darkened
{
    CGFloat h, s, b, a;
    [[self colorUsingColorSpaceName:NSCalibratedRGBColorSpace] getHue:&h saturation:&s brightness:&b alpha:&a];
    return [NSColor colorWithHue:h saturation:s brightness:b * 0.75 alpha:a];
}

@end

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
    _matchesHighlightColor = [[NSColor yellowColor] colorWithAlphaComponent:0.8];
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

- (void)setUnderlineMatches:(BOOL)underlineMatches
{
    _underlineMatches = underlineMatches;
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
    
    if (self.underlineMatches) {
        [updated removeAttribute:NSUnderlineStyleAttributeName range:searchRange];
        [updated removeAttribute:NSUnderlineColorAttributeName range:searchRange];
    }
    
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
             NSColor *effectiveHighlightColor = (self.cell.backgroundStyle == NSBackgroundStyleDark) ? self.matchesHighlightColorForHighlightedBackground : self.matchesHighlightColor;
             
             [updated addAttribute:NSBackgroundColorAttributeName
                             value:effectiveHighlightColor
                             range:foundRange];
             
             if (self.underlineMatches) {
                 NSColor *computedUnderlineColor = [[effectiveHighlightColor colorWithAlphaComponent:1.0] darkened];
                 [updated addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:foundRange];
                 [updated addAttribute:NSUnderlineColorAttributeName value:computedUnderlineColor range:foundRange];
             }
             
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
