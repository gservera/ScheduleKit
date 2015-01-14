//
//  NSView+SKCAdditions.m
//  ScheduleKit
//
//  Created by Guillem on 24/12/14.
//  Copyright (c) 2014 Guillem Servera. All rights reserved.
//

#import "NSView+SKCAdditions.h"

@implementation NSView (SKCAdditions)

- (void)markAsNeedingDisplay {
    self.needsDisplay = YES;
}

- (void)hide {
    self.hidden = YES;
}

- (void)unhide {
    self.hidden = NO;
}

@end
