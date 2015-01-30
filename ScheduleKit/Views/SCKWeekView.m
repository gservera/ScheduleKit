//
//  SCKWeekView.m
//  ScheduleKit
//
//  Created by Guillem on 31/12/14.
//  Copyright (c) 2014 Guillem Servera. All rights reserved.
//

#import "SCKWeekView.h"
#import "SCKViewPrivate.h"
#import "SCKEventManager.h"
#import "SCKDayPoint.h"
#import "SCKEventView.h"
#import "SCKEventHolder.h"

@implementation SCKWeekView

- (void)customInit {
    [super customInit];
    _dayCount = 7;
    _dayStartPoint = [[SCKDayPoint alloc] initWithHour:0 minute:0 second:0];
    _dayEndPoint = [[SCKDayPoint alloc] initWithHour:21 minute:0 second:0];
    _firstHour = _dayStartPoint.hour;
    _hourCount = _dayEndPoint.hour - _dayStartPoint.hour;
    [self invalidateIntrinsicContentSize];
}

- (void)setStartDate:(NSDate *)startDate {
    [super setStartDate:startDate];
    if (self.endDate) {
        _dayCount = [_calendar components:NSCalendarUnitDay fromDate:startDate toDate:self.endDate options:0].day;
    }
}

- (void)setEndDate:(NSDate *)endDate {
    [super setEndDate:endDate];
    if (self.startDate) {
        _dayCount = [_calendar components:NSCalendarUnitDay fromDate:self.startDate toDate:endDate options:0].day;
    }
}

- (void)readDefaultsFromDelegate {
    [super readDefaultsFromDelegate]; // Sets up unavailable ranges and marks as needing display
    
    if (self.delegate != nil) {
        _dayStartPoint = [[SCKDayPoint alloc] initWithHour:[self.delegate dayStartHourForWeekView:self] minute:0 second:0];
        _dayEndPoint = [[SCKDayPoint alloc] initWithHour:[self.delegate dayEndHourForWeekView:self] minute:0 second:0];
        _firstHour = _dayStartPoint.hour;
        _hourCount = _dayEndPoint.hour - _dayStartPoint.hour;
        [self invalidateIntrinsicContentSize];
        
        if ([self.delegate respondsToSelector:@selector(dayCountForWeekView:)]) {
            NSInteger dayCount = [self.delegate dayCountForWeekView:self];
            if (_dayCount != dayCount) {
                self.endDate = [_calendar dateByAddingUnit:NSCalendarUnitDay value:dayCount toDate:self.startDate options:0];
                [self.eventManager reloadData];
            }
        }
        [self triggerRelayoutForAllEventViews]; //Trigger this even if we call reloadData because it may not reload anything
    }
}

#pragma mark - Event layout calculations

- (CGFloat)yForHour:(NSInteger)h minute:(NSInteger)m {
    NSRect canvas = [self contentRect];
    return NSMinY(canvas) + NSHeight(canvas) * ((CGFloat)(h-_firstHour) + (CGFloat)m/60.0) / (CGFloat)_hourCount;
}

- (NSRect)rectForUnavailableTimeRange:(SCKUnavailableTimeRange *)rng {
    NSRect canvasRect = [self contentRect];
    CGFloat dayWidth = NSWidth(canvasRect)/(CGFloat)_dayCount;
    NSDate *sDate = [_calendar dateBySettingHour:rng.startHour minute:rng.startMinute second:0 ofDate:self.startDate options:0];
    SCKRelativeTimeLocation sOffset = [self calculateRelativeTimeLocationForDate:sDate];
    if (sOffset != SCKRelativeTimeLocationNotFound) {
        NSDate *eDate = [sDate dateByAddingTimeInterval:(rng.endMinute*60+rng.endHour*3600)-(rng.startMinute*60+rng.startHour*3600)];
        SCKRelativeTimeLocation eOffset = [self calculateRelativeTimeLocationForDate:eDate];
        CGFloat yOrigin, yLength;
        if (eOffset != SCKRelativeTimeLocationNotFound) {
            yOrigin = [self yForHour:rng.startHour minute:rng.startMinute];
            yLength = [self yForHour:rng.endHour minute:rng.endMinute] - yOrigin;
        } else {
            yOrigin = [self yForHour:rng.startHour minute:rng.startMinute];
            yLength = NSMaxY(self.frame) - yOrigin;
        }
        return NSMakeRect(NSMinX(canvasRect) + (CGFloat)rng.weekday * dayWidth, yOrigin, dayWidth, yLength);
    } else {
        return NSZeroRect;
    }
    
}

- (void)relayoutEventView:(SCKEventView*)eventView animated:(BOOL)animation {
    NSParameterAssert([eventView isKindOfClass:[SCKEventView class]]);
    NSRect canvasRect = [self contentRect];
    NSRect oldFrame = eventView.frame;
    
    NSAssert1(_dayCount > 0, @"Day count must be greater than zero. %lu found instead.",_dayCount);
    SCKRelativeTimeLocation offsetPerDay = 1.0/(double)_dayCount;
    SCKRelativeTimeLocation startOffset = eventView.eventHolder.cachedRelativeStart;
    NSAssert1(startOffset != SCKRelativeTimeLocationNotFound, @"Expected relativeStart to be set for holder: %@", eventView.eventHolder);
    NSInteger day = (NSInteger)trunc(startOffset/offsetPerDay);
    CGFloat dayWidth = NSWidth(canvasRect)/(CGFloat)_dayCount;
    
    NSRect newFrame = NSZeroRect;

    NSDate *scheduledDate = eventView.eventHolder.cachedScheduleDate;
    SCKDayPoint *sPoint = [[SCKDayPoint alloc] initWithDate:scheduledDate];
    SCKDayPoint *ePoint = [[SCKDayPoint alloc] initWithHour:sPoint.hour minute:sPoint.minute+eventView.eventHolder.cachedDuration second:sPoint.second];
    newFrame.origin.y = [self yForHour:sPoint.hour minute:sPoint.minute];
    newFrame.size.height = [self yForHour:ePoint.hour minute: ePoint.minute]-newFrame.origin.y;
    
    NSArray *conflicts = nil;
    NSInteger idx = [[self eventManager] positionInConflictForEventHolder:eventView.eventHolder holdersInConflict:&conflicts];
    newFrame.size.width = dayWidth / (CGFloat)[conflicts count];
    newFrame.origin.x = canvasRect.origin.x + (CGFloat)day * dayWidth + (newFrame.size.width * (CGFloat)idx);
    
    if (!NSEqualRects(oldFrame, newFrame)) {
        if (animation) {
            eventView.animator.frame = newFrame;
        } else {
            eventView.frame = newFrame;
        }
    }
}

- (SCKRelativeTimeLocation)relativeTimeLocationForPoint:(NSPoint)location {
    NSRect canvasRect = [self contentRect];
    if (NSPointInRect(location, canvasRect)) {
        CGFloat dayWidth = NSWidth(canvasRect)/(CGFloat)_dayCount;
        SCKRelativeTimeLocation offsetPerDay = 1.0/(double)_dayCount;
        NSInteger day = (NSInteger)trunc((location.x-NSMinX(canvasRect))/dayWidth);
        SCKRelativeTimeLocation dayOffset = offsetPerDay * (double)day;
        SCKRelativeTimeLocation offsetPerMin = [self calculateRelativeTimeLocationForDate:[self.startDate dateByAddingTimeInterval:60]];
        SCKRelativeTimeLocation offsetPerHour = 60.0 * offsetPerMin;
        CGFloat totalMinutes = (double)(60*_hourCount);
        CGFloat minute = totalMinutes * (location.y-NSMinY(canvasRect)) / NSHeight(canvasRect);
        SCKRelativeTimeLocation minuteOffset = offsetPerMin * minute;
        return dayOffset + offsetPerHour * (double)_firstHour + minuteOffset;
    } else {
        return SCKRelativeTimeLocationNotFound;
    }
}

#pragma mark - User Actions

- (IBAction)increaseWeekOffset:(id)sender {
    self.startDate = [_calendar dateByAddingUnit:NSCalendarUnitWeekOfYear value:1 toDate:self.startDate options:0];
    self.endDate = [_calendar dateByAddingUnit:NSCalendarUnitWeekOfYear value:1 toDate:self.endDate options:0];
    [self.eventManager reloadData];
}

- (IBAction)decreaseWeekOffset:(id)sender {
    self.startDate = [_calendar dateByAddingUnit:NSCalendarUnitWeekOfYear value:-1 toDate:self.startDate options:0];
    self.endDate = [_calendar dateByAddingUnit:NSCalendarUnitWeekOfYear value:-1 toDate:self.endDate options:0];
    [self.eventManager reloadData];
}

- (IBAction)resetWeekOffset:(id)sender {
    NSDate *beginningOfWeek = nil;
    [_calendar rangeOfUnit:NSCalendarUnitWeekOfYear startDate:&beginningOfWeek interval:nil forDate:[NSDate date]];
    self.startDate = beginningOfWeek;
    if ([self.delegate respondsToSelector:@selector(dayCountForWeekView:)]) {
        NSInteger dayCount = [self.delegate dayCountForWeekView:self];
        self.endDate = [_calendar dateByAddingUnit:NSCalendarUnitDay value:dayCount toDate:beginningOfWeek options:0];
    } else {
        self.endDate = [_calendar dateByAddingUnit:NSCalendarUnitWeekOfYear value:1 toDate:beginningOfWeek options:0];
    }
    [self.eventManager reloadData];
}


@end
