//
//  SCKDayPoint.h
//  ScheduleKit
//
//  Created by Guillem on 31/12/14.
//  Copyright (c) 2014 Guillem Servera. All rights reserved.
//

@import Foundation;

@interface SCKDayPoint : NSObject

+ (instancetype)zeroPoint;
- (instancetype)initWithDate:(NSDate*)date;
- (instancetype)initWithHour:(NSInteger)h minute:(NSInteger)m second:(NSInteger)s;

- (BOOL)isEarlierThanDayPoint:(SCKDayPoint*)p;
- (BOOL)isLaterThanDayPoint:(SCKDayPoint*)p;

@property (readonly) NSTimeInterval dayOffset;
@property (assign) NSInteger hour;
@property (assign) NSInteger minute;
@property (assign) NSInteger second;
@end
