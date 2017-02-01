//
//  ScheduleKit-ObjC.swift
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 15/11/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

import Cocoa

@objc(SCKEventManaging) public protocol SCKObjCEventManaging: NSObjectProtocol {
    
    @available(OSX 10.12, *)
    @objc optional func events(in dateInterval: DateInterval,
                               for controller: SCKViewController) -> [SCKEvent]
    
    @available(OSX, deprecated: 10.12, message: "_DateInterval is unavailable in macOS 10.12, use native DateInterval instead.")
    @objc optional func events(inLegacy dateInterval: _DateInterval,
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
        
        @available(OSX 10.12, *)
        func events(in dateInterval: DateInterval,
                    for controller: SCKViewController) -> [SCKEvent] {
            return delegate?.events?(in: dateInterval, for: controller) ?? []
        }
        
        func events(inLegacy dateInterval: _DateInterval,
                    for controller: SCKViewController) -> [SCKEvent] {
            return delegate?.events?(inLegacy: dateInterval, for: controller) ?? []
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

