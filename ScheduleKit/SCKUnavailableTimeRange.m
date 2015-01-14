//
//  SCKUnavailableTimeRange.m
//  ScheduleKit
//
//  Created by Guillem on 31/12/14.
//  Copyright (c) 2014 Guillem Servera. All rights reserved.
//

#import "SCKUnavailableTimeRange.h"

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
        _weekday = [aDecoder decodeIntegerForKey:@"BreakWeekday"];
        _startHour = [aDecoder decodeIntegerForKey:@"BreakSH"];
        _startMinute = [aDecoder decodeIntegerForKey:@"BreakSM"];
        _endHour = [aDecoder decodeIntegerForKey:@"BreakEH"];
        _endMinute = [aDecoder decodeIntegerForKey:@"BreakEM"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:_weekday      forKey:@"BreakWeekday"];
    [aCoder encodeInteger:_startHour    forKey:@"BreakSH"];
    [aCoder encodeInteger:_startMinute  forKey:@"BreakSM"];
    [aCoder encodeInteger:_endHour      forKey:@"BreakEH"];
    [aCoder encodeInteger:_endMinute    forKey:@"BreakEM"];
}

@end
