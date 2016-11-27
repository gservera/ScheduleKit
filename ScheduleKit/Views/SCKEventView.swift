/*
 *  SCKEventView.swift
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

import Cocoa

enum SCKDraggingStatus {
    case idle
    case draggingDuration(oldValue: Int, lastValue: Int)
    case draggingContent
}

struct SCKActionContext {
    var status: SCKDraggingStatus = .idle
    var didDoubleClick: Bool = false
    var oldRelativeStart: SCKRelativeTimeLocation = 0.0
    var newRelativeStart: SCKRelativeTimeLocation = 0.0
    var internalDelta: CGFloat = 0.0
    var oldDate: TimeInterval = 0.0
}






/** SCKEventView is the NSView subclass used to display events as subviews of
 * an SCKView instance. Its functions include:
 * - Managing an inner label (SCKTextField subclass) which shows info about
 *   the represented event and drag and drop actions.
 * - Handling click, double click and drag and drop events to allow selection
 *   and conditional modification of the represented object's duration and/or
 *   scheduledDate.
 */
public final class SCKEventView: NSView {
    
    private var draggingStatus: SCKDraggingStatus = .idle
    
    /** Indicates whether the view has passed the redistribution process. */
    var layoutDone: Bool = false
    
    /** The view's represented event holder */
    var eventHolder: SCKEventHolder! {
        didSet {
            innerLabel.stringValue = eventHolder.cachedTitle
        }
    }
    
    /** The view's inner label */
    var innerLabel: SCKTextField = {
        let label = SCKTextField(frame: .zero)
        label.setContentCompressionResistancePriority(249, for: .horizontal)
        label.setContentCompressionResistancePriority(249, for: .vertical)
        label.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        return label
    }()
    
    private var kindColor: NSColor! = nil
    
    internal private(set) var backgroundColor: NSColor! = nil
    
    public override func draw(_ dirtyRect: CGRect) {
        guard let view = superview as? SCKGridView else {
            return
        }
        
        
        var fillColor: NSColor, strokeColor: NSColor
        
        if view.selectedEventView != nil && view.selectedEventView != self {
            // Set color to gray when another event is selected
            fillColor = NSColor(white: 0.85, alpha: 1.0)
            strokeColor = NSColor(white: 0.75, alpha: 1.0)
        } else {
            switch view.colorMode {
            case .byEventKind:
                let type = eventHolder.representedObject.eventKind
                if kindColor == nil {
                    kindColor = view.delegate?.color?(for: type, in: view) ?? NSColor.darkGray
                }
                fillColor = kindColor
            case .byEventOwner:
                fillColor = eventHolder.cachedUser?.eventColor ?? NSColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
                let red = fillColor.redComponent, green = fillColor.greenComponent, blue = fillColor.blueComponent
                strokeColor = NSColor(red: red-0.1, green:green-0.1, blue:blue-0.1, alpha:1.0)
            }
        }
        if view.selectedEventView != nil && view.selectedEventView == self, case .draggingContent = action.status {
            fillColor = fillColor.withAlphaComponent(0.5)
        }
        
        
        if inLiveResize {
            fillColor.set()
            NSRectFill(CGRect(origin: CGPoint.zero, size: frame.size))
        } else {
            fillColor.setFill()
            fillColor.setStroke()
            let path = NSBezierPath(roundedRect: bounds, xRadius: 2.0, yRadius: 2.0)
            if view.contentRect.origin.y > view.convert(frame.origin, from: self).y || view.contentRect.maxY < frame.maxY {
                fillColor.withAlphaComponent(0.2).setFill()
                var lineDash: [CGFloat] = [2.0, 1.0]
                path.setLineDash(&lineDash, count: 2, phase: 1)
            }
            
            path.fill()
            path.lineWidth = view.selectedEventView == self ? 3.0 : 0.65
            path.stroke()
        }
    }
    

