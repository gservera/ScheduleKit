//
//  WeekViewController.swift
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 15/11/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

import Cocoa
import ScheduleKit


final class WeekViewController: SCKViewController, SCKConcreteEventManaging {
    
    typealias EventType = TestEvent
    
    var isReloadingData = false
    var activeRequest: SCKConcreteEventRequest<TestEvent>?
    
    let eventLoadingView = EventLoadingView(frame: .zero)
    
    @IBOutlet var arrayController: NSArrayController!
    
    override func viewDidLoad() {
        arrayController.content = EventEngine.shared.events
        super.viewDidLoad()
        self.eventManager = self
        loadsEventsAsynchronously = true
        arrayController.addObserver(self, forKeyPath: "arrangedObjects.count", context: nil)
        DispatchQueue.main.asyncAfter(deadline: .now()+4.0) {
            EventEngine.shared.events[5].scheduledDate = EventEngine.shared.events[3].scheduledDate
        }
        lastCount = EventEngine.shared.events.count
        NotificationCenter.default.addObserver(forName: .eventCountChanged, object: nil, queue: nil) { _ in
            self.arrayController.content = EventEngine.shared.events
            self.arrayController.rearrangeObjects()
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        mode = .week
        let calendar = Calendar.current
        
        let weekBeginning = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear,.weekOfYear], from: Date()))!
        let weekEnding = calendar.date(byAdding: .weekOfYear, value: 1, to: weekBeginning)!
        
        scheduleView.dateInterval = DateInterval(start: weekBeginning, end: weekEnding)
        reloadData(ofConcreteType: TestEvent.self)
        (scheduleView as! SCKWeekView).delegate = self
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
    
    //MARK: - SCKConcreteEventManaging
    
    func scheduleController(_ controller: SCKViewController,
                            didMakeConcreteEventRequest request: SCKConcreteEventRequest<TestEvent>) {
        isReloadingData = true
        arrayController.filterPredicate = NSPredicate(format: "scheduledDate BETWEEN %@", [request.startDate,request.endDate])
        activeRequest = request
        eventLoadingView.frame = view.bounds
        eventLoadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(eventLoadingView, positioned: .above, relativeTo: nil)
        eventLoadingView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        eventLoadingView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        eventLoadingView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        eventLoadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        eventLoadingView.needsDisplay = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            print("Providing week events asynchronously")
            let events = self.arrayController.arrangedObjects as! [TestEvent]
            sleep(2)
            DispatchQueue.main.async {
                self.activeRequest?.complete(with: events)
                print("WeekView: \(events.count) events")
                self.isReloadingData = false
                self.eventLoadingView.removeFromSuperview()
            }
        }
    }
    
    @objc public var dayStartHour = 8 {
        didSet {
            (self.scheduleView as! SCKGridView).invalidateUserDefaults()
        }
    }
    @objc public var dayEndHour = 20 {
        didSet {
            (self.scheduleView as! SCKGridView).invalidateUserDefaults()
        }
    }
    @objc public var showsSaturdays = true {
        didSet {
            (self.scheduleView as! SCKGridView).invalidateUserDefaults()
        }
    }
    @objc public var showsSundays = true {
        didSet {
            (self.scheduleView as! SCKGridView).invalidateUserDefaults()
        }
    }
}

extension WeekViewController: SCKGridViewDelegate {
    
    func unavailableTimeRanges(for gridView: SCKGridView) -> [SCKUnavailableTimeRange] {
        return [
            SCKUnavailableTimeRange(weekday: 0, startHour: 13, startMinute: 0, endHour: 15, endMinute: 0),
            SCKUnavailableTimeRange(weekday: 1, startHour: 19, startMinute: 0, endHour: 20, endMinute: 0),
            SCKUnavailableTimeRange(weekday: 2, startHour: 19, startMinute: 0, endHour: 20, endMinute: 0),
            SCKUnavailableTimeRange(weekday: 3, startHour: 19, startMinute: 0, endHour: 20, endMinute: 0),
            SCKUnavailableTimeRange(weekday: 4, startHour: 19, startMinute: 0, endHour: 20, endMinute: 0),
            SCKUnavailableTimeRange(weekday: 5, startHour: 19, startMinute: 0, endHour: 20, endMinute: 0),
            SCKUnavailableTimeRange(weekday: 6, startHour: 19, startMinute: 0, endHour: 20, endMinute: 0),
        ]
    }
    
    func dayStartHour(for gridView: SCKGridView) -> Int {
        return dayStartHour
    }
    
    func dayEndHour(for gridView: SCKGridView) -> Int {
        return dayEndHour
    }
    
    func color(for eventKindValue: Int, in scheduleView: SCKView) -> NSColor {
        if let kind = EventKind(rawValue: eventKindValue) {
            return kind.color
        }
        return NSColor.red
    }
    
}
