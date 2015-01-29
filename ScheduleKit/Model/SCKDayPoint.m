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
    NSParameterAssert(date != nil);
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
