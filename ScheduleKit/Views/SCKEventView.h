//
//  SCKEventView.h
//  ScheduleKit
//
//  Created by Guillem on 24/12/14.
//  Copyright (c) 2014 Guillem Servera. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SCKEventHolder.h"
#import "ScheduleKitDefinitions.h"
#import "SCKTextField.h"

@interface SCKEventView : NSView {
    SCKActionContext _actionContext;
}

+ (NSColor*)colorForEventType:(SCKEventType)type;
+ (NSColor*)strokeColorForEventType:(SCKEventType)type;

- (void)prepareForRelayout;

@property (nonatomic, assign) BOOL layoutDone;
@property (nonatomic, strong) SCKEventHolder * eventHolder;
@property (nonatomic, strong) SCKTextField * innerLabel;
@end
