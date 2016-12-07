//
//  SCKUnavailableTimeRangesTests.swift
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 7/12/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

import XCTest
@testable import ScheduleKit

class SCKUnavailableTimeRangesTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInitialization() {
        let unavailable = SCKUnavailableTimeRange(weekday: 3, startHour: 1, startMinute: 2, endHour: 5, endMinute: 6)
        XCTAssertEqual(unavailable.weekday, 3)
        XCTAssertEqual(unavailable.startHour, 1)
        XCTAssertEqual(unavailable.startMinute, 2)
        XCTAssertEqual(unavailable.endHour, 5)
        XCTAssertEqual(unavailable.endMinute, 6)
        
        XCTAssertTrue(SCKUnavailableTimeRange.supportsSecureCoding)
    }
    
    func testArchiving() {
        let unavailable = SCKUnavailableTimeRange(weekday: 3, startHour: 1, startMinute: 2, endHour: 5, endMinute: 6)
        
        let data = NSKeyedArchiver.archivedData(withRootObject: unavailable)
        
        let unarchived = NSKeyedUnarchiver.unarchiveObject(with: data) as! SCKUnavailableTimeRange
        
        XCTAssertEqual(unarchived.weekday, 3)
        XCTAssertEqual(unarchived.startHour, 1)
        XCTAssertEqual(unarchived.startMinute, 2)
        XCTAssertEqual(unarchived.endHour, 5)
        XCTAssertEqual(unarchived.endMinute, 6)
    }
    
    func testEqualty() {
        let unavailable = SCKUnavailableTimeRange(weekday: 3, startHour: 1, startMinute: 2, endHour: 5, endMinute: 6)
        let equal = SCKUnavailableTimeRange(weekday: 3, startHour: 1, startMinute: 2, endHour: 5, endMinute: 6)
        let diffWeekday = SCKUnavailableTimeRange(weekday: 9, startHour: 1, startMinute: 2, endHour: 5, endMinute: 6)
        let diffSH = SCKUnavailableTimeRange(weekday: 3, startHour: 9, startMinute: 2, endHour: 5, endMinute: 6)
        let diffSM = SCKUnavailableTimeRange(weekday: 3, startHour: 1, startMinute: 9, endHour: 5, endMinute: 6)
        let diffEH = SCKUnavailableTimeRange(weekday: 3, startHour: 1, startMinute: 2, endHour: 9, endMinute: 6)
        let diffEM = SCKUnavailableTimeRange(weekday: 3, startHour: 1, startMinute: 2, endHour: 5, endMinute: 9)
        
        XCTAssertEqual(unavailable, equal)
        XCTAssertNotEqual(unavailable, diffWeekday)
        XCTAssertNotEqual(unavailable, diffSH)
        XCTAssertNotEqual(unavailable, diffSM)
        XCTAssertNotEqual(unavailable, diffEH)
        XCTAssertNotEqual(unavailable, diffEM)
        
        XCTAssertFalse(unavailable.isEqual(self))
    }

    func testHashability() {
        let unavailable = SCKUnavailableTimeRange(weekday: 3, startHour: 1, startMinute: 2, endHour: 5, endMinute: 6)
        let equal = SCKUnavailableTimeRange(weekday: 3, startHour: 1, startMinute: 2, endHour: 5, endMinute: 6)
        let diffWeekday = SCKUnavailableTimeRange(weekday: 9, startHour: 1, startMinute: 2, endHour: 5, endMinute: 6)
        XCTAssertEqual(unavailable.hashValue, equal.hashValue)
        XCTAssertNotEqual(unavailable.hashValue, diffWeekday.hashValue)
        _ = Set<SCKUnavailableTimeRange>([unavailable, diffWeekday])
    }

}
