//
//  SCKEventHolder.h
//  ScheduleKit
//
//  Created by Guillem on 24/12/14.
//  Copyright (c) 2014 Guillem Servera. All rights reserved.
//

#import "SCKEvent.h"
#import "ScheduleKitDefinitions.h"

@class SCKEventView;
@interface SCKEventHolder : NSObject 

- (instancetype)initWithEvent:(id <SCKEvent>)e owner:(SCKEventView*)v;
- (void)reset;

- (void)lock;
- (void)unlock;
- (void)recalculateRelativeValues;

@property (readonly) BOOL ready;
@property (readonly) BOOL locked;
@property (nonatomic, weak) id <SCKEvent> representedObject;
@property (weak) SCKEventView * owningView;

@property (assign) SCKRelativeTimeLocation cachedRelativeStart;
@property (assign) SCKRelativeTimeLocation cachedRelativeEnd;
@property (assign) SCKRelativeTimeLength   cachedRelativeLength;
@property (copy) NSColor  * cachedUserLabelColor;
@property (copy) NSString * cachedTitle;
@property (copy) NSDate   * cachedScheduleDate;
@property (copy) NSNumber * cachedDuration;

@end
