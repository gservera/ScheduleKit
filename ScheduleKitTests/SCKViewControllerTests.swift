//
//  SCKViewControllerTests.swift
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 27/2/17.
//  Copyright © 2017 Guillem Servera. All rights reserved.
//

import XCTest
@testable import ScheduleKit

final class SCKViewControllerSyncGenericTests: XCTestCase, SCKEventManaging {
    
    var blankDateExpectation: XCTestExpectation?
    
    private var w: NSWindow!
    private var c: SCKViewController!
    
    private var testEvents: [SCKEventMock] = []
    
    override func setUp() {
        super.setUp()
        w = NSWindow(contentRect: CGRect(x:0,y:0,width:800,height:600), styleMask: [], backing: .buffered, defer: false)
        c = SCKViewController(nibName: NSNib.Name(rawValue: "TestController"), bundle: Bundle(for: SCKViewControllerSyncGenericTests.self))
        w.contentView = c.view
        w.orderFront(nil)
        c.eventManager = self
        let calendar = Calendar.current
        let dayBeginning = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        let dayEnding = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
        c.scheduleView.dateInterval = DateInterval(start: dayBeginning, end: dayEnding)
        let testEvent = SCKEventMock()
        testEvent.scheduledDate = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date())!
        testEvents = [testEvent]
    }
    
    override func tearDown() {
        w.orderOut(nil)
        c.eventManager = nil
        c = nil
        w = nil
        blankDateExpectation = nil
        super.tearDown()
    }
    
    func testDataLoading() {
        c.reloadData()
        XCTAssertEqual(c.eventHolders.count, 1)
    }
    
    //MARK: - Basic tests
    
    func testBasicProperties() {
        XCTAssertTrue(c.scheduleView.isKind(of: SCKDayView.self))
        c.mode = .week
        XCTAssertTrue(c.scheduleView.isKind(of: SCKWeekView.self))
    }
    
    // MARK: - Offset tests
    
    func testPreviousOffset() {
        let calendar = Calendar.current
        let t = calendar.date(byAdding: .day, value: -1, to: Date())!
        let sD = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: t)
        let eD = calendar.date(bySettingHour:23, minute:59, second:59, of: t)
        let interval = DateInterval(start: sD!, end: eD!)
        c.decreaseOffset(self)
        XCTAssertEqual(c.scheduleView.dateInterval, interval, "Yesterday not set.")
        
        c.mode = .week
        let wStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear,.weekOfYear], from: Date()))!
        let wEnd = calendar.date(byAdding: .weekOfYear, value: 1, to: wStart)!
        c.scheduleView.dateInterval = DateInterval(start: wStart, end: wEnd)
        
        c.decreaseOffset(self)
        
        var weekComps = calendar.dateComponents([.weekOfYear,.yearForWeekOfYear], from: Date())
        weekComps.weekOfYear = weekComps.weekOfYear! - 1
        let weekBeginning = calendar.date(from: weekComps)!
        weekComps.weekOfYear = weekComps.weekOfYear! + 1
        let nextWeekBeginning = calendar.date(from: weekComps)
        let winterval = DateInterval(start: weekBeginning, end: nextWeekBeginning!)
        XCTAssertEqual(c.scheduleView.dateInterval, winterval, "Last week not set.")
    }
    
    func testNextOffset() {
        let calendar = Calendar.current
        let t = calendar.date(byAdding: .day, value: 1, to: Date())!
        let sD = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: t)
        let eD = calendar.date(bySettingHour:23, minute:59, second:59, of: t)
        let interval = DateInterval(start: sD!, end: eD!)
        c.increaseOffset(self)
        XCTAssertEqual(c.scheduleView.dateInterval, interval, "Tomorrow not set.")
    }
    
    func testResetOffset() {
        let calendar = Calendar.current
        let sD = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())
        let eD = calendar.date(bySettingHour:23, minute:59, second:59, of: Date())
        let interval = DateInterval(start: sD!, end: eD!)
        c.decreaseOffset(self)
        c.resetOffset(self)
        XCTAssertEqual(c.scheduleView.dateInterval, interval, "Today not set.")
    }
    
    func testDoubleClickBlankDateDelegate() {
        blankDateExpectation = expectation(description: "Double click on blank date delegate call")
        let event = NSEvent.mouseEvent(with: .leftMouseDown, location: c.scheduleView.convert(CGPoint(x: c.scheduleView.bounds.midX, y:c.scheduleView.bounds.maxY-10.0), to: nil), modifierFlags: [], timestamp: 0, windowNumber: 0, context: nil, eventNumber: 0, clickCount: 2, pressure: 0)
        c.scheduleView.mouseDown(with: event!)
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    //MARK: - SCKEventManaging
    
    func events(in dateInterval: DateInterval, for controller: SCKViewController) -> [SCKEvent] {
        if dateInterval.contains(testEvents.first!.scheduledDate) {
            return testEvents
        }
        return []
    }
    
    func scheduleController(_ controller: SCKViewController, didDoubleClickBlankDate date: Date) {
        blankDateExpectation?.fulfill()
    }
    
}

