//
//  SCKGridView.m
//  ScheduleKit
//
//  Created by Guillem on 30/12/14.
//  Copyright (c) 2014 Guillem Servera. All rights reserved.
//

#import "SCKGridView.h"
#import "SCKViewPrivate.h"
#import "SCKEventView.h"
#import "SCKDayPoint.h"
#import "SCKEventManagerPrivate.h"

#define kHourLabelWidth 56.0
#define kDayLabelHeight 36.0
#define kMaxHourHeight 300.0

NSString * const SCKDefaultsGridViewZoomLevelKey = @"MEKZoom";

@implementation SCKGridView

static NSDictionary * __dayLabelAttrs = nil;
static NSDictionary * __monthLabelAttrs = nil;
static NSDictionary * __hourLabelAttrs = nil;
static NSDictionary * __subHourLabelAttrs = nil;

+ (void)initialize {
    if (self == [SCKGridView self]) {
        NSMutableParagraphStyle *cStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        NSMutableParagraphStyle *rStyle = [cStyle mutableCopy];
        cStyle.alignment = NSCenterTextAlignment;
        rStyle.alignment = NSRightTextAlignment;
        __dayLabelAttrs = @{NSParagraphStyleAttributeName:  cStyle,
                            NSForegroundColorAttributeName: [NSColor darkGrayColor],
                            NSFontAttributeName: [NSFont systemFontOfSize:14.0]};
        __monthLabelAttrs = @{NSParagraphStyleAttributeName:  cStyle,
                            NSForegroundColorAttributeName: [NSColor lightGrayColor],
                            NSFontAttributeName: [NSFont systemFontOfSize:12.0]};
        __hourLabelAttrs = @{NSParagraphStyleAttributeName:  cStyle,
                            NSForegroundColorAttributeName: [NSColor darkGrayColor],
                            NSFontAttributeName: [NSFont systemFontOfSize:11.0]};
        __subHourLabelAttrs = @{NSParagraphStyleAttributeName: rStyle,
                            NSForegroundColorAttributeName: [NSColor lightGrayColor],
                            NSFontAttributeName: [NSFont systemFontOfSize:10.0]};
    }
}

- (void)customInit {
    [super customInit];
    _calendar = [NSCalendar currentCalendar];
    _dayLabelDateFormatter = [[NSDateFormatter alloc] init];
    _dayLabelDateFormatter.dateFormat = @"EEEE d";
    _monthLabelDateFormatter = [[NSDateFormatter alloc] init];
    _monthLabelDateFormatter.dateFormat = @"MMM";
    _dayCount = 1;
    _hourCount = 1;
    _firstHour = 1;
    NSString *key = [SCKDefaultsGridViewZoomLevelKey stringByAppendingString:[NSString stringWithFormat:@".%@",NSStringFromClass(self.class)]];
    _hourHeight = [[NSUserDefaults standardUserDefaults] doubleForKey:key];
    _minuteTimer = [NSTimer scheduledTimerWithTimeInterval:60.0
                                                    target:self
                                                  selector:@selector(minuteTimerFired:)
                                                  userInfo:nil
                                                   repeats:YES];
    _minuteTimer.tolerance = 10.0;
}

- (void)minuteTimerFired:(NSTimer*)timer {
    [self setNeedsDisplay:YES];
}

- (NSRect)contentRect {
    return NSMakeRect(kHourLabelWidth,
                      kDayLabelHeight,
                      self.frame.size.width - kHourLabelWidth,
                      self.frame.size.height - kDayLabelHeight);
}