    /** Sent to all SCKEventView's in a SCKView instance before
     * scheduling a redistribution process (movement of overlapping
     * events. TODO: The whole redistribution process should be
     * improved. */
    public func prepareForRedistribution() {
        layoutDone = false
    }
    
    
    private var action = SCKActionContext()
    
    public override func menu(for event: NSEvent) -> NSMenu? {
        guard let gridView = superview as? SCKGridView else {
            return nil
        }
        return gridView.controller?.eventManager?.scheduleController(gridView.controller!, menuForEvent: eventHolder.representedObject)
    }
    
    public override func rightMouseDown(with event: NSEvent) {
        guard let gridView = superview as? SCKGridView else {
            return
        }
        if gridView.selectedEventView != self {
            gridView.selectedEventView = self
        }
        super.rightMouseDown(with: event)
    }
    
    public override func rightMouseUp(with event: NSEvent) {
        super.rightMouseUp(with: event)
        needsDisplay = true
    }
    
    public override func mouseDown(with event: NSEvent) {
        action = SCKActionContext()
        guard let gridView = superview as? SCKGridView else {
            return
        }
        if gridView.selectedEventView != self {
            gridView.selectedEventView = self
        }
        if event.clickCount == 2 {
            action.didDoubleClick = true
        }
    }
    
    public override func mouseDragged(with event: NSEvent) {
        guard let gridView = superview as? SCKGridView else {
            return
        }
        switch action.status {
        
        case .idle where NSCursor.current() == NSCursor.resizeUpDown():
            action.status = .draggingDuration(oldValue: eventHolder.cachedDuration,
                                              lastValue: eventHolder.cachedDuration)
            gridView.beginDraggingEventView(self)
            fallthrough
        case .draggingDuration(_, _):
            parseDurationDrag(with: event)
        default:
            if case SCKDraggingStatus.idle = action.status {
                action.oldRelativeStart = eventHolder.relativeStart
                action.newRelativeStart = eventHolder.relativeStart
                action.status = .draggingContent
                action.oldDate = eventHolder.cachedScheduledDate.timeIntervalSinceReferenceDate
                action.internalDelta = convert(event.locationInWindow, from: nil).y
                gridView.beginDraggingEventView(self)
            }
            parseContentDrag(with: event)
        }
        gridView.invalidateFrame(for: self) //FIXME: Enough?
        gridView.continueDraggingEventView(self)
    }
    
    private func parseDurationDrag(with event: NSEvent) {
        guard let gridView = superview as? SCKGridView else {
            return
        }
        guard case .draggingDuration(let old, let last) = action.status else {
            return
        }
        let superLoc = gridView.convert(event.locationInWindow, from: nil)
        
        let sDate = eventHolder.cachedScheduledDate
        if let eDate = gridView.calculateDate(for: gridView.relativeTimeLocation(for: superLoc)) {
            var newDuration = Int(trunc((eDate.timeIntervalSince(sDate) / 60.0)))
            if newDuration != last {
                if newDuration >= 5 {
                    eventHolder.cachedDuration = newDuration
                    let inSeconds = newDuration * 60
                    let endDate = eventHolder.cachedScheduledDate.addingTimeInterval(Double(inSeconds))
                    var relativeEnd = gridView.calculateRelativeTimeLocation(for: endDate)
                    if relativeEnd == Double(NSNotFound) {
                        relativeEnd = 1.0;
                    }
                    eventHolder.relativeLength = relativeEnd - eventHolder.relativeStart
                    gridView.invalidateFrame(for: self)
                } else {
                    newDuration = 5
                }
                innerLabel.stringValue = "\(newDuration) min"
                //Update context
                action.status = .draggingDuration(oldValue: old, lastValue: newDuration)
            }
        }
        
    }
    
