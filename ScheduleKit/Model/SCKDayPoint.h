/*
 *  SCKDayPoint.h
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

/** Instances of this class represent an abstract time point between the start
    and the end of a day-width time range. */
@interface SCKDayPoint : NSObject

/**
 *  Convenience method that initializes an @c SCKDayPoint with all properties set to zero.
 *  @return The initialized object, autoreleased.
 */
+ (nonnull instancetype)zeroPoint;

/**
 *  Convenience initializer. Creates a new SCKDayPoint object with hour, minute and
 *  second extracted from an NSDate object.
 *  @param date The NSDate object from which to get h/m/s parameters. Must not be nil.
 *  @return The initialized SCKDayPoint.
 */
- (nonnull instancetype)initWithDate:(nonnull NSDate*)date;

/**
 *  Initializes a new SCKDayPoint object with hour, minute and second set to the
 *  specified values. If any parameter is less than 0 or more than 60, it gets passed
 *  to the higher unit if possible.
 *
 *  @param h The point's hour.
 *  @param m The point's minute. If less than 0 or greater than 60 it gets passed to hour.
 *  @param s The point's second. If less than 0 or greater than 60 it gets passed to minute
 *
 *  @return The initialized SCKDayPoint.
 */
- (nonnull instancetype)initWithHour:(NSInteger)h minute:(NSInteger)m second:(NSInteger)s NS_DESIGNATED_INITIALIZER;

/**
 *  Compares two SCKDayPoint objects.
 *  @param dayPoint The SCKDayPoint object to be compared to self.
 *  @return YES if self is earlier in time than @c p. NO instead.
 */
- (BOOL)isEarlierThanDayPoint:(nonnull SCKDayPoint*)p;

/**
 *  Compares two SCKDayPoint objects.
 *  @param dayPoint The SCKDayPoint object to be compared to self.
 *  @return YES if self is later in time than @c p. NO instead.
 */
- (BOOL)isLaterThanDayPoint:(nonnull SCKDayPoint*)p;

/**
 *  Compares two SCKDayPoint objects.
 *  @param dayPoint The SCKDayPoint object to be compared to self.
 *  @return YES if dayOffsets are equal. NO instead.
 */
- (BOOL)isEqualToDayPoint:(nonnull SCKDayPoint*)dayPoint;

@property (readonly) NSTimeInterval dayOffset; /**< Returns the total number of seconds */
@property (assign) NSInteger hour;   /**< The day point's hour */
@property (assign) NSInteger minute; /**< The day point's minute */
@property (assign) NSInteger second; /**< The day point's second. Usually zero. */
@end
