/*
 *  SCKEventView.m
 *  ScheduleKit
 *
 *  Created:    Guillem Servera on 24/12/2014.
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

#import "SCKEventView.h"
#import "SCKGridView.h"
#import "SCKEventManager.h"
#import "SCKViewPrivate.h"

SCKActionContext SCKActionContextZero() {
    SCKActionContext cx;
    cx.status = SCKDraggingStatusIlde;
    cx.doubleClick = NO;
    cx.oldDuration = 0;
    cx.lastDuration = 0;
    cx.newDuration = 0;
    cx.oldRelativeStart = 0.0;
    cx.newRelativeStart = 0.0;
    cx.internalDelta = 0.0;
    return cx;
}

@implementation SCKEventView

static NSArray *__colors, *__strokeColors;
static NSColor *__specialEventColor;
static NSColor *__specialEventStrokeColor;

+ (void)initialize {
    if (self == [SCKEventView self]) {
        /// Modify these two arrays if you add more values to the `SCKEventType` enum.
        __colors = @[[NSColor colorWithCalibratedRed:0.60 green:0.90 blue:0.60 alpha:1.0],
                     [NSColor colorWithCalibratedRed:1.00 green:0.86 blue:0.29 alpha:1.0],
                     [NSColor colorWithCalibratedRed:0.66 green:0.82 blue:1.00 alpha:1.0]];
        __strokeColors = @[[NSColor colorWithCalibratedRed:0.50 green:0.80 blue:0.50 alpha:1.0],
                           [NSColor colorWithCalibratedRed:0.90 green:0.76 blue:0.19 alpha:1.0],
                           [NSColor colorWithCalibratedRed:0.56 green:0.72 blue:0.90 alpha:1.0]];
        __specialEventColor = [NSColor colorWithCalibratedRed:1.00 green:0.40 blue:0.10 alpha:1.0];
        __specialEventStrokeColor = [NSColor colorWithCalibratedRed:0.9 green:0.3 blue:0.0 alpha:1.0];
    }
}

+ (nonnull NSColor*)colorForEventType:(SCKEventType)type {
    return (type == SCKEventTypeSpecial)? __specialEventColor : __colors[type];
}

+ (NSColor*)strokeColorForEventType:(SCKEventType)type {
    return (type == SCKEventTypeSpecial)? __specialEventStrokeColor : __strokeColors[type];
}

- (instancetype)initWithFrame:(NSRect)f {
    self = [super initWithFrame:f];
    if (self) {
        _actionContext = SCKActionContextZero();
        _innerLabel = [[SCKTextField alloc] initWithFrame:NSMakeRect(0.0, 0.0, NSWidth(f),NSHeight(f))];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    SCKGridView *view = (SCKGridView*)self.superview;
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:self.bounds xRadius:2.0 yRadius:2.0];
    NSColor *fillColor, *strokeColor;
    
    if (view.selectedEventView != nil && view.selectedEventView != self) {
        // Set color to gray when another event is selected
        fillColor = [NSColor colorWithCalibratedWhite:0.85 alpha:1.0];
        strokeColor = [NSColor colorWithCalibratedWhite:0.75 alpha:1.0];
    } else {
        if (view.colorMode == SCKEventColorModeByEventType) {
            SCKEventType type = [_eventHolder.representedObject eventType]; // Does not query db
            fillColor = [self.class colorForEventType:type];
            strokeColor = [self.class strokeColorForEventType:type];
        } else {
            fillColor = _eventHolder.cachedUserLabelColor?:[NSColor colorWithCalibratedRed:0.5 green:0.5 blue:0.5 alpha:1.0];
            double red = fillColor.redComponent, green = fillColor.greenComponent, blue = fillColor.blueComponent;
            strokeColor = [NSColor colorWithCalibratedRed:red-0.1 green:green-0.1 blue:blue-0.1 alpha:1.0];
        }
        if (view.selectedEventView != nil &&
            view.selectedEventView == self &&
            _actionContext.status == SCKDraggingStatusDraggingContent) {
            fillColor = [fillColor colorWithAlphaComponent:0.2];
        }
    }
    [fillColor setFill];
    [strokeColor setStroke];
    
    if (NSMinY(view.contentRect) > [view convertPoint:self.frame.origin fromView:self].y ||
        NSMaxY(view.contentRect) < NSMaxY(self.frame)) {
        CGFloat lineDash[] = {2.0,1.0};
        [[fillColor colorWithAlphaComponent:0.1] setFill];
        [path setLineDash:lineDash count:2 phase:1];
    }
    [path fill];
    [path setLineWidth:(view.selectedEventView == self)? 3.0 : 0.65];
    [path stroke];
}

- (void)prepareForRedistribution {
    self.layoutDone = NO;
}

- (NSMenu *)menuForEvent:(NSEvent *)event {
    SCKEventManager *eM = [(SCKView*)self.superview eventManager];
    id <SCKEventManagerDelegate> delegate = [eM delegate];
    if ([delegate respondsToSelector:@selector(eventManager:menuForEvent:)]) {
        return [delegate eventManager:eM menuForEvent:self.eventHolder.representedObject];
    }
    return nil;
}

- (void)rightMouseDown:(NSEvent *)theEvent {
    if ([(SCKGridView*)self.superview selectedEventView] != self) {
        [(SCKGridView*)self.superview setSelectedEventView:self];
    }
    [super rightMouseDown:theEvent];
}

- (void)rightMouseUp:(NSEvent *)theEvent {
    [super rightMouseUp:theEvent];
    self.needsDisplay = YES;
}

- (void)mouseDown:(NSEvent *)theEvent { // Reset context, select this view if needed and set doubleClick if needed.
    _actionContext = SCKActionContextZero();
    if ([(SCKGridView*)self.superview selectedEventView] != self) {
        [(SCKGridView*)self.superview setSelectedEventView:self];
    }
    if (theEvent.clickCount == 2) {
        _actionContext.doubleClick = YES;
    }
}

- (void)mouseDragged:(NSEvent *)theEvent {
    SCKGridView *rootView = (SCKGridView*)self.superview;
    if ((_actionContext.status == SCKDraggingStatusDraggingDuration) ||
        (_actionContext.status == SCKDraggingStatusIlde && [[NSCursor currentCursor] isEqual:[NSCursor resizeUpDownCursor]])) {
        if (_actionContext.status == SCKDraggingStatusIlde) {
            _actionContext.status = SCKDraggingStatusDraggingDuration;
            _actionContext.oldDuration = self.eventHolder.cachedDuration;
            _actionContext.lastDuration = _actionContext.oldDuration;
            [rootView beginDraggingEventView:self];
        }
        [self parseDurationDrag:theEvent];
    } else {
        if (_actionContext.status == SCKDraggingStatusIlde) {
            _actionContext.status = SCKDraggingStatusDraggingContent;
            _actionContext.oldRelativeStart = [_eventHolder cachedRelativeStart];
            _actionContext.oldDateRef = [[_eventHolder cachedScheduleDate] timeIntervalSinceReferenceDate];
            _actionContext.internalDelta = [self convertPoint:theEvent.locationInWindow fromView:nil].y;
            [rootView beginDraggingEventView:self];
        }
        [self parseContentDrag:theEvent];
    }
    [rootView relayoutEventView:self animated:NO];
    [rootView continueDraggingEventView:self];
}

- (void)parseDurationDrag:(NSEvent*)theEvent {
    SCKGridView *view = (SCKGridView*)self.superview;
    NSPoint superLoc = [view convertPoint:theEvent.locationInWindow fromView:nil];
    
    NSDate *sDate = _eventHolder.cachedScheduleDate;
    NSDate *eDate = [view calculateDateForRelativeTimeLocation:[view relativeTimeLocationForPoint:superLoc]]; //Get new end
    _actionContext.newDuration = (NSInteger)([eDate timeIntervalSinceDate:sDate] / 60.0); // Calculate new duration
    if (_actionContext.newDuration != _actionContext.lastDuration) { // Check if difers from last call
        if (_actionContext.newDuration >= 5) {
            NSPoint localLoc = [self convertPoint:theEvent.locationInWindow fromView:nil];
            NSRect newFrame = self.frame;
            newFrame.size.height = localLoc.y;
            self.frame = newFrame;
            _eventHolder.cachedDuration = _actionContext.newDuration;
        } else {
            _actionContext.newDuration = 5;
        }
        _innerLabel.stringValue = [NSString stringWithFormat:@"%ld min",_actionContext.newDuration];
        _actionContext.lastDuration = _actionContext.newDuration; // Update context
    }
}

- (void)parseContentDrag:(NSEvent*)theEvent {
    SCKGridView *view = (SCKGridView*)self.superview;
    NSPoint tPoint = [view convertPoint:theEvent.locationInWindow fromView:nil];
    tPoint.y -= _actionContext.internalDelta;
    
    SCKRelativeTimeLocation newStartLoc = [view relativeTimeLocationForPoint:tPoint];
    if (newStartLoc == SCKRelativeTimeLocationNotFound && (tPoint.y < NSMidY(view.frame))) { // May be too close to an edge. Check if too low
        tPoint.y = NSMinY([view contentRect]);
        newStartLoc = [view relativeTimeLocationForPoint:tPoint];
    }
    if (newStartLoc != SCKRelativeTimeLocationNotFound) {
        tPoint.y += NSHeight(self.frame);
        SCKRelativeTimeLocation newEndLoc =[view relativeTimeLocationForPoint:tPoint];
        if (newEndLoc != SCKRelativeTimeLocationNotFound) {
            _eventHolder.cachedRelativeStart = newStartLoc;
            _eventHolder.cachedRelativeEnd = newEndLoc;
            _eventHolder.cachedScheduleDate = [view calculateDateForRelativeTimeLocation:newStartLoc];
            _actionContext.newRelativeStart = newStartLoc;
        }
    }
}

- (void)mouseUp:(NSEvent *)theEvent {
    SCKGridView *view = (SCKGridView*)self.superview;
    switch (_actionContext.status) {
        case SCKDraggingStatusDraggingDuration: {
            _innerLabel.stringValue = _eventHolder.cachedTitle?:@"?";
            BOOL changeAllowed = YES;
            if ([view.eventManager.delegate respondsToSelector:@selector(eventManager:shouldChangeLengthOfEvent:fromValue:toValue:)]) {
                changeAllowed = [view.eventManager.delegate eventManager:view.eventManager shouldChangeLengthOfEvent:_eventHolder.representedObject fromValue:_actionContext.oldDuration toValue:_actionContext.newDuration];
            }
            if (changeAllowed) {
                [_eventHolder.representedObject setDuration:@(_actionContext.newDuration)];
                [_eventHolder recalculateRelativeValues];
                [view triggerRelayoutForAllEventViews];
            } else {
                [_eventHolder stopObservingRepresentedObjectChanges];
                [_eventHolder setCachedDuration:_actionContext.oldDuration];
                [_eventHolder resumeObservingRepresentedObjectChanges];
                [view relayoutEventView:self animated:YES];
            }
            [view endDraggingEventView:self];
        } break;
        case SCKDraggingStatusDraggingContent: {
            BOOL changeAllowed = YES;
            NSDate *scheduledDate = [view calculateDateForRelativeTimeLocation:_actionContext.newRelativeStart];
            if ([view.eventManager.delegate respondsToSelector:@selector(eventManager:shouldChangeDateOfEvent:fromValue:toValue:)]) {
                changeAllowed = [view.eventManager.delegate eventManager:view.eventManager shouldChangeDateOfEvent:_eventHolder.representedObject fromValue:[_eventHolder.representedObject scheduledDate] toValue:scheduledDate];
            }
            if (changeAllowed) {
                [_eventHolder stopObservingRepresentedObjectChanges];
                [_eventHolder.representedObject setScheduledDate:scheduledDate];
                [_eventHolder resumeObservingRepresentedObjectChanges];
                [_eventHolder recalculateRelativeValues];
                [view triggerRelayoutForAllEventViews];
            } else {
                [_eventHolder setCachedScheduleDate:[NSDate dateWithTimeIntervalSinceReferenceDate:_actionContext.oldDateRef]];
                [_eventHolder recalculateRelativeValues];
                [view relayoutEventView:self animated:YES];
            }
            [view endDraggingEventView:self];
        } break;
        case SCKDraggingStatusIlde: {
            if (_actionContext.doubleClick && [view.eventManager.delegate respondsToSelector:@selector(eventManager:didDoubleClickEvent:)]) {
                [view.eventManager.delegate eventManager:view.eventManager didDoubleClickEvent:_eventHolder.representedObject];
            }
        } break;
    }
    _actionContext = SCKActionContextZero();
    self.needsDisplay = YES;
}

- (void)viewDidMoveToWindow {
    if (self.superview != nil) {
        [self addSubview:_innerLabel];
        _innerLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_innerLabel setContentCompressionResistancePriority:250 forOrientation:NSLayoutConstraintOrientationHorizontal];
        [_innerLabel setContentCompressionResistancePriority:250 forOrientation:NSLayoutConstraintOrientationVertical];
        NSDictionary *dict = @{@"x":_innerLabel};
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[x]-0-|" options:0 metrics:nil views:dict]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[x]-0-|" options:0 metrics:nil views:dict]];
    }
}

- (void)setEventHolder:(SCKEventHolder *)eventHolder {
    _eventHolder = eventHolder;
    _innerLabel.stringValue = _eventHolder.cachedTitle?:@"";
}

- (BOOL)isFlipped {
    return YES;
}

- (void)resetCursorRects {
    NSRect r = NSMakeRect(0.0, self.frame.size.height-2.0, self.frame.size.width, 4.0);
    [self addCursorRect:r cursor:[NSCursor resizeUpDownCursor]];
}

@end