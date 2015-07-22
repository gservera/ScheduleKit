/*
 *  SCKUnavailableTimeRange.h
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

@import Foundation;

// NSCoding support keys:
extern __nonnull NSString * const SCKBreakWeekdayKey;
extern __nonnull NSString * const SCKBreakStartHourKey;
extern __nonnull NSString * const SCKBreakStartMinuteKey;
extern __nonnull NSString * const SCKBreakEndHourKey;
extern __nonnull NSString * const SCKBreakEndMinuteKey;

/**
 This class can be used to represent (and to make persistent copies) a break or
 unavailable time range withing a day being represented by a subclass of @c
 SCKGridView. This class supports testing for equalty.
 */
@interface SCKUnavailableTimeRange : NSObject <NSSecureCoding>

/**
 *  Initializes a new @c SCKUnavailableTimeRange object representing a specified
 *  time range within a day.
 *
 *  @param weekday     A weekday index for @c SCKWeekView or -1 for @c SCKDayView.
 *  @param startHour   The time range's start hour.
 *  @param startMinute The time range's start minute.
 *  @param endHour     The time range's end hour.
 *  @param endMinute   The time range's end minute.
 *
 *  @return The initialized @c SCKUnavailableTimeRange
 */
- (nonnull instancetype)initWithWeekday:(NSInteger)weekday startHour:(NSInteger)startHour startMinute:(NSInteger)startMinute endHour:(NSInteger)endHour endMinute:(NSInteger)endMinute NS_DESIGNATED_INITIALIZER;

/**
 *  Compares two @c SCKUnavailableTimeRange objects
 *
 *  @param range A range to be compared with self.
 *
 *  @return YES if the ranges are equal. NO instead.
 */
- (BOOL)isEqualToUnavailableTimeRange:(nonnull SCKUnavailableTimeRange *)range;

@property (assign) NSInteger weekday;     /**< Weekday index in @c SCKView*/
@property (assign) NSInteger startHour;   /**< Break's start hour */
@property (assign) NSInteger startMinute; /**< Break's start minute */
@property (assign) NSInteger endHour;     /**< Break's ending hour */
@property (assign) NSInteger endMinute;   /**< Break's ending minute */
@end
