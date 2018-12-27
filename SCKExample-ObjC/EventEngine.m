//
//  EventEngine.m
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 14/11/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

#import "EventEngine.h"

@import AppKit;

static EventEngine * __shared;

@implementation EventEngine

- (instancetype)init {
    self = [super init];
    if (self) {
        _users = @[
                   [[TestUser alloc] initWithName:@"Dr. Test 1" color:[NSColor systemOrangeColor]],
                   [[TestUser alloc] initWithName:@"Dr. Test 2" color:[NSColor systemBlueColor]]
        ];
        _events = [TestEvent sampleEventsForUsers:_users];
    }
    return self;
}

+ (nonnull instancetype)sharedEngine {
    if (__shared == nil) {
        __shared = [[EventEngine alloc] init];
    }
    return __shared;
}


@end
