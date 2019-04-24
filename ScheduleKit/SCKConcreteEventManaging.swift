/*
 *  SCKConcreteEventManaging.swift
 *  ScheduleKit
 *
 *  Created:    Guillem Servera on 6/12/2016.
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

/// A convenience generic wrapper (and thus, Swift only) around `SCKEventManaging` 
/// that provides better-typed methods for your event manager implementation. 
/// 
/// Conform to this protocol when working with a single event class in a Swift 
/// target. In any other case, conform to `SCKEventManaging` directly. See the 
/// `SCKViewController` class description to learn more.
public protocol SCKConcreteEventManaging: SCKEventManaging {

    /// The event type that the associated `SCKViewController` manages.
    associatedtype EventType

    // MARK: - Data source

    /// This method is required when providing events to a SCKViewController
    /// synchronously.
    ///
    /// - Parameters:
    ///   - dateInterval: The date interval being displayed.
    ///   - controller: The SCKViewController requesting events.
    /// - Returns: An array of events compatible with the passed date interval to
    ///            be displayed in the controller's schedule view.
    func concreteEvents(in dateInterval: DateInterval, for controller: SCKViewController) -> [EventType]

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
    func scheduleController(_ controller: SCKViewController,
                            didMakeConcreteEventRequest request: SCKConcreteEventRequest<EventType>)

    // MARK: - Event selection

    /// Implement this method to be notified when an event is selected.
    ///
    /// - Parameters:
    ///   - controller: The SCKViewController owning the selected event view.
    ///   - event: The selected event object.
    func scheduleController(_ controller: SCKViewController, didSelectConcreteEvent event: EventType)

    // MARK: Double clicking

    /// Implement this method to be notified when an event is double clicked in a
    /// schedule view.
    ///
    /// - Parameters:
    ///   - controller: The SCKViewController managing the event.
    ///   - event: The double clicked event.
    func scheduleController(_ controller: SCKViewController, didDoubleClickConcreteEvent event: EventType)

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
                            shouldChangeDurationOfConcreteEvent event: EventType,
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
                            shouldChangeDateOfConcreteEvent event: EventType,
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
    func scheduleController(_ controller: SCKViewController, menuForConcreteEvent event: EventType) -> NSMenu?
}

// MARK: - SCKConcreteEventManaging <-> SCKEventManaging translation
// swiftlint:disable missing_docs
public extension SCKConcreteEventManaging where EventType: SCKEvent {

    private func casted(_ event: SCKEvent) -> EventType {
        guard let casted = event as? EventType else {
            fatalError("Passed \(event) does not match expected type \(String(describing: EventType.self))")
        }
        return casted
    }

    // SCKConcreteEventManaging's SCKEventManaging implementation.

    func events(in dateInterval: DateInterval, for controller: SCKViewController) -> [SCKEvent] {
        return concreteEvents(in: dateInterval, for: controller)
    }

    func scheduleController(_ controller: SCKViewController, didMakeEventRequest request: SCKEventRequest) {
        guard let casted = request as? SCKConcreteEventRequest<EventType> else {
            fatalError("Passed \(request) does not match expected type \(String(describing: EventType.self))")
        }
        return scheduleController(controller, didMakeConcreteEventRequest: casted)
    }

    func scheduleController(_ controller: SCKViewController, didSelectEvent event: SCKEvent) {
        scheduleController(controller, didSelectConcreteEvent: casted(event))
    }

    func scheduleController(_ controller: SCKViewController, didDoubleClickEvent event: SCKEvent) {
        scheduleController(controller, didDoubleClickConcreteEvent: casted(event))
    }

    func scheduleController(_ controller: SCKViewController,
                                   shouldChangeDurationOfEvent event: SCKEvent,
                                   from oldValue: Int, to newValue: Int) -> Bool {
        return scheduleController(controller, shouldChangeDurationOfConcreteEvent: casted(event),
                                  from: oldValue, to: newValue)
    }

    func scheduleController(_ controller: SCKViewController,
                                   shouldChangeDateOfEvent event: SCKEvent,
                                   from oldValue: Date, to newValue: Date) -> Bool {
        return scheduleController(controller, shouldChangeDateOfConcreteEvent: casted(event),
                                  from: oldValue, to: newValue)
    }

    func scheduleController(_ controller: SCKViewController, menuForEvent event: SCKEvent) -> NSMenu? {
        return scheduleController(controller, menuForConcreteEvent: casted(event))
    }
}

public extension SCKConcreteEventManaging where EventType: SCKEvent {

    // MARK: - SCKConcreteEventManaging default implementations
    // We provide default implementations to make them optional

    func concreteEvents(in dateInterval: DateInterval, for controller: SCKViewController) -> [EventType] {
        return []
    }

    func scheduleController(_ controller: SCKViewController,
                                   didMakeConcreteEventRequest request: SCKConcreteEventRequest<EventType>) {
    }

    func scheduleControllerDidClearSelection(_ controller: SCKViewController) {

    }

    func scheduleController(_ controller: SCKViewController, didSelectConcreteEvent event: EventType) {

    }

    func scheduleController(_ controller: SCKViewController, didDoubleClickBlankDate date: Date) {

    }

    func scheduleController(_ controller: SCKViewController, didDoubleClickConcreteEvent event: EventType) {

    }

    func scheduleController(_ controller: SCKViewController,
                                   shouldChangeDurationOfConcreteEvent event: EventType,
                                   from oldValue: Int, to newValue: Int) -> Bool {
        return true
    }

    func scheduleController(_ controller: SCKViewController,
                                   shouldChangeDateOfConcreteEvent event: EventType,
                                   from oldValue: Date, to newValue: Date) -> Bool {
        return true
    }

    func scheduleController(_ controller: SCKViewController, menuForConcreteEvent event: EventType) -> NSMenu? {
        return nil
    }
}
