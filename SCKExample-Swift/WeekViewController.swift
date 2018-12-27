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

    @objc public var weekView: SCKWeekView! {
        return scheduleView as? SCKWeekView
    }

    var isReloadingData = false
    var activeRequest: SCKConcreteEventRequest<TestEvent>?

    let eventLoadingView = EventLoadingView(frame: .zero)

    private var arrayController = EventArrayController(content: nil)

    override func loadView() {
        mode = .week
        super.loadView()
    }

    private var arrangedEventsObservation: NSKeyValueObservation?
    private var eventCountObservation: NSObjectProtocol?

    override func viewDidLoad() {
        arrayController.content = EventEngine.shared.events
        super.viewDidLoad()
        self.eventManager = self
        loadsEventsAsynchronously = true

        arrangedEventsObservation = arrayController.observe(\.eventCount) { [unowned self] (_, change) in
            if !self.isReloadingData && change.oldValue != change.newValue {
                self.reloadData(ofConcreteType: TestEvent.self)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now()+4.0) {
            EventEngine.shared.events[5].scheduledDate = EventEngine.shared.events[3].scheduledDate
        }
        let center = NotificationCenter.default
        eventCountObservation = center.addObserver(forName: .eventCountChanged, object: nil, queue: nil) { _ in
            self.arrayController.content = EventEngine.shared.events
            self.arrayController.rearrangeObjects()
        }
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        let calendar = Calendar.current

        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let weekEnding = calendar.date(byAdding: .weekOfYear, value: 1, to: weekStart)!

        scheduleView.dateInterval = DateInterval(start: weekStart, end: weekEnding)
        reloadData(ofConcreteType: TestEvent.self)
        self.scheduleView.delegate = self
        scheduleView.needsDisplay = true
    }

    // MARK: - SCKConcreteEventManaging

    func scheduleController(_ controller: SCKViewController,
                            didMakeConcreteEventRequest request: SCKConcreteEventRequest<TestEvent>) {
        isReloadingData = true
        let predicate = NSPredicate(format: "scheduledDate BETWEEN %@", [request.startDate, request.endDate])
        arrayController.filterPredicate = predicate
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
            let events = self.arrayController.arrangedEvents
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
            self.weekView.invalidateUserDefaults()
        }
    }
    @objc public var dayEndHour = 20 {
        didSet {
            self.weekView.invalidateUserDefaults()
        }
    }
    @objc public var showsSaturdays = true {
        didSet {
            updateDayCount()
        }
    }
    @objc public var showsSundays = true {
        didSet {
            updateDayCount()
        }
    }

    private func updateDayCount() {
        self.weekView.invalidateUserDefaults()
        var dayCount = 5
        if showsSaturdays {
            dayCount += 1
            if showsSundays {
                dayCount += 1
            }
        }
        let eDate = Calendar.current.date(byAdding: .day, value: dayCount, to: scheduleView.dateInterval.start)!
        scheduleView.dateInterval = DateInterval(start: scheduleView.dateInterval.start, end: eDate)
        reloadData(ofConcreteType: TestEvent.self)
    }
}

extension WeekViewController: SCKGridViewDelegate {

    func unavailableTimeRanges(for gridView: SCKGridView) -> [SCKUnavailableTimeRange] {
        return [
            SCKUnavailableTimeRange(weekday: 0, startHour: 13, startMinute: 0, endHour: 15, endMinute: 0)!,
            SCKUnavailableTimeRange(weekday: 1, startHour: 19, startMinute: 0, endHour: 20, endMinute: 0)!,
            SCKUnavailableTimeRange(weekday: 2, startHour: 19, startMinute: 0, endHour: 20, endMinute: 0)!,
            SCKUnavailableTimeRange(weekday: 3, startHour: 19, startMinute: 0, endHour: 20, endMinute: 0)!,
            SCKUnavailableTimeRange(weekday: 4, startHour: 19, startMinute: 0, endHour: 20, endMinute: 0)!,
            SCKUnavailableTimeRange(weekday: 5, startHour: 19, startMinute: 0, endHour: 20, endMinute: 0)!,
            SCKUnavailableTimeRange(weekday: 6, startHour: 19, startMinute: 0, endHour: 20, endMinute: 0)!
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
