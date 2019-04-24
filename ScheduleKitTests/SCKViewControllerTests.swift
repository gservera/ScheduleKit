/*
 *  SCKViewControllerTests.swift
 *  ScheduleKit
 *
 *  Created:    Guillem Servera on 27/2/2017.
 *  Copyright:  © 2017-2019 Guillem Servera (https://github.com/gservera)
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 */

import XCTest
@testable import ScheduleKit

final class SCKViewControllerSyncGenericTests: XCTestCase, SCKEventManaging {

    var blankDateExpectation: XCTestExpectation?

    private var window: NSWindow!
    private var controller: SCKViewController!

    private var testEvents: [SCKEventMock] = []

    override func setUp() {
        super.setUp()
        let bundle = Bundle(for: SCKViewControllerSyncGenericTests.self)
        let windowFrame = CGRect(x: 0, y: 0, width: 800, height: 600)
        window = NSWindow(contentRect: windowFrame, styleMask: [], backing: .buffered, defer: false)
        controller = SCKViewController(nibName: "TestController", bundle: bundle)
        window.contentView = controller.view
        window.orderFront(nil)
        controller.eventManager = self
        let calendar = Calendar.current
        let dayBeginning = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        let dayEnding = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
        controller.scheduleView.dateInterval = DateInterval(start: dayBeginning, end: dayEnding)
        let testEvent = SCKEventMock()
        testEvent.scheduledDate = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date())!
        testEvents = [testEvent]
    }

    override func tearDown() {
        window.orderOut(nil)
        controller.eventManager = nil
        controller = nil
        window = nil
        blankDateExpectation = nil
        super.tearDown()
    }

    func testDataLoading() {
        controller.reloadData()
        XCTAssertEqual(controller.eventHolders.count, 1)
    }

    // MARK: - Basic tests

    func testBasicProperties() {
        XCTAssertTrue(controller.scheduleView.isKind(of: SCKDayView.self))
        controller.mode = .week
        XCTAssertTrue(controller.scheduleView.isKind(of: SCKWeekView.self))
    }

    // MARK: - Offset tests

    func testPreviousOffset() {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        let sDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: yesterday)
        let eDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: yesterday)
        let interval = DateInterval(start: sDate!, end: eDate!)
        controller.decreaseOffset(self)
        XCTAssertEqual(controller.scheduleView.dateInterval, interval, "Yesterday not set.")

        controller.mode = .week
        let wStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let wEnd = calendar.date(byAdding: .weekOfYear, value: 1, to: wStart)!
        controller.scheduleView.dateInterval = DateInterval(start: wStart, end: wEnd)

        controller.decreaseOffset(self)

        var weekComps = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: Date())
        weekComps.weekOfYear = weekComps.weekOfYear! - 1
        let weekBeginning = calendar.date(from: weekComps)!
        weekComps.weekOfYear = weekComps.weekOfYear! + 1
        let nextWeekBeginning = calendar.date(from: weekComps)
        let winterval = DateInterval(start: weekBeginning, end: nextWeekBeginning!)
        XCTAssertEqual(controller.scheduleView.dateInterval, winterval, "Last week not set.")
    }

    func testNextOffset() {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        let sDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: tomorrow)
        let eDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: tomorrow)
        let interval = DateInterval(start: sDate!, end: eDate!)
        controller.increaseOffset(self)
        XCTAssertEqual(controller.scheduleView.dateInterval, interval, "Tomorrow not set.")
    }

    func testResetOffset() {
        let calendar = Calendar.current
        let sDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())
        let eDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date())
        let interval = DateInterval(start: sDate!, end: eDate!)
        controller.decreaseOffset(self)
        controller.resetOffset(self)
        XCTAssertEqual(controller.scheduleView.dateInterval, interval, "Today not set.")
    }

    func testDoubleClickBlankDateDelegate() {
        blankDateExpectation = expectation(description: "Double click on blank date delegate call")
        let viewLocation = CGPoint(x: controller.scheduleView.bounds.midX, y: controller.scheduleView.bounds.maxY-10.0)
        let location = controller.scheduleView.convert(viewLocation, to: nil)
        let event = NSEvent.mouseEvent(with: .leftMouseDown, location: location, modifierFlags: [], timestamp: 0,
                                       windowNumber: 0, context: nil, eventNumber: 0, clickCount: 2, pressure: 0)
        controller.scheduleView.mouseDown(with: event!)
        waitForExpectations(timeout: 10, handler: nil)
    }

    // MARK: - SCKEventManaging

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

final class SCKViewControllerSyncGenericDefaultTests: XCTestCase, SCKEventManaging {

    private var window: NSWindow!
    private var controller: SCKViewController!

    private var testEvents: [SCKEventMock] = []