final class SCKViewControllerSyncGenericDefaultImplTests: XCTestCase, SCKEventManaging {
    
    
    private var w: NSWindow!
    private var c: SCKViewController!
    
    private var testEvents: [SCKEventMock] = []
    
    override func setUp() {
        super.setUp()
        w = NSWindow(contentRect: CGRect(x:0,y:0,width:800,height:600), styleMask: [], backing: .buffered, defer: false)
        c = SCKViewController(nibName: NSNib.Name(rawValue: "TestController"), bundle: Bundle(for: SCKViewControllerSyncGenericTests.self))
        w.contentView = c.view
        w.orderFront(nil)
        c.eventManager = self
        let calendar = Calendar.current
        let dayBeginning = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        let dayEnding = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
        c.scheduleView.dateInterval = DateInterval(start: dayBeginning, end: dayEnding)
        let testEvent = SCKEventMock()
        testEvent.scheduledDate = Date()
        testEvents = [testEvent]
    }
    
    override func tearDown() {
        w.orderOut(nil)
        c.eventManager = nil
        c = nil
        w = nil
        super.tearDown()
    }
    
    func testDataLoading() {
        c.reloadData()
        XCTAssertEqual(c.eventHolders.count, 0)
    }
    
    // This always succeeds. However, if the delegate method is not called, test coverage won't be 100%.
    func testDoubleClickBlankDateDelegate() {
        let event = NSEvent.mouseEvent(with: .leftMouseDown, location: c.scheduleView.convert(CGPoint(x: c.scheduleView.bounds.midX, y:c.scheduleView.bounds.maxY-10.0), to: nil), modifierFlags: [], timestamp: 0, windowNumber: 0, context: nil, eventNumber: 0, clickCount: 2, pressure: 0)
        c.scheduleView.mouseDown(with: event!)
    }
    
}


final class SCKViewControllerSyncConcreteTests: XCTestCase, SCKConcreteEventManaging {
    
    typealias EventType = SCKEventMock
    
    private var w: NSWindow!
    private var c: SCKViewController!
    
    private var testEvents: [SCKEventMock] = []
    
    override func setUp() {
        super.setUp()
        w = NSWindow(contentRect: CGRect(x:0,y:0,width:800,height:600), styleMask: [], backing: .buffered, defer: false)
        c = SCKViewController(nibName: NSNib.Name(rawValue: "TestController"), bundle: Bundle(for: SCKViewControllerSyncGenericTests.self))
        w.contentView = c.view
        w.orderFront(nil)
        c.eventManager = self
        let calendar = Calendar.current
        let dayBeginning = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        let dayEnding = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
        c.scheduleView.dateInterval = DateInterval(start: dayBeginning, end: dayEnding)
        let testEvent = SCKEventMock()
        testEvent.scheduledDate = Date()
        testEvents = [testEvent]
    }
    
    override func tearDown() {
        w.orderOut(nil)
        c.eventManager = nil
        c = nil
        w = nil
        super.tearDown()
    }
    
    func testDataLoading() {
        c.reloadData(ofConcreteType: SCKEventMock.self)
        XCTAssertEqual(c.eventHolders.count, 1)
    }
    
    //MARK: - SCKEventManaging
    
    func concreteEvents(in dateInterval: DateInterval, for controller: SCKViewController) -> [SCKEventMock] {
        if dateInterval.contains(testEvents.first!.scheduledDate) {
            return testEvents
        }
        return []
    }
    
}

final class SCKViewControllerSyncConcreteDefaultImplTests: XCTestCase, SCKConcreteEventManaging {
    
    typealias EventType = SCKEventMock
    
    private var w: NSWindow!
    private var c: SCKViewController!
    
    private var testEvents: [SCKEventMock] = []
    
    override func setUp() {
        super.setUp()
        w = NSWindow(contentRect: CGRect(x:0,y:0,width:800,height:600), styleMask: [], backing: .buffered, defer: false)
        c = SCKViewController(nibName: NSNib.Name(rawValue: "TestController"), bundle: Bundle(for: SCKViewControllerSyncGenericTests.self))
        w.contentView = c.view
        w.orderFront(nil)
        c.eventManager = self
        let calendar = Calendar.current
        let dayBeginning = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        let dayEnding = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
        c.scheduleView.dateInterval = DateInterval(start: dayBeginning, end: dayEnding)
        let testEvent = SCKEventMock()
        testEvent.scheduledDate = Date()
        testEvents = [testEvent]
    }
    
    override func tearDown() {
        w.orderOut(nil)
        c.eventManager = nil
        c = nil
        w = nil
        super.tearDown()
    }
    
    func testDataLoading() {
        c.reloadData(ofConcreteType: SCKEventMock.self)
        XCTAssertEqual(c.eventHolders.count, 0)
    }
    
}
