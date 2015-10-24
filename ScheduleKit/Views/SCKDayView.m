//
//  SCKDayView.m
//  ScheduleKit
//
//  Created by Guillem on 31/12/14.
//  Copyright (c) 2014 Guillem Servera. All rights reserved.
//

#import "SCKDayView.h"
#import "SCKViewPrivate.h"
#import "SCKEventView.h"
#import "SCKEventManager.h"

@implementation SCKDayView

- (void)customInit {
    [super customInit];
    _dayCount = 1;
    _firstHour = 0;
    _hourCount = 23;
}

- (void)setStartDate:(NSDate *)startDate {
    [super setStartDate:startDate];
    _firstHour = [_calendar component:NSCalendarUnitHour fromDate:startDate];
    _hourCount = (NSInteger)[self absoluteTimeInterval]/3600.0;
}

- (void)setEndDate:(NSDate *)endDate {
    [super setEndDate:endDate];
    _hourCount = (NSInteger)[self absoluteTimeInterval]/3600.0;
    CGFloat minHHeight = NSHeight([self contentRect])/(CGFloat)_hourCount;
    if (self.hourHeight < minHHeight) {
        self.hourHeight = minHHeight;
    }
}

- (NSRect)rectForUnavailableTimeRange:(SCKUnavailableTimeRange *)rng {
    NSRect canvasRect = [self contentRect];
    NSDate *sDate = [_calendar dateBySettingHour:rng.startHour minute:rng.startMinute second:0 ofDate:self.startDate options:0];
    SCKRelativeTimeLocation sOffset = [self calculateRelativeTimeLocationForDate:sDate];
    if (sOffset != SCKRelativeTimeLocationNotFound) {
        NSDate *eDate = [_calendar dateBySettingHour:rng.endHour minute:rng.endMinute second:0 ofDate:self.startDate options:0];
        SCKRelativeTimeLocation eOffset = [self calculateRelativeTimeLocationForDate:eDate];
        CGFloat yOrigin, yLength;
        if (eOffset != SCKRelativeTimeLocationNotFound) {
            yOrigin = NSMinY(canvasRect) + sOffset * NSHeight(canvasRect);
            yLength = (eOffset-sOffset) * NSHeight(canvasRect);
        } else {
            yOrigin = NSMinY(canvasRect) + sOffset * NSHeight(canvasRect);
            yLength = NSMaxY(self.frame) - yOrigin;
        }
        return NSMakeRect(NSMinX(canvasRect), yOrigin, NSWidth(canvasRect), yLength);
    } else {
        return NSZeroRect;
    }
}

- (void)relayoutEventView:(SCKEventView*)eventView animated:(BOOL)animation {
    NSRect canvasRect = [self contentRect];
    NSRect oldFrame = eventView.frame;
    
    NSRect newFrame = NSZeroRect;
    newFrame.origin.y = canvasRect.origin.y + canvasRect.size.height * eventView.eventHolder.cachedRelativeStart;
    newFrame.size.height = canvasRect.size.height * eventView.eventHolder.cachedRelativeLength;
    
    NSArray *conflicts = nil;
    NSInteger idx = [[self eventManager] positionInConflictForEventHolder:eventView.eventHolder holdersInConflict:&conflicts];
    if ([conflicts count] > 0) {
        newFrame.size.width = canvasRect.size.width / (CGFloat)[conflicts count];
    }
    else {
        newFrame.size.width = canvasRect.size.width;
    }
    newFrame.origin.x = canvasRect.origin.x + (newFrame.size.width * (CGFloat)idx);
    
    if (!NSEqualRects(oldFrame, newFrame)) {
        if (animation) {
            eventView.animator.frame = newFrame;
        } else {
            eventView.frame = newFrame;
        }
    }
}

- (SCKRelativeTimeLocation)relativeTimeLocationForPoint:(NSPoint)location {
    NSRect contentRect = [self contentRect];
    if (NSPointInRect(location, contentRect)) {
        return (location.y - contentRect.origin.y) / contentRect.size.height;
    } else {
        return SCKRelativeTimeLocationNotFound;
    }
}

- (IBAction)increaseDayOffset:(id)sender {
    self.startDate = [_calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:self.startDate options:0];
    self.endDate = [_calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:self.endDate options:0];
    [self.eventManager reloadData];
}

- (IBAction)decreaseDayOffset:(id)sender {
    self.startDate = [_calendar dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:self.startDate options:0];
    self.endDate = [_calendar dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:self.endDate options:0];
    [self.eventManager reloadData];
}

- (IBAction)resetDayOffset:(id)sender {
    NSInteger startHour = [_calendar component:NSCalendarUnitHour fromDate:self.startDate];
    NSInteger endHour = [_calendar component:NSCalendarUnitHour fromDate:self.endDate];
    self.startDate = [_calendar dateBySettingHour:startHour minute:0 second:0 ofDate:[NSDate date] options:0];
    if (endHour < startHour) {
        NSDate *next = [_calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:[NSDate date] options:0];
        self.endDate = [_calendar dateBySettingHour:endHour minute:0 second:0 ofDate:next options:0];
    } else {
        self.endDate = [_calendar dateBySettingHour:endHour minute:0 second:0 ofDate:[NSDate date] options:0];
    }
    [self.eventManager reloadData];
}

@end
