//
//  TestUser.swift
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 2/11/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

import ScheduleKit
import Cocoa

final class TestUser: NSObject, SCKUser {
    var name: String
    var eventColor: NSColor
    
    init(name: String, color: NSColor) {
        self.name = name
        self.eventColor = color
        super.init()
    }
}
