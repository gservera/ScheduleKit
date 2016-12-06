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
    [_scheduleController.scheduleView setDelegate:self];
    [self addChildViewController:_scheduleController];
}

- (void)viewWillAppear {
    [super viewWillAppear];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *dayBeginning = [calendar dateBySettingHour:0 minute:0 second:0 ofDate:[NSDate date] options:0];
    NSDate *dayEnding = [calendar dateBySettingHour:23 minute:59 second:59 ofDate:[NSDate date] options:0];
    NSDateInterval *interval = [[NSDateInterval alloc] initWithStartDate:dayBeginning endDate:dayEnding];
    [_scheduleController.scheduleView setDateInterval:interval];
    [_scheduleController.scheduleView setColorMode:SCKEventColorModeByEventOwner];
    [_scheduleController reloadData];
    [_scheduleController.scheduleView setNeedsDisplay:YES];
}

- (void)viewDidAppear {
    NSWindow *window = [self.view window];
    [window setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantLight]];
    [window setTitlebarAppearsTransparent:YES];
    [window setTitleVisibility:NSWindowTitleHidden];
    [super viewDidAppear];
}

- (NSArray<id<SCKEvent>> *)eventsIn:(NSDateInterval *)dateInterval
                                for:(SCKViewController *)controller {
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"scheduledDate BETWEEN %@",@[dateInterval.startDate,dateInterval.endDate]];
    NSArray *events = [[[EventEngine sharedEngine] events] filteredArrayUsingPredicate:filter];
    return events;
}

#pragma mark - SCKGridView Delegate

- (NSInteger)dayStartHourForGridView:(SCKGridView *)gridView {
    return 7;
}

- (NSInteger)dayEndHourForGridView:(SCKGridView *)gridView {
    return 19;
}

@end
