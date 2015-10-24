/*
 *  SCKEventRequestPrivate.h
 *  ScheduleKit
 *
 *  Created:    Guillem Servera on 16/07/2015.
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

#import "SCKEventRequest.h"

@class SCKEventManager;
@interface SCKEventRequest (Private)

/**
 *  Initializes a new SCKEventRequest with the specified properties. This method
 *  should only be called from the owning SCKEventManager.
 *
 *  @param eM The owning SCKEventManager. Can't be nil.
 *  @param sD The start date for an event fetch criteria. Can't be nil.
 *  @param eD The end date for an event fetch criteria. Can't be nil.
 *
 *  @return The initialized SCKEventRequest object.
 */
- (instancetype)initWithEventManager:(SCKEventManager*)eM startDate:(NSDate*)sD endDate:(NSDate*)eD;

@end