//
//  SCKEventRequest.h
//  ScheduleKit
//
//  Created by Guillem Servera on 16/7/15.
//  Copyright (c) 2015 Guillem Servera. All rights reserved.
//

@import Foundation;

@class SCKEventManager;

@interface SCKEventRequest : NSObject {
    BOOL _completed;
    BOOL _canceled;
}

- (void)cancel;
- (void)completeWithEvents:(NSArray*)events;

@property (nonatomic, weak) SCKEventManager *eventManager;
@property (nonatomic, copy) NSDate *startDate;
@property (nonatomic, copy) NSDate *endDate;
@end
