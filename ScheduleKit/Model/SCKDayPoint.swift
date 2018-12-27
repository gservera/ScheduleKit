/*
 *  SCKDayPoint.swift
 *  ScheduleKit
 *
 *  Created:    Guillem Servera on 31/12/2014.
 *  Copyright:  © 2014-2019 Guillem Servera (https://github.com/gservera)
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

import Foundation

/// A type that represents an abstract time point within a day.
public struct SCKDayPoint {

    /// The absolute number of seconds this point represents.
    let dayOffset: TimeInterval
    let hour: Int
    let minute: Int
    let second: Int

    /// Returns a `SCKDayPoint` object with all properties set to zero.
    static var zero: SCKDayPoint {
        return self.init(hour: 0, minute: 0, second: 0)
    }

    /// Convenience initializer. Creates a new SCKDayPoint object with hour, minute and
    /// second extracted from an Date object.
    ///
    /// - parameter date: The Date object from which to get h/m/s parameters.
    ///
    /// - returns: The initialized SCKDayPoint.
    public init(date: Date) {
        let components = sharedCalendar.dateComponents([.hour, .minute, .second], from: date)
        self.init(hour: components.hour!, minute: components.minute!, second: components.second!)
    }

    /// Initializes a new `SCKDayPoint` object with hour, minute and second set to the
    /// specified values. If any parameter is less than 0 or more than 60, it gets passed
    /// to the higher unit if possible.
    ///
    /// - parameter hour:   The point's hour.
    /// - parameter minute: The point's minute. If less than 0 or greater than 60 it gets passed to hour.
    /// - parameter second: The point's second. If less than 0 or greater than 60 it gets passed to minute.
    ///
    /// - returns: The initialized SCKDayPoint.
    public init(hour: Int, minute: Int, second: Int) {
        var zHour = hour, zMinute = minute, zSecond = second
        while zSecond >= 60 {
            zSecond -= 60; zMinute += 1
        }
        while zSecond <= -60 {
            zSecond += 60; zMinute -= 1
        }
        if zSecond < 0 {
            zSecond = 60 + zSecond; zMinute -= 1
        }
        while zMinute >= 60 {
            zMinute -= 60; zHour += 1
        }
        while zMinute <= -60 {
            zMinute += 60; zHour -= 1
        }
        if zMinute < 0 {
            zMinute = 60 + zMinute; zHour -= 1
        }
        self.hour = zHour
        self.minute = zMinute
        self.second = zSecond
        dayOffset = Double(zSecond) + Double(zMinute * 60) + Double (zHour * 3600)
    }
}

extension SCKDayPoint: Comparable {

    public static func == (lhs: SCKDayPoint, rhs: SCKDayPoint) -> Bool {
        return lhs.dayOffset == rhs.dayOffset
    }

    public static func < (lhs: SCKDayPoint, rhs: SCKDayPoint) -> Bool {
        return lhs.dayOffset < rhs.dayOffset
    }

}

extension SCKDayPoint: Hashable {
    public var hashValue: Int {
        return dayOffset.hashValue
    }
}
