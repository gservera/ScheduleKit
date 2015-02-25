//
//  AppDelegate.m
//  SCKTester
//
//  Created by Guillem on 12/1/15.
//  Copyright (c) 2015 Guillem Servera. All rights reserved.
//

#import "AppDelegate.h"
#import "TestUser.h"
#import "TestEvent.h"

@implementation AppDelegate

- (instancetype)init {
    self = [super init];
    if (self) {
        __users = @[[[TestUser alloc] initWithName:@"Dr. Test 1" color:[NSColor colorWithCalibratedRed:0.9 green:0.65 blue:0.4 alpha:1.0]],[[TestUser alloc] initWithName:@"Dr. Test 2" color:[NSColor colorWithCalibratedRed:0.4 green:0.65 blue:0.9 alpha:1.0]]];
        _users = [NSMutableArray new];
        _eventArray = [[NSMutableArray alloc] initWithArray:[TestEvent sampleEvents:__users]];
        _reloadingDayData = NO;
        _reloadingWeekData = NO;
        _showsSaturdays = YES;
        _showsSundays = YES;
        _dayStartHour = 8;
        _dayEndHour = 20;
        _calendarViewSelection = [NSDate date];
    }
    return self;
}

- (id<SCKEvent>)selectedEvent {
    if (_tableView.selectedRow == -1) {
        return nil;
    } else {
        return _eventArray[_tableView.selectedRow];
    }
}

- (void)setShowsSaturdays:(BOOL)showsSaturdays {
    _showsSaturdays = showsSaturdays;
    [(SCKGridView*)_weekEventManager.view invalidateUserDefaults];
}

- (void)setShowsSundays:(BOOL)showsSundays {
    _showsSundays = showsSundays;
    [(SCKGridView*)_weekEventManager.view invalidateUserDefaults];
}

- (void)setDayStartHour:(NSInteger)dayStartHour {
    _dayStartHour = dayStartHour;
    [(SCKGridView*)_weekEventManager.view invalidateUserDefaults];
}

- (void)setDayEndHour:(NSInteger)dayEndHour {
    _dayEndHour = dayEndHour;
    [(SCKGridView*)_weekEventManager.view invalidateUserDefaults];
}