- (void)setHourHeight:(CGFloat)hourHeight {
    if (_hourHeight != hourHeight) {
        _hourHeight = hourHeight;
        NSString *key = [SCKDefaultsGridViewZoomLevelKey stringByAppendingString:[NSString stringWithFormat:@".%@",NSStringFromClass(self.class)]];
        [[NSUserDefaults standardUserDefaults] setDouble:hourHeight
                                                  forKey:key];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)viewWillMoveToSuperview:(NSView *)newSuperview {
    if (newSuperview != nil) {
        CGFloat minHHeight = (NSHeight(newSuperview.frame)-kDayLabelHeight)/(CGFloat)_hourCount;
        if (_hourHeight < minHHeight) {
            self.hourHeight = minHHeight;
        }
    }
}

- (void)setDelegate:(id<SCKGridViewDelegate>)delegate {
    _delegate = delegate;
    [self readDefaultsFromDelegate];
}

- (void)readDefaultsFromDelegate {
    if ([_delegate respondsToSelector:@selector(unavailableTimeRangesForGridView:)]) {
        _unavailableTimeRanges = [_delegate unavailableTimeRangesForGridView:self];
    }
    [self setNeedsDisplay:YES];
}

- (void)invalidateUserDefaults {
    [self readDefaultsFromDelegate];
}

- (NSRect)rectForUnavailableTimeRange:(SCKUnavailableTimeRange*)rng {
    return NSZeroRect;
}

- (void)drawDayLabelRect { //private
    NSRect dayLabelingRect = NSMakeRect(kHourLabelWidth,
                                        self.bounds.origin.y,
                                        self.frame.size.width - kHourLabelWidth,
                                        kDayLabelHeight);
    [[NSColor colorWithCalibratedWhite:0.95 alpha:1.0] set];
    NSRectFill(dayLabelingRect);
    
    CGFloat dayWidth = (NSWidth(self.frame) - kHourLabelWidth) / (CGFloat)_dayCount;
    _dayLabelDateFormatter.dateFormat = (dayWidth < 100.0)? @"EEE d" : @"EEEE d";
    _monthLabelDateFormatter.dateFormat = (dayWidth < 100.0)? @"MMM" : @"MMMM";
    
    for (NSInteger d = 0; d < _dayCount; d++) {
        NSDate *dayDate = [_calendar dateByAddingUnit:NSCalendarUnitDay value:d toDate:self.startDate options:0];
        NSString *dayLabel = [[_dayLabelDateFormatter stringFromDate:dayDate] uppercaseString];
        NSSize dayLabelSize = [dayLabel sizeWithAttributes:__dayLabelAttrs];
        NSRect dayLabelRect = NSMakeRect(NSMinX(dayLabelingRect)+dayWidth*(CGFloat)d,
                                         kDayLabelHeight/2.0-dayLabelSize.height/2.0,
                                         dayWidth,
                                         dayLabelSize.height);
        if ((d == 0) || ([[dayLabel componentsSeparatedByString:@" "][1] intValue] == 1)) {
            dayLabelRect.origin.y -= 8.0;
            NSString *monthLabel = [[_monthLabelDateFormatter stringFromDate:dayDate] uppercaseString];
            NSSize monthLabelSize = [monthLabel sizeWithAttributes:__monthLabelAttrs];
            NSRect monthLabelRect = NSMakeRect(dayLabelRect.origin.x,
                                               kDayLabelHeight/2.0-dayLabelSize.height/2.0 + 7.0,
                                               dayLabelRect.size.width,
                                               monthLabelSize.height);
            [monthLabel drawInRect:monthLabelRect withAttributes:__monthLabelAttrs];
        }
        [dayLabel drawInRect:dayLabelRect withAttributes:__dayLabelAttrs];
        [[NSColor colorWithCalibratedWhite:0.85 alpha:1.0] set];
        NSRectFill(NSMakeRect(NSMinX(dayLabelRect)-0.5, 0.0, 1.0, NSHeight(self.frame)));
    }
    NSRectFill(NSMakeRect(kHourLabelWidth-8.0, kDayLabelHeight-0.5, self.frame.size.width, 1.0));
}

- (void)drawHourDelimiters { //Private
    NSRect canvas = [self contentRect];
    [[NSColor colorWithCalibratedWhite:0.95 alpha:1.0] set];
    for (int h = 0; h < _hourCount; h++) {
        NSRect r = NSMakeRect(canvas.origin.x-8.0, canvas.origin.y + _hourHeight*(CGFloat)h - 0.4, NSWidth(canvas) + 8.0, 0.8);
        NSRectFill(r);
    }
}

- (void)drawHourLabels {
    NSRect canvas = [self contentRect];
    for (int h = 0; h < _hourCount; h++) {
        NSRect r = NSMakeRect(NSMinX(canvas)-8.0, NSMinY(canvas) + _hourHeight*(CGFloat)h-0.4, NSWidth(canvas)+8.0, 0.8);
        NSString *hourLabel = [NSString stringWithFormat:@"%ld:00",_firstHour+h]; //"\(firstHour + h):00"
        CGFloat hourLabelHeight = [hourLabel sizeWithAttributes:__hourLabelAttrs].height;
        NSRect hourLabelRect = NSMakeRect(0.0, NSMidY(r)-hourLabelHeight/2.0-0.5,kHourLabelWidth-12.0,hourLabelHeight);
        [hourLabel drawInRect:hourLabelRect withAttributes:__hourLabelAttrs];
        
        // Draw half hours if space available
        if (_hourHeight > 40.0) {
            NSString *midHourLabel = [NSString stringWithFormat:@"%ld:30   -",_firstHour+h];
            CGFloat midHourLabelHeight = [midHourLabel sizeWithAttributes:__subHourLabelAttrs].height;
            NSRect midHourLabelRect = NSMakeRect(0.0, NSMidY(r)+_hourHeight/2.0-midHourLabelHeight/2.0-0.5, kHourLabelWidth, midHourLabelHeight);
            [midHourLabel drawInRect:midHourLabelRect withAttributes:__subHourLabelAttrs];
            
            if (_hourHeight > 120.0) { // Draw 10ths
                for (int min = 10; min <= 50; min += 10) {
                    NSString *minLabel = [NSString stringWithFormat:@"%ld:%d   -",_firstHour+h,min];
                    CGFloat minLabelHeight = [minLabel sizeWithAttributes:__subHourLabelAttrs].height;
                    NSRect minLabelRect = NSMakeRect(0.0, NSMidY(r)+_hourHeight/60.0*(CGFloat)min-minLabelHeight/2.0-0.5, kHourLabelWidth, minLabelHeight);
                    [minLabel drawInRect:minLabelRect withAttributes:__subHourLabelAttrs];
                }
            } else if (_hourHeight > 80.0) { // Draw 15ths
                for (int min = 15; min <= 45; min += 15) {
                    NSString *minLabel = [NSString stringWithFormat:@"%ld:%d   -",_firstHour+h,min];
                    CGFloat minLabelHeight = [minLabel sizeWithAttributes:__subHourLabelAttrs].height;
                    NSRect minLabelRect = NSMakeRect(0.0, NSMidY(r)+_hourHeight/60.0*(CGFloat)min-minLabelHeight/2.0-0.5, kHourLabelWidth, minLabelHeight);
                    [minLabel drawInRect:minLabelRect withAttributes:__subHourLabelAttrs];
                }
            }
        }
    }
}

- (void)drawUnavailableTimeRanges {
    [[NSColor colorWithCalibratedRed:0.925 green:0.942 blue:0.953 alpha:1.000] set];
    for (SCKUnavailableTimeRange *range in _unavailableTimeRanges) {
        NSRectFill([self rectForUnavailableTimeRange:range]);
    }
}

#define fill(x,y,w,h) NSRectFill(NSMakeRect(x,y,w,h))

- (void)drawDraggingGuides {
    SCKEventView *eV = _eventViewBeingDragged;
    if (self.colorMode == SCKEventColorModeByEventType) {
        [[SCKEventView strokeColorForEventType:[eV.eventHolder.representedObject eventType]] setFill];
    } else if ([eV.eventHolder cachedUserLabelColor] != nil) {
        [[eV.eventHolder cachedUserLabelColor] setFill];
    } else {
        [[NSColor darkGrayColor] setFill];
    }
    
    NSRect canvasRect = [self contentRect];
    NSRect eventRect = eV.frame;
    
    //Left guide
    fill(NSMinX(canvasRect), NSMidY(eventRect)-1.0, NSMinX(eventRect)-NSMinX(canvasRect), 2.0);
    //Right guide
    fill(NSMaxX(eventRect), NSMidY(eventRect)-1.0, NSWidth(self.frame)-NSMaxX(eventRect), 2.0);
    fill(NSMinX(canvasRect)-10.0, NSMinY(eventRect), 10.0, 2.0);
    fill(NSMinX(canvasRect)-10.0, NSMaxY(eventRect)-2.0, 10.0, 2.0);
    fill(NSMinX(canvasRect)-2, NSMinY(eventRect), 2.0, NSHeight(eventRect));
    //Top guide
    fill(NSMidX(eventRect)-1.0, NSMinY(canvasRect), 2.0, NSMinY(eventRect)-NSMinY(canvasRect));
    //Bottom guide
    fill(NSMidX(eventRect)-1.0, NSMaxY(eventRect), 2.0, NSHeight(self.frame)-NSMaxY(eventRect));
    
    CGFloat dayWidth = NSWidth(canvasRect) / (CGFloat)_dayCount;
    SCKRelativeTimeLocation offsetPerDay = 1.0/(double)_dayCount;
    SCKRelativeTimeLocation startOffset = [self relativeTimeLocationForPoint:NSMakePoint(NSMidX(eV.frame), NSMinY(eV.frame))];
    if (startOffset != SCKRelativeTimeLocationNotFound) {
        fill(NSMinX(canvasRect)+dayWidth*trunc(startOffset/offsetPerDay), NSMinY(canvasRect), dayWidth, 2.0);
        
        NSDate *startDate = [self calculateDateForRelativeTimeLocation:startOffset];
        SCKDayPoint *sPoint = [[SCKDayPoint alloc] initWithDate:startDate];
        SCKDayPoint *ePoint = [[SCKDayPoint alloc] initWithDate:[startDate dateByAddingTimeInterval:eV.eventHolder.cachedDuration*60.0]];
        NSString *sHourLabel = [NSString stringWithFormat:@"%ld:%02ld",sPoint.hour,sPoint.minute];
        NSString *eHourLabel = [NSString stringWithFormat:@"%ld:%02ld",ePoint.hour,ePoint.minute];
        CGFloat height = [sHourLabel sizeWithAttributes:__hourLabelAttrs].height;
        NSRect sHourLabelRect = NSMakeRect(0.0, NSMinY(eventRect)-height/2.0, NSMinX(canvasRect)-12, height);
        NSRect eHourLabelRect = NSMakeRect(0.0, NSMaxY(eventRect)-height/2.0, NSMinX(canvasRect)-12, height);
        [sHourLabel drawInRect:sHourLabelRect withAttributes:__hourLabelAttrs];
        [eHourLabel drawInRect:eHourLabelRect withAttributes:__hourLabelAttrs];
        
        NSString *durationLabel = [NSString stringWithFormat:@"%ld min",eV.eventHolder.cachedDuration];
        NSRect durationRect = NSMakeRect(0.0, NSMidY(eventRect)-height/2.0, NSMinX(canvasRect)-12, height);
        [durationLabel drawInRect:durationRect withAttributes:__hourLabelAttrs];
    }
}

- (void)drawCurrentTimeLine {
    NSRect canvas = [self contentRect];
    NSDateComponents *components = [_calendar components:NSCalendarUnitHour|NSCalendarUnitMinute
                                                fromDate:[NSDate date]];
    double mOffset = (double)_hourCount * 60.0;
    double cOffset = (double)(components.hour-_firstHour) * 60.0 + (double)components.minute;
    CGFloat yOrigin = NSMinY(canvas) + NSHeight(canvas) * (cOffset / mOffset);
    [[NSColor redColor] setFill];
    NSRectFill(NSMakeRect(NSMinX(canvas), yOrigin-0.25, NSWidth(canvas), 0.5));
    NSBezierPath *circle = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(NSMinX(canvas)-2.0, yOrigin-2.0, 4.0, 4.0)];
    [circle fill];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect]; // Fills background
    if ((_absoluteStartTimeRef < _absoluteEndTimeRef) && (_hourCount > 0)) {
        [self drawUnavailableTimeRanges];
        [self drawDayLabelRect];
        [self drawHourDelimiters];
        [self drawCurrentTimeLine];
        if (_eventViewBeingDragged) {
            [self drawDraggingGuides];
        } else {
            [self drawHourLabels];
        }
    } 
}

