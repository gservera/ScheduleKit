//
//  SCKUnavailableTimeRange.h
//  ScheduleKit
//
//  Created by Guillem on 31/12/14.
//  Copyright (c) 2014 Guillem Servera. All rights reserved.
//

@import Foundation;
@interface SCKUnavailableTimeRange : NSObject <NSCoding>

- (instancetype)initWithWeekday:(NSInteger)weekday
                      startHour:(NSInteger)startHour
                    startMinute:(NSInteger)startMinute
                        endHour:(NSInteger)endHour
                      endMinute:(NSInteger)endMinute;

@property (assign) NSInteger weekday;
@property (assign) NSInteger startHour;
@property (assign) NSInteger startMinute;
@property (assign) NSInteger endHour;
@property (assign) NSInteger endMinute;
@end
