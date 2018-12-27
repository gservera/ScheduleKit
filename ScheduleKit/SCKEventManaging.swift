/*
 *  SCKEventManaging.swift
 *  ScheduleKit
 *
 *  Created:    Guillem Servera on 15/11/2016.
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

/// A type that implements the required methods to provide events either
/// synchronously or asynchronously to a `SCKViewController`; plus some methods
/// related to the user interaction with the controller's schedule view.
///
/// If you use Swift, you may choose between implementing `SCKEventManaging` or
/// working in concrete mode by conforming to `SCKConcreteEventManaging` and
/// declaring an event type. Use the concrete mode when working with a single
/// event class to benefit from Swift's type safety and work with better-typed
/// methods in your event manager implementation. In any other case, conform to
/// this protocol directly. See the `SCKViewController` class description to
/// learn more.
public protocol SCKEventManaging: class {

    // MARK: - Data source

    /// This method is required when providing events to a SCKViewController
    /// synchronously.
    ///
    /// - Parameters:
    ///   - dateInterval: The date interval being displayed.
    ///   - controller: The SCKViewController requesting events.
    /// - Returns: An array of events compatible with the passed date interval to
    ///            be displayed in the controller's schedule view.
    func events(in dateInterval: DateInterval, for controller: SCKViewController) -> [SCKEvent]

    /// This method is required when providing events to a SCKViewController
    /// asynchronously. To fetch events in a background queue, keep a reference
    /// of the event request (from which you can get the requested date interval)
    /// and perform the actual fetch asynchronously. When finished, make sure you
    /// call `complete(with:)` from the main queue to pass the fetched events
    /// back to the controller.
    ///
    /// - Parameters:
    ///   - controller: The SCKViewController requesting events.
    ///   - request: The just created event request.
    func scheduleController(_ controller: SCKViewController, didMakeEventRequest request: SCKEventRequest)

    // MARK: - Event selection

    /// Implement this method to be notified when an event is selected.
    ///
    /// - Parameters:
    ///   - controller: The SCKViewController owning the selected event view.
    ///   - event: The selected event object.
    func scheduleController(_ controller: SCKViewController, didSelectEvent event: SCKEvent)

    /// Implement this method to be notified when an event is deselected in a
    /// schedule view.
    ///
    /// - Parameter controller: The SCKViewController owning the schedule view.
    func scheduleControllerDidClearSelection(_ controller: SCKViewController)

    // MARK: Double clicking

    /// Implement this method to be notified when an empty date is double clicked
    /// in a schedule view.
    ///
    /// - Parameters:
    ///   - controller: The SCKViewController owning the schedule view.
    ///   - date: The double clicked date.
    func scheduleController(_ controller: SCKViewController, didDoubleClickBlankDate date: Date)

    /// Implement this method to be notified when an event is double clicked in a
    /// schedule view.
    ///
    /// - Parameters:
    ///   - controller: The SCKViewController managing the event.
    ///   - event: The double clicked event.
    func scheduleController(_ controller: SCKViewController, didDoubleClickEvent event: SCKEvent)

    // MARK: Event changing

    /// Implement this method to conditionally allow or deny a user-initiated
    /// duration change in one of the events managed by a SCKViewController. If
    /// you don't implement this method, changes are allowed by default.
    ///
    /// - Parameters:
    ///   - controller: The SCKViewController asking for permission.
    ///   - event: The event's whose duration is going to change.
    ///   - oldValue: The current event's duration in minutes.
    ///   - newValue: The proposed event's duration in minutes.
    /// - Returns: `true` if the change should be commited or `false` instead.
    func scheduleController(_ controller: SCKViewController,
                            shouldChangeDurationOfEvent event: SCKEvent,
                            from oldValue: Int, to newValue: Int) -> Bool

    /// Implement this method to conditionally allow or deny a user-initiated
    /// date change in one of the events managed by a SCKViewController. If
    /// you don't implement this method, changes are allowed by default.
    ///
    /// - Parameters:
    ///   - controller: The SCKViewController asking for permission.
    ///   - event: The event's whose duration is going to change.
    ///   - oldValue: The current event's scheduled date in minutes.
    ///   - newValue: The proposed event's schaduled date in minutes.
    /// - Returns: `true` if the change should be commited or `false` instead.
    func scheduleController(_ controller: SCKViewController,
                            shouldChangeDateOfEvent event: SCKEvent,
                            from oldValue: Date, to newValue: Date) -> Bool

    // MARK: Contextual menu

    /// Implement this method to conditionally provide a contextual menu for
    /// one or more events in a schedule view.
    ///
    /// - Parameters:
    ///   - controller: The SCKViewController managing a right clicked event.
    ///   - event: The right clicked event.
    /// - Returns: An NSMenu object to will be displayed as a contextual menu or
    ///            `nil` if you don't want to display a menu for this particular
    ///            event.
    func scheduleController(_ controller: SCKViewController, menuForEvent event: SCKEvent) -> NSMenu?

}

// swiftlint:disable missing_docs
public extension SCKEventManaging {

    func events(in dateInterval: DateInterval, for controller: SCKViewController) -> [SCKEvent] {
        return []
    }

    func scheduleController(_ controller: SCKViewController, didMakeEventRequest request: SCKEventRequest) { }

    func scheduleController(_ controller: SCKViewController, didSelectEvent event: SCKEvent) {}

    func scheduleControllerDidClearSelection(_ controller: SCKViewController) {}

    func scheduleController(_ controller: SCKViewController, didDoubleClickBlankDate date: Date) {}

    func scheduleController(_ controller: SCKViewController, didDoubleClickEvent event: SCKEvent) {}

    func scheduleController(_ controller: SCKViewController,
                            shouldChangeDurationOfEvent event: SCKEvent,
                            from oldValue: Int, to newValue: Int) -> Bool {
        return true
    }

    func scheduleController(_ controller: SCKViewController,
                            shouldChangeDateOfEvent event: SCKEvent,
                            from oldValue: Date, to newValue: Date) -> Bool {
        return true
    }

    func scheduleController(_ controller: SCKViewController,
                            menuForEvent event: SCKEvent) -> NSMenu? {
        return nil
    }
}
