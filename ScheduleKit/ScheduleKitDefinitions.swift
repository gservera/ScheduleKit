/*
 *  ScheduleKitDefinitions.swift
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

import Foundation

internal let sharedCalendar = Calendar.current


/** A type to represent relative time points between the lower and upper limits in a
 @c SCKView subclass, where a value of 0.0 represents the lower limit and a value of
 1.0 represents the upper limit. */
public typealias SCKRelativeTimeLocation = Double

/** A type to represent the relative length (in percentage) of an event in a concrete
 @c SCKView subclass. */
public typealias SCKRelativeTimeLength = Double


/// Possible color styles for drawing event view background.
///
/// - byEventKind:  Sets the `SCKEventView`s background color according to their 
///                 event holder's event kind.
/// - byEventOwner: Sets the `SCKEventView`s background color according to the label
///                 color of their event holder's user.
@objc public enum SCKEventColorMode: Int {
    case byEventKind
    case byEventOwner
}


#if os(iOS)
    import UIKit
    public typealias ViewBaseClass = UIView
    public typealias ColorClass = UIColor
    public typealias SCKBezierPath = UIBezierPath
    public func SCKRectFill(_ rect: CGRect) {
        UIRectFill(rect)
    }
#else
    import Cocoa
    public typealias ViewBaseClass = NSView
    public typealias ColorClass = NSColor
    public typealias SCKBezierPath = NSBezierPath
    public func SCKRectFill(_ rect: CGRect) {
        NSRectFill(rect)
    }
#endif



//typedef NS_ENUM(NSInteger, SCKDraggingStatus) {
//    SCKDraggingStatusIlde             = -1,
//    SCKDraggingStatusDraggingDuration =  1,
//    SCKDraggingStatusDraggingContent  =  2
//};

//typedef struct SCKActionContext {
//    SCKDraggingStatus status;
//    BOOL doubleClick;
//    NSInteger oldDuration;
//    NSInteger lastDuration;
//    NSInteger newDuration;
//    SCKRelativeTimeLocation oldRelativeStart;
//    SCKRelativeTimeLocation newRelativeStart;
//    CGFloat internalDelta;
//    NSTimeInterval oldDateRef;
//} SCKActionContext;

