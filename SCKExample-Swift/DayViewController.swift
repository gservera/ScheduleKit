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
    
    var isReloadingData = false
    
    @IBOutlet var arrayController: NSArrayController!
    
    override func viewDidLoad() {
        arrayController.content = EventEngine.shared.events
        super.viewDidLoad()
        self.eventManager = self
        
        arrayController.addObserver(self, forKeyPath: "arrangedObjects.count", context: nil)
        lastCount = EventEngine.shared.events.count
        NotificationCenter.default.addObserver(forName: .eventCountChanged, object: nil, queue: nil) { _ in
            self.arrayController.content = EventEngine.shared.events
            self.arrayController.rearrangeObjects()
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        let calendar = Calendar.current
        let dayBeginning = calendar.date(bySettingHour: 7, minute: 0, second: 0, of: Date())!
        let dayEnding = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: Date())!
        scheduleView.setDateBounds(lower: dayBeginning, upper: dayEnding)
        reloadData(ofConcreteType: TestEvent.self)
        scheduleView.needsDisplay = true
    }
    
    private var lastCount = 0
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let o = object as? NSArrayController, o == arrayController {
            if !isReloadingData && (arrayController.arrangedObjects as! [TestEvent]).count != lastCount {
                lastCount = (arrayController.arrangedObjects as! [TestEvent]).count
                reloadData(ofConcreteType: TestEvent.self)
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "DayCalendarPopover" {
            let destination = segue.destinationController as! DayCalendarPopoverViewController
            destination.dayView = scheduleView as! SCKDayView!
        }
    }
    
    //MARK: - SCKConcreteEventManaging
    
    func concreteEvents(from startDate: Date, to endDate: Date, for controller: SCKViewController) -> [TestEvent] {
        isReloadingData = true
        arrayController.filterPredicate = NSPredicate(format: "scheduledDate BETWEEN %@", [startDate,endDate])
        arrayController.rearrangeObjects()
        let events = arrayController.arrangedObjects as! [TestEvent]
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
    
    func scheduleController(_ controller: SCKViewController, shouldChangeDurationOfConcreteEvent event: TestEvent, from oldValue: Int, to newValue: Int) -> Bool {
        let alert = NSAlert()
        alert.messageText = "Duration change"
        alert.informativeText = "You've modified the duration of event '\(event.title)'.\n\nPrevious date: \(oldValue) min.\nNew date: \(newValue) min.\n\nAre you sure?)"
        alert.addButton(withTitle: "Save changes")
        alert.addButton(withTitle: "Discard")
        return alert.runModal() == NSAlertFirstButtonReturn
    }
    
    func scheduleController(_ controller: SCKViewController, shouldChangeDateOfConcreteEvent event: TestEvent, from oldValue: Date, to newValue: Date) -> Bool {
        let formatter = DateFormatter(); formatter.dateStyle = .medium; formatter.timeStyle = .medium
        let alert = NSAlert()
        alert.messageText = "Date change"
        alert.informativeText = "You've modified the date and time of event '\(event.title)'.\n\nPrevious date: \(formatter.string(from: oldValue)).\nNew date: \(formatter.string(from: newValue)).\n\nAre you sure?)"
        alert.addButton(withTitle: "Save changes")
        alert.addButton(withTitle: "Discard")
        return alert.runModal() == NSAlertFirstButtonReturn
    }
}

