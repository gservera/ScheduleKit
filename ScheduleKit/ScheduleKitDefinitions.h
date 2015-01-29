//
//  ScheduleKitDefinitions.h
//  ScheduleKit
//
//  Created by Guillem on 24/12/14.
//  Copyright (c) 2014 Guillem Servera. All rights reserved.
//

typedef double SCKRelativeTimeLocation;
typedef double SCKRelativeTimeLength;

#define SCKRelativeTimeLocationNotFound (double)NSNotFound

typedef NS_ENUM(NSUInteger, SCKEventColorMode) {
    SCKEventColorModeByEventType  = 0,
    SCKEventColorModeByEventOwner = 1
};


typedef NS_ENUM(NSInteger, SCKDraggingStatus) {
    SCKDraggingStatusIlde             = -1,
    SCKDraggingStatusDraggingDuration =  1,
    SCKDraggingStatusDraggingContent  =  2
};

typedef struct SCKActionContext {
    SCKDraggingStatus status;
    BOOL doubleClick;
    NSInteger oldDuration, lastDuration, newDuration;
    SCKRelativeTimeLocation oldRelativeStart, newRelativeStart;
    CGFloat internalDelta;
    NSTimeInterval oldDateRef;
} SCKActionContext;

SCKActionContext SCKActionContextZero();