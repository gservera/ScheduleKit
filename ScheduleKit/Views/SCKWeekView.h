//
//  SCKWeekView.h
//  ScheduleKit
//
//  Created by Guillem on 31/12/14.
//  Copyright (c) 2014 Guillem Servera. All rights reserved.
//

#import "SCKGridView.h"

@class SCKWeekView, SCKDayPoint;

@protocol SCKWeekViewDelegate <SCKGridViewDelegate>
- (NSInteger)dayStartHourForWeekView:(SCKWeekView*)wView;
- (NSInteger)dayEndHourForWeekView:(SCKWeekView*)wView;
@optional
- (NSInteger)dayCountForWeekView:(SCKWeekView*)wView;
@end


@interface SCKWeekView : SCKGridView {
    SCKDayPoint *_dayStartPoint;
    SCKDayPoint *_dayEndPoint;
}



- (IBAction)increaseWeekOffset:(id)sender;
- (IBAction)decreaseWeekOffset:(id)sender;
- (IBAction)resetWeekOffset:(id)sender;

@property (nonatomic, weak) id <SCKWeekViewDelegate> delegate;
@end
