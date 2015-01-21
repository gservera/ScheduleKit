//
//  SCKView.h
//  ScheduleKit
//
//  Created by Guillem on 24/12/14.
//  Copyright (c) 2014 Guillem Servera. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ScheduleKitDefinitions.h"

@class SCKEventManager, SCKEventView;
@interface SCKView : NSView {
    double _absoluteStartTimeRef;
    double _absoluteEndTimeRef;
    SCKEventView * _eventViewBeingDragged;
    NSArray * _otherEventViews;
}

- (void)prepare;
- (void)beginRelayout;
- (void)endRelayout;
- (void)relayoutEventView:(SCKEventView*)eventView animated:(BOOL)animation;
- (void)triggerRelayoutForEventViews:(NSArray*)eventViews animated:(BOOL)animation;
- (void)triggerRelayoutForAllEventViews;
- (void)markContentViewAsNeedingDisplay;

- (NSDate*)calculateDateForRelativeTimeLocation:(SCKRelativeTimeLocation)offset;
- (SCKRelativeTimeLocation)calculateRelativeTimeLocationForDate:(NSDate *)date;
- (SCKRelativeTimeLocation)relativeTimeLocationForPoint:(NSPoint)location;

@property (nonatomic, assign) BOOL relayoutInProgress;
@property (readonly) NSTimeInterval absoluteTimeInterval;
@property (nonatomic, strong) NSDate * startDate;
@property (nonatomic, strong) NSDate * endDate;
@property (nonatomic, assign) SCKEventColorMode colorMode;

@property (nonatomic, weak) SCKEventManager * eventManager;
@property (nonatomic, weak) SCKEventView * selectedEventView;
@end
