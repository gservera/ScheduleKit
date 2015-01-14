//
//  SCKEventManager.m
//  ScheduleKit
//
//  Created by Guillem on 28/12/14.
//  Copyright (c) 2014 Guillem Servera. All rights reserved.
//

#import "SCKEventManager.h"
#import "SCKEventManagerPrivate.h"
#import "SCKEventHolder.h"
#import "ScheduleKitDefinitions.h"
#import "SCKEventView.h"
#import "SCKView.h"

#define SCKKey(key) NSStringFromSelector(@selector(key))
#define SCKSorter(key,asc) [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(key)) ascending:asc]

static NSArray * __sorters = nil;

@implementation SCKEventManager

+ (void)initialize {
    if (self == [SCKEventManager self]) {
        __sorters = @[SCKSorter(cachedRelativeStart, YES), SCKSorter(cachedTitle, YES), SCKSorter(description, YES)];
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _managedContainers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSInteger)positionInConflictForEventHolder:(SCKEventHolder*)e
                            holdersInConflict:(NSArray**)conflictsPtr {
    SCKRelativeTimeLocation eStart = e.cachedRelativeStart;
    SCKRelativeTimeLocation eEnd = e.cachedRelativeEnd;
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"(%K == YES) AND NOT (cachedRelativeEnd < %@ OR cachedRelativeStart > %@)",SCKKey(ready),@(eStart),@(eEnd)];
    NSArray *unsortedConflicts = [_managedContainers filteredArrayUsingPredicate:filter];
    NSArray *sortedEventsInConflict = [unsortedConflicts sortedArrayUsingDescriptors:__sorters];
    if (conflictsPtr != NULL) {
        *conflictsPtr = sortedEventsInConflict;
    }
    return [sortedEventsInConflict indexOfObject:e];
}

- (void)reloadData {
    if (_dataSource) {
        if ([self.view relayoutInProgress]) {
            NSLog(@"Waiting for relayout to terminate before reloading data");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(1.0 * NSEC_PER_SEC)),dispatch_get_main_queue(),^{
                [self reloadData];
            });
            return;
        }
        NSMutableArray *events = [[_dataSource eventManager:self requestsEventsBetweenDate:_view.startDate andDate:_view.endDate] mutableCopy];
        for (SCKEventHolder *holder in [_managedContainers copy]) {
            if (![events containsObject:holder.representedObject]) {
                //Remove
                [holder lock];
                [holder.owningView removeFromSuperview];
                [_managedContainers removeObject:holder];
            } else {
                [events removeObject:holder.representedObject];
            }
        }
        for (id <SCKEvent> e in events) {
            SCKEventView *aView = [[SCKEventView alloc] initWithFrame:NSZeroRect];
            SCKEventHolder *aHolder = [[SCKEventHolder alloc] initWithEvent:e owner:aView];
            aView.eventHolder = aHolder;
            [_view addSubview:aView];
            [_managedContainers addObject:aHolder];
        }
        //TRIGGER RELAYOUT
        [_view triggerRelayoutForAllEventViews];
    }
}

@end

@implementation SCKEventManager (Private)

- (NSArray*)managedEventHolders {
    return [_managedContainers copy];
}

@end

