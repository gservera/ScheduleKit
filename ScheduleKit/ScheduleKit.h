/*
 *  ScheduleKit.h
 *  ScheduleKit
 *
 *  Created:    Guillem Servera on 24/12/2014.
 *  Copyright:  © 2014-2015 Guillem Servera (http://github.com/gservera)
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 */


@import Cocoa;

//! Project version number for ScheduleKit.
FOUNDATION_EXPORT double ScheduleKitVersionNumber;

//! Project version string for ScheduleKit.
FOUNDATION_EXPORT const unsigned char ScheduleKitVersionString[];

#import <ScheduleKit/ScheduleKitDefinitions.h>
#import <ScheduleKit/SCKEvent.h>
#import <ScheduleKit/SCKEventHolder.h>
#import <ScheduleKit/SCKUnavailableTimeRange.h>
#import <ScheduleKit/SCKTextField.h>
#import <ScheduleKit/SCKEventManager.h>
#import <ScheduleKit/SCKEventView.h>
#import <ScheduleKit/SCKWeekView.h>
#import <ScheduleKit/SCKDayView.h>
#import <ScheduleKit/SCKEventRequest.h>

extern NSString * const SCKDefaultsGridViewZoomLevelKey;