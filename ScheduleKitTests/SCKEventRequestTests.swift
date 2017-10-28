/*
 *  SCKEventRequestTests.swift
 *  ScheduleKit
 *
 *  Created:    Guillem Servera on 22/2/2017.
 *  Copyright:  © 2017 Guillem Servera (http://github.com/gservera)
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

class RequestParsingMock: AsynchronousRequestParsing {

    var completed = false

    let expectation: XCTestExpectation?

    init(expectation: XCTestExpectation?) {
        self.expectation = expectation
    }

    var asynchronousRequests: Set<SCKEventRequest> = []

    func parseData(in eventArray: [SCKEvent], from request: SCKEventRequest) {
        completed = true
        expectation?.fulfill()
    }
}

class SCKEventRequestTests: XCTestCase {

    var parser: RequestParsingMock?

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        parser = nil
        super.tearDown()
    }

    func testSynchronousStandardRequest() {
        let condition = expectation(description: "Standard event request")
        parser = RequestParsingMock(expectation: condition)

        let anyDateInterval = DateInterval(start: Date(), duration: 1)
        let request = SCKEventRequest(controller: parser!,
                                      dateInterval: anyDateInterval)
        parser!.asynchronousRequests.insert(request)
        XCTAssertEqual(request.debugDescription, "SCKEventRequest (In progress | Start: \(anyDateInterval.start.description) | End: \(anyDateInterval.end.description))")
        XCTAssertFalse(request.isCanceled)
        XCTAssertEqual(request.dateInterval, anyDateInterval)
        XCTAssertEqual(request.startDate, anyDateInterval.start)
        XCTAssertEqual(request.endDate, anyDateInterval.end)
        XCTAssertEqual(parser!.asynchronousRequests.count, 1)
        request.complete(with: [])
        XCTAssertFalse(request.isCanceled)
        XCTAssertTrue(parser!.completed)
        XCTAssertEqual(parser!.asynchronousRequests.count, 0)
        XCTAssertEqual(request.debugDescription, "SCKEventRequest (Completed | Start: \(anyDateInterval.start.description) | End: \(anyDateInterval.end.description))")
        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testAsynchronousMainThreadCompletion() {
        let condition = expectation(description: "Standard event request")
        parser = RequestParsingMock(expectation: condition)

        let anyDateInterval = DateInterval(start: Date(), duration: 1)
        let request = SCKEventRequest(controller: parser!,
                                      dateInterval: anyDateInterval)
        parser!.asynchronousRequests.insert(request)
        DispatchQueue.global(qos: .background).async {
            sleep(2)
            DispatchQueue.main.async {
                request.complete(with: [])
                XCTAssertTrue(self.parser!.completed)
            }
        }
        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testAsynchronousBackgroundThreadNoCompletion() {
        parser = RequestParsingMock(expectation: nil)
        let exp = expectation(description: "Not called")
        let anyDateInterval = DateInterval(start: Date(), duration: 1)
        let request = SCKEventRequest(controller: parser!,
                                      dateInterval: anyDateInterval)
        parser!.asynchronousRequests.insert(request)
        DispatchQueue.global(qos: .background).async {
            request.complete(with: [])
            DispatchQueue.main.async {
                XCTAssertFalse(self.parser!.completed)
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testCancellationNoCompletion() {
        parser = RequestParsingMock(expectation: nil)
        let exp = expectation(description: "Not called")
        let anyDateInterval = DateInterval(start: Date(), duration: 1)
        let request = SCKEventRequest(controller: parser!,
                                      dateInterval: anyDateInterval)
        parser!.asynchronousRequests.insert(request)
        request.cancel()
        XCTAssertEqual(parser!.asynchronousRequests.count, 0)
        DispatchQueue.global(qos: .background).async {
            request.complete(with: [])
            DispatchQueue.main.async {
                XCTAssertFalse(self.parser!.completed)
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testConcreteAsynchronousMainThreadCompletion() {
        let condition = expectation(description: "Standard event request")
        parser = RequestParsingMock(expectation: condition)

        let anyDateInterval = DateInterval(start: Date(), duration: 1)
        let request: SCKConcreteEventRequest<SCKEventMock> = SCKConcreteEventRequest(controller: parser!,
                                      dateInterval: anyDateInterval)
        parser!.asynchronousRequests.insert(request)
        DispatchQueue.global(qos: .background).async {
            sleep(2)
            DispatchQueue.main.async {
                let mocks: [SCKEventMock] = []
                request.complete(with: mocks)
                XCTAssertTrue(self.parser!.completed)
            }
        }
        waitForExpectations(timeout: 5.0, handler: nil)
    }

}
