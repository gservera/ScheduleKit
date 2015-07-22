//
//  SCKEventRequest.m
//  ScheduleKit
//
//  Created by Guillem Servera on 16/7/15.
//  Copyright (c) 2015 Guillem Servera. All rights reserved.
//

#import "SCKEventRequest.h"
#import "SCKEventRequestPrivate.h"
#import "SCKEventManagerPrivate.h"

@implementation SCKEventRequest {
    BOOL _completed;
    BOOL _canceled;
}

- (void)cancel {
    _canceled = YES;
    [_eventManager.asynchronousEventRequests removeObject:self];
}

- (void)completeWithEvents:(NSArray*)events {
    if (!_canceled && !_completed) {
        [self.eventManager reloadDataWithAsynchronouslyLoadedEvents:events request:self];
        _completed = YES;
        [_eventManager.asynchronousEventRequests removeObject:self];
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ (Completed: %d, Canceled: %d)",[super description],_completed,_canceled];
}

#pragma mark - Equality

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    } else if ([object isKindOfClass:[SCKEventRequest class]]) {
        SCKEventRequest *req = object;
        return ((req.eventManager == self.eventManager) && [req.startDate isEqualToDate:_startDate] && [req.endDate isEqualToDate:_endDate]);
    }
    return NO;
}

- (NSUInteger)hash {
    return _eventManager.hash ^ _startDate.hash ^ _endDate.hash;
}

@end

@implementation SCKEventRequest (Private)

- (instancetype)initWithEventManager:(SCKEventManager*)eM startDate:(NSDate*)sD endDate:(NSDate*)eD {
    self = [super init];
    if (self) {
        _eventManager = eM;
        _startDate = [sD copy];
        _endDate = [eD copy];
    }
    return self;
}

@end
