//
//  SCKTextField.m
//  ScheduleKit
//
//  Created by Guillem on 1/1/15.
//  Copyright (c) 2015 Guillem Servera. All rights reserved.
//

#import "SCKTextField.h"

@implementation SCKTextFieldCell

- (NSRect)drawingRectForBounds:(NSRect)theRect {
    NSRect rect = [super drawingRectForBounds:theRect];
    if (!_editingOrSelected) {
        NSSize textSize = [self cellSizeForBounds:theRect];
        CGFloat heightDelta = NSHeight(rect) - textSize.height;
        if (heightDelta > 0.0) {
            rect.size.height -= heightDelta;
            rect.origin.y += (heightDelta/2.0);
        }
    }
    return rect;
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength {
    NSRect rect = [self drawingRectForBounds:aRect];
    _editingOrSelected = YES;
    [super selectWithFrame:rect inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
    _editingOrSelected = NO;
}

- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent {
    NSRect rect = [self drawingRectForBounds:aRect];
    _editingOrSelected = YES;
    [super editWithFrame:rect inView:controlView editor:textObj delegate:anObject event:theEvent];
    _editingOrSelected = NO;
}

@end

@implementation SCKTextField

+ (void)initialize {
    if (self == [SCKTextField self]) {
        [self setCellClass:[SCKTextFieldCell class]];
    }
}

@end