/*
 *  SCKView.h
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

#import "SCKEventView.h"

@class SCKEventManager;

/** SCKView is an abstract NSView subclass which implements common functionality for any
  * subclasses that display a collection of @c SCKEventView subviews provided by the
  * delegate of an associated @c SCKEventManager object. This base class provides:
  * - Basic date scope management via @c startDate, @c endDate and @c absoluteTimeInterval.
  * - Functional conversion between @c NSDate and @c SCKRelativeTimeLocation values, and
  *   also the @c relativeTimeLocationForPoint: which subclasses should override.
  * - Ability to get/set the coloring policy used to draw subviews' background.
  * - Basic event selection and deselection handling.
  * - Handling of double click on an empty space.
  * - Drag and drop feedback methods for SCKEventView class.
  * - Common event view (un)locking and relayout workflow.
  */
@interface SCKView : NSView {
    double _absoluteStartTimeRef; /**< Absolute value for @c startDate */
    double _absoluteEndTimeRef; /**< Absolute value for @c endDate */
    NSMutableArray * _eventViews; /**< SCKEventView subviews */
    SCKEventView * _eventViewBeingDragged; /**< When dragging, the subview being dragged */
    NSArray * _otherEventViews; /**< When dragging, SCKEventView(s) NOT being dragged */
}

#pragma mark - Time-based calculations

/** 
 *  Calculates the date represented by a specific relative time location between @c
 *  startDate and @c endDate. Note that seconds are rounded so they'll be zero.
 *  @param offset The relative time location. Should be a value between 0.0 and 1.0.
 *  @return The calculated NSDate object or nil if @c offset is not valid.
 */
- (NSDate*)calculateDateForRelativeTimeLocation:(SCKRelativeTimeLocation)offset;


/**
 *  Calculates the relative time location between @c startDate and @c endDate for a given
 *  NSDate object.
 *
 *  @param date The date from which to perform the calculation. Should not be nil.
 *  @return A double value between 0.0 and 1.0 representing the relative position of @c
 *  date between @c startDate and @c endDate; or @c SCKRelativeTimeLocationNotFound if @c
 *  date is before @c startDate or after @c endDate.
 */
- (SCKRelativeTimeLocation)calculateRelativeTimeLocationForDate:(NSDate *)date;

/**
 *  Calculates the relative time location between @c startDate and @c for a given point
 *  inside the view coordinates. Default implementation always returns
 *  SCKRelativeLocationNotFound, consider overriding this method in subclasses.
 *
 *  @param location The NSPoint for which to perform the calculation.
 *  @return In subclasses, a double value between 0.0 and 1.0 representing the relative 
 *  position of @c location between @c startDate and @c endDate; or @c 
 *  SCKRelativeTimeLocationNotFound if @c location falls out of the content rect.
 */
- (SCKRelativeTimeLocation)relativeTimeLocationForPoint:(NSPoint)location;

#pragma mark - Event view layout

/**
 *  This methods performs a series of operations in order to relayout an array of
 *  SCKEventView objects according to their date, duration and other events in conflict.
 *  The full process implies locking all subviews' event holder (as to prevent changes
 *  on their properties while conflict calculations take place), calling
 *  @c relayoutEventView:animated: for each SCKEventView in @c eventViews and finally
 *  unlocking the previously locked event holders.
 *
 *  @discussion When an event view is being dragged, its event holder does not get locked 
 *  or unlocked.
 *  @discussion Don't override this method. See @c beginRelayout and @c endRelayout instead.
 *
 *  @param eventViews The array of SCKEventView objects to be redrawn.
 *  @param animation  Pass YES if you want relayout to have animation. Pass no instead.
 */
- (void)triggerRelayoutForEventViews:(NSArray*)eventViews animated:(BOOL)animation;

/**
 *  Calls @c triggerRelayoutForEventViews:animated: passing all event views and NO as 
 *  parameters.
 */
- (void)triggerRelayoutForAllEventViews;

#pragma mark - Properties

/** This property is set to YES when a relayout has been triggered and back to NO when the
    process finishes. Mind that relayout methods are invoked quite often. */
@property (readonly) BOOL relayoutInProgress;

/** Returns the number of seconds between @c startDate and @c endDate. */
@property (readonly) NSTimeInterval absoluteTimeInterval;

/** The minimum date being repesented. Setter sets view as needing display. Call super. */
@property (nonatomic, strong) NSDate * startDate;

/** The maximum date being repesented. Setter sets view as needing display. Call super. */
@property (nonatomic, strong) NSDate * endDate;

/** The style used by subviews to draw their background. @see ScheduleKitDefinitions.h */
@property (nonatomic, assign) SCKEventColorMode colorMode;

@property (nonatomic, weak) SCKEventView * selectedEventView;
@property (nonatomic, weak) IBOutlet SCKEventManager * eventManager;
@end
