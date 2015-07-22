/*
 *  SCKEventRequest.h
 *  ScheduleKit
 *
 *  Created:    Guillem Servera on 16/07/2015.
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

@import Foundation;

@class SCKEventManager;

/**
 *  The SCKEventRequest class represents a structure used by an
 *  SCKEventManager object to encapsulate relevant info and to handle
 *  new events when reloading events asynchronously.
 *
 *  Asynchronous event loading is disabled by default. You may enable it
 *  by setting SCKEventManager's @c loadsEventsAsynchronously to YES. When
 *  this is set, @c -eventManager:requestsEventsBetweenDate:andDate:  won't 
 *  be called on data source. Instead, @c -eventManager:didMakeEventRequest:
 *  will get called with an SCKEventRequest object as a parameter. Then, the
 *  data source is responsible of keeping a (weak) reference to this
 *  request, loading the apropiated events asynchronously and, when done,
 *  passing them back to the request via @c -completeWithEvents: on the
 *  main queue.
 */
@interface SCKEventRequest : NSObject

/**
 *  Cancels the request if not canceled yet. This will make it ignore any
 *  @c -completeWithEvents: calls made afterwards. Additionally, the request
 *  will be released by its owning SCKEventManager (If you don't own any 
 *  strong references to it, it will be deallocated and your weak references
 *  will become nil.
 */
- (void)cancel;

/**
 *  If not cancelled, completes the request passing the provided events back
 *  to the owning SCKEventManager. Any future call to this method will be 
 *  ignored. Additionally, the request will be released by its owning
 *  SCKEventManager (If you don't own any strong references to it, it will
 *  be deallocated and your weak references will become nil.
 *
 *  @warning This method MUST be called from the main thread.
 *  @param events The asynchronously loaded events.
 */
- (void)completeWithEvents:(nonnull NSArray*)events;

/** Returns whether the request has been canceled */
@property (readonly, assign, getter=isCanceled) BOOL canceled;
/** The SCKEventManager object that issued the request */
@property (readonly, weak, nullable) SCKEventManager *eventManager;
/** The requested start date parameter for the event fetch criteria */
@property (readonly, strong, nonnull) NSDate *startDate;
/** The requested end date parameter for the event fetch criteria */
@property (readonly, strong, nonnull) NSDate *endDate;
@end
