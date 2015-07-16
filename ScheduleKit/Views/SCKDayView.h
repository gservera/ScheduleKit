//
//  SCKDayView.h
//  ScheduleKit
//
//  Created by Guillem on 31/12/14.
//  Copyright (c) 2014 Guillem Servera. All rights reserved.
//

#import "SCKGridView.h"

@interface SCKDayView : SCKGridView

- (IBAction)increaseDayOffset:(id)sender;
- (IBAction)decreaseDayOffset:(id)sender;
- (IBAction)resetDayOffset:(id)sender;

@end
