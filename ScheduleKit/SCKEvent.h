//
//  SCKEvent.h
//  ScheduleKit
//
//  Created by Guillem on 24/12/14.
//  Copyright (c) 2014 Guillem Servera. All rights reserved.
//

@import Cocoa;

typedef NS_ENUM(NSUInteger, SCKEventType) {
    SCKEventTypeDefault = 0,
    SCKEventTypeSession = 1,
    SCKEventTypeSurgery = 2,
    SCKEventTypeSpecial = 3
};

@protocol SCKUser <NSObject>

- (NSColor*)labelColor;

@end

@protocol SCKEvent <NSObject>

- (SCKEventType)eventType;
- (id <SCKUser>)user;
- (id)patient;
- (NSString*)title;
- (NSNumber*)duration;
- (void)setDuration:(NSNumber*)duration;
- (NSDate*)scheduledDate;
- (void)setScheduledDate:(NSDate*)scheduledDate;

@end