    override func setUp() {
        super.setUp()
        let bundle = Bundle(for: SCKViewControllerSyncGenericTests.self)
        let windowFrame = CGRect(x: 0, y: 0, width: 800, height: 600)
        window = NSWindow(contentRect: windowFrame, styleMask: [], backing: .buffered, defer: false)
        controller = SCKViewController(nibName: "TestController", bundle: bundle)
        window.contentView = controller.view
        window.orderFront(nil)
        controller.eventManager = self
        let calendar = Calendar.current
        let dayBeginning = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        let dayEnding = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
        controller.scheduleView.dateInterval = DateInterval(start: dayBeginning, end: dayEnding)
        let testEvent = SCKEventMock()
        testEvent.scheduledDate = Date()
        testEvents = [testEvent]
    }

    override func tearDown() {
        window.orderOut(nil)
        controller.eventManager = nil
        controller = nil
        window = nil
        super.tearDown()
    }

    func testDataLoading() {
        controller.reloadData()
        XCTAssertEqual(controller.eventHolders.count, 0)
    }

    // This always succeeds. However, if the delegate method is not called, test coverage won't be 100%.
    func testDoubleClickBlankDateDelegate() {
        let viewLocation = CGPoint(x: controller.scheduleView.bounds.midX, y: controller.scheduleView.bounds.maxY-10)
        let location = controller.scheduleView.convert(viewLocation, to: nil)
        let event = NSEvent.mouseEvent(with: .leftMouseDown, location: location, modifierFlags: [], timestamp: 0,
                                       windowNumber: 0, context: nil, eventNumber: 0, clickCount: 2, pressure: 0)
        controller.scheduleView.mouseDown(with: event!)
    }

}

final class SCKViewControllerSyncConcreteTests: XCTestCase, SCKConcreteEventManaging {

    typealias EventType = SCKEventMock

    private var window: NSWindow!
    private var controller: SCKViewController!

    private var testEvents: [SCKEventMock] = []

    override func setUp() {
        super.setUp()
        let bundle = Bundle(for: SCKViewControllerSyncGenericTests.self)
        let windowFrame = CGRect(x: 0, y: 0, width: 800, height: 600)
        window = NSWindow(contentRect: windowFrame, styleMask: [], backing: .buffered, defer: false)
        controller = SCKViewController(nibName: "TestController", bundle: bundle)
        window.contentView = controller.view
        window.orderFront(nil)
        controller.eventManager = self
        let calendar = Calendar.current
        let dayBeginning = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        let dayEnding = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
        controller.scheduleView.dateInterval = DateInterval(start: dayBeginning, end: dayEnding)
        let testEvent = SCKEventMock()
        testEvent.scheduledDate = Date()
        testEvents = [testEvent]
    }

    override func tearDown() {
        window.orderOut(nil)
        controller.eventManager = nil
        controller = nil
        window = nil
        super.tearDown()
    }

    func testDataLoading() {
        controller.reloadData(ofConcreteType: SCKEventMock.self)
        XCTAssertEqual(controller.eventHolders.count, 1)
    }

    // MARK: - SCKEventManaging

    func concreteEvents(in dateInterval: DateInterval, for controller: SCKViewController) -> [SCKEventMock] {
        if dateInterval.contains(testEvents.first!.scheduledDate) {
            return testEvents
        }
        return []
    }

}

final class SCKViewControllerSyncConcreteImplTests: XCTestCase, SCKConcreteEventManaging {

    typealias EventType = SCKEventMock

    private var window: NSWindow!
    private var controller: SCKViewController!

    private var testEvents: [SCKEventMock] = []

    override func setUp() {
        super.setUp()
        let bundle = Bundle(for: SCKViewControllerSyncGenericTests.self)
        let windowFrame = CGRect(x: 0, y: 0, width: 800, height: 600)
        window = NSWindow(contentRect: windowFrame, styleMask: [], backing: .buffered, defer: false)
        controller = SCKViewController(nibName: "TestController", bundle: bundle)
        window.contentView = controller.view
        window.orderFront(nil)
        controller.eventManager = self
        let calendar = Calendar.current
        let dayBeginning = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        let dayEnding = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
        controller.scheduleView.dateInterval = DateInterval(start: dayBeginning, end: dayEnding)
        let testEvent = SCKEventMock()
        testEvent.scheduledDate = Date()
        testEvents = [testEvent]
    }

    override func tearDown() {
        window.orderOut(nil)
        controller.eventManager = nil
        controller = nil
        window = nil
        super.tearDown()
    }

    func testDataLoading() {
        controller.reloadData(ofConcreteType: SCKEventMock.self)
        XCTAssertEqual(controller.eventHolders.count, 0)
    }

}
