/*
 *  SCKView.m
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

#import "SCKView.h"
#import "SCKEventManagerPrivate.h"
#import "SCKEventHolder.h"

@implementation SCKView

#pragma mark - Lifecycle methods

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit {
    _eventViews = [[NSMutableArray alloc] init];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - NSView overrides

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor whiteColor] setFill];
    NSRectFill(dirtyRect);
}

- (void)mouseDown:(NSEvent *)theEvent { // Called when user clicks on an empty space.
    // Deselect selected event view if any
    [self setSelectedEventView:nil];
    // If double clicked on valid coordinates, notify the event manager's delegate.
    if (theEvent.clickCount == 2) {
        NSPoint loc = [self convertPoint:theEvent.locationInWindow fromView:nil];
        SCKRelativeTimeLocation offset = [self relativeTimeLocationForPoint:loc];
        if (offset != SCKRelativeTimeLocationNotFound) {
            if ([_eventManager.delegate respondsToSelector:@selector(eventManager:didDoubleClickBlankDate:)]) {
                NSDate *blankDate = [self calculateDateForRelativeTimeLocation:offset];
                NSAssert(blankDate, @"Should've generated a date from valid offset");
                [_eventManager.delegate eventManager:_eventManager didDoubleClickBlankDate:blankDate];
            }
        }
    }
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldSize {
    [super resizeWithOldSuperviewSize:oldSize];
    [self triggerRelayoutForAllEventViews];
}

- (BOOL)isFlipped {
    return YES;
}

- (BOOL)isOpaque {
    return YES;
}

#pragma mark - Custom getters, setters and KVO-compliance methods

+ (NSSet *)keyPathsForValuesAffectingAbsoluteTimeInterval {
    return [NSSet setWithObjects:
            NSStringFromSelector(@selector(startDate)),
            NSStringFromSelector(@selector(endDate)), nil];
}

- (void)setStartDate:(NSDate *)startDate {
    _startDate = startDate;
    _absoluteStartTimeRef = [startDate timeIntervalSinceReferenceDate];
    [self setNeedsDisplay:YES];
}

- (void)setEndDate:(NSDate *)endDate {
    _endDate = endDate;
    _absoluteEndTimeRef = [endDate timeIntervalSinceReferenceDate];
    [self setNeedsDisplay:YES];
}

- (void)setColorMode:(SCKEventColorMode)colorMode {
    if (colorMode != _colorMode) {
        _colorMode = colorMode;
        for (SCKEventView *eventView in _eventViews) {
            [eventView setNeedsDisplay:YES];
        }
    }
}

- (NSTimeInterval)absoluteTimeInterval {
    return _absoluteEndTimeRef - _absoluteStartTimeRef;
}

- (void)setSelectedEventView:(SCKEventView *)selectedEventView {
    if (_selectedEventView != nil && selectedEventView == nil) {
        if ([_eventManager.delegate respondsToSelector:@selector(eventManagerDidClearSelection:)]) {
            [_eventManager.delegate eventManagerDidClearSelection:_eventManager];
        }
    }
    _selectedEventView = selectedEventView;
    for (SCKEventView *eventView in _eventViews) {
        [eventView setNeedsDisplay:YES];
    }
    if (selectedEventView) {
        if ([_eventManager.delegate respondsToSelector:@selector(eventManager:didSelectEvent:)]) {
            [_eventManager.delegate eventManager:_eventManager
                                  didSelectEvent:selectedEventView.eventHolder.representedObject];
        }
    }
}

#pragma mark - Subview management

- (void)addEventView:(SCKEventView*)eventView {
    NSParameterAssert(eventView != nil);
    [_eventViews addObject:eventView];
}

- (void)removeEventView:(SCKEventView*)eventView {
    NSParameterAssert(eventView != nil);
    [_eventViews removeObject:eventView];
}

#pragma mark - Time-based calculations

- (NSDate*)calculateDateForRelativeTimeLocation:(SCKRelativeTimeLocation)offset {
    if (offset == SCKRelativeTimeLocationNotFound) {
        return nil;
    } else {
        int interval = (int)(_absoluteStartTimeRef + offset * [self absoluteTimeInterval]);
        while ((interval % 60) > 0) {
            interval++;
        }
        return [NSDate dateWithTimeIntervalSinceReferenceDate:(double)interval];
    }
}

- (SCKRelativeTimeLocation)calculateRelativeTimeLocationForDate:(NSDate *)date {
    if (date == nil) {
        NSParameterAssert(date);
        return SCKRelativeTimeLocationNotFound;
    }
    NSTimeInterval timeRef = [date timeIntervalSinceReferenceDate];
    if (timeRef < _absoluteStartTimeRef || timeRef > _absoluteEndTimeRef) {
        return SCKRelativeTimeLocationNotFound;
    } else {
        return (timeRef - _absoluteStartTimeRef) / [self absoluteTimeInterval];
    }
}

- (SCKRelativeTimeLocation)relativeTimeLocationForPoint:(NSPoint)location {
    return SCKRelativeTimeLocationNotFound;
}

#pragma mark - Drag & drop support

- (void)beginDraggingEventView:(SCKEventView*)eV {
    NSMutableArray *subviews = [_eventViews mutableCopy];
    [subviews removeObject:eV];
    _otherEventViews = subviews;
    _eventViewBeingDragged = eV;
    [eV.eventHolder lock];
}

- (void)continueDraggingEventView:(SCKEventView*)eV {
    [self triggerRelayoutForEventViews:_otherEventViews animated:NO];
    [self setNeedsDisplay:YES];
}

- (void)endDraggingEventView:(SCKEventView*)eV {
    [_eventViewBeingDragged.eventHolder unlock];
    _otherEventViews = nil;
    _eventViewBeingDragged = nil;
    [self triggerRelayoutForAllEventViews];
    [self setNeedsDisplay:YES];
}

#pragma mark - Event view layout

- (void)beginRelayout {
    [self willChangeValueForKey:NSStringFromSelector(@selector(relayoutInProgress))];
    _relayoutInProgress = YES;
    [self didChangeValueForKey:NSStringFromSelector(@selector(relayoutInProgress))];
}

- (void)relayoutEventView:(SCKEventView*)eventView animated:(BOOL)animation {
    // Default implementation does nothing
}

- (void)endRelayout {
    [self willChangeValueForKey:NSStringFromSelector(@selector(relayoutInProgress))];
    _relayoutInProgress = NO;
    [self didChangeValueForKey:NSStringFromSelector(@selector(relayoutInProgress))];
}

- (void)triggerRelayoutForEventViews:(NSArray*)eventViews animated:(BOOL)animation {
    NSAssert(!_relayoutInProgress,@"Relayout invoked when already triggered");
    NSArray *allHolders = [_eventManager managedEventHolders];
    if (_eventViewBeingDragged) {
        allHolders = [_otherEventViews valueForKey:NSStringFromSelector(@selector(eventHolder))];
    }
    [self beginRelayout];
    [allHolders makeObjectsPerformSelector:@selector(lock)];
    for (SCKEventView *eventView in eventViews) {
        [self relayoutEventView:eventView animated:animation];
    }
    [allHolders makeObjectsPerformSelector:@selector(unlock)];
    [self endRelayout];
}

- (void)triggerRelayoutForAllEventViews {
    [self triggerRelayoutForEventViews:_eventViews animated:NO];
}

@end