    private func parseContentDrag(with event: NSEvent) {
        guard let gridView = superview as? SCKGridView else {
            return
        }
        var tPoint = gridView.convert(event.locationInWindow, from: nil)
        tPoint.y -= action.internalDelta
        
        var newStartLoc = gridView.relativeTimeLocation(for: tPoint)
        if newStartLoc == SCKRelativeTimeLocationInvalid && tPoint.y < gridView.frame.midY {
            //May be too close to an edge, check if too low
            tPoint.y = gridView.contentRect.minY
            newStartLoc = gridView.relativeTimeLocation(for: tPoint)
        }
        if newStartLoc != SCKRelativeTimeLocationInvalid  {
            tPoint.y += frame.height
            let newEndLoc = gridView.relativeTimeLocation(for: tPoint)
            if newEndLoc != SCKRelativeTimeLocationInvalid {
                eventHolder.relativeStart = newStartLoc
                eventHolder.relativeEnd = newEndLoc
                eventHolder.cachedScheduledDate = gridView.calculateDate(for: newStartLoc)!
                action.newRelativeStart = newStartLoc
            }
        }
    }
    
    public override func mouseUp(with event: NSEvent) {
        guard let gridView = superview as? SCKGridView else {
            return
        }
        
        switch action.status {
        case .draggingDuration(let old, let new):
            innerLabel.stringValue = eventHolder.cachedTitle
            
            var shouldContinue = true
            if let eventManager = gridView.controller.eventManager {
                /*if*/ let answer = eventManager.scheduleController(gridView.controller, shouldChangeDurationOfEvent: eventHolder.representedObject, from: old, to: new) //{
                    shouldContinue = answer
                //}
            }
            
            if shouldContinue {
                eventHolder.stopObservingRepresentedObjectChanges()
                eventHolder.representedObject.duration = new
                eventHolder.resumeObservingRepresentedObjectChanges()
                eventHolder.recalculateRelativeValues()
                gridView.invalidateFrameForAllEventViews()
            } else {
                eventHolder.cachedDuration = old
                gridView.invalidateFrame(for: self)
            }
            gridView.endDraggingEventView(self)
        case .draggingContent:
            if let scheduledDate = gridView.calculateDate(for: action.newRelativeStart) {
                
                var shouldContinue = true
                if let eventManager = gridView.controller.eventManager {
                    /*if*/ let answer = eventManager.scheduleController(gridView.controller, shouldChangeDateOfEvent: eventHolder.representedObject, from: eventHolder.representedObject.scheduledDate, to: scheduledDate) //{
                        shouldContinue = answer
                    //}
                }
                
                if shouldContinue {
                    eventHolder.stopObservingRepresentedObjectChanges()
                    eventHolder.representedObject.scheduledDate = scheduledDate
                    eventHolder.resumeObservingRepresentedObjectChanges()
                    eventHolder.recalculateRelativeValues()
                    gridView.invalidateFrameForAllEventViews()
                } else {
                    eventHolder.cachedScheduledDate = Date(timeIntervalSinceReferenceDate: action.oldDate)
                    eventHolder.recalculateRelativeValues()
                    gridView.invalidateFrame(for: self)
                }
            }
            gridView.endDraggingEventView(self)
            
        case .idle where action.didDoubleClick:
            gridView.controller.eventManager?.scheduleController(gridView.controller, didDoubleClickEvent: eventHolder.representedObject)
        default: break;
        }
        action = SCKActionContext()
        needsDisplay = true
    }
    
    public override func viewDidMoveToWindow() {
        if superview != nil {
            innerLabel.frame = CGRect(origin: .zero, size: frame.size)
            addSubview(innerLabel)
        }
    }
    
    public override var isFlipped: Bool {
        return true
    }
    
    public override func resetCursorRects() {
        let r = NSRect(x: 0.0, y: frame.height-2.0, width: frame.width, height: 4.0)
        addCursorRect(r, cursor: .resizeUpDown())
    }
    
    public override func viewDidEndLiveResize() {
        super.viewDidEndLiveResize()
        needsDisplay = true
    }
    
}
