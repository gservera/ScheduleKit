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
        sharedCalendar = Calendar.current
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

    func testMatchingNoWeekday() {
        let unavailable = SCKUnavailableTimeRange(weekday: -1, startHour: 10, startMinute: 30, endHour: 12, endMinute: 30)
        
        let calendar = Calendar.current
        var weekComps = calendar.dateComponents([.weekOfYear,.yearForWeekOfYear], from: Date())
        let weekStart = calendar.date(from: weekComps)!
        weekComps.weekOfYear = weekComps.weekOfYear! + 1
        let weekEnd = calendar.date(from: weekComps)!.addingTimeInterval(-1)
        
        let interval = DateInterval(start: weekStart, end: weekEnd)
        
        let matches = unavailable.matchingOccurrences(in: interval)
        
        XCTAssertTrue(matches.count == 7)
    }
    
    func testMatchingWithWeekday() {
        // Testing with weekday 2 in grid view, which is wednesday in Spain
        let unavailable = SCKUnavailableTimeRange(weekday: 2, startHour: 10, startMinute: 30, endHour: 12, endMinute: 30)
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2 //Testing with pre-defined first day = Monday.
        sharedCalendar = calendar
        
        
        var dec2016Start = DateComponents()
        dec2016Start.day = 1; dec2016Start.month = 12; dec2016Start.year = 2016;
        var dec2016End = DateComponents()
        dec2016End.day = 31; dec2016End.month = 12; dec2016End.year = 2016;
        
        let monthStart = calendar.date(from: dec2016Start)!
        let monthEnd = calendar.date(from: dec2016End)!
        
        let interval = DateInterval(start: monthStart, end: monthEnd)
        
        let matches = unavailable.matchingOccurrences(in: interval)
        
        XCTAssertTrue(matches.count == 4)
    }
    
}
