//
//  AppDelegate.h
//  SCKTester
//
//  Created by Guillem on 12/1/15.
//  Copyright (c) 2015 Guillem Servera. All rights reserved.
//

@import Cocoa;
@import ScheduleKit;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, SCKEventManagerDataSource, SCKEventManagerDelegate, SCKWeekViewDelegate> {
    NSArray * __users;
    BOOL _reloadingDayData;
    BOOL _reloadingWeekData;
    SCKEventRequest *_asynchronousRequest;
}

- (IBAction)addEvent:(id)sender;
- (IBAction)removeEvent:(id)sender;
- (IBAction)toggleUser:(NSButton*)sender;
- (IBAction)setColorMode:(NSPopUpButton*)sender;
- (IBAction)toggleSettingsPopover:(id)sender;
- (IBAction)toggleCalendarPopover:(id)sender;

@property (weak) IBOutlet NSWindow * window;
@property (weak) IBOutlet NSArrayController * dayEventArrayController;
@property (weak) IBOutlet NSArrayController * weekEventArrayController;
@property (weak) IBOutlet SCKEventManager * dayEventManager;
@property (weak) IBOutlet SCKEventManager * weekEventManager;
@property (weak) IBOutlet NSTableView * tableView;
@property (weak) IBOutlet NSPopover * settingsPopover;
@property (weak) IBOutlet NSPopover * calendarPopover;

@property (readonly) id <SCKEvent> selectedEvent;
@property (strong) NSMutableArray * users;
@property (strong) NSMutableArray * eventArray;
@property (nonatomic,assign) BOOL showsSaturdays;
@property (nonatomic,assign) BOOL showsSundays;
@property (nonatomic,assign) NSInteger dayStartHour;
@property (nonatomic,assign) NSInteger dayEndHour;
@property (nonatomic,strong) NSDate * calendarViewSelection;
@end