- (void)setCalendarViewSelection:(NSDate *)calendarViewSelection {
    _calendarViewSelection = calendarViewSelection;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [(SCKView*)_dayEventManager.view setStartDate:[calendar dateBySettingHour:7 minute:0 second:0 ofDate:calendarViewSelection options:0]];
    [(SCKView*)_dayEventManager.view setEndDate:[calendar dateBySettingHour:23 minute:0 second:0 ofDate:calendarViewSelection options:0]];
    [_dayEventManager reloadData];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *dayBeginning = [cal dateBySettingHour:7 minute:0 second:0 ofDate:[NSDate date] options:0];
    NSDate *dayEnding = [cal dateBySettingHour:17 minute:0 second:0 ofDate:[NSDate date] options:0];
    _dayEventManager.view.startDate = dayBeginning;
    _dayEventManager.view.endDate = dayEnding;
    _dayEventManager.dataSource = self;
    _dayEventManager.delegate = self;
    [_dayEventManager reloadData];
    [(SCKGridView*)_dayEventManager.view setDelegate:self];
    
    NSDate *weekBeginning;
    [cal rangeOfUnit:NSCalendarUnitWeekOfYear startDate:&weekBeginning interval:nil forDate:[NSDate date]];
    NSDate *weekEnging = [cal dateByAddingUnit:NSCalendarUnitWeekOfYear value:1 toDate:weekBeginning options:0];
    _weekEventManager.view.startDate = weekBeginning;
    _weekEventManager.view.endDate = weekEnging;
    _weekEventManager.dataSource = self;
    _weekEventManager.delegate = self;
    [_weekEventManager reloadData];
    [(SCKGridView*)_weekEventManager.view setDelegate:self];
    
    [_dayEventArrayController addObserver:self forKeyPath:@"arrangedObjects.count" options:NSKeyValueObservingOptionNew context:nil];
    [_weekEventArrayController addObserver:self forKeyPath:@"arrangedObjects.count" options:NSKeyValueObservingOptionNew context:nil];
    
    [_eventArray[5] performSelector:@selector(setScheduledDate:) withObject:[_eventArray[3] scheduledDate ] afterDelay:4];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == _dayEventArrayController && !_reloadingDayData) {
        [_dayEventManager reloadData];
    } else if (object == _weekEventArrayController && !_reloadingWeekData) {
        [_weekEventManager reloadData];
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (IBAction)addEvent:(id)sender {
    [self willChangeValueForKey:@"eventArray"];
    [_eventArray addObject:[[TestEvent alloc] initWithType:SCKEventTypeDefault user:__users[1] patient:nil title:@"New event" duration:60 date:[NSDate date]]];
    [self didChangeValueForKey:@"eventArray"];
    [_tableView reloadData];
}

- (IBAction)removeEvent:(id)sender {
    if ([self selectedEvent]) {
        [self willChangeValueForKey:@"eventArray"];
        [_eventArray removeObject:[self selectedEvent]];
        [self didChangeValueForKey:@"eventArray"];
        [_tableView reloadData];
    }
}

- (IBAction)toggleUser:(NSButton*)sender {
    NSTableCellView *superv = (NSTableCellView*)[sender superview];
    TestEvent *event = [superv objectValue];
    if (event.user == __users[0]) {
        event.user = __users[1];
    } else {
        event.user = __users[0];
    }
}

- (IBAction)setColorMode:(NSPopUpButton*)sender {
    _dayEventManager.view.colorMode = sender.indexOfSelectedItem;
    _weekEventManager.view.colorMode = sender.indexOfSelectedItem;
}

- (IBAction)toggleSettingsPopover:(id)sender {
    if ([_settingsPopover isShown]) {
        [_settingsPopover close];
    } else {
        [_settingsPopover showRelativeToRect:[sender frame] ofView:[sender superview] preferredEdge:NSMaxYEdge];
    }
}

- (IBAction)toggleCalendarPopover:(id)sender {
    if ([_calendarPopover isShown]) {
        [_calendarPopover close];
    } else {
        [_calendarPopover showRelativeToRect:[sender frame] ofView:[sender superview] preferredEdge:NSMaxYEdge];
    }
}

#pragma mark - NSTableView Data Source Protocol

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _eventArray.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return _eventArray[row];
}

#pragma mark - SCKEventManager Data Source

- (NSArray *)eventManager:(SCKEventManager *)eM requestsEventsBetweenDate:(NSDate *)sD andDate:(NSDate *)eD {
    if (eM == _dayEventManager) {
        _reloadingDayData = YES;
        _dayEventArrayController.filterPredicate = [NSPredicate predicateWithFormat:@"scheduledDate BETWEEN %@",@[sD,eD]];
        [_dayEventArrayController rearrangeObjects];
        _reloadingDayData = NO;
        NSLog(@"DayEventManager: %lu events",[_dayEventArrayController.arrangedObjects count]);
        return _dayEventArrayController.arrangedObjects;
    } else {
        _reloadingWeekData = YES;
        _weekEventArrayController.filterPredicate = [NSPredicate predicateWithFormat:@"scheduledDate BETWEEN %@",@[sD,eD]];
        [_weekEventArrayController rearrangeObjects];
        _reloadingWeekData = NO;
        NSLog(@"WeekEventManager: %lu events",[_weekEventArrayController.arrangedObjects count]);
        return _weekEventArrayController.arrangedObjects;
    }
}

#pragma mark - SCKEventManager Delegate

- (void)eventManager:(SCKEventManager *)eM didSelectEvent:(id<SCKEvent>)e {
    NSString *who = (eM == _weekEventManager)?@"WeekView":@"DayView";
    NSLog(@"%@: Did select event with title '%@'",who,[e title]);
}

- (void)eventManagerDidClearSelection:(SCKEventManager *)eM {
    NSString *who = (eM == _weekEventManager)?@"WeekView":@"DayView";
    NSLog(@"%@: Did clear selection",who);
}

- (void)eventManager:(SCKEventManager *)eM didDoubleClickEvent:(id<SCKEvent>)e {
    NSAlert *alert = [NSAlert new];
    alert.messageText = @"Double click";
    alert.informativeText = [NSString stringWithFormat:@"Clicked on event '%@'",[e title]];
    [alert runModal];
}

