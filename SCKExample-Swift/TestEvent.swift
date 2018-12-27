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
        case .generic: return NSColor.systemBlue
        case .visit: return NSColor.systemYellow
        case .surgery: return NSColor.systemGreen
        case .transitory: return NSColor.systemOrange
        }
    }
}

@objcMembers final class TestEvent: NSObject, SCKEvent {

    var eventKind: Int
    var user: SCKUser
    var testUser: TestUser! {
        return user as? TestUser
    }
    var title: String
    var duration: Int
    var scheduledDate: Date

    init(kind: EventKind, user: TestUser, title: String, duration: Int, date: Date) {
        eventKind = kind.rawValue
        self.user = user
        self.title = title
        self.duration = duration

        var noSecondsDate = Int(date.timeIntervalSinceReferenceDate)
        while noSecondsDate % 60 > 0 {
            noSecondsDate += 1
        }
        self.scheduledDate = Date(timeIntervalSinceReferenceDate: Double(noSecondsDate))
        super.init()
    }

    class func sampleEvents(for users: [TestUser]) -> [TestEvent] {
        var events: [TestEvent] = []

        let user1 = users[0]
        let user2 = users[1]

        let cal = Calendar.current
        var comps = cal.dateComponents([.day, .month, .year], from: Date())
        comps.hour = 9

        var dayMinus = DateComponents(); dayMinus.day = -1; dayMinus.hour = 1

        func add(kind: EventKind, user: TestUser, title: String, components: DateComponents) {
            let date = cal.date(from: components)!
            events.append(TestEvent(kind: kind, user: user, title: title, duration: 60, date: date))
        }
        add(kind: .generic, user: user1, title: "Event 1", components: comps)
        add(kind: .generic, user: user1, title: "Event 11", components: comps)
        add(kind: .visit, user: user2, title: "Event 12", components: comps)

        comps.hour = 10

        add(kind: .surgery, user: user1, title: "Event 2", components: comps)
        add(kind: .visit, user: user2, title: "Event 3", components: comps)

        comps.hour = 12

        add(kind: .generic, user: user1, title: "Event 4", components: comps)
        add(kind: .surgery, user: user1, title: "Event 13", components: comps)
        add(kind: .generic, user: user1, title: "Event 14", components: comps)

        comps.hour = 14

        add(kind: .generic, user: user1, title: "Event 5", components: comps)
        add(kind: .visit, user: user2, title: "Event 6", components: comps)
        add(kind: .generic, user: user1, title: "Event 7", components: comps)

        comps.minute = 30
        add(kind: .visit, user: user2, title: "Event 8", components: comps)
        comps.minute = 0
        comps.hour = 16
        add(kind: .generic, user: user1, title: "Event 9", components: comps)
        comps.hour = 17
        add(kind: .surgery, user: user2, title: "Event 10", components: comps)
        return events
    }
}
