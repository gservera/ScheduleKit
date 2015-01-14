//
//  SCKView.m
//  ScheduleKit
//
//  Created by Guillem on 24/12/14.
//  Copyright (c) 2014 Guillem Servera. All rights reserved.
//

#import "SCKView.h"
#import "NSView+SKCAdditions.h"
#import "SCKEventManagerPrivate.h"
#import "SCKEventView.h"
#import "SCKEventHolder.h"

@implementation SCKView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self prepare];
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        [self prepare];
    }
    return self;
}

- (void)prepare {
    _absoluteStartTimeRef = 0;
    _absoluteEndTimeRef = 0;
    _relayoutInProgress = NO;
    [[NSNotificationCenter defaultCenter] addObserverForName:NSViewFrameDidChangeNotification object:self queue:nil usingBlock:^(NSNotification *note) {
        [self triggerRelayoutForAllEventViews];
    }];
}

- (void)setStartDate:(NSDate *)startDate {
    _startDate = startDate;
    _absoluteStartTimeRef = [startDate timeIntervalSinceReferenceDate];
    self.needsDisplay = YES;
}

- (void)setEndDate:(NSDate *)endDate {
    _endDate = endDate;
    _absoluteEndTimeRef = [endDate timeIntervalSinceReferenceDate];
    self.needsDisplay = YES;
}

- (void)setColorMode:(SCKEventColorMode)colorMode {
    _colorMode = colorMode;
    [self.subviews makeObjectsPerformSelector:@selector(markAsNeedingDisplay)];
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
    [self.subviews makeObjectsPerformSelector:@selector(markAsNeedingDisplay)];
    if (selectedEventView) {
        if ([_eventManager.delegate respondsToSelector:@selector(eventManager:didSelectEvent:)]) {
            [_eventManager.delegate eventManager:_eventManager didSelectEvent:selectedEventView.eventHolder.representedObject];
        }
    }
}

- (SCKRelativeTimeLocation)calculateRelativeTimeLocationForDate:(NSDate *)date {
    NSTimeInterval timeRef = [date timeIntervalSinceReferenceDate];
    if (timeRef < _absoluteStartTimeRef || timeRef > _absoluteEndTimeRef) {
        return SCKRelativeTimeLocationNotFound;
    } else {
        return (timeRef - _absoluteStartTimeRef) / [self absoluteTimeInterval];
    }
}

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

- (SCKRelativeTimeLocation)relativeTimeLocationForPoint:(NSPoint)location {
    return SCKRelativeTimeLocationNotFound;
}

- (BOOL)isFlipped {
    return YES;
}

- (BOOL)isOpaque {
    return YES;
}

- (BOOL)autoresizesSubviews {
    return YES;
}

- (void)markContentViewAsNeedingDisplay {
    self.needsDisplay = YES;
}

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor whiteColor] setFill];
    NSRectFill(dirtyRect);
}

- (void)beginRelayout {
    _relayoutInProgress = YES;
}

- (void)relayoutEventView:(SCKEventView*)eventView animated:(BOOL)animation {
    
}

- (void)endRelayout {
    _relayoutInProgress = NO;
}

- (void)triggerRelayoutForEventViews:(NSArray*)eventViews animated:(BOOL)animation {
    NSAssert(!_relayoutInProgress,@"Relayout invoked when already triggered");
    [self beginRelayout];
    NSArray *allHolders = [_eventManager managedEventHolders];
    [allHolders makeObjectsPerformSelector:@selector(lock)];
    [eventViews makeObjectsPerformSelector:@selector(prepareForRelayout)];
    for (SCKEventView *eventView in [eventViews copy]) {
        [self relayoutEventView:eventView animated:animation];
    }
    [allHolders makeObjectsPerformSelector:@selector(unlock)];
    [self endRelayout];
}

- (void)triggerRelayoutForAllEventViews {
    [self triggerRelayoutForEventViews:[self subviews] animated:NO];
}

- (void)mouseDown:(NSEvent *)theEvent {
    self.selectedEventView = nil;
    if (theEvent.clickCount == 2) {
        NSPoint loc = [self convertPoint:theEvent.locationInWindow fromView:nil];
        SCKRelativeTimeLocation offset = [self relativeTimeLocationForPoint:loc];
        if (offset != SCKRelativeTimeLocationNotFound) {
            if ([_eventManager.delegate respondsToSelector:@selector(eventManager:didDoubleClickBlankDate:)]) {
                NSDate *blankDate = [self calculateDateForRelativeTimeLocation:offset];
                NSAssert(blankDate != nil, @"Should've generated a date from valid offset");
                [_eventManager.delegate eventManager:_eventManager didDoubleClickBlankDate:blankDate];
            }
        }
    }
}

@end
