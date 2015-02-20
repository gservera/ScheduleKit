/*
 *  SCKDayPointTests.h
 *  ScheduleKitTests
 *
 *  Created:    Guillem Servera on 05/02/2015.
 *  Copyright:  © 2014-2015 Guillem Servera (http://github.com/gservera)
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

@import Cocoa;
@import XCTest;

#import "SCKDayPoint.h"

@interface SCKDayPointTests : XCTestCase
@end

@implementation SCKDayPointTests

- (void)testDesignatedInit {
    SCKDayPoint *p1 = [[SCKDayPoint alloc] initWithHour:18 minute:30 second:25];
    XCTAssertNotNil(p1,@"SCKDayPoint initialization failed");
    XCTAssertEqual(p1.hour, 18, @"SCKDayPoint initialization failed");
    XCTAssertEqual(p1.minute, 30, @"SCKDayPoint initialization failed");
    XCTAssertEqual(p1.second, 25, @"SCKDayPoint initialization failed");
    
    SCKDayPoint *p2 = [[SCKDayPoint alloc] initWithHour:18 minute:30 second:65];
    XCTAssertNotNil(p2,@"SCKDayPoint initialization failed");
    XCTAssertEqual(p2.hour, 18, @"SCKDayPoint initialization failed");
    XCTAssertEqual(p2.minute, 31, @"SCKDayPoint initialization failed");
    XCTAssertEqual(p2.second, 5, @"SCKDayPoint initialization failed");
    
    SCKDayPoint *p3 = [[SCKDayPoint alloc] initWithHour:18 minute:65 second:65];
    XCTAssertNotNil(p3,@"SCKDayPoint initialization failed");
    XCTAssertEqual(p3.hour, 19, @"SCKDayPoint initialization failed");
    XCTAssertEqual(p3.minute, 6, @"SCKDayPoint initialization failed");
    XCTAssertEqual(p3.second, 5, @"SCKDayPoint initialization failed");
    
    SCKDayPoint *p4 = [[SCKDayPoint alloc] initWithHour:0 minute:0 second:-65];
    XCTAssertNotNil(p4,@"SCKDayPoint initialization failed");
    XCTAssertEqual(p4.hour, 0, @"SCKDayPoint initialization failed");
    XCTAssertEqual(p4.minute, -1, @"SCKDayPoint initialization failed");
    XCTAssertEqual(p4.second, -5, @"SCKDayPoint initialization failed");
    
    SCKDayPoint *p5 = [[SCKDayPoint alloc] initWithHour:12 minute:-60 second:-3600];
    XCTAssertNotNil(p5,@"SCKDayPoint initialization failed");
    XCTAssertEqual(p5.hour, 10, @"SCKDayPoint initialization failed");
    XCTAssertEqual(p5.minute, 0, @"SCKDayPoint initialization failed");
    XCTAssertEqual(p5.second, 0, @"SCKDayPoint initialization failed");
}

- (void)testZeroInit {
    SCKDayPoint *zP = [SCKDayPoint zeroPoint];
    XCTAssertNotNil(zP,@"SCKDayPoint zero initialization failed");
    XCTAssertEqual(zP.hour, 0, @"SCKDayPoint zero initialization failed");
    XCTAssertEqual(zP.minute, 0, @"SCKDayPoint zero initialization failed");
    XCTAssertEqual(zP.second, 0, @"SCKDayPoint zero initialization failed");
}

- (void)testDateInit {
    NSDate *d = [[NSCalendar currentCalendar] dateBySettingHour:18 minute:30 second:25 ofDate:[NSDate date] options:0];
    SCKDayPoint *zP = [[SCKDayPoint alloc] initWithDate:d];
    XCTAssertNotNil(zP,@"SCKDayPoint date initialization failed");
    XCTAssertEqual(zP.hour, 18, @"SCKDayPoint date initialization failed");
    XCTAssertEqual(zP.minute, 30, @"SCKDayPoint date initialization failed");
    XCTAssertEqual(zP.second, 25, @"SCKDayPoint date initialization failed");
}

- (void)testDayOffset {
    SCKDayPoint *p1 = [[SCKDayPoint alloc] initWithHour:18 minute:30 second:25];
    XCTAssertEqual(p1.dayOffset, 66625, @"Day offset calculation failed");
}

- (void)testComparsion {
    SCKDayPoint *p1 = [[SCKDayPoint alloc] initWithHour:1 minute:50 second:55];
    SCKDayPoint *p2 = [[SCKDayPoint alloc] initWithHour:2 minute:35 second:1];
    SCKDayPoint *p3 = [[SCKDayPoint alloc] initWithHour:2 minute:35 second:1];
    SCKDayPoint *p4 = [[SCKDayPoint alloc] initWithHour:3 minute:17 second:56];
    XCTAssertTrue([p2 isEqual:p3],@"SCKDayPoint comparsion failed");
    XCTAssertFalse([p2 isEqual:p1],@"SCKDayPoint comparsion failed");
    XCTAssertTrue([p2 isEqualToDayPoint:p3],@"SCKDayPoint comparsion failed");
    XCTAssertFalse([p2 isEqualToDayPoint:p1],@"SCKDayPoint comparsion failed");
    XCTAssertTrue([p2 isLaterThanDayPoint:p1],@"SCKDayPoint comparsion failed");
    XCTAssertFalse([p2 isLaterThanDayPoint:p4],@"SCKDayPoint comparsion failed");
    XCTAssertTrue([p2 isEarlierThanDayPoint:p4],@"SCKDayPoint comparsion failed");
    XCTAssertFalse([p2 isEarlierThanDayPoint:p1],@"SCKDayPoint comparsion failed");
    XCTAssertFalse([p2 isEarlierThanDayPoint:p3],@"SCKDayPoint comparsion failed");
    XCTAssertFalse([p2 isLaterThanDayPoint:p3],@"SCKDayPoint comparsion failed");
}

@end
