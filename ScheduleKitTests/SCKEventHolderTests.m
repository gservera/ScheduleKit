/*
 *  SCKEventHolderTests.m
 *  ScheduleKitTests
 *
 *  Created:    Guillem Servera on 20/02/2015.
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
#import <ScheduleKit/SCKViewPrivate.h>

@interface SCKEventHolderTests : XCTestCase {
    SCKMockUser *_sharedUser;
    SCKMockEvent *_testEvent;
    SCKView *_rootView;
    SCKEventView *_eventView;
}

@end

@implementation SCKEventHolderTests

- (void)setUp {
    [super setUp];
    _sharedUser = [SCKMockUser new];
    _sharedUser.labelColor = [NSColor blueColor];
    _testEvent = [SCKMockEvent new];
    _testEvent.eventType = SCKEventTypeDefault;
    _testEvent.user = _sharedUser;
    _testEvent.patient = nil;
    _testEvent.title = @"Test";
    _testEvent.duration = @60;
    _testEvent.scheduledDate = [NSDate dateWithTimeIntervalSinceReferenceDate:5400];
    _rootView = [[SCKView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 800.0, 600.0)];
    _rootView.startDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
    _rootView.endDate = [NSDate dateWithTimeIntervalSinceReferenceDate:10800];
    _eventView = [[SCKEventView alloc] initWithFrame:NSZeroRect];
    [_rootView addSubview:_eventView];
    [_rootView addEventView:_eventView];
}

- (void)tearDown {
    _sharedUser = nil;
    _testEvent = nil;
    [super tearDown];
}

- (void)testCreation {
    SCKEventHolder *holder = [[SCKEventHolder alloc] initWithEvent:_testEvent owner:_eventView];
    XCTAssertNotNil(holder,@"Event holder creation failed");
    [holder lock];//Calling lock to prevent exceptions when deallocing. Usually done by the event manager.
}

- (void)testCachedProperties {
    SCKEventHolder *holder = [[SCKEventHolder alloc] initWithEvent:_testEvent owner:_eventView];
    XCTAssertTrue(holder.ready,@"SCKEventHolder properties not working as expected");
    XCTAssertFalse(holder.locked,@"SCKEventHolder properties not working as expected");
    XCTAssertEqualObjects(holder.representedObject, _testEvent,@"SCKEventHolder error");
    XCTAssertEqualObjects(holder.owningView, _eventView,@"SCKEventHolder error");
    XCTAssertEqualWithAccuracy(holder.cachedRelativeStart, 0.5, 0.0001, @"Cached err");
    XCTAssertEqualWithAccuracy(holder.cachedRelativeEnd, 0.8333333, 0.0000001, @"Cached err");
    XCTAssertEqualWithAccuracy(holder.cachedRelativeLength, 0.3333333, 0.000001, @"Cached err");
    XCTAssertEqualObjects(holder.cachedUserLabelColor, [NSColor blueColor],@"Cached err");
    XCTAssertEqualObjects(holder.cachedTitle, @"Test",@"Cached err");
    XCTAssertEqualObjects(holder.cachedScheduleDate, [NSDate dateWithTimeIntervalSinceReferenceDate:5400],@"Cached err");
    XCTAssertEqual(holder.cachedDuration, 60,@"Cached err");
    [holder lock]; //Calling lock to prevent exceptions when deallocing. Usually done by the event manager.
}

- (void)testLockingAndUnlocking {
    SCKEventHolder *holder = [[SCKEventHolder alloc] initWithEvent:_testEvent owner:_eventView];
    XCTAssertEqualObjects(holder.cachedScheduleDate, [NSDate dateWithTimeIntervalSinceReferenceDate:5400],@"Cached err");
    [holder lock];
    _testEvent.scheduledDate = [NSDate dateWithTimeIntervalSinceReferenceDate:3600];
    XCTAssertEqualObjects(holder.cachedScheduleDate, [NSDate dateWithTimeIntervalSinceReferenceDate:5400],@"Cached err");
    [holder unlock]; //TODO: Find an efficient way to look up for changes after unlocking.
    XCTAssertEqualObjects(holder.cachedScheduleDate, [NSDate dateWithTimeIntervalSinceReferenceDate:3600],@"Cached err");
    _testEvent.scheduledDate = [NSDate dateWithTimeIntervalSinceReferenceDate:7200];
    XCTAssertEqualObjects(holder.cachedScheduleDate, [NSDate dateWithTimeIntervalSinceReferenceDate:7200],@"Cached err");
    [holder lock]; //Calling lock to prevent exceptions when deallocing. Usually done by the event manager.
}

- (void)testRecalculateRelativeValuesAndReadyness {
    SCKEventHolder *holder = [[SCKEventHolder alloc] initWithEvent:_testEvent owner:_eventView];
    XCTAssertTrue(holder.ready,@"SCKEventHolder relative calcs and readyness err");
    XCTAssertEqualWithAccuracy(holder.cachedRelativeStart, 0.5, 0.0001, @"SCKEventHolder relative calcs and readyness err");
    XCTAssertEqualWithAccuracy(holder.cachedRelativeEnd, 0.8333333, 0.0000001, @"SCKEventHolder relative calcs and readyness err");
    XCTAssertEqualWithAccuracy(holder.cachedRelativeLength, 0.3333333, 0.000001, @"SCKEventHolder relative calcs and readyness err err");
    _rootView.endDate = [NSDate dateWithTimeIntervalSinceReferenceDate:21600];
    XCTAssertEqualWithAccuracy(holder.cachedRelativeStart, 0.5, 0.0001, @"SCKEventHolder relative calcs and readyness err");
    XCTAssertEqualWithAccuracy(holder.cachedRelativeEnd, 0.8333333, 0.0000001, @"SCKEventHolder relative calcs and readyness err");
    XCTAssertEqualWithAccuracy(holder.cachedRelativeLength, 0.3333333, 0.000001, @"SCKEventHolder relative calcs and readyness err err");
    [holder recalculateRelativeValues];
    XCTAssertEqualWithAccuracy(holder.cachedRelativeStart, 0.25, 0.0001, @"SCKEventHolder relative calcs and readyness err");
    XCTAssertEqualWithAccuracy(holder.cachedRelativeEnd, 0.41666666, 0.0000001, @"SCKEventHolder relative calcs and readyness err");
    XCTAssertEqualWithAccuracy(holder.cachedRelativeLength, 0.41666666-0.25, 0.000001, @"SCKEventHolder relative calcs and readyness err err");
    [_rootView setEndDate:[NSDate dateWithTimeIntervalSinceReferenceDate:100]];
    [holder recalculateRelativeValues];
    XCTAssertFalse(holder.ready,@"Holder readyness calculation failed");
    XCTAssertEqual(holder.cachedRelativeStart, SCKRelativeTimeLocationNotFound, @"SCKEventHolder relative calcs and readyness err err");
    XCTAssertEqual(holder.cachedRelativeEnd, SCKRelativeTimeLocationNotFound, @"SCKEventHolder relative calcs and readyness err err");
    XCTAssertEqual(holder.cachedRelativeLength, 0, @"SCKEventHolder relative calcs and readyness err err");
    [holder lock]; //Calling lock to prevent exceptions when deallocing. Usually done by the event manager.
}

@end
