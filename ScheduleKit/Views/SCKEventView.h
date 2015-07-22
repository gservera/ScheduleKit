/*
 *  SCKEventView.h
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

#import "SCKEventHolder.h"
#import "SCKTextField.h"

/** SCKEventView is the NSView subclass used to display events as subviews of
  * an SCKView instance. Its functions include:
  * - Managing an inner label (SCKTextField subclass) which shows info about
  *   the represented event and drag and drop actions.
  * - Handling click, double click and drag and drop events to allow selection
  *   and conditional modification of the represented object's duration and/or
  *   scheduledDate. 
  */
@interface SCKEventView : NSView {
@private
    SCKActionContext _actionContext;
}

/** Called from @c -drawRect when superview's @c colorMode is set to 
  * `SCKEventColorModeByEventType`. Returns a different fill color for each
  * value defined in the `SCKEventType` enum.
  * 
  * @param type The type for which to return a fill color
  * @return The fill color for events of type `type`.
  */
+ (nonnull NSColor*)colorForEventType:(SCKEventType)type;

/** Called from @c -drawRect when superview's @c colorMode is set to
 * `SCKEventColorModeByEventType`. Returns a different stroke color for each
 * value defined in the `SCKEventType` enum.
 *
 * @param type The type for which to return a stroke color
 * @return The stroke color for events of type `type`.
 */
+ (nonnull NSColor*)strokeColorForEventType:(SCKEventType)type;

/** Sent to all SCKEventView's in a SCKView instance before
  * scheduling a redistribution process (movement of overlapping
  * events. TODO: The whole redistribution process should be
  * improved. */
- (void)prepareForRedistribution;

/** Indicates whether the view has passed the redistribution process. */
@property (nonatomic, assign) BOOL layoutDone;

/** The view's represented event holder */
@property (nonatomic, strong, nonnull) SCKEventHolder * eventHolder;

/** The view's inner label */
@property (nonatomic, strong, nonnull) SCKTextField * innerLabel;
@end
