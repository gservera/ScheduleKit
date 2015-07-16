//
//  SCKEventRequest.h
//  ScheduleKit
//
//  Created by Guillem Servera on 16/7/15.
//  Copyright (c) 2015 Guillem Servera. All rights reserved.
//

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

/** The SCKEventManager object that issued the request */
@property (nonnull, readonly, weak) SCKEventManager *eventManager;
/** The requested start date parameter for the event fetch criteria */
@property (nonnull, readonly, strong) NSDate *startDate;
/** The requested end date parameter for the event fetch criteria */
@property (nonnull, readonly, strong) NSDate *endDate;
@end
