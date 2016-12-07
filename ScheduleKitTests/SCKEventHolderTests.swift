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
    var eventColor: NSColor {
        return NSColor.orange
    }
}

class SCKEventMock: NSObject, SCKEvent {
    
    @objc var eventKind: Int {
        return 0
    }
    
    @objc var duration: Int = 15
    
    @objc var scheduledDate = Calendar.current.date(bySettingHour: 11, minute: 0, second: 0, of: Date())!
    
    
    @objc var title: String {
        return "Mock"
    }
    
    @objc let user: SCKUser = SCKUserMock()
    
}

final class SCKEventHolderTests: XCTestCase {
    
    var controller: SCKViewController!
    var scheduleView: SCKView!
    var eventView: SCKEventView!
    var validTestEvent: SCKEventMock!
    var invalidTestEvent: SCKEventMock!

    override func setUp() {
        super.setUp()
        let bundle = Bundle(for: SCKEventHolderTests.self)
        controller = SCKViewController(nibName: "TestController", bundle: bundle)
        _ = controller.view
        scheduleView = controller.scheduleView!
        let sD = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date())!
        let eD = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
        scheduleView.dateInterval = DateInterval(start: sD, end: eD)
        eventView = SCKEventView(frame: .zero)
        validTestEvent = SCKEventMock()
        invalidTestEvent = SCKEventMock()
        invalidTestEvent.scheduledDate = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInitialization() {
        scheduleView.addSubview(eventView)
        scheduleView.addEventView(eventView)
        let holder = SCKEventHolder(event: validTestEvent, view: eventView, controller: controller)
        XCTAssertNotNil(holder,"Should have been initialized")
        
        XCTAssertEqual(holder!.representedObject as? SCKEventMock, validTestEvent, "Error")
        XCTAssertTrue(holder!.isReady, "Should be ready")
        
        
        let holder2 = SCKEventHolder(event: invalidTestEvent, view: eventView, controller: controller)
        XCTAssertNil(holder2,"Should have failed")
    }
    

}
