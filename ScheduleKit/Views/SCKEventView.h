//
//  SCKEventView.h
//  ScheduleKit
//
//  Created by Guillem on 24/12/14.
//  Copyright (c) 2014 Guillem Servera. All rights reserved.
//

#import "SCKEventHolder.h"
#import "SCKTextField.h"

@interface SCKEventView : NSView {
@private
    SCKActionContext _actionContext;
}

+ (NSColor*)colorForEventType:(SCKEventType)type;
+ (NSColor*)strokeColorForEventType:(SCKEventType)type;

- (void)prepareForRedistribution;

@property (nonatomic, assign) BOOL layoutDone;
@property (nonatomic, strong) SCKEventHolder * eventHolder;
@property (nonatomic, strong) SCKTextField * innerLabel;
@end
