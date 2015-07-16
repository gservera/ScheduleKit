/*
 *  ScheduleKitTests.h
 *  ScheduleKitTests
 *
 *  Created:    Guillem Servera on 31/12/2014.
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

#import "SCKTestMockObjects.h"

@implementation SCKMockEvent
@end

@implementation SCKMockUser
@end


@interface ScheduleKitTests : XCTestCase
@end

@implementation ScheduleKitTests

- (void)testTargetIntegrity {
    XCTAssertNotNil([SCKTextField class], @"Target integrity tests failed");
    XCTAssertNotNil([SCKEventHolder class], @"Target integrity tests failed");
    XCTAssertNotNil([SCKUnavailableTimeRange class], @"Target integrity tests failed");
    XCTAssertNotNil([SCKEventView class], @"Target integrity tests failed");
    XCTAssertNotNil([SCKWeekView class], @"Target integrity tests failed");
    XCTAssertNotNil([SCKDayView class], @"Target integrity tests failed");
    XCTAssertNotNil([SCKEventManager class], @"Target integrity tests failed");
}

@end
