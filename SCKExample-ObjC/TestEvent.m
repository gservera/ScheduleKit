//
//  TestEvent.m
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 14/11/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

#import "TestEvent.h"

@implementation TestEvent

- (nonnull instancetype)initWithKind:(NSInteger)kind user:(nonnull TestUser*)user title:(nonnull NSString*)title duration:(NSInteger)duration date:(nonnull NSDate*)date {
    self = [super init];
    if (self) {
        _eventKind = kind;
        _user = user;
        _title = title;
        _duration = duration;
        
        NSInteger t = (NSInteger)[date timeIntervalSinceReferenceDate];
        while (t % 60 > 0) {
            t++;
        }
        _scheduledDate = [NSDate dateWithTimeIntervalSinceReferenceDate:t];
    }
    return self;
}

+ (nonnull NSArray<TestEvent*>*)sampleEventsForUsers:(nonnull NSArray<TestUser*>*)users {
    NSMutableArray<TestEvent*>* events = [NSMutableArray new];
    
    TestUser *user1 = users[0];
    TestUser *user2 = users[1];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:[NSDate date]];
    comps.hour = 9;
    
    NSDateComponents *dayMinus = [[NSDateComponents alloc] init];
    dayMinus.day = -1;
    dayMinus.hour = 1;
    
    [events addObject:[[TestEvent alloc] initWithKind:0 user:user1 title:@"Event 1" duration:60 date:[cal dateFromComponents:comps]]];
    [events addObject:[[TestEvent alloc] initWithKind:0 user:user1 title:@"Event 11" duration:60 date:[cal dateFromComponents:comps]]];
    [events addObject:[[TestEvent alloc] initWithKind:1 user:user2 title:@"Event 12" duration:60 date:[cal dateFromComponents:comps]]];
    comps.hour = 10;
    [events addObject:[[TestEvent alloc] initWithKind:2 user:user1 title:@"Event 2" duration:60 date:[cal dateFromComponents:comps]]];
    [events addObject:[[TestEvent alloc] initWithKind:1 user:user2 title:@"Event 3" duration:60 date:[cal dateFromComponents:comps]]];
    comps.hour = 12;
    [events addObject:[[TestEvent alloc] initWithKind:0 user:user1 title:@"Event 4" duration:60 date:[cal dateFromComponents:comps]]];
    [events addObject:[[TestEvent alloc] initWithKind:2 user:user1 title:@"Event 13" duration:60 date:[cal dateFromComponents:comps]]];
    [events addObject:[[TestEvent alloc] initWithKind:0 user:user1 title:@"Event 14" duration:60 date:[cal dateFromComponents:comps]]];
    
    comps.hour = 14;
    
    [events addObject:[[TestEvent alloc] initWithKind:0 user:user1 title:@"Event 5" duration:60 date:[cal dateFromComponents:comps]]];
    [events addObject:[[TestEvent alloc] initWithKind:1 user:user2 title:@"Event 6" duration:60 date:[cal dateFromComponents:comps]]];
    [events addObject:[[TestEvent alloc] initWithKind:2 user:user1 title:@"Event 7" duration:60 date:[cal dateFromComponents:comps]]];
    
    comps.minute = 30;
    
    
    [events addObject:[[TestEvent alloc] initWithKind:1 user:user2 title:@"Event 8" duration:60 date:[cal dateFromComponents:comps]]];
    comps.minute = 0;
    comps.hour = 16;
    [events addObject:[[TestEvent alloc] initWithKind:0 user:user1 title:@"Event 9" duration:60 date:[cal dateFromComponents:comps]]];
    comps.hour = 17;
    [events addObject:[[TestEvent alloc] initWithKind:2 user:user2 title:@"Event 10" duration:60 date:[cal dateFromComponents:comps]]];
    return events;
}

@end
