//
//  SCKEventManaging.swift
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 15/11/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

import Cocoa

public protocol SCKEventManaging: class {
    
    func events(from startDate: Date, to endDate: Date, for controller: SCKViewController) -> [SCKEvent]
    
    func scheduleController(_ controller: SCKViewController, didMakeEventRequest request: SCKEventRequest)
    
    func scheduleController(_ controller: SCKViewController, didSelectEvent event: SCKEvent)
    func scheduleControllerDidClearSelection(_ controller: SCKViewController)
    
    func scheduleController(_ controller: SCKViewController, didDoubleClickBlankDate date: Date)
    func scheduleController(_ controller: SCKViewController, didDoubleClickEvent event: SCKEvent)
    
    
    func scheduleController(_ controller: SCKViewController, shouldChangeDurationOfEvent event: SCKEvent, from oldValue: Int, to newValue: Int) -> Bool
    func scheduleController(_ controller: SCKViewController, shouldChangeDateOfEvent event: SCKEvent, from oldValue: Date, to newValue: Date) -> Bool
    
    func scheduleController(_ controller: SCKViewController, menuForEvent event: SCKEvent) -> NSMenu?
    
}

public protocol SCKConcreteEventManaging: SCKEventManaging {
    associatedtype EventType
    
    func concreteEvents(from startDate: Date, to endDate: Date, for controller: SCKViewController) -> [EventType]
    
    func scheduleController(_ controller: SCKViewController, didMakeConcreteEventRequest request: SCKConcreteEventRequest<EventType>)
    
    func scheduleController(_ controller: SCKViewController, didSelectConcreteEvent event: EventType)
    
    func scheduleController(_ controller: SCKViewController, didDoubleClickConcreteEvent event: EventType)
    
    func scheduleController(_ controller: SCKViewController, shouldChangeDurationOfConcreteEvent event: EventType, from oldValue: Int, to newValue: Int) -> Bool
    
    func scheduleController(_ controller: SCKViewController, shouldChangeDateOfConcreteEvent event: EventType, from oldValue: Date, to newValue: Date) -> Bool
    
    func scheduleController(_ controller: SCKViewController, menuForConcreteEvent event: EventType) -> NSMenu?
}


public extension SCKConcreteEventManaging where EventType: SCKEvent  {
    
    public func events(from startDate: Date, to endDate: Date, for controller: SCKViewController) -> [SCKEvent] {
        return concreteEvents(from: startDate, to: endDate, for: controller)
    }
    
    public func scheduleController(_ controller: SCKViewController, didMakeEventRequest request: SCKEventRequest) {
        return scheduleController(controller, didMakeConcreteEventRequest: request as! SCKConcreteEventRequest<EventType>)
    }
    
    public func scheduleController(_ controller: SCKViewController, didSelectEvent event: SCKEvent) {
        scheduleController(controller, didSelectConcreteEvent: event as! EventType)
    }
    
    public func scheduleController(_ controller: SCKViewController, didDoubleClickEvent event: SCKEvent) {
        scheduleController(controller, didDoubleClickConcreteEvent: event as! EventType)
    }
    
    public func scheduleController(_ controller: SCKViewController, shouldChangeDurationOfEvent event: SCKEvent, from oldValue: Int, to newValue: Int) -> Bool {
        return scheduleController(controller, shouldChangeDurationOfConcreteEvent: event as! EventType, from: oldValue, to: newValue)
    }
    
    public func scheduleController(_ controller: SCKViewController, shouldChangeDateOfEvent event: SCKEvent, from oldValue: Date, to newValue: Date) -> Bool {
        return scheduleController(controller, shouldChangeDateOfConcreteEvent: event as! EventType, from: oldValue, to: newValue)
    }
    
    public func scheduleController(_ controller: SCKViewController, menuForEvent event: SCKEvent) -> NSMenu? {
        return scheduleController(controller, menuForConcreteEvent: event as! EventType)
    }
    
    
    //Optionalizing
    
    public func concreteEvents(from startDate: Date, to endDate: Date, for controller: SCKViewController) -> [EventType] {
        return []
    }
    
    public func scheduleController(_ controller: SCKViewController, didMakeConcreteEventRequest request: SCKConcreteEventRequest<EventType>) {
        
    }
    
    public func scheduleControllerDidClearSelection(_ controller: SCKViewController) {
        
    }
    
    public func scheduleController(_ controller: SCKViewController, didSelectConcreteEvent event: EventType) {
        
    }
    
    public func scheduleController(_ controller: SCKViewController, didDoubleClickBlankDate date: Date) {
        
    }
    
    public func scheduleController(_ controller: SCKViewController, didDoubleClickConcreteEvent event: EventType) {
        
    }
    
    public func scheduleController(_ controller: SCKViewController, shouldChangeDurationOfConcreteEvent event: EventType, from oldValue: Int, to newValue: Int) -> Bool {
        return true
    }
    
    public func scheduleController(_ controller: SCKViewController, shouldChangeDateOfConcreteEvent event: EventType, from oldValue: Date, to newValue: Date) -> Bool {
        return true
    }
    
    public func scheduleController(_ controller: SCKViewController, menuForConcreteEvent event: EventType) -> NSMenu? {
        return nil
    }
    
}
