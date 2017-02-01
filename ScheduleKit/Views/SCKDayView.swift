/*
 *  SCKDayView.swift
 *  ScheduleKit
 *
 *  Created:    Guillem Servera on 29/10/2016.
 *  Copyright:  © 2016 Guillem Servera (https://github.com/gservera)
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

import Cocoa

/// An grid-style schedule view that displays events in a single day date
/// interval. Use it by creating a new `SCKViewController` object and setting its
/// `mode` property to `SCKViewControllerMode.day`. Then, configure the view with
/// a date interval from the start of a day (00:00:00) to its last second 
/// (23:59:59).
///
/// Optionally, you may set the `delegate` property and implement its methods to
/// change the displayed hour range (which defaults to the whole day).
///
public final class SCKDayView: SCKGridView {

    // MARK: - Day offset actions
    
    /// Displays the previous day and asks the controller to fetch any matching
    /// events.
    ///
    func decreaseDayOffset(_ sender: Any) {
        let c = sharedCalendar
        if #available(OSX 10.12, *) {
            dateInterval = c.dateInterval(dateInterval, offsetBy: -1, .day)
        } else {
            let base = _DateInterval(start: startDate, end: endDate)
            let offset = c.dateInterval(base, offsetBy: -1, .day)
            setDateIntervalWithDates(from: offset.start, to: offset.end)
        }
        controller._internalReloadData()
    }

    
    /// Displays the next day and asks the controller to fetch any matching
    /// events.
    ///
    func increaseDayOffset(_ sender: Any) {
        let c = sharedCalendar
        if #available(OSX 10.12, *) {
            dateInterval = c.dateInterval(dateInterval, offsetBy: 1, .day)
        } else {
            let base = _DateInterval(start: startDate, end: endDate)
            let offset = c.dateInterval(base, offsetBy: 1, .day)
            setDateIntervalWithDates(from: offset.start, to: offset.end)
        }
        controller._internalReloadData()
    }

    
    /// Displays the default date interval (today) and asks the controller to
    /// fetch matching events.
    ///
    func resetDayOffset(_ sender: Any) {
        let c = sharedCalendar
        guard let sD = c.date(bySettingHour: 0, minute: 0, second: 0, of: Date())
            else {
            fatalError("Could not calculate the start date for current day.")
        }
        if #available(OSX 10.12, *) {
            dateInterval = DateInterval(start: sD, duration: dateInterval.duration)
        } else {
            let offset = _DateInterval(start: sD, duration: duration)
            setDateIntervalWithDates(from: sD, to: offset.end)
        }
        controller._internalReloadData()
    }
}