- (void)eventManager:(SCKEventManager *)eM didDoubleClickBlankDate:(NSDate *)d {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterMediumStyle;
    df.timeStyle = NSDateFormatterMediumStyle;
    NSAlert *alert = [NSAlert new];
    alert.messageText = @"Double click on empty date";
    alert.informativeText = [NSString stringWithFormat:@"Clicked on empty date: '%@'",[df stringFromDate:d]];
    [alert runModal];
}

- (BOOL)eventManager:(SCKEventManager *)eM shouldChangeLengthOfEvent:(id<SCKEvent>)e fromValue:(NSInteger)oV toValue:(NSInteger)fV {
    NSAlert *alert = [NSAlert new];
    alert.messageText = @"Duration change";
    alert.informativeText = [NSString stringWithFormat:@"You've modified the duration of event '%@'.\n\nPrevious duration: %ld min.\nNew duration: %ld min.\n\nAre you sure?",[e title],oV,fV];
    [alert addButtonWithTitle:@"Save changes"];
    [alert addButtonWithTitle:@"Discard"];
    return ([alert runModal] == NSAlertFirstButtonReturn);
}

- (BOOL)eventManager:(SCKEventManager *)eM shouldChangeDateOfEvent:(id<SCKEvent>)e fromValue:(NSDate *)oD toValue:(NSDate *)fD {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterMediumStyle;
    df.timeStyle = NSDateFormatterMediumStyle;
    NSAlert *alert = [NSAlert new];
    alert.messageText = @"Date change";
    alert.informativeText = [NSString stringWithFormat:@"You've modified the date and time of event '%@'.\n\nPrevious date: %@.\nNew date: %@.\n\nAre you sure?",[e title],[df stringFromDate:oD],[df stringFromDate:fD]];
    [alert addButtonWithTitle:@"Save changes"];
    [alert addButtonWithTitle:@"Discard"];
    return ([alert runModal] == NSAlertFirstButtonReturn);
}

#pragma mark - SCKWeekViewDelegate

- (NSArray *)unavailableTimeRangesForGridView:(SCKGridView *)view {
    if (view == _dayEventManager.view) {
        return @[
                 [[SCKUnavailableTimeRange alloc] initWithWeekday:-1 startHour:13 startMinute:0 endHour:15 endMinute:0],
                 [[SCKUnavailableTimeRange alloc] initWithWeekday:-1 startHour:19 startMinute:0 endHour:20 endMinute:0],
        ];
    } else {
        return @[
                 [[SCKUnavailableTimeRange alloc] initWithWeekday:0 startHour:13 startMinute:0 endHour:15 endMinute:0],
                 [[SCKUnavailableTimeRange alloc] initWithWeekday:1 startHour:19 startMinute:0 endHour:20 endMinute:0],
                 [[SCKUnavailableTimeRange alloc] initWithWeekday:2 startHour:19 startMinute:0 endHour:20 endMinute:0],
                 [[SCKUnavailableTimeRange alloc] initWithWeekday:3 startHour:19 startMinute:0 endHour:20 endMinute:0],
                 [[SCKUnavailableTimeRange alloc] initWithWeekday:4 startHour:19 startMinute:0 endHour:20 endMinute:0],
                 [[SCKUnavailableTimeRange alloc] initWithWeekday:5 startHour:19 startMinute:0 endHour:20 endMinute:0],
                 [[SCKUnavailableTimeRange alloc] initWithWeekday:6 startHour:19 startMinute:0 endHour:20 endMinute:0],
                 ];
    }
}

- (NSInteger)dayStartHourForWeekView:(SCKWeekView *)wView {
    return _dayStartHour;
}

- (NSInteger)dayEndHourForWeekView:(SCKWeekView *)wView {
    return _dayEndHour;
}

- (NSInteger)dayCountForWeekView:(SCKWeekView *)wView {
    NSInteger c = 5;
    if (_showsSaturdays) {
        c++;
        if (_showsSundays) {
            c++;
        }
    }
    return c;
}

@end
