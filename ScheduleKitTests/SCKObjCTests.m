//
//  SCKObjCTests.m
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 9/12/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

#import <XCTest/XCTest.h>

@import ScheduleKit;

@interface MockUser : NSObject <SCKUser>
@property (nonatomic, nonnull, strong) NSColor * eventColor;
@end

@interface MockEvent : NSObject <SCKEvent>
@property (nonatomic, readonly) NSInteger eventKind;
@property (nonatomic) NSInteger duration;
@property (nonatomic, copy) NSDate * _Nonnull scheduledDate;
@property (nonatomic, copy) NSString * _Nonnull title;
@property (nonatomic, strong) MockUser * _Nonnull user;
@end

@implementation MockUser
@synthesize eventColor;
@end

@implementation MockEvent
@synthesize eventKind, duration, scheduledDate, title, user;
@end

@interface SCKObjCTests : XCTestCase <SCKEventManaging> {
    SCKViewController *_controller;
    SCKView *_scheduleView;
    
    XCTestExpectation *_asyncDataSourceExpectation;
    XCTestExpectation *_syncDataSourceExpectation;
    XCTestExpectation *_doubleClickBlankDateExpectation;
    XCTestExpectation *_doubleClickEventExpectation;
    XCTestExpectation *_selectEventExpectation;
    XCTestExpectation *_deselectEventExpectation;
    XCTestExpectation *_menuExpectation;
}

@end

@implementation SCKObjCTests

- (void)setUp {
    [super setUp];
    NSBundle *bundle = [NSBundle bundleForClass:[SCKObjCTests class]];
    _controller = [[SCKViewController alloc] initWithNibName:@"TestController" bundle:bundle];
    [_controller view];
    _scheduleView = [_controller scheduleView];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *start = [cal dateBySettingHour:0 minute:0 second:0 ofDate:[NSDate date] options:0];
    NSDate *end = [cal dateBySettingHour:23 minute:59 second:59 ofDate:[NSDate date] options:0];
    _scheduleView.dateInterval = [[NSDateInterval alloc] initWithStartDate:start endDate:end];
}

- (void)tearDown {
    _scheduleView = nil;
    _controller = nil;
    [super tearDown];
}

#pragma mark - Data source

- (void)testSyncLoading {
    [_controller setObjCDelegate:self];
    _syncDataSourceExpectation = [self expectationWithDescription:@"Sync loading"];
    [_controller reloadData];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testAsyncLoading {
    [_controller setObjCDelegate:self];
    [_controller setLoadsEventsAsynchronously:YES];
    _asyncDataSourceExpectation = [self expectationWithDescription:@"Async loading"];
    [_controller reloadData];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testDoubleClickOnBlankDate {
    [_controller setObjCDelegate:self];
    _doubleClickBlankDateExpectation = [self expectationWithDescription:@"Blank date"];
    [_scheduleView mouseDown:[NSEvent mouseEventWithType:NSEventTypeLeftMouseDown location:CGPointMake(_scheduleView.frame.size.width/2, _scheduleView.frame.size.height/4) modifierFlags:0 timestamp:0 windowNumber:0 context:nil eventNumber:0 clickCount:2 pressure:0]];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testDoubleClickEvent {
    [_controller setObjCDelegate:self];
    _doubleClickEventExpectation = [self expectationWithDescription:@"Double click event"];
    [_controller reloadData];
    //Select
    for (NSView *subview in _scheduleView.subviews) {
        if ([subview isKindOfClass:[SCKEventView class]]) {
            [subview mouseUp:[NSEvent mouseEventWithType:NSEventTypeLeftMouseUp location:CGPointZero modifierFlags:0 timestamp:0 windowNumber:0 context:nil eventNumber:0 clickCount:2 pressure:0]];
            break;
        }
    }
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}


- (void)testEventSelection {
    [_controller setObjCDelegate:self];
    _selectEventExpectation = [self expectationWithDescription:@"Select event"];
    _deselectEventExpectation = [self expectationWithDescription:@"Deselect event"];
    [_controller reloadData];
    //Select
    for (NSView *subview in _scheduleView.subviews) {
        if ([subview isKindOfClass:[SCKEventView class]]) {
            [subview mouseDown:[NSEvent mouseEventWithType:NSEventTypeLeftMouseDown location:CGPointMake(_scheduleView.frame.size.width/2, _scheduleView.frame.size.height/2) modifierFlags:0 timestamp:0 windowNumber:0 context:nil eventNumber:0 clickCount:1 pressure:0]];
            break;
        }
    }
    
    //Deselect
    [_scheduleView mouseDown:[NSEvent mouseEventWithType:NSEventTypeLeftMouseDown location:CGPointMake(_scheduleView.frame.size.width/2, _scheduleView.frame.size.height/4) modifierFlags:0 timestamp:0 windowNumber:0 context:nil eventNumber:0 clickCount:1 pressure:0]];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testRightClickMenu {
    [_controller setObjCDelegate:self];
    _menuExpectation = [self expectationWithDescription:@"Contextual menu"];
    [_controller reloadData];
    //Select
    for (NSView *subview in _scheduleView.subviews) {
        if ([subview isKindOfClass:[SCKEventView class]]) {
            [subview rightMouseDown:[NSEvent mouseEventWithType:NSEventTypeRightMouseDown location:CGPointZero modifierFlags:0 timestamp:0 windowNumber:0 context:nil eventNumber:0 clickCount:1 pressure:0]];
            break;
        }
    }
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

#pragma mark - SCKEventManaging

- (NSArray<id<SCKEvent>> *)eventsIn:(NSDateInterval *)dateInterval for:(SCKViewController *)controller {
    [_syncDataSourceExpectation fulfill];
    MockUser *user = [MockUser new]; user.eventColor = [NSColor blueColor];
    MockEvent *eventInTheMiddle = [MockEvent new]; eventInTheMiddle.user = user; eventInTheMiddle.title = @"Event"; eventInTheMiddle.duration = 60; eventInTheMiddle.scheduledDate = [NSDate dateWithTimeIntervalSinceReferenceDate:dateInterval.startDate.timeIntervalSinceReferenceDate+(dateInterval.endDate.timeIntervalSinceReferenceDate-dateInterval.startDate.timeIntervalSinceReferenceDate)/2-1800];
    return @[eventInTheMiddle];
}

- (void)scheduleController:(SCKViewController *)controller didMakeEventRequest:(SCKEventRequest *)request {
    [_asyncDataSourceExpectation fulfill];
}

- (void)scheduleController:(SCKViewController *)controller didDoubleClickBlankDate:(NSDate *)date{
    [_doubleClickBlankDateExpectation fulfill];
}

- (void)scheduleController:(SCKViewController *)controller didDoubleClickEvent:(id<SCKEvent>)event {
    XCTAssertNotNil(event);
    [_doubleClickEventExpectation fulfill];
}

- (void)scheduleController:(SCKViewController *)controller didSelectEvent:(id<SCKEvent>)event {
    XCTAssertNotNil(event);
    [_selectEventExpectation fulfill];
}

- (void)scheduleControllerDidClearSelection:(SCKViewController *)controller {
    [_deselectEventExpectation fulfill];
}

- (NSMenu *)scheduleController:(SCKViewController *)controller menuForEvent:(id<SCKEvent>)event {
    [_menuExpectation fulfill];
    return nil;
}

@end
