//
//  EventEngine.swift
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 2/11/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

import Cocoa
import ScheduleKit

extension NSNotification.Name {
    static var eventCountChanged = NSNotification.Name("eventCountChangedNotification")
}

final class EventEngine {

    var events: [TestEvent]
    var users: [TestUser]

    static var shared: EventEngine = EventEngine()
    private init() {
        users = [
            TestUser(name: "Test user 1", color: NSColor.systemOrange),
            TestUser(name: "Test user 2", color: NSColor.systemBlue)
        ]
        events = TestEvent.sampleEvents(for: users)
    }

    func notifyUpdates() {
        NotificationCenter.default.post(name: .eventCountChanged, object: self)
    }
}
