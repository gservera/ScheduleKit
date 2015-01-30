/*
 *  SCKViewPrivate.h
 *  ScheduleKit
 *
 *  Created:    Guillem Servera on 28/01/2015.
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

#import "SCKView.h"

@class SCKEventView;

@interface SCKView (Private)

/** Convenienve method called from both @c -initWithCoder: and @c
 *  -initWithFrame. Default implementation initializes an array used to
 *  store the @c SCKEventView subviews contained in this view.
 *  @discussion You should always call super when subclassing. */
- (void)customInit;

#pragma mark - Subview management

/**
 *  Adds an SCKEventView to the array of subviews managed by this
 *  instance. This method is typically called from the event manager.
 *  @param eventView The view to be added. Must already be a subview of self.
 */
- (void)addEventView:(SCKEventView*)eventView;

/**
 *  Removes an SCKEventView from the array of subviews managed by
 *  this instance. This method is typically called from the event manager.
 *  @param eventView The view to be removed. 
 *  @discussion @c -removeFromSuperview should also be called on @c eventView.
 */
- (void)removeEventView:(SCKEventView*)eventView;

#pragma mark - Drag & drop support

/**
 *  Called from an @c SCKEventView subview when a drag action begins.
 *  This method sets @c _eventViewBeingDragged and @c _otherEventViews,
 *  and also calls @c -lock on the event view's event holder.
 *  @discussion Locking and unlocking for SCKEventView subviews being dragged are
 *  handled here (and not during successive relayout processes) in order to avoid
 *  inconsistencies between the drag & drop action and changes that could be
 *  observed while the @c SCKEventView is being dragged.
 *  @param eV The @c SCKEventView being dragged.
 */
- (void)beginDraggingEventView:(SCKEventView*)eV;

/**
 *  Called from an @c SCKEventView subview when a drag action moves.
 *  This method sets this view as needing display (to make dragging guides appear)
 *  and triggers a relayout for other event views (since conflicts may have changed).
 *  @param eV The @c SCKEventView being dragged.
 */
- (void)continueDraggingEventView:(SCKEventView*)eV;

/**
 *  Called from an @c SCKEventView subview when a drag action ends.
 *  This method clears @c _eventViewBeingDragged and @c _otherEventViews,
 *  calls @c -unlock on the event view's event holder, triggers a final relayout
 *  and finally sets this view as needing display (to clear dragging guides).
 *  @discussion Locking and unlocking for SCKEventView subviews being dragged are
 *  handled here (and not during successive relayout processes) in order to avoid
 *  inconsistencies between the drag & drop action and changes that could be
 *  observed while the @c SCKEventView is being dragged.
 *  @param eV The @c SCKEventView being dragged.
 */
- (void)endDraggingEventView:(SCKEventView*)eV;

#pragma mark - Event view layout

/**
 *  This method is called when a relayout is triggered. You may override it to 
 *  perform additional tasks before the actual relayout process takes place. In
 *  that case, you must call super.
 */
- (void)beginRelayout;

/**
 *  SCKView subclasses override this method to implement positioning (updating
 *  frame) of their SCKEventView subviews when a relayout process is triggered.
 *  The ultimate objective of this method is to calculate a new frame for a
 *  concrete subview based on the properties of its holder. Conflict calculations
 *  should also be performed here. Default implementation does nothing.
 *
 *  @param eventView The event view whose frame needs to be updated.
 *  @param animation YES if change should be animated, NO instead.
 */
- (void)relayoutEventView:(SCKEventView*)eventView animated:(BOOL)animation;

/**
 *  This method is called when a relayout finishes. You may override it to
 *  perform additional tasks after the actual relayout process takes place. In
 *  that case, you must call super.
 */
- (void)endRelayout;

@end