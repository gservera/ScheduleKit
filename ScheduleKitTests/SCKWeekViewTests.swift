//
//  SCKWeekViewTests.swift
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 9/12/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

import XCTest
@testable import ScheduleKit

private class _MockController: SCKViewController {
    override func internalReloadData() {

    }
}

class SCKWeekViewTests: XCTestCase {

    var weekView = SCKWeekView(frame: .zero)
    fileprivate let mockController = _MockController()

    override func setUp() {
        super.setUp()
        weekView = SCKWeekView(frame: .zero)
        weekView.controller = mockController

        // Default date interval (today)
        let calendar = Calendar.current
        var weekComps = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: Date())
        let weekBeginning = calendar.date(from: weekComps)!
        weekComps.weekOfYear = weekComps.weekOfYear! + 1
        let nextWeekBeginning = calendar.date(from: weekComps)
        let eD = nextWeekBeginning?.addingTimeInterval(-1)
        let interval = DateInterval(start: weekBeginning, end: eD!)
        weekView.dateInterval = interval
    }

    func testPreviousWeekDateInterval() {
        weekView.decreaseWeekOffset(self)

        let calendar = Calendar.current
        var weekComps = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: Date())
        weekComps.weekOfYear = weekComps.weekOfYear! - 1
        let weekBeginning = calendar.date(from: weekComps)!
        weekComps.weekOfYear = weekComps.weekOfYear! + 1
        let nextWeekBeginning = calendar.date(from: weekComps)
        let eD = nextWeekBeginning?.addingTimeInterval(-1)
        let interval = DateInterval(start: weekBeginning, end: eD!)

        XCTAssertEqual(weekView.dateInterval, interval, "Last week not set.")
    }

    func testNextWeekDateInterval() {
        weekView.increaseWeekOffset(self)

        let calendar = Calendar.current
        var weekComps = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: Date())
        weekComps.weekOfYear = weekComps.weekOfYear! + 1
        let weekBeginning = calendar.date(from: weekComps)!
        weekComps.weekOfYear = weekComps.weekOfYear! + 1
        let nextWeekBeginning = calendar.date(from: weekComps)
        let eD = nextWeekBeginning?.addingTimeInterval(-1)
        let interval = DateInterval(start: weekBeginning, end: eD!)

        XCTAssertEqual(weekView.dateInterval, interval, "Next week not set.")
    }

    func testResetDateInterval() {
        weekView.increaseWeekOffset(self)
        XCTAssertFalse(weekView.dateInterval.contains(Date()))
        weekView.resetWeekOffset(self)
        XCTAssertTrue(weekView.dateInterval.contains(Date()))
    }
}
