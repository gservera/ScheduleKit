//
//  SCKTesterTests.m
//  SCKTesterTests
//
//  Created by Guillem on 12/1/15.
//  Copyright (c) 2015 Guillem Servera. All rights reserved.
//

@import Cocoa;
@import XCTest;

@interface SCKTesterTests : XCTestCase

@end

@implementation SCKTesterTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
