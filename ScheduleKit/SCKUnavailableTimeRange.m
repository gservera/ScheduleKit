//
//  SCKUnavailableTimeRange.m
//  ScheduleKit
//
//  Created by Guillem on 31/12/14.
//  Copyright (c) 2014 Guillem Servera. All rights reserved.
//

#import "SCKUnavailableTimeRange.h"

NSString * const SCKBreakWeekdayKey = @"BreakWeekday";
NSString * const SCKBreakStartHourKey = @"BreakSH";
NSString * const SCKBreakStartMinuteKey = @"BreakSM";
NSString * const SCKBreakEndHourKey = @"BreakEH";
NSString * const SCKBreakEndMinuteKey = @"BreakEM";

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

@end
