//
//  ScheduleKitUITests.swift
//  ScheduleKitUITests
//
//  Created by Guillem Servera Negre on 29/12/2018.
//  Copyright © 2018 Guillem Servera. All rights reserved.
//

import XCTest
@testable import ScheduleKit

class ScheduleKitUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    func testDoubleClickEmptySpace() {

        let app = XCUIApplication()
        let dayView = app.scrollViews.descendants(matching: .any).matching(identifier: "DayView").element

        let normalized = dayView.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let emptySpace = normalized.withOffset(CGVector(dx: 150, dy: 190))
        emptySpace.doubleClick()

        let okButton = app.dialogs.firstMatch.buttons["OK"]
        okButton.click()

    }

    func testClickEvent() {

        let app = XCUIApplication()
        let dayView = app.scrollViews.descendants(matching: .any).matching(identifier: "DayView").element

        let normalized = dayView.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let emptySpace = normalized.withOffset(CGVector(dx: 150, dy: 220))
        emptySpace.click()

    }

}
