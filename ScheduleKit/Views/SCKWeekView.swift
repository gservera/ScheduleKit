/*
 *  SCKWeekView.swift
 *  ScheduleKit
 *
 *  Created:    Guillem Servera on 29/10/2016.
 *  Copyright:  © 2016-2019 Guillem Servera (https://github.com/gservera)
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

/// An grid-style schedule view that displays events in a week date interval. 
/// Use it by creating a new `SCKViewController` object and setting its `mode` 
/// property to `SCKViewControllerMode.week`. Then, configure the view with
/// a date interval from the start of the first day in the week (00:00:00) to the 
/// last second (23:59:59) of the last day.
///
/// Optionally, you may set the `delegate` property and implement its methods to
/// change the displayed hour range (which defaults to the whole day).
///
@objcMembers public final class SCKWeekView: SCKGridView {

    // MARK: - Displayed week offset

    /// Displays the previous week and asks the controller to fetch any matching
    /// events.
    func decreaseWeekOffset(_ sender: Any) {
        dateInterval = sharedCalendar.dateInterval(dateInterval, offsetBy: -1, .weekOfYear)
        controller.internalReloadData()
    }

    /// Displays the next week and asks the controller to fetch any matching 
    /// events.
    func increaseWeekOffset(_ sender: Any) {
        dateInterval = sharedCalendar.dateInterval(dateInterval, offsetBy: 1, .weekOfYear)
        controller.internalReloadData()
    }

    /// Displays the default date interval (this week) and asks the controller to
    /// reload matching events.
    func resetWeekOffset(_ sender: Any) {
        let units: Set<Calendar.Component> = [.weekOfYear, .yearForWeekOfYear]
        let weekComponents = sharedCalendar.dateComponents(units, from: Date())
        guard let start = sharedCalendar.date(from: weekComponents) else {
            fatalError("Could not calculate the start date for current week.")
        }
        dateInterval = DateInterval(start: start, duration: dateInterval.duration)
        controller.internalReloadData()
    }
}
