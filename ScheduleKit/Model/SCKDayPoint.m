/*
 *  SCKDayPoint.m
 *  ScheduleKit
 *
 *  Created:    Guillem Servera on 31/12/2014.
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

#import "SCKDayPoint.h"

@implementation SCKDayPoint

static NSCalendar * __calendar;

+ (void)initialize {
    if (self == [SCKDayPoint self]) {
        __calendar = [NSCalendar currentCalendar];
    }
}

+ (instancetype)zeroPoint {
    return [[self alloc] initWithHour:0 minute:0 second:0];
}

- (instancetype)init {
    return [self initWithHour:0 minute:0 second:0];
}

- (instancetype)initWithDate:(NSDate*)date {
    NSParameterAssert(date != nil);
    NSCalendarUnit flags = NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
    NSDateComponents *comps = [__calendar components:flags fromDate:date];
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

#pragma mark - Equalty testing

- (BOOL)isEqualToDayPoint:(SCKDayPoint*)dayPoint {
    return ([dayPoint dayOffset] == self.dayOffset);
}

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    } else if (![object isKindOfClass:[SCKDayPoint class]]) {
        return NO;
    }
    return [self isEqualToDayPoint:(SCKDayPoint*)object];
}

- (NSUInteger)hash {
    return @([self dayOffset]).hash;
}

@end
