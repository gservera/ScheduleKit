//
//  SCKEventHolder.m
//  ScheduleKit
//
//  Created by Guillem on 24/12/14.
//  Copyright (c) 2014 Guillem Servera. All rights reserved.
//

#import "SCKEventHolder.h"
#import "SCKEventView.h"
#import "SCKView.h"
#import "SCKEventManager.h"

static void * KVOContext = &KVOContext;

@implementation SCKEventHolder {
    NSArray *_previousConflicts;
    BOOL _observing;
#if DEBUG
    NSInteger _lockBalance;
#endif
}

- (instancetype)initWithEvent:(id <SCKEvent>)e owner:(SCKEventView*)v {
    NSParameterAssert([e conformsToProtocol:@protocol(SCKEvent)]);
    NSParameterAssert([v isKindOfClass:[SCKEventView class]]);
    self = [super init];
    if (self) {
        _observing = NO;
#if DEBUG
        _lockBalance = 0;
#endif
        [self reset];
        [self setOwningView:v];
        [self setRepresentedObject:e];
    }
    return self;
}

- (void)reset {
    _ready = NO;
    _locked = NO;
    self.cachedUserLabelColor = nil;
    self.cachedTitle = nil;
    self.cachedScheduleDate = nil;
    self.cachedDuration = nil;
    self.cachedRelativeStart = SCKRelativeTimeLocationNotFound;
    self.cachedRelativeEnd = SCKRelativeTimeLocationNotFound;
    self.cachedRelativeLength = 0;
}

- (void)setRepresentedObject:(id<SCKEvent>)representedObject {
    if (_representedObject != representedObject) {
        if (_representedObject && _observing) {
            [self stopObservingRepresentedObject];
        }
        _representedObject = representedObject;
        _cachedUserLabelColor = [[representedObject user] labelColor];
        _cachedTitle = [representedObject title];
        _cachedScheduleDate = [representedObject scheduledDate];
        _cachedDuration = [representedObject duration];
        [self recalculateRelativeValues];
        if (representedObject) {
            [self startObservingRepresentedObject];
        }
    }
    
}

- (void)stopObservingRepresentedObject {
    if (_representedObject != nil && _observing) {
        id obj = self.representedObject;
        [obj removeObserver:self forKeyPath:NSStringFromSelector(@selector(scheduledDate))];
        [obj removeObserver:self forKeyPath:NSStringFromSelector(@selector(duration))];
        [obj removeObserver:self forKeyPath:NSStringFromSelector(@selector(title))];
    }
    _observing = NO;
}

- (void)startObservingRepresentedObject {
    if (_representedObject != nil) {
        id obj = self.representedObject;
        [obj addObserver:self
              forKeyPath:NSStringFromSelector(@selector(scheduledDate))
                 options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionPrior
                 context:KVOContext];
        [obj addObserver:self
              forKeyPath:NSStringFromSelector(@selector(duration))
                 options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionPrior
                 context:KVOContext];
        [obj addObserver:self
              forKeyPath:NSStringFromSelector(@selector(title))
                 options:NSKeyValueObservingOptionNew context:KVOContext];
        _observing = YES;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)o change:(NSDictionary *)change context:(void *)context {
    if (context == KVOContext) {
        if (change[NSKeyValueChangeNotificationIsPriorKey] != nil) {
            // Is prior, we'll cache actual conflicting events to trigger relayout on them, too.
            _previousConflicts = nil;
            NSArray *previousConflicts;
            [[(SCKView*)self.owningView.superview eventManager] positionInConflictForEventHolder:self holdersInConflict:&previousConflicts];
            _previousConflicts = previousConflicts;
        } else {
            if ([keyPath isEqualToString:NSStringFromSelector(@selector(duration))]) {
                self.cachedDuration = [_representedObject duration];
            } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(scheduledDate))]) {
                self.cachedScheduleDate = [_representedObject scheduledDate];
                SCKView *supremeOwner = (SCKView*)_owningView.superview;
                if ([_cachedScheduleDate isLessThan:supremeOwner.startDate] || [_cachedScheduleDate isGreaterThan:supremeOwner.endDate]) {
                    [[supremeOwner eventManager] reloadData];
                    return;
                }
            } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(title))]) {
                self.cachedTitle = [_representedObject title];
                self.owningView.innerLabel.stringValue = _cachedTitle;
            }
            [self recalculateRelativeValues];
            NSArray *conflicts;
            [[(SCKView*)self.owningView.superview eventManager] positionInConflictForEventHolder:self holdersInConflict:&conflicts];
            [(SCKView*)self.owningView.superview triggerRelayoutForEventViews:[[conflicts arrayByAddingObjectsFromArray:_previousConflicts] valueForKey:@"owningView"] animated:YES];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:o change:change context:context];
    }
}



- (void)lock {
#if DEBUG 
    _lockBalance++; NSAssert(_lockBalance == 1, @"Overlocked");
#endif
    [self stopObservingRepresentedObject];
    _locked = YES;
}

- (void)unlock {
#if DEBUG
    _lockBalance--; NSAssert(_lockBalance == 0, @"Overunlocked");
#endif
    _locked = NO;
    [self startObservingRepresentedObject];
}

- (void)recalculateRelativeValues {
    _ready = NO;
    _cachedRelativeStart = SCKRelativeTimeLocationNotFound;
    _cachedRelativeEnd = SCKRelativeTimeLocationNotFound;
    _cachedRelativeLength = 0;
    if ([_owningView superview]) {
        SCKView *rootView = (SCKView*)_owningView.superview;
        if ([self cachedScheduleDate]) {
            _cachedRelativeStart = [rootView calculateRelativeTimeLocationForDate:_cachedScheduleDate];
            if (_cachedRelativeStart != SCKRelativeTimeLocationNotFound) {
                if (_cachedDuration > 0) {
                    NSDate *endDate = [_cachedScheduleDate dateByAddingTimeInterval:_cachedDuration.doubleValue*60.0];
                    _cachedRelativeEnd = [rootView calculateRelativeTimeLocationForDate:endDate];
                    if (_cachedRelativeEnd == SCKRelativeTimeLocationNotFound) {
                        _cachedRelativeEnd = 1.0;
                    }
                    _cachedRelativeLength = _cachedRelativeEnd - _cachedRelativeStart;
                    _ready = YES;
                }
            }
        }
    }
}

@end
