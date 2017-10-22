/*
 *  SCKEventHolderTests.swift
 *  ScheduleKit
 *
 *  Created:    Guillem Servera on 27/11/2016.
 *  Copyright:  © 2014-2016 Guillem Servera (http://github.com/gservera)
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

class SCKUserMock: NSObject, SCKUser {
    var eventColor: NSColor = NSColor.orange

}

class SCKEventMock: NSObject, SCKEvent {
    
    @objc var eventKind: Int {
        return 0
    }
    
    @objc var duration: Int = 15
    
    @objc var scheduledDate = Calendar.current.date(bySettingHour: 11, minute: 0, second: 0, of: Date())!
    
    
    @objc var title: String = "Mock"
    
    @objc var user: SCKUser = SCKUserMock()
    
}

private class _ControllerMock: SCKViewController {
    
    var layoutInvalidationPromise: XCTestExpectation?
    var reloadDataPromise: XCTestExpectation?
    
    var priorCalled = false
    
    fileprivate override func resolvedConflicts(for holder: SCKEventHolder) -> [SCKEventHolder] {
        if !priorCalled {
            priorCalled = true
            return [holder]
        }
        if reloadDataPromise != nil {
            XCTFail("Relayout should not have been called")
        }
        layoutInvalidationPromise?.fulfill()
        layoutInvalidationPromise = nil
        return [holder]
    }
    
    fileprivate override func _internalReloadData() {
        if layoutInvalidationPromise != nil {
            XCTFail("Reload data should not have been called")
        }
        reloadDataPromise?.fulfill()
    }
}

final class SCKEventHolderTests: XCTestCase {
    
    private var controller: _ControllerMock!
    var scheduleView: SCKView!
    var eventView: SCKEventView!
    var validTestEvent: SCKEventMock!
    var invalidTestEvent: SCKEventMock!

    override func setUp() {
        super.setUp()
        let bundle = Bundle(for: SCKEventHolderTests.self)
        controller = _ControllerMock(nibName: NSNib.Name(rawValue: "TestController"), bundle: bundle)
        _ = controller.view
        scheduleView = controller.scheduleView!
        let sD = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        let eD = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
        scheduleView.dateInterval = DateInterval(start: sD, end: eD)
        eventView = SCKEventView(frame: .zero)
        validTestEvent = SCKEventMock()
        invalidTestEvent = SCKEventMock()
        invalidTestEvent.scheduledDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!.addingTimeInterval(-1)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInitialization() {
        scheduleView.addSubview(eventView)
        scheduleView.addEventView(eventView)
        var holder = SCKEventHolder(event: validTestEvent, view: eventView, controller: controller)
        XCTAssertNotNil(holder,"Should have been initialized")
        
        XCTAssertEqual(holder!.representedObject as? SCKEventMock, validTestEvent, "Error")
        XCTAssertTrue(holder!.isReady, "Should be ready")
        
        let holder2 = SCKEventHolder(event: invalidTestEvent, view: eventView, controller: controller)
        XCTAssertNil(holder2,"Should have failed")
        holder = nil
        
        let borderlineEvent = SCKEventMock()
        borderlineEvent.scheduledDate = Calendar.current.date(bySettingHour: 23, minute: 55, second: 0, of: Date())!
        let holder3 = SCKEventHolder(event: borderlineEvent, view: eventView, controller: controller)
        XCTAssertNotNil(holder3,"Should have been initialized")
        
        XCTAssertEqual(holder3!.relativeEnd, 1.0)
        XCTAssertTrue(holder3!.isReady, "Should be ready")
    }
    
    func testCachedProperties() {
        scheduleView.addSubview(eventView)
        scheduleView.addEventView(eventView)
        let holder = SCKEventHolder(event: validTestEvent, view: eventView, controller: controller)!
        XCTAssertEqual(holder.cachedDuration, validTestEvent.duration)
        XCTAssertEqual(holder.cachedScheduledDate, validTestEvent.scheduledDate)
        XCTAssertEqual(holder.cachedTitle, validTestEvent.title)
        XCTAssertTrue(holder.cachedUser! === validTestEvent.user)
        
        let borderlineEvent = SCKEventMock()
        borderlineEvent.scheduledDate = Calendar.current.date(bySettingHour: 23, minute: 55, second: 0, of: Date())!
        let holder3 = SCKEventHolder(event: borderlineEvent, view: eventView, controller: controller)
        XCTAssertEqual(holder3!.relativeEnd, 1.0)
        XCTAssertTrue(holder3!.isReady, "Should be ready")
    }
    
    func testRecalculateRelativeValuesWithNoScheduleView() {
        let holder = SCKEventHolder(event: validTestEvent, view: eventView, controller: controller)
        XCTAssertNil(holder,"Should fail initialization (no schedule view)")
    }
    
    // MARK: - Test change observing
    
    func testObservationMisuse() {
        scheduleView.addSubview(eventView)
        scheduleView.addEventView(eventView)
        let holder = SCKEventHolder(event: validTestEvent, view: eventView, controller: controller)!
        eventView.eventHolder = holder
        holder.observeValue(forKeyPath: nil, of: nil, change: nil, context: nil)
    }
    
    func testDurationObserving() {
        scheduleView.addSubview(eventView)
        scheduleView.addEventView(eventView)
        let holder = SCKEventHolder(event: validTestEvent, view: eventView, controller: controller)!
        eventView.eventHolder = holder
        controller.layoutInvalidationPromise = expectation(description: "Layout")
        XCTAssertEqual(holder.cachedDuration, 15)
        validTestEvent.setValue(30, forKey: "duration")
        XCTAssertEqual(holder.cachedDuration, 30)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDateObservingChangeToValidDate() {
        scheduleView.addSubview(eventView)
        scheduleView.addEventView(eventView)
        let holder = SCKEventHolder(event: validTestEvent, view: eventView, controller: controller)!
        eventView.eventHolder = holder
        controller.layoutInvalidationPromise = expectation(description: "Layout")
        let newDate = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
        XCTAssertEqual(holder.cachedScheduledDate, validTestEvent.scheduledDate)
        validTestEvent.setValue(newDate, forKey: "scheduledDate")
        XCTAssertEqual(holder.cachedScheduledDate, newDate)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDateObservingChangeToInvalidDate() {
        scheduleView.addSubview(eventView)
        scheduleView.addEventView(eventView)
        let holder = SCKEventHolder(event: validTestEvent, view: eventView, controller: controller)!
        eventView.eventHolder = holder
        controller.reloadDataPromise = expectation(description: "Reload")
        let newDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!.addingTimeInterval(-1)
        XCTAssertEqual(holder.cachedScheduledDate, validTestEvent.scheduledDate)
        validTestEvent.setValue(newDate, forKey: "scheduledDate")
        XCTAssertEqual(holder.cachedScheduledDate, newDate)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testTitleObserving() {
        scheduleView.addSubview(eventView)
        scheduleView.addEventView(eventView)
        let holder = SCKEventHolder(event: validTestEvent, view: eventView, controller: controller)!
        eventView.eventHolder = holder
        XCTAssertEqual(holder.cachedTitle, "Mock")
        validTestEvent.setValue("Other", forKey: "title")
        XCTAssertEqual(holder.cachedTitle, "Other")
    }
    
    func testUserEventColorObserving() {
        scheduleView.colorMode = .byEventOwner
        scheduleView.addSubview(eventView)
        scheduleView.addEventView(eventView)
        let holder = SCKEventHolder(event: validTestEvent, view: eventView, controller: controller)!
        eventView.eventHolder = holder
        XCTAssertTrue(holder.cachedUser === validTestEvent.user)
        let user2 = SCKUserMock()
        user2.eventColor = NSColor.blue
        validTestEvent.setValue(user2, forKey: "user")
        XCTAssertTrue(holder.cachedUser === user2)
        XCTAssertEqual(eventView.backgroundColor, NSColor.blue)
    }
    
    func testUserEventColorObserving2() {
        scheduleView.colorMode = .byEventOwner
        scheduleView.addSubview(eventView)
        scheduleView.addEventView(eventView)
        let holder = SCKEventHolder(event: validTestEvent, view: eventView, controller: controller)!
        eventView.eventHolder = holder
        XCTAssertTrue(holder.cachedUser === validTestEvent.user)
        (validTestEvent.user as! SCKUserMock).setValue(NSColor.blue, forKey: "eventColor")
        XCTAssertEqual(eventView.backgroundColor, NSColor.blue)
    }
    
    // MARK: Stop observing and resume observing
    
    func testStopAndResumeObserving() {
        scheduleView.addSubview(eventView)
        scheduleView.addEventView(eventView)
        let holder = SCKEventHolder(event: validTestEvent, view: eventView, controller: controller)!
        eventView.eventHolder = holder
        
        XCTAssertEqual(holder.cachedDuration, 15)
        validTestEvent.setValue(30, forKey: "duration")
        XCTAssertEqual(holder.cachedDuration, 30)
        
        holder.stopObservingRepresentedObjectChanges()
        validTestEvent.setValue(45, forKey: "duration")
        XCTAssertEqual(holder.cachedDuration, 30)
        
        holder.resumeObservingRepresentedObjectChanges()
        XCTAssertEqual(holder.cachedDuration, 30)
        validTestEvent.setValue(60, forKey: "duration")
        XCTAssertEqual(holder.cachedDuration, 60)
    }
    
    // MARK: Freezing and unfreezing
    
    func testHolderFreezing() {
        scheduleView.addSubview(eventView)
        scheduleView.addEventView(eventView)
        let holder = SCKEventHolder(event: validTestEvent, view: eventView, controller: controller)!
        eventView.eventHolder = holder
        
        XCTAssertEqual(holder.cachedDuration, 15)
        holder.freeze()
        validTestEvent.setValue(30, forKey: "duration")
        XCTAssertEqual(holder.cachedDuration, 15)
        holder.unfreeze()
        XCTAssertEqual(holder.cachedDuration, 30)
    }
    
    func testDoubleFreezingForCoveragePurposes() {
        scheduleView.addSubview(eventView)
        scheduleView.addEventView(eventView)
        let holder = SCKEventHolder(event: validTestEvent, view: eventView, controller: controller)!
        eventView.eventHolder = holder
        XCTAssertFalse(holder.isFrozen)
        holder.freeze()
        holder.freeze()
        XCTAssertTrue(holder.isFrozen)
        holder.unfreeze()
        holder.unfreeze()
        XCTAssertFalse(holder.isFrozen)
    }

}
