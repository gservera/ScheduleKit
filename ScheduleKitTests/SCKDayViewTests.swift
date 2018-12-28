//
//  SCKDayViewTests.swift
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 7/12/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

import XCTest
@testable import ScheduleKit

private class _MockController: SCKViewController {
    override func internalReloadData() {

    }
}

class SCKDayViewTests: XCTestCase {

    var dayView = SCKDayView(frame: .zero)
    fileprivate let mockController = _MockController()

    override func setUp() {
        super.setUp()
        dayView = SCKDayView(frame: .zero)
        dayView.controller = mockController

        // Default date interval (today)
        let calendar = Calendar.current
        let sD = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())
        let eD = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date())
        let interval = DateInterval(start: sD!, end: eD!)
        dayView.dateInterval = interval
    }

    func testTodayDateInterval() {
        XCTAssertEqual(dayView.hourCount, 24, "Hour count should be 24.")
    }

    func testYesterdayDateInterval() {
        let calendar = Calendar.current
        let t = calendar.date(byAdding: .day, value: -1, to: Date())!
        let sD = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: t)
        let eD = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: t)
        let interval = DateInterval(start: sD!, end: eD!)
        dayView.decreaseDayOffset(self)
        XCTAssertEqual(dayView.dateInterval, interval, "Yesterday not set.")
    }

    func testTomorrowDateInterval() {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        let sDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: tomorrow)
        let eDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: tomorrow)
        let interval = DateInterval(start: sDate!, end: eDate!)
        dayView.increaseDayOffset(self)
        XCTAssertEqual(dayView.dateInterval, interval, "Tomorrow not set.")
    }

    func testResetDateInterval() {
        let calendar = Calendar.current
        let sDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())
        let eDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date())
        let interval = DateInterval(start: sDate!, end: eDate!)
        dayView.decreaseDayOffset(self)
        dayView.resetDayOffset(self)
        XCTAssertEqual(dayView.dateInterval, interval, "Today not set.")
    }

}
