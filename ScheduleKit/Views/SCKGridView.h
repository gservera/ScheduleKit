//
//  SCKGridView.h
//  ScheduleKit
//
//  Created by Guillem on 30/12/14.
//  Copyright (c) 2014 Guillem Servera. All rights reserved.
//

#import "SCKView.h"
#import "SCKUnavailableTimeRange.h"

@class SCKGridView;

@protocol SCKGridViewDelegate <NSObject>
@optional
- (NSArray*)unavailableTimeRangesForGridView:(SCKGridView*)view;
@end

@interface SCKGridView : SCKView {
    NSCalendar * _calendar;
    NSTimer *_minuteTimer;
    NSArray *_unavailableTimeRanges;
    NSInteger _dayCount;
    NSInteger _hourCount;
    NSInteger _firstHour;
    
    NSDateFormatter * _dayLabelDateFormatter;
    NSDateFormatter * _monthLabelDateFormatter;
}

- (void)readDefaultsFromDelegate;
- (void)invalidateUserDefaults;


- (NSRect)rectForUnavailableTimeRange:(SCKUnavailableTimeRange*)rng;

- (IBAction)increaseZoomFactor:(id)sender;
- (IBAction)decreaseZoomFactor:(id)sender;

@property (nonatomic, weak) id <SCKGridViewDelegate> delegate;
@property (nonatomic, assign) CGFloat hourHeight;
@property (readonly) NSRect contentRect;
@end
