/*
 *  SCKUnavailableTimeRange.m
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

#import "SCKUnavailableTimeRange.h"

NSString * const SCKBreakWeekdayKey     = @"BreakWeekday";
NSString * const SCKBreakStartHourKey   = @"BreakSH";
NSString * const SCKBreakStartMinuteKey = @"BreakSM";
NSString * const SCKBreakEndHourKey     = @"BreakEH";
NSString * const SCKBreakEndMinuteKey   = @"BreakEM";

@implementation SCKUnavailableTimeRange

- (instancetype)initWithWeekday:(NSInteger)weekday
                      startHour:(NSInteger)startHour
                    startMinute:(NSInteger)startMinute
                        endHour:(NSInteger)endHour
                      endMinute:(NSInteger)endMinute {
    self = [super init];
    if (self) {
        _weekday = weekday;
        _startHour = startHour;
        _startMinute = startMinute;
        _endHour = endHour;
        _endMinute = endMinute;
    }
    return self;
}

#pragma mark - NSCoding Protocol

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _weekday     = [aDecoder decodeIntegerForKey:SCKBreakWeekdayKey];
        _startHour   = [aDecoder decodeIntegerForKey:SCKBreakStartHourKey];
        _startMinute = [aDecoder decodeIntegerForKey:SCKBreakStartMinuteKey];
        _endHour     = [aDecoder decodeIntegerForKey:SCKBreakEndHourKey];
        _endMinute   = [aDecoder decodeIntegerForKey:SCKBreakEndMinuteKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:_weekday     forKey:SCKBreakWeekdayKey];
    [aCoder encodeInteger:_startHour   forKey:SCKBreakStartHourKey];
    [aCoder encodeInteger:_startMinute forKey:SCKBreakStartMinuteKey];
    [aCoder encodeInteger:_endHour     forKey:SCKBreakEndHourKey];
    [aCoder encodeInteger:_endMinute   forKey:SCKBreakEndMinuteKey];
}

#pragma mark - Equalty testing

- (BOOL)isEqualToUnavailableTimeRange:(SCKUnavailableTimeRange *)range {
    if (!range) {
        return NO;
    }
    BOOL equalWeekdays = (_weekday == range.weekday);
    BOOL equalStartHour = (_startHour == range.startHour);
    BOOL equalStartMinute = (_startMinute == range.startMinute);
    BOOL equalEndHour = (_endHour == range.endHour);
    BOOL equalEndMinute = (_endMinute == range.endMinute);
    return equalWeekdays && equalStartHour && equalStartMinute && equalEndHour && equalEndMinute;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[SCKUnavailableTimeRange class]]) {
        return NO;
    }
    return [self isEqualToUnavailableTimeRange:(SCKUnavailableTimeRange*)object];
}

- (NSUInteger)hash {
    return @(_weekday).hash^@(_startHour).hash^@(_startMinute).hash^@(_endHour).hash^@(_endMinute).hash;
}

@end