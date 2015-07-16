//
//  SCKEventRequestPrivate.h
//  ScheduleKit
//
//  Created by Guillem Servera on 16/7/15.
//  Copyright (c) 2015 Guillem Servera. All rights reserved.
//

#import "SCKEventRequest.h"

@class SCKEventManager;
@interface SCKEventRequest (Private)

- (instancetype)initWithEventManager:(SCKEventManager*)eM
                           startDate:(NSDate*)date
                             endDate:(NSDate*)date;

@end