/*
 *  SCKEventView.swift
 *  ScheduleKit
 *
 *  Created:    Guillem Servera on 24/12/2014.
 *  Copyright:  © 2014-2017 Guillem Servera (https://github.com/gservera)
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

/// The view class used by ScheduleKit to display each event in a schedule view.
/// This view is responsible of managing a descriptive label and also of handling
/// mouse events, including drag and drop operations, which may derive in changes
/// to the represented event.
public final class SCKEventView: NSView {
    
    /// The event holder represented by this view.
    internal var eventHolder: SCKEventHolder! {
        didSet {
            innerLabel.stringValue = eventHolder.cachedTitle
        }
    }
    
    /// A label that displays the represented event's title or its duration when
    /// dragging the view from the bottom edge. The title value is updated
    /// automatically by the event holder when a change in the event's title is 
    /// observed.
    private(set) var innerLabel: SCKTextField = {
        let _label = SCKTextField(frame: .zero)
        _label.setContentCompressionResistancePriority(249, for: .horizontal)
        _label.setContentCompressionResistancePriority(249, for: .vertical)
        _label.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        return _label
    }()
    
    // MARK: - Drawing
    
    /// A cached copy of the last used background color to increase drawing
    /// performance. Invalidated when the schedule view's color mode changes or
    /// when the event's user or user event color changes in .byEventOwner mode.
    internal var backgroundColor: NSColor? = nil
    
    public override func draw(_ dirtyRect: CGRect) {
        let isAnyViewSelected = (scheduleView.selectedEventView != nil)
        let isThisViewSelected = (scheduleView.selectedEventView == self)
        
        var fillColor: NSColor
        
        if isAnyViewSelected && !isThisViewSelected {
            // Set color to gray when another event is selected
            fillColor = NSColor(white: 0.85, alpha: 1.0)
        } else {
            // No view selected or this view selected. Let's determine background
            // color.
            if backgroundColor == nil {
                switch scheduleView.colorMode {
                case .byEventKind:
                    let kind = eventHolder.representedObject.eventKind
                    let color = scheduleView.delegate?.color?(for: kind, in: scheduleView)
                    backgroundColor = color ?? NSColor.darkGray
                case .byEventOwner:
                    let color = eventHolder.cachedUser?.eventColor
                    backgroundColor = color ?? NSColor.darkGray
                }
            }
            fillColor = backgroundColor!
        }
        
        // Make more transparent if dragging this view.
        if isThisViewSelected, case .draggingContent(_,_,_) = draggingStatus {
            fillColor = fillColor.withAlphaComponent(0.7)
        }
        
        let wholeRect = CGRect(origin: CGPoint.zero, size: frame.size)
        if inLiveResize {
            fillColor.set()
            NSRectFill(wholeRect)
        } else {
            fillColor.setFill()
            let path = NSBezierPath(roundedRect: wholeRect, xRadius: 2.0, yRadius: 2.0)
            if scheduleView.contentRect.origin.y > scheduleView.convert(frame.origin, from: self).y || scheduleView.contentRect.maxY < frame.maxY {
                fillColor.withAlphaComponent(0.2).setFill()
            }
            path.fill()
        }
    }
    
    // MARK: - View lifecycle
    
    /// The `SCKView` instance th which this view has been added.
    private weak var scheduleView: SCKView!
    
    public override func viewDidEndLiveResize() {
        super.viewDidEndLiveResize()
        needsDisplay = true
    }
    
    public override func viewDidMoveToSuperview() {
        scheduleView = superview as? SCKView
        // Add the title label to the view hierarchy.
        if superview != nil && innerLabel.superview == nil {
            innerLabel.frame = CGRect(origin: .zero, size: frame.size)
            addSubview(innerLabel)
        }
    }
    
    // MARK: - Overrides
    
    public override var isFlipped: Bool {
        return true
    }
    
    public override func resetCursorRects() {
        // FIXME: Cursor beyond view bounds?
        let r = NSRect(x: 0, y: frame.height-2.0, width: frame.width, height: 4.0)
        addCursorRect(r, cursor: .resizeUpDown())
    }
    
    // MARK: - Mouse events and dragging
    
    public override func mouseDown(with event: NSEvent) {
        // Select this view if not selected yet. This will trigger selection
        // methods on the controller's delegate.
        if scheduleView.selectedEventView != self {
            scheduleView.selectedEventView = self
        }
    }
    
    // MARK: Dragging
    
    /// A type to describe the drag & drop state of an `SCKEventView`.
    ///
    /// - idle: The view is not being dragged yet.
    /// - draggingDuration: The view is being stretched vertically.
    /// - draggingContent: The view is being moved to another position.
    private enum Status {
        case idle
        case draggingDuration(oldValue: Int, lastValue: Int)
        case draggingContent(
            oldStart: SCKRelativeTimeLocation,
            newStart: SCKRelativeTimeLocation,
            innerDelta: CGFloat
        )
    }
    
    /// The view's drag and drop state.
    private var draggingStatus: Status = .idle
    
    public override func mouseDragged(with event: NSEvent) {
        switch draggingStatus {
        // User began dragging from bottom
        case .idle where NSCursor.current() == NSCursor.resizeUpDown():
            draggingStatus = .draggingDuration(oldValue: eventHolder.cachedDuration,
                                              lastValue: eventHolder.cachedDuration)
            scheduleView.beginDragging(eventView: self)
            fallthrough
        // User continued dragging (and fallthrough)
        case .draggingDuration(_, _):
            parseDurationDrag(with: event)
        default:
            // User began dragging from center
            if case .idle = draggingStatus {
                draggingStatus = .draggingContent(oldStart: eventHolder.relativeStart,
                                                  newStart: eventHolder.relativeStart,
                                                  innerDelta: convert(event.locationInWindow, from: nil).y)
                scheduleView.beginDragging(eventView: self)
            }
            // User continued dragging (and fallthrough)
            parseContentDrag(with: event)
        }
        scheduleView.continueDragging()
    }
    
    private func parseDurationDrag(with event: NSEvent) {
        guard case .draggingDuration(let old, let last) = draggingStatus else {
            return
        }
        
        let superLoc = scheduleView.convert(event.locationInWindow, from: nil)
        let sDate = eventHolder.cachedScheduledDate
        if let eDate = scheduleView.calculateDate(for: scheduleView.relativeTimeLocation(for: superLoc)) {
            var newDuration = Int(trunc((eDate.timeIntervalSince(sDate) / 60.0)))
            if newDuration != last {
                if newDuration >= 5 {
                    eventHolder.cachedDuration = newDuration
                    let inSeconds = newDuration * 60
                    let endDate = eventHolder.cachedScheduledDate.addingTimeInterval(Double(inSeconds))
                    var relativeEnd = scheduleView.calculateRelativeTimeLocation(for: endDate)
                    if relativeEnd == Double(NSNotFound) {
                        relativeEnd = 1.0;
                    }
                    eventHolder.relativeLength = relativeEnd - eventHolder.relativeStart
                    scheduleView.invalidateLayout(for: self)
                } else {
                    newDuration = 5
                }
                innerLabel.stringValue = "\(newDuration) min"
                //Update context
                draggingStatus = .draggingDuration(oldValue: old, lastValue: newDuration)
            }
        }
    }
    
    private func parseContentDrag(with event: NSEvent) {
        guard case .draggingContent(let old, _, let delta) = draggingStatus else {
            return
        }
        
        var tPoint = scheduleView.convert(event.locationInWindow, from: nil)
        tPoint.y -= delta
        
        var newStartLoc = scheduleView.relativeTimeLocation(for: tPoint)
        if newStartLoc == SCKRelativeTimeLocationInvalid && tPoint.y < scheduleView.frame.midY {
            //May be too close to an edge, check if too low
            tPoint.y = scheduleView.contentRect.minY
            newStartLoc = scheduleView.relativeTimeLocation(for: tPoint)
        }
        if newStartLoc != SCKRelativeTimeLocationInvalid  {
            tPoint.y += frame.height
            let newEndLoc = scheduleView.relativeTimeLocation(for: tPoint)
            if newEndLoc != SCKRelativeTimeLocationInvalid {
                eventHolder.relativeStart = newStartLoc
                eventHolder.relativeEnd = newEndLoc
                eventHolder.cachedScheduledDate = scheduleView.calculateDate(for: newStartLoc)!
                draggingStatus = .draggingContent(oldStart: old, newStart: newStartLoc, innerDelta: delta)
            }
        }
    }
    
    // MARK: Mouse up
    
    public override func mouseUp(with event: NSEvent) {
        switch draggingStatus {
        case .draggingDuration(let old, let new):
            
            // Restore title 
            innerLabel.stringValue = eventHolder.cachedTitle
            
            var shouldContinue = true
            if let eventManager = scheduleView.controller.eventManager {
                shouldContinue = eventManager.scheduleController(scheduleView.controller, shouldChangeDurationOfEvent: eventHolder.representedObject, from: old, to: new)
            }
            if shouldContinue {
                commitDraggingOperation {
                    eventHolder.representedObject.duration = new
                }
            } else {
                eventHolder.cachedDuration = old
                flushUncommitedDraggingOperation()
            }
            
            scheduleView.endDragging()
            
        case .draggingContent(let oldStart, let newStart, _):
            if let scheduledDate = scheduleView.calculateDate(for: newStart) {
                var shouldContinue = true
                if let eventManager = scheduleView.controller.eventManager {
                    shouldContinue = eventManager.scheduleController(scheduleView.controller, shouldChangeDateOfEvent: eventHolder.representedObject, from: eventHolder.representedObject.scheduledDate, to: scheduledDate)
                }
                if shouldContinue {
                    commitDraggingOperation {
                        eventHolder.representedObject.scheduledDate = scheduledDate
                    }
                } else {
                    let oldDate = scheduleView.calculateDate(for: oldStart)!
                    eventHolder.cachedScheduledDate = oldDate
                    flushUncommitedDraggingOperation()
                }
            }
            scheduleView.endDragging()
            
        case .idle where event.clickCount == 2:
            scheduleView.controller.eventManager?.scheduleController(scheduleView.controller, didDoubleClickEvent: eventHolder.representedObject)
        default: break;
        }
        draggingStatus = .idle
        needsDisplay = true
    }
    
    private func commitDraggingOperation(withChanges closure: () -> ()) {
        eventHolder.stopObservingRepresentedObjectChanges()
        closure()
        eventHolder.resumeObservingRepresentedObjectChanges()
        eventHolder.recalculateRelativeValues()
        // FIXME: needed? will be called from endDraggingEventView
        scheduleView.invalidateLayoutForAllEventViews()
    }
    
    private func flushUncommitedDraggingOperation() {
        eventHolder.recalculateRelativeValues()
        scheduleView.invalidateLayout(for: self)
    }
    
    // MARK: Right mouse events
    
    public override func menu(for event: NSEvent) -> NSMenu? {
        guard let c = scheduleView.controller, let eM = c.eventManager else {
            return nil
        }
        return eM.scheduleController(c, menuForEvent: eventHolder.representedObject)
    }
    
    public override func rightMouseDown(with event: NSEvent) {
        // Select the event if not selected and continue showing the contextual
        // menu if any.
        if scheduleView.selectedEventView != self {
            scheduleView.selectedEventView = self
        }
        super.rightMouseDown(with: event)
    }
    
}
