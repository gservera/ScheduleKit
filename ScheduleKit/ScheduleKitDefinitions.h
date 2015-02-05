/*
 *  ScheduleKitDefinitions.h
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

/** A type to represent relative time points between the lower and upper limits in a
 @c SCKView subclass, where a value of 0.0 represents the lower limit and a value of
 1.0 represents the upper limit. */
typedef double SCKRelativeTimeLocation;

/** A type to represent the relative length (in percentage) of an event in a concrete
 @c SCKView subclass. */
typedef double SCKRelativeTimeLength;

/** Used to represent not found or invalid @c SCKRelativeTimeLocation values */
#define SCKRelativeTimeLocationNotFound (SCKRelativeTimeLocation)NSNotFound

/** Possible color styles for drawing event view background. */
typedef NS_ENUM(NSUInteger, SCKEventColorMode){
    /** The 'by event type' mode sets event views' background color according to their
     *  event holder's event type. */
    SCKEventColorModeByEventType  = 0,
    /** The 'by event owner' mode sets event views' background color according to the
     *  label color of their event holder's user. */
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
    NSInteger oldDuration;
    NSInteger lastDuration;
    NSInteger newDuration;
    SCKRelativeTimeLocation oldRelativeStart;
    SCKRelativeTimeLocation newRelativeStart;
    CGFloat internalDelta;
    NSTimeInterval oldDateRef;
} SCKActionContext;

/** Initializes a new SCKActionContext with all values set to zero. */
SCKActionContext SCKActionContextZero();