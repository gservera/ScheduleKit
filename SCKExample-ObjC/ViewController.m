//
//  ViewController.m
//  SCKExample-ObjC
//
//  Created by Guillem Servera Negre on 14/11/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

#import "ViewController.h"
#import "EventEngine.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_scheduleController setObjCDelegate:self];
    [self addChildViewController:_scheduleController];
}

- (void)viewWillAppear {
    [super viewWillAppear];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *dayBeginning = [calendar dateBySettingHour:7 minute:0 second:0 ofDate:[NSDate date] options:0];
    NSDate *dayEnding = [calendar dateBySettingHour:18 minute:0 second:0 ofDate:[NSDate date] options:0];
    [_scheduleController.scheduleView setDateBoundsWithLower:dayBeginning upper:dayEnding];
    [_scheduleController.scheduleView setColorMode:SCKEventColorModeByEventOwner];
    [_scheduleController reloadData];
    [_scheduleController.scheduleView setNeedsDisplay:YES];
    [_scheduleController useDayMode];
}

- (NSArray<id <SCKEvent>> * _Nonnull)eventsFrom:(NSDate * _Nonnull)startDate to:(NSDate * _Nonnull)endDate for:(SCKViewController * _Nonnull)controller {
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"scheduledDate BETWEEN %@",@[startDate,endDate]];
    NSArray *events = [[[EventEngine sharedEngine] events] filteredArrayUsingPredicate:filter];
    return events;
}

@end
