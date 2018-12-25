/*
 *  ScheduleKit-ObjC.swift
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

@objc(SCKEventManaging) public protocol SCKObjCEventManaging: NSObjectProtocol {

    @available(OSX 10.12, *)
    @objc optional func events(in dateInterval: DateInterval, for controller: SCKViewController) -> [SCKEvent]
    
    @available(OSX, deprecated: 10.12, message: "_DateInterval is unavailable in macOS 10.12, use native DateInterval instead.")
    @objc optional func events(inLegacy dateInterval: _DateInterval,
                for controller: SCKViewController) -> [SCKEvent]

    @objc optional func scheduleController(_ controller: SCKViewController,
                                           didMakeEventRequest request: SCKEventRequest)

    @objc optional func scheduleController(_ controller: SCKViewController, didSelectEvent event: SCKEvent)

    @objc optional func scheduleControllerDidClearSelection(_ controller: SCKViewController)

    @objc optional func scheduleController(_ controller: SCKViewController, didDoubleClickBlankDate date: Date)

    @objc optional func scheduleController(_ controller: SCKViewController, didDoubleClickEvent event: SCKEvent)

    @objc optional func scheduleController(_ controller: SCKViewController,
                                           shouldChangeDurationOfEvent event: SCKEvent,
                                           from oldValue: Int,
                                           to newValue: Int) -> Bool

    @objc optional func scheduleController(_ controller: SCKViewController,
                                           shouldChangeDateOfEvent event: SCKEvent,
                                           from oldValue: Date,
                                           to newValue: Date) -> Bool

    @objc optional func scheduleController(_ controller: SCKViewController, menuForEvent event: SCKEvent) -> NSMenu?

}

extension SCKViewController {

    internal final class InternalObjCSCKEventManagingProxy: SCKEventManaging {

        weak var delegate: SCKObjCEventManaging?

        init?(_ object: SCKObjCEventManaging?) {
            guard let some = object else { return nil }
            delegate = some
        }

        @available(OSX 10.12, *)
        func events(in dateInterval: DateInterval,
                    for controller: SCKViewController) -> [SCKEvent] {
            return delegate?.events?(in: dateInterval, for: controller) ?? []
        }

        func events(inLegacy dateInterval: _DateInterval,
                    for controller: SCKViewController) -> [SCKEvent] {
            return delegate?.events?(inLegacy: dateInterval, for: controller) ?? []
        }

        func scheduleController(_ controller: SCKViewController,
                                didMakeEventRequest request: SCKEventRequest) {
            delegate?.scheduleController?(controller, didMakeEventRequest: request)
        }

        func scheduleController(_ controller: SCKViewController, didSelectEvent event: SCKEvent) {
            delegate?.scheduleController?(controller, didSelectEvent: event)
        }

        func scheduleControllerDidClearSelection(_ controller: SCKViewController) {
            delegate?.scheduleControllerDidClearSelection?(controller)
        }

        func scheduleController(_ controller: SCKViewController, didDoubleClickBlankDate date: Date) {
            delegate?.scheduleController?(controller, didDoubleClickBlankDate: date)
        }

        func scheduleController(_ controller: SCKViewController, didDoubleClickEvent event: SCKEvent) {
            delegate?.scheduleController?(controller, didDoubleClickEvent: event)
        }

        func scheduleController(_ controller: SCKViewController,
                                shouldChangeDurationOfEvent event: SCKEvent,
                                from current: Int, to new: Int) -> Bool {
            return delegate?.scheduleController?(controller,
                             shouldChangeDurationOfEvent: event, from: current, to: new) ?? true
        }

        func scheduleController(_ controller: SCKViewController,
                                shouldChangeDateOfEvent event: SCKEvent,
                                from current: Date, to new: Date) -> Bool {
            return delegate?.scheduleController?(controller,
                                                 shouldChangeDateOfEvent: event, from: current, to: new) ?? true
        }

        func scheduleController(_ controller: SCKViewController,
                                menuForEvent event: SCKEvent) -> NSMenu? {
            return delegate?.scheduleController?(controller, menuForEvent: event)
        }
    }

}
