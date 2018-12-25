//
//  SegueHandling.swift
//  SCKExample-Swift
//
//  Created by Guillem Servera Negre on 23/10/17.
//  Copyright © 2017 Guillem Servera. All rights reserved.
//

import AppKit

struct SegueDescriptor<T: NSViewController> {
    
    let segue: NSStoryboardSegue
    
    init(segue: NSStoryboardSegue) {
        self.segue = segue
    }
    
    var destination: T {
        guard let destination = segue.destinationController as? T else {
            fatalError("Could not unarchive segue destination. Wrong type.")
        }
        return destination
    }
}

extension NSStoryboardSegue.Identifier {
    static let edit = "edit"
    static let dayCalendarPopover = "dayCalendarPopover"
}

@objcMembers class EventArrayController: NSArrayController {
    
    override func arrange(_ objects: [Any]) -> [Any] {
        willChangeValue(for: \.eventCount)
        let result = super.arrange(objects)
        didChangeValue(for: \.eventCount)
        return result
    }
    
    dynamic var arrangedEvents: [TestEvent] {
        guard let castedArrangedObjects = arrangedObjects as? [TestEvent] else {
            fatalError("Could not cast arrangedObjects to [TestEvent]")
        }
        return castedArrangedObjects
    }
    
    dynamic var eventCount: NSNumber {
        return NSNumber(value: arrangedEvents.count)
    }
}
