/*
 *  SCKUnavailableTimeRangeTests.m
 *  ScheduleKitTests
 *
 *  Created:    Guillem Servera on 04/02/2015.
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
@import ScheduleKit;

@interface SCKUnavailableTimeRangeTests : XCTestCase
@end

@implementation SCKUnavailableTimeRangeTests

- (void)testDesignatedInit {
    SCKUnavailableTimeRange *breakRep = [[SCKUnavailableTimeRange alloc] initWithWeekday:1
                                                                               startHour:13
                                                                             startMinute:1
                                                                                 endHour:15
                                                                               endMinute:1];
    XCTAssertNotNil(breakRep, @"SCKUnavailableTimeRange initialization error");
    XCTAssertEqual(breakRep.weekday, 1, @"SCKUnavailableTimeRange initialization error");
    XCTAssertEqual(breakRep.startHour, 13, @"SCKUnavailableTimeRange initialization error");
    XCTAssertEqual(breakRep.startMinute, 1, @"SCKUnavailableTimeRange initialization error");
    XCTAssertEqual(breakRep.endHour, 15, @"SCKUnavailableTimeRange initialization error");
    XCTAssertEqual(breakRep.endMinute, 1, @"SCKUnavailableTimeRange initialization error");
}

- (void)testAlternativeInit {
    SCKUnavailableTimeRange *breakRep = [[SCKUnavailableTimeRange alloc] init];
    breakRep.weekday = 1;
    breakRep.startHour = 13;
    breakRep.startMinute = 1;
    breakRep.endHour = 15;
    breakRep.endMinute = 1;
    XCTAssertNotNil(breakRep, @"SCKUnavailableTimeRange initialization error");
    XCTAssertEqual(breakRep.weekday, 1, @"SCKUnavailableTimeRange property setting error");
    XCTAssertEqual(breakRep.startHour, 13, @"SCKUnavailableTimeRange property setting error");
    XCTAssertEqual(breakRep.startMinute, 1, @"SCKUnavailableTimeRange property setting error");
    XCTAssertEqual(breakRep.endHour, 15, @"SCKUnavailableTimeRange property setting error");
    XCTAssertEqual(breakRep.endMinute, 1, @"SCKUnavailableTimeRange property setting error");
}

- (void)testArchivingAndUnarchiving {
    SCKUnavailableTimeRange *breakRep = [[SCKUnavailableTimeRange alloc] init];
    breakRep.weekday = 1;
    breakRep.startHour = 13;
    breakRep.startMinute = 1;
    breakRep.endHour = 15;
    breakRep.endMinute = 1;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:breakRep];
    XCTAssertNotNil(data, @"SCKUnavailableTimeRange archiving error");
    
    SCKUnavailableTimeRange *rBreak = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    XCTAssertNotNil(rBreak, @"SCKUnavailableTimeRange unarchiving error");
    XCTAssertEqual(breakRep.weekday, rBreak.weekday, @"SCKUnavailableTimeRange coding error");
    XCTAssertEqual(breakRep.startHour, rBreak.startHour, @"SCKUnavailableTimeRange coding error");
    XCTAssertEqual(breakRep.startMinute,rBreak.startMinute, @"SCKUnavailableTimeRange coding error");
    XCTAssertEqual(breakRep.endHour, rBreak.endHour, @"SCKUnavailableTimeRange coding error");
    XCTAssertEqual(breakRep.endMinute, rBreak.endMinute, @"SCKUnavailableTimeRange coding error");
}

- (void)testEqualty {
    SCKUnavailableTimeRange *breakRep = [[SCKUnavailableTimeRange alloc] init];
    breakRep.weekday = 1;
    breakRep.startHour = 13;
    breakRep.startMinute = 1;
    breakRep.endHour = 15;
    breakRep.endMinute = 1;
    SCKUnavailableTimeRange *breakRep2 = [[SCKUnavailableTimeRange alloc] init];
    breakRep2.weekday = 1;
    breakRep2.startHour = 13;
    breakRep2.startMinute = 1;
    breakRep2.endHour = 15;
    breakRep2.endMinute = 1;
    SCKUnavailableTimeRange *breakRep3 = [[SCKUnavailableTimeRange alloc] init];
    breakRep3.weekday = 1;
    breakRep3.startHour = 13;
    breakRep3.startMinute = 2;
    breakRep3.endHour = 15;
    breakRep3.endMinute = 1;
    XCTAssertFalse(breakRep == breakRep2, @"SCKUnavailableTimeRange equality testing failed");
    XCTAssertFalse(breakRep == breakRep3, @"SCKUnavailableTimeRange equality testing failed");
    XCTAssertTrue([breakRep isEqual:breakRep2], @"SCKUnavailableTimeRange equality testing failed");
    XCTAssertFalse([breakRep isEqual:breakRep3], @"SCKUnavailableTimeRange equality testing failed");
    XCTAssertTrue([breakRep isEqualToUnavailableTimeRange:breakRep2], @"SCKUnavailableTimeRange equality testing failed");
    XCTAssertFalse([breakRep isEqualToUnavailableTimeRange:breakRep3], @"SCKUnavailableTimeRange equality testing failed");
}

@end
