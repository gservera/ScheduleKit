//
//  EventLoadingView.m
//  ScheduleKit
//
//  Created by Guillem Servera on 16/7/15.
//  Copyright (c) 2015 Guillem Servera. All rights reserved.
//

#import "EventLoadingView.h"

@implementation EventLoadingView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [[NSColor colorWithCalibratedWhite:1.0 alpha:1.0] set];
    NSRectFill(self.bounds);
    
    NSString *loadingStr = @"Loading events...";
    NSDictionary *attrs = @{NSFontAttributeName:[NSFont systemFontOfSize:22.0]};
    NSSize size = [loadingStr sizeWithAttributes:attrs];
    NSPoint dPoint = NSMakePoint(NSMidX(self.bounds)-size.width/2, NSMidY(self.bounds)-size.height/2);
    [loadingStr drawAtPoint:dPoint withAttributes:attrs];
}

@end
