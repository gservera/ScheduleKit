//
//  WhiteView.m
//  ScheduleKit
//
//  Created by Guillem on 14/1/15.
//  Copyright (c) 2015 Guillem Servera. All rights reserved.
//

#import "WhiteView.h"

@implementation WhiteView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [[NSColor whiteColor] set];
    NSRectFill(dirtyRect);
    
    [[NSColor lightGrayColor] setFill];
    NSRectFill(NSMakeRect(0.0, _dividerPosition, self.frame.size.width, 0.5));
}

@end
