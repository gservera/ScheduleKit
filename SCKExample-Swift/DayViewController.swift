//
//  DayViewController.swift
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 2/11/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

import Cocoa
import ScheduleKit

final class DayViewController: SCKViewController, SCKConcreteEventManaging {

    typealias EventType = TestEvent

    @objc public var dayView: SCKDayView! {
        return scheduleView as? SCKDayView
    }

    var isReloadingData = false

    private var arrayController = EventArrayController(content: nil)
    private var observation: NSKeyValueObservation?
    private var notificationCenterObservation: NSObjectProtocol?

    override func viewDidLoad() {
        arrayController.content = EventEngine.shared.events
        super.viewDidLoad()
        self.eventManager = self

        observation = arrayController.observe(\.eventCount) { [unowned self] (_, change) in
            if !self.isReloadingData && change.oldValue != change.newValue {
                self.reloadData(ofConcreteType: TestEvent.self)
            }
        }

        lastCount = EventEngine.shared.events.count
        let center = NotificationCenter.default
        notificationCenterObservation = center.addObserver(forName: .eventCountChanged, object: nil, queue: nil) { _ in
            self.arrayController.content = EventEngine.shared.events
            self.arrayController.rearrangeObjects()
        }
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        let calendar = Calendar(identifier: .gregorian)
        var testDateComponents = DateComponents()
        testDateComponents.year = 2020
        testDateComponents.month = 5
        testDateComponents.day = 1
        let date = calendar.date(from: testDateComponents)!
        let dayBeginning = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: date)!
        let dayEnding = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
        scheduleView.setAccessibilityIdentifier("DayView")
        scheduleView.setAccessibilityElement(true)
        scheduleView.delegate = self
        scheduleView.dateInterval = DateInterval(start: dayBeginning, end: dayEnding)
        reloadData(ofConcreteType: TestEvent.self)
        scheduleView.colorMode = .byEventOwner
    }

    private var lastCount = 0

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "dayCalendarPopover" {
            let destination = SegueDescriptor<DayCalendarPopoverViewController>(segue: segue).destination
            destination.dayView = dayView
        }
    }

    // MARK: - SCKConcreteEventManaging

    func concreteEvents(in dateInterval: DateInterval, for controller: SCKViewController) -> [TestEvent] {
        isReloadingData = true
        let predicate = NSPredicate(format: "scheduledDate BETWEEN %@", [dateInterval.start, dateInterval.end])
        arrayController.filterPredicate = predicate
        arrayController.rearrangeObjects()
        guard let events = arrayController.arrangedObjects as? [TestEvent] else {
            fatalError("Could not cast arrangedObjects to [TestEvent]")
        }
        isReloadingData = false
        print("DayEventManager: \(events.count) events")
        return events
    }

    func scheduleController(_ controller: SCKViewController, didSelectConcreteEvent event: TestEvent) {
        print("DayView: Did select event with title '\(event.title)'")
    }

    func scheduleControllerDidClearSelection(_ controller: SCKViewController) {
        print("DayView: Did clear selection")
    }

    func scheduleController(_ controller: SCKViewController, didDoubleClickBlankDate date: Date) {
        let formatter = DateFormatter(); formatter.dateStyle = .medium; formatter.timeStyle = .medium
        let alert = NSAlert()
        alert.messageText = "Double click on empty date"
        alert.informativeText = "Clicked on empty date '\(formatter.string(from: date))'"
        alert.runModal()
    }

    func scheduleController(_ controller: SCKViewController, didDoubleClickConcreteEvent event: TestEvent) {
        let alert = NSAlert()
        alert.messageText = "Double click"
        alert.informativeText = "Clicked on event '\(event.title)'"
        alert.runModal()
    }

    func scheduleController(_ controller: SCKViewController, shouldChangeDurationOfConcreteEvent event: TestEvent,
                            from oldValue: Int, to newValue: Int) -> Bool {
        let alert = NSAlert()
        alert.messageText = "Duration change"
        alert.informativeText = """
                                You've modified the duration of event '\(event.title)'.

                                Previous date: \(oldValue) min.
                                New date: \(newValue) min.

                                Are you sure?)
                                """
        alert.addButton(withTitle: "Save changes")
        alert.addButton(withTitle: "Discard")
        return alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
    }

    func scheduleController(_ controller: SCKViewController, shouldChangeDateOfConcreteEvent event: TestEvent,
                            from oldValue: Date, to newValue: Date) -> Bool {
        let formatter = DateFormatter(); formatter.dateStyle = .medium; formatter.timeStyle = .medium
        let alert = NSAlert()
        alert.messageText = "Date change"
        alert.informativeText = """
                                You've modified the date and time of event '\(event.title)'.

                                Previous date: \(formatter.string(from: oldValue)).
                                New date: \(formatter.string(from: newValue)).

                                Are you sure?
                                """
        alert.addButton(withTitle: "Save changes")
        alert.addButton(withTitle: "Discard")
        return alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
    }
}

extension DayViewController: SCKGridViewDelegate {

    func dayStartHour(for gridView: SCKGridView) -> Int {
        return 7
    }

    func dayEndHour(for gridView: SCKGridView) -> Int {
        return 19
    }
}
