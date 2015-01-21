/*
 *  SCKEventHolder.h
 *  ScheduleKit
 *
 *  Created:    Guillem Servera on 24/12/2014.
 *  Copyright:  © 2014-2015 Guillem Servera. All rights reserved.
 */

#import "SCKEvent.h"
#import "ScheduleKitDefinitions.h"

@class SCKEventView;

/** Instances of this class work in conjunction with an @c SCKEventView
 *  representing an object conforming to the @c SCKEvent protocol. */
@interface SCKEventHolder : NSObject

/**
 *  SCKEventHolder designated initializer. Sets up a new instance
 *  representing any object conforming to the @c SCKEvent protocol
 *  for the specified @c SCKEventView.
 *
 *  @param e The represented object. Can't be nil.
 *  @param v The owning view for this instance. Must have been already
 *  added to a view hierarchy. Can't be nil. 
 */
- (instancetype)initWithEvent:(id <SCKEvent>)e owner:(SCKEventView*)v;

/**
 *  Stops observing changes in represented object. Called by SCKView
 *  on every @c SCKEventHolder object at the beginning of a relayout or 
 *  drag to prevent conflict-related errors in case these properties
 *  change during the process. Also called by SCKEventManager before
 *  invalidating an instance. Don't call this method yourself. */
- (void)lock;


/**
 *  Resumes observing changes in represented object. Called by SCKView
 *  on every @c SCKEventHolder item at the end of a relayout or drag
 *  to prevent conflict-related errors in case these properties change
 *  during the process. Don't call this method yourself. 
 *  @discussion TODO: Changes between the @c lock: and the @c unlock: 
 *  calls are not being processed by now. */
- (void)unlock;


/**
 *  Recalculates @c cachedRelativeStart, @c cachedRelativeEnd and @c
 *  cachedRelativeLength according to the values set for properties
 *  @c duration and @c scheduledDate, based on the owning view limits
 *  (@c startDate and @c endDate). This  is called automatically:
 *  - Immediatly after initialization.
 *  - Whenever @c scheduledDate and/or @c duration change if unlocked.
 *  - When the owning view ends either content or duration dragging.
 *  - NOT when owningView's @c startDate or @endDate change, because 
 *    SCKEventManager's @c reloadData gets called instead. 
 */
- (void)recalculateRelativeValues;

@property (readonly, getter=isReady) BOOL ready;
@property (readonly, getter=isLocked) BOOL locked;
@property (readonly) id <SCKEvent> representedObject;
@property (weak) SCKEventView * owningView;

@property (assign) SCKRelativeTimeLocation cachedRelativeStart;
@property (assign) SCKRelativeTimeLocation cachedRelativeEnd;
@property (assign) SCKRelativeTimeLength   cachedRelativeLength;
@property (readonly) NSColor  * cachedUserLabelColor;
@property (strong) NSString * cachedTitle;
@property (strong) NSDate   * cachedScheduleDate;
@property (strong) NSNumber * cachedDuration;
@end