- (NSSize)intrinsicContentSize {
    return NSMakeSize(NSViewNoInstrinsicMetric, kDayLabelHeight+(CGFloat)_hourCount*_hourHeight);
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldSize {
    [super resizeWithOldSuperviewSize:oldSize]; // Triggers relayout
    CGFloat visibleHeight = self.superview.frame.size.height - kDayLabelHeight;
    CGFloat contentHeight = (CGFloat)_hourCount * _hourHeight;
    if (contentHeight < visibleHeight && _hourCount > 0) {
        [self setHourHeight:(visibleHeight / (CGFloat)_hourCount)];
    }
}

- (void)magnifyWithEvent:(NSEvent *)event {
    CGFloat futureHourHeight = _hourHeight + 16.0 * event.magnification;
    if (futureHourHeight*(CGFloat)_hourCount >= NSHeight(self.superview.frame)-kDayLabelHeight) {
        self.hourHeight = futureHourHeight;
    } else {
        self.hourHeight = (NSHeight(self.superview.frame)-kDayLabelHeight) / (CGFloat)_hourCount;
    }
    self.needsDisplay = YES;
}

- (IBAction)increaseZoomFactor:(id)sender {
    if (_hourHeight < kMaxHourHeight) {
        self.hourHeight += 8.0;
        self.needsDisplay = YES;
    }
}

- (IBAction)decreaseZoomFactor:(id)sender {
    CGFloat futureHourHeight = _hourHeight - 8.0;
    if (futureHourHeight*(CGFloat)_hourCount >= NSHeight(self.superview.frame)-kDayLabelHeight) {
        self.hourHeight = futureHourHeight;
    } else {
        self.hourHeight = (NSHeight(self.superview.frame)-kDayLabelHeight) / (CGFloat)_hourCount;
    }
    self.needsDisplay = YES;
}

- (void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    if (self.superview != nil) {
        [self setContentCompressionResistancePriority:NSLayoutPriorityDragThatCannotResizeWindow
                                       forOrientation:NSLayoutConstraintOrientationVertical];
    }
}

//FIXME: Find a better algorythm. Some events still overlap after this
- (void)redistributeOverlappingEvents {
    [_eventViews makeObjectsPerformSelector:@selector(prepareForRedistribution)];
    CGFloat dayWidth = NSWidth(self.contentRect)/(CGFloat)_dayCount;
    
    for (SCKEventView *eV in _eventViews) {
        NSRect frame = eV.frame;
        NSUInteger day = (NSUInteger)trunc((NSMidX(frame)-kHourLabelWidth)/dayWidth);
        for (SCKEventView *sV in _eventViews) {
            if (sV != eV && !sV.layoutDone) {
                
                if (NSIntersectsRect(NSInsetRect(frame, 1, 1), NSInsetRect(sV.frame, 1, 1))) {
                    // Get offset in day width
                    NSRect dayRect = NSMakeRect(self.contentRect.origin.x+day*dayWidth, NSMinY(self.contentRect), dayWidth, NSHeight(self.contentRect));
                    NSRect altFrame = sV.frame;
                    NSUInteger eventsInColumn = (NSUInteger)round(dayWidth/NSWidth(altFrame));
                    NSUInteger posInColumn = (NSUInteger)trunc((NSMidX(altFrame)-kHourLabelWidth-day*dayWidth)/dayWidth);
                    //NSLog(@"Mask:(%lu:%lu)",posInColumn,eventsInColumn);
                    BOOL moved = NO;
                    // Check if previous places are empty
                    if (posInColumn > 0) {
                        NSUInteger testPos = posInColumn;
                        while (testPos > 0) {
                            testPos--;
                            NSRect testRect = NSInsetRect(altFrame, 1, 1);
                            testRect.origin.x -= NSWidth(altFrame);
                            if (!NSContainsRect(dayRect, testRect)) {
                                continue;
                            }
                            BOOL available = YES;
                            for (SCKEventView *xV in _eventViews) {
                                if (NSIntersectsRect(xV.frame, testRect)) {
                                    available = NO;
                                }
                            }
                            if (available) {
                                NSRect newFrame = sV.frame;
                                newFrame.origin.x -= newFrame.size.width;
                                sV.frame = newFrame;
                                moved = YES;
                                //NSLog(@"Moved %@ from pos %lu to pos %lu",sV.eventHolder.cachedTitle,posInColumn,testPos);
                                sV.layoutDone = YES;
                                break;
                            }
                        }
                    }
                    if (!moved && posInColumn < eventsInColumn) {
                        NSUInteger testPos = posInColumn;
                        while (testPos < eventsInColumn) {
                            testPos++;
                            NSRect testRect = NSInsetRect(altFrame, 1, 1);
                            testRect.origin.x += NSWidth(altFrame);
                            if (!NSContainsRect(dayRect, testRect)) {
                                continue;
                            }
                            BOOL available = YES;
                            for (SCKEventView *xV in _eventViews) {
                                if (NSIntersectsRect(xV.frame, testRect)) {
                                    available = NO;
                                }
                            }
                            if (available) {
                                NSRect newFrame = sV.frame;
                                newFrame.origin.x += newFrame.size.width;
                                sV.frame = newFrame;
                                //NSLog(@"Moved %@ from pos %lu to pos %lu",sV.eventHolder.cachedTitle,posInColumn,testPos);
                                sV.layoutDone = YES;
                                break;
                            }
                        }
                    }
                }
            }
        }
        //eV.layoutDone = YES;
    }

}

- (void)endRelayout {
    [self redistributeOverlappingEvents];
    [self redistributeOverlappingEvents];
    [super endRelayout];
}

@end
