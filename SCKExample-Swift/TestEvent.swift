//
//  TestEvent.swift
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 2/11/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

import Cocoa
import ScheduleKit

final class TestEvent: NSObject, SCKEvent {
    
    var eventType: Int
    @objc var user: SCKUser
    var title: String
    var duration: Int
    var scheduledDate: Date
    
    init(kind: SCKEventKind, user: TestUser, title: String, duration: Int, date: Date) {
        eventType = kind.rawValue
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
