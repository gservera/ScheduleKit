/*
 *  SCKEvent.swift
 *  ScheduleKit
 *
 *  Created:    Guillem Servera on 24/12/2014.
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

import Cocoa

/// Any type implementing the relevant methods for an `SCKEvent`'s user.
@objc public protocol SCKUser: class {

    /// The color that will be used as `SCKEventView`s background when displayed
    /// in a `SCKView` with `colorMode` set to `.byEventOwner`.
    @objc var eventColor: NSColor { get }
}

/// Any type implementing the properties required to define an event displayed in
/// a `SCKView` subclass.
@objc public protocol SCKEvent where Self: NSObject {

    /// An integer used by the `SCKView` to distinguish between different event
    /// types when `colorMode` is set to `.byEventKind`. Please reserve the `-1`
    /// value for special or transitory events.
    ///
    /// - Note: A good practice when managing events whith different types could 
    ///         could be creating an enum wrapper and returning its raw values in
    ///         this property. The framework does not include the enum to allow
    ///         you to define it with the event types you need.
    @objc var eventKind: Int { get }

    /// The event's duration in minutes.
    @objc var duration: Int { get set }

    /// The event's starting date and time.
    @objc var scheduledDate: Date { get set }

    /// A string describing this event. It will be drawn inside of the respective
    /// `SCKEventView`.
    @objc var title: String { get }

    /// The user object associated with the event, also referred as the event's
    /// owner.
    @objc var user: SCKUser { get }
}
