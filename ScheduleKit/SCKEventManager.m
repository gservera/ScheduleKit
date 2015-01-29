//
//  SCKEventManager.m
//  ScheduleKit
//
//  Created by Guillem on 28/12/14.
//  Copyright (c) 2014 Guillem Servera. All rights reserved.
//

#import "SCKEventManagerPrivate.h"
#import "SCKEventHolder.h"
#import "ScheduleKitDefinitions.h"
#import "SCKEventView.h"
#import "SCKViewPrivate.h"

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
        _lastRequest = [NSPointerArray weakObjectsPointerArray];
    }
    return self;
}

- (NSInteger)positionInConflictForEventHolder:(SCKEventHolder*)e holdersInConflict:(NSArray**)conflictsPtr {
    SCKRelativeTimeLocation eStart = e.cachedRelativeStart;
    SCKRelativeTimeLocation eEnd = e.cachedRelativeEnd;
    NSPredicate *filter = [NSPredicate predicateWithBlock:^BOOL(SCKEventHolder *x, NSDictionary *bindings) {
        return ([x isReady] && !(x.cachedRelativeEnd <= eStart || x.cachedRelativeStart >= eEnd));
    }];
    NSArray *unsortedConflicts = [_managedContainers filteredArrayUsingPredicate:filter];
    NSAssert(unsortedConflicts.count >0,@"Must find itself!");
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
        NSMutableArray *events = [[_dataSource eventManager:self
                                  requestsEventsBetweenDate:_view.startDate
                                                    andDate:[_view.endDate dateByAddingTimeInterval:-1]] mutableCopy];
        if (![events isEqualToArray:_lastRequest.allObjects]) {
            _lastRequest = nil;
            _lastRequest = [NSPointerArray weakObjectsPointerArray];
            for (id <SCKEvent> e in events) {
                NSAssert1(!([[e scheduledDate] isLessThan:_view.startDate] || [[e scheduledDate] isGreaterThan:_view.endDate]), @"Invalid scheduledDate for new event: %@",e);
                [_lastRequest addPointer:(__bridge void *)(e)];
            }
            for (SCKEventHolder *holder in [_managedContainers copy]) {
                if (![events containsObject:holder.representedObject]) {
                    //Remove
                    [holder lock];
                    [_view removeEventView:holder.owningView];
                    [holder.owningView removeFromSuperview];
                    [_managedContainers removeObject:holder];
                } else {
                    [events removeObject:holder.representedObject];
                }
            }
            for (id <SCKEvent> e in events) {
                SCKEventView *aView = [[SCKEventView alloc] initWithFrame:NSZeroRect];
                [_view addSubview:aView];
                [_view addEventView:aView];
                SCKEventHolder *aHolder = [[SCKEventHolder alloc] initWithEvent:e owner:aView];
                aView.eventHolder = aHolder;
                [_managedContainers addObject:aHolder];
            }
            //TRIGGER RELAYOUT
            [_view triggerRelayoutForAllEventViews];
        }
    }
}

@end

@implementation SCKEventManager (Private)

- (NSArray*)managedEventHolders {
    return [_managedContainers copy];
}

@end

