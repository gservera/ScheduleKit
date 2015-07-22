//
//  SCKEventManagerPrivate.h
//  ScheduleKit
//
//  Created by Guillem on 14/1/15.
//  Copyright (c) 2015 Guillem Servera. All rights reserved.
//

#import "SCKEventManager.h"
#import "SCKEventRequest.h"

@interface SCKEventManager (Private)

- (NSMutableArray*)asynchronousEventRequests;
- (NSArray*)managedEventHolders;
- (void)reloadDataWithAsynchronouslyLoadedEvents:(NSArray*)events request:(SCKEventRequest*)req;

@end