//
//  SCKDayPointTests.swift
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 10/12/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

import XCTest
@testable import ScheduleKit

//TODO: Mind hour count? (some days have 23! others 25!). Import from schedule view?

final class SCKDayPointTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInitialization() {
        let point = SCKDayPoint(hour: 10, minute: 20, second: 30)
        XCTAssertEqual(point.hour, 10)
        XCTAssertEqual(point.minute, 20)
        XCTAssertEqual(point.second, 30)
        XCTAssertEqual(point.dayOffset, 37230)
        
        let calendar = Calendar.current
        let d = calendar.date(bySettingHour: 10, minute: 20, second: 30, of: Date())
        let point2 = SCKDayPoint(date: d!)
        XCTAssertEqual(point2.hour, 10)
        XCTAssertEqual(point2.minute, 20)
        XCTAssertEqual(point2.second, 30)
        XCTAssertEqual(point2.dayOffset, 37230)
    }
    
    func testInitializationWithOverflow() {
        let point = SCKDayPoint(hour: 0, minute: 0, second: 37230)
        XCTAssertEqual(point.hour, 10)
        XCTAssertEqual(point.minute, 20)
        XCTAssertEqual(point.second, 30)
        XCTAssertEqual(point.dayOffset, 37230)
    }
    
    func testInitializationWithOverflow2() {
        let point = SCKDayPoint(hour: 10, minute: 21, second: -20)
        XCTAssertEqual(point.hour, 10)
        XCTAssertEqual(point.minute, 20)
        XCTAssertEqual(point.second, 40)
        XCTAssertEqual(point.dayOffset, 37240)
        
        let point2 = SCKDayPoint(hour: 10, minute: 22, second: -80)
        XCTAssertEqual(point2.hour, 10)
        XCTAssertEqual(point2.minute, 20)
        XCTAssertEqual(point2.second, 40)
        XCTAssertEqual(point2.dayOffset, 37240)
    }
    
    func testInitializationWithOverflow3() {
        let point = SCKDayPoint(hour: 11, minute: -40, second: 30)
        XCTAssertEqual(point.hour, 10)
        XCTAssertEqual(point.minute, 20)
        XCTAssertEqual(point.second, 30)
        XCTAssertEqual(point.dayOffset, 37230)
        
        let point2 = SCKDayPoint(hour: 12, minute: -100, second: 30)
        XCTAssertEqual(point2.hour, 10)
        XCTAssertEqual(point2.minute, 20)
        XCTAssertEqual(point2.second, 30)
        XCTAssertEqual(point2.dayOffset, 37230)
    }
    
    func testComparsion() {
        let point = SCKDayPoint(hour: 9, minute: 30, second: 1)
        let point2 = SCKDayPoint(hour: 10, minute: 29, second: 6)
        let point3 = SCKDayPoint(hour: 9, minute: 30, second: 1)
        XCTAssertEqual(point, point3)
        XCTAssertNotEqual(point, point2)
        XCTAssertTrue(point < point2)
        XCTAssertTrue(point2 > point)
        XCTAssertEqual(point.hashValue, point3.hashValue)
        XCTAssertNotEqual(point.hashValue, point2.hashValue)
    }
    

}
