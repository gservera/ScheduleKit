/*
 *  ScheduleKit-ObjC.swift
 *  ScheduleKit
 *
 *  Created:    Guillem Servera on 15/11/2016.
 *  Copyright:  © 2016-2017 Guillem Servera (https://github.com/gservera)
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
    
    @objc optional func events(in dateInterval: DateInterval,
                               for controller: SCKViewController) -> [SCKEvent]
    
    @objc optional func scheduleController(_ controller: SCKViewController,
                                           didMakeEventRequest request: SCKEventRequest)
    
    @objc optional func scheduleController(_ controller: SCKViewController,
                                           didSelectEvent event: SCKEvent)
    @objc optional func scheduleControllerDidClearSelection(_ controller: SCKViewController)
    
    @objc optional func scheduleController(_ controller: SCKViewController,
                                           didDoubleClickBlankDate date: Date)
    @objc optional func scheduleController(_ controller: SCKViewController,
                                           didDoubleClickEvent event: SCKEvent)
    
    
    @objc optional func scheduleController(_ controller: SCKViewController,
                                           shouldChangeDurationOfEvent event: SCKEvent,
                                           from oldValue: Int,
                                           to newValue: Int) -> Bool
    @objc optional func scheduleController(_ controller: SCKViewController,
                                           shouldChangeDateOfEvent event: SCKEvent,
                                           from oldValue: Date,
                                           to newValue: Date) -> Bool
    
    @objc optional func scheduleController(_ controller: SCKViewController,
                                           menuForEvent event: SCKEvent) -> NSMenu?
    
}

extension SCKViewController {
    
    internal final class _SCKObjCEventManagingProxy: SCKEventManaging {
        
        weak var delegate: SCKObjCEventManaging?
        
        init(_ object: SCKObjCEventManaging) {
            delegate = object
        }
        
        func events(in dateInterval: DateInterval,
                    for controller: SCKViewController) -> [SCKEvent] {
            return delegate?.events?(in: dateInterval, for: controller) ?? []
        }
        
        func scheduleController(_ c: SCKViewController,
                                didMakeEventRequest request: SCKEventRequest) {
            delegate?.scheduleController?(c, didMakeEventRequest: request)
        }
        
        func scheduleController(_ c: SCKViewController,
                                didSelectEvent event: SCKEvent) {
            delegate?.scheduleController?(c, didSelectEvent: event)
        }
        
        func scheduleControllerDidClearSelection(_ c: SCKViewController) {
            delegate?.scheduleControllerDidClearSelection?(c)
        }
        
        func scheduleController(_ c: SCKViewController,
                                didDoubleClickBlankDate date: Date) {
            delegate?.scheduleController?(c, didDoubleClickBlankDate: date)
        }
        
        func scheduleController(_ c: SCKViewController,
                                didDoubleClickEvent event: SCKEvent) {
            delegate?.scheduleController?(c, didDoubleClickEvent: event)
        }
        
        func scheduleController(_ c: SCKViewController,
                                shouldChangeDurationOfEvent e: SCKEvent,
                                from o: Int, to n: Int) -> Bool {
            return delegate?.scheduleController?(c,
                             shouldChangeDurationOfEvent: e, from: o, to: n) ?? true
        }
        
        func scheduleController(_ c: SCKViewController,
                                shouldChangeDateOfEvent e: SCKEvent,
                                from o: Date, to n: Date) -> Bool {
            return delegate?.scheduleController?(c,
                             shouldChangeDateOfEvent: e, from: o, to: n) ?? true
        }
        
        func scheduleController(_ c: SCKViewController,
                                menuForEvent event: SCKEvent) -> NSMenu? {
            return delegate?.scheduleController?(c, menuForEvent: event)
        }
    }
    
}

