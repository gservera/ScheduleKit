/*
 *  SCKTextField.m
 *  ScheduleKit
 *
 *  Created:    Guillem Servera on 01/01/2015.
 *  Copyright:  © 2014-2015 Guillem Servera (http://github.com/gservera)
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 */

#import "SCKTextField.h"

@interface SCKTextFieldCell : NSTextFieldCell {
    BOOL _editingOrSelected;
}
@end

@implementation SCKTextFieldCell

- (NSRect)drawingRectForBounds:(NSRect)theRect {
    NSRect rect = [super drawingRectForBounds:theRect];
    if (!_editingOrSelected) {
        NSSize textSize = [self cellSizeForBounds:theRect];
        CGFloat heightDelta = rect.size.height - textSize.height;
        if (heightDelta > 0.0) {
            rect.size.height -= heightDelta;
            rect.origin.y += (heightDelta/2.0);
        }
    }
    return rect;
}

- (void)selectWithFrame:(NSRect)aRect
                 inView:(NSView *)controlView
                 editor:(NSText *)obj
               delegate:(id)anObject
                  start:(NSInteger)sS
                 length:(NSInteger)sL {
    NSRect rect = [self drawingRectForBounds:aRect];
    _editingOrSelected = YES;
    [super selectWithFrame:rect inView:controlView editor:obj delegate:anObject start:sS length:sL];
    _editingOrSelected = NO;
}

- (void)editWithFrame:(NSRect)aRect
               inView:(NSView *)controlView
               editor:(NSText *)textObj
             delegate:(id)anObject
                event:(NSEvent *)theEvent {
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