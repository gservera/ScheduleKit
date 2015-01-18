//
//  SCKDayPoint.m
//  ScheduleKit
//
//  Created by Guillem on 31/12/14.
//  Copyright (c) 2014 Guillem Servera. All rights reserved.
//

#import "SCKDayPoint.h"

static NSCalendar * __calendar;

@implementation SCKDayPoint

+ (void)initialize {
    if (self == [SCKDayPoint self]) {
        __calendar = [NSCalendar currentCalendar];
    }
}

+ (instancetype)zeroPoint {
    return [[self alloc] initWithHour:0 minute:0 second:0];
}

- (instancetype)initWithDate:(NSDate*)date {
    NSDateComponents *comps = [__calendar components:NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
    return [self initWithHour:comps.hour minute:comps.minute second:comps.second];
}

- (instancetype)initWithHour:(NSInteger)h minute:(NSInteger)m second:(NSInteger)s {
    self = [super init];
    if (self) {
        _hour = h;
        _minute = m;
        _second = s;
        while (_second >= 60) {
            _second -= 60; _minute += 1;
        }
        while (_second <= -60) {
            _second += 60; _minute -= 1;
        }
        while (_minute >= 60) {
            _minute -= 60; _hour += 1;
        }
        while (_minute <= -60) {
            _minute += 60; _hour -= 1;
        }
    }
    return self;
}

- (NSTimeInterval)dayOffset {
    return (double)_second + (double)(_minute * 60) + (double)(_hour * 3600);
}

- (BOOL)isEarlierThanDayPoint:(SCKDayPoint*)p {
    return (self.dayOffset < p.dayOffset);
}

- (BOOL)isLaterThanDayPoint:(SCKDayPoint*)p {
    return (self.dayOffset > p.dayOffset);
}

- (BOOL)isEqual:(id)object {
    return ([object isKindOfClass:self.class] && [object dayOffset] == self.dayOffset);
}

- (NSUInteger)hash {
    return (NSUInteger)[self dayOffset];
}

@end
