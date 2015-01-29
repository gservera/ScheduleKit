//
//  SCKViewPrivate.h
//  ScheduleKit
//
//  Created by Guillem on 28/1/15.
//  Copyright (c) 2015 Guillem Servera. All rights reserved.
//

#import "SCKView.h"

@class SCKEventView;

@interface SCKView (Private)

/** Convenienve method called from both @c -initWithCoder: and @c
 *  -initWithFrame. Default implementation registers self to be notified
 *  when frame changes in order to be able to relayout event views.
 *  @discussion You should always call super when subclassing. */
- (void)customInit;

- (void)addEventView:(SCKEventView*)eventView;
- (void)removeEventView:(SCKEventView*)eventView;

- (void)relayoutEventView:(SCKEventView*)eventView animated:(BOOL)animation;


- (void)beginRelayout;
- (void)endRelayout;

- (void)beginDraggingEventView:(SCKEventView*)eV;
- (void)continueDraggingEventView:(SCKEventView*)eV;
- (void)endDraggingEventView:(SCKEventView*)eV;

@end