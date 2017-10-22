//
//  TestEvent.swift
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 2/11/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

import Cocoa
import ScheduleKit

/** A set of values used to distinguish between different event types.
 *  Actual values are related to different events on the medical field, since this
 *  framework was first intended to be used with medical apps, but feel free to include
 *  any other event types you need (try to keep the default and special values though). */
public enum EventKind: Int {
    case generic  /**< A generic type of event. */
    
    case visit
    case surgery
    
    //Feel free to add any event types you need here.
    case transitory = -1 /**< A special event type for transitory events */
    
    var color: NSColor {
        switch self {
        case .generic: return NSColor(red: 0.60, green: 0.90, blue: 0.60, alpha: 1.0)
        case .visit: return NSColor(red: 1.00, green: 0.86, blue: 0.29, alpha: 1.0)
        case .surgery: return NSColor(red: 0.66, green: 0.82, blue: 1.00, alpha: 1.0)
        case .transitory: return NSColor(red: 1.0, green: 0.4, blue: 0.1, alpha: 1.0)
            
        }
    }
}

@objc final class TestEvent: NSObject, SCKEvent {
    
    @objc var eventKind: Int
    @objc var user: SCKUser
    @objc var title: String
    @objc var duration: Int
    @objc var scheduledDate: Date
    
    init(kind: EventKind, user: TestUser, title: String, duration: Int, date: Date) {
        eventKind = kind.rawValue
        self.user = user
        self.title = title
        self.duration = duration
        
        var t = Int(date.timeIntervalSinceReferenceDate)
        while t % 60 > 0 {
            t += 1
        }
        self.scheduledDate = Date(timeIntervalSinceReferenceDate: Double(t))
        super.init()
    }
    
    class func sampleEvents(for users: [TestUser]) -> [SCKEvent] {
        var events: [TestEvent] = []
        
        let user1 = users[0]
        let user2 = users[1]
        
        let cal = Calendar.current
        var comps = cal.dateComponents([.day, .month, .year], from: Date())
        comps.hour = 9
    
        var dayMinus = DateComponents(); dayMinus.day = -1; dayMinus.hour = 1
        
        events.append(TestEvent(kind: .generic, user: user1, title: "Event 1", duration: 60, date: cal.date(from: comps)!))
        events.append(TestEvent(kind: .generic, user: user1, title: "Event 11", duration: 60, date: cal.date(from: comps)!))
        events.append(TestEvent(kind: .visit, user: user2, title: "Event 12", duration: 60, date: cal.date(from: comps)!))
        comps.hour = 10
        events.append(TestEvent(kind: .surgery, user: user1, title: "Event 2", duration: 60, date: cal.date(from: comps)!))
        events.append(TestEvent(kind: .visit, user: user2, title: "Event 3", duration: 60, date: cal.date(from: comps)!))
        
        comps.hour = 12
        events.append(TestEvent(kind: .generic, user: user1, title: "Event 4", duration: 60, date: cal.date(from: comps)!))
        events.append(TestEvent(kind: .surgery, user: user1, title: "Event 13", duration: 60, date: cal.date(from: comps)!))
        events.append(TestEvent(kind: .generic, user: user1, title: "Event 14", duration: 60, date: cal.date(from: comps)!))
        
        comps.hour = 14
        events.append(TestEvent(kind: .generic, user: user1, title: "Event 5", duration: 60, date: cal.date(from: comps)!))
        events.append(TestEvent(kind: .visit, user: user2, title: "Event 6", duration: 60, date: cal.date(from: comps)!))
        events.append(TestEvent(kind: .generic, user: user1, title: "Event 7", duration: 60, date: cal.date(from: comps)!))
        
        comps.minute = 30
        events.append(TestEvent(kind: .visit, user: user2, title: "Event 8", duration: 60, date: cal.date(from: comps)!))
        comps.minute = 0
        comps.hour = 16
        events.append(TestEvent(kind: .generic, user: user1, title: "Event 9", duration: 60, date: cal.date(from: comps)!))
        comps.hour = 17
        events.append(TestEvent(kind: .surgery, user: user2, title: "Event 10", duration: 60, date: cal.date(from: comps)!))
        return events
    }
    
}
