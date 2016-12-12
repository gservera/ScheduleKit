//
//  SCKFreeTimeFinderTests.swift
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 12/12/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

import XCTest
@testable import ScheduleKit



final class SCKSynchronousFreeTimeFinderTests: XCTestCase, SCKEventManaging {

    let controller = SCKViewController()
    var testID = 0
    
    override func setUp() {
        super.setUp()
        controller.eventManager = self
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSimulatedNoUnavailabilitiesNorConflicts() { testID = 0
        let finder = SCKFreeTimeFinder(controller: controller, excluding: [])
        let date = Date()
        let availableDate = finder.firstAvailableDate(forEventWithDuration: 15, user: nil, from: date)
        XCTAssertEqual(date, availableDate)
    }
    
    func testSimulatedNoUnavailabilitiesWithConflicts() { testID = 1
        let finder = SCKFreeTimeFinder(controller: controller, excluding: [])
        let date = Date()
        let availableDate = finder.firstAvailableDate(forEventWithDuration: 15, user: nil, from: date)
        XCTAssertEqual(date, availableDate)
        
        let availableDate2 = finder.firstAvailableDate(forEventWithDuration: 30, user: nil, from: date)
        let expected = date.addingTimeInterval(75*60)
        XCTAssertEqual(availableDate2, expected)
    }
    
    //MARK: - SCKEventManaging
    
    func events(in dateInterval: DateInterval, for controller: SCKViewController) -> [SCKEvent] {
        switch testID {
        case 0:
            return []
        case 1:
            let mock = SCKEventMock(); mock.scheduledDate = Date().addingTimeInterval(15*60); mock.duration = 60
            let mock2 = SCKEventMock(); mock2.scheduledDate = Date().addingTimeInterval(15*60); mock.duration = 60
            return [mock]
        default:
            return []
        }
    }
    
    
    
    
    
    
    
    

}
