/*
 *  SCKEventRequest.swift
 *  ScheduleKit
 *
 *  Created:    Guillem Servera on 16/07/2015.
 *  Copyright:  © 2014-2017 Guillem Servera (https://github.com/gservera)
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

internal protocol AsynchronousRequestParsing: class {
    var asynchronousRequests: Set<SCKEventRequest> { get set }
    func parseData(in eventArray: [SCKEvent], from request: SCKEventRequest)
}

/// The `SCKEventRequest` class represents a wrapper type used by an
/// `SCKViewController` object to encapsulate relevant info and to handle
/// new events when reloading events asynchronously.
///
/// Asynchronous event loading is disabled by default. You may enable it by
/// setting `SCKViewController`'s `loadsEventsAsynchronously` to `true`. When
/// this option is enabled, the `events(from:to:for:)` method won't be called
/// on the event manager. Instead, `scheduleController(_:didMakeEventRequest:)`
/// will get called with this object as a parameter. The event manager is
/// responsible of keeping a (weak) reference to this request, loading the
/// appropiate events asynchronously and, eventually, passing them back to
/// the request on the main queue via the `complete(with:)` method.

@objc public class SCKEventRequest: NSObject {

    // MARK: Variables

    /// Returns whether the request has been canceled.
    @objc public private(set) var isCanceled: Bool = false

    /// The object that issued the request.
    internal private(set) weak var controller: AsynchronousRequestParsing?

    /// The requested starting date parameter for the event fetch criteria.
    @objc public private(set) var startDate: Date

    /// The requested ending date parameter for the event fetch criteria.
    @objc public private(set) var endDate: Date

    /// The request date interval.
    @available(OSX 10.12, *)
    @objc public var dateInterval: DateInterval {
        return DateInterval(start: startDate, end: endDate)
    }
    
    /// An internal flat to track completion.
    fileprivate var isCompleted: Bool = false

    // MARK: Methods

    /// Called from the `SCKViewController` objects to initialize a new `SCKEventRequest`
    /// based on the effective date criteria. This method does not insert the
    /// created request in the controller's `asynchronousRequests` set.
    ///
    /// - Parameters:
    ///   - c: The controller object that creates the request.
    ///   - dateInterval: The date interval that must be used in the event fetching.
    @available(OSX 10.12, *)
    convenience internal init(controller: AsynchronousRequestParsing, dateInterval: DateInterval) {
        self.init(controller: controller, from: dateInterval.start, to: dateInterval.end)
    }
    
    
    /// Called from the `SCKViewController` objects to initialize a new `SCKEventRequest`
    /// based on the effective date criteria. This method does not insert the
    /// created request in the controller's `asynchronousRequests` set.
    ///
    /// - Parameters:
    ///   - c: The controller object that creates the request.
    ///   - sD: The starting date that must be used in the event fetching.
    ///   - eD: The ending date that must be used in the event fetching.
    internal init(controller: AsynchronousRequestParsing, from start: Date, to end: Date) {
        self.controller = controller
        startDate = start
        endDate = end
        super.init()
    }

    ///
    /// Cancels the request if not canceled yet. This will make it ignore any
    /// subsequent calls to `complete(with:)`. In addition, the request will be
    /// released by its owning `SCKViewController` object, so if you don't own any
    /// other strong references to it, it will be also deallocated.
    ///
    @objc public func cancel() {
        isCanceled = true
        _ = controller?.asynchronousRequests.remove(self)
    }

    /// If not canceled or already completed, fulfills the request passing back
    /// the suitable `SCKEvent` objects to the owning `SCKViewController`. In addition, 
    /// the request will be released by its owning `SCKViewController` object, so if 
    /// you don't own any other strong references to it, it will be also deallocated.
    ///
    /// - Parameter events: The asynchronously loaded events.
    /// - Warning: This method **must** be called from the main thread.
    ///
    @objc(completeWithEvents:) public func complete(with events: [SCKEvent]) {
        guard Thread.isMainThread else {
            print("Warning: Background call to SCKEventRequest.complete(with:) will be ignored.")
            return
        }
        if !isCanceled && !isCompleted {
            controller?.parseData(in: events, from: self)
            isCompleted = true
            _ = controller?.asynchronousRequests.remove(self)
        }
    }

    // MARK: Description

    public override var debugDescription: String {
        var base = String(describing: type(of: self))
        base += " (" + (isCompleted ? "Completed | " : "In progress | ")
        base += "Start: \(startDate) | End: \(endDate))"
        return base
    }

}

/// The `SCKConcreteEventRequest` is a convenience generic (thus, Swift-only) 
/// `SCKEventRequest` subclass that replaces the base class when the owning 
/// `SCKViewController` is working with a type-specific delegate, which allows
/// you work in a more type-safe way.
public final class SCKConcreteEventRequest<T>: SCKEventRequest {

    /// If not canceled or already completed, fulfills the request passing back
    /// the suitable `SCKEvent` objects to the owning `SCKViewController`. In addition,
    /// the request will be released by its owning `SCKViewController` object, so if
    /// you don't own any other strong references to it, it will be also deallocated.
    ///
    /// - Parameter events: The asynchronously loaded events.
    /// - Warning: This method **must** be called from the main thread.
    ///
    public func complete<T: SCKEvent>(with events: [T]) {
        super.complete(with: events)
    }

}
