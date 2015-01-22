/*
 *  SCKEventHolder.h
 *  ScheduleKit
 *
 *  Created:    Guillem Servera on 24/12/2014.
 *  Copyright:  © 2014-2015 Guillem Servera (http://github.com/gservera)
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
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
 *  added to a view hierarchy. Can't be nil. */
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
 *    SCKEventManager's @c reloadData gets called instead. */
- (void)recalculateRelativeValues;

/** Indicates wether cached relative values are valid so drawing is safe.*/
@property (readonly, getter=isReady) BOOL ready;
@property (readonly, getter=isLocked) BOOL locked;
@property (readonly) id <SCKEvent> representedObject;
@property (readonly, weak) SCKEventView *owningView;

// Cached values
@property (assign) SCKRelativeTimeLocation cachedRelativeStart;
@property (assign) SCKRelativeTimeLocation cachedRelativeEnd;
@property (assign) SCKRelativeTimeLength cachedRelativeLength;
@property (strong) NSColor *cachedUserLabelColor;
@property (strong) NSString *cachedTitle;
@property (strong) NSDate *cachedScheduleDate;
@property (assign) NSInteger cachedDuration;
@end