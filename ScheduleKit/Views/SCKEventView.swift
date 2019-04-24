/*
 *  SCKEventView.swift
 *  ScheduleKit
 *
 *  Created:    Guillem Servera on 24/12/2014.
 *  Copyright:  © 2014-2019 Guillem Servera (https://github.com/gservera)
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
        let label = SCKTextField(frame: .zero)
        label.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(rawValue: 249), for: .horizontal)
        label.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(rawValue: 249), for: .vertical)
        label.autoresizingMask = [.width, .height]
        label.textColor = .black
        return label
    }()

    // MARK: - Drawing

    /// A cached copy of the last used background color to increase drawing
    /// performance. Invalidated when the schedule view's color mode changes or
    /// when the event's user or user event color changes in .byEventOwner mode.
    internal var backgroundColor: NSColor?

    public override func draw(_ dirtyRect: CGRect) {
        let isAnyViewSelected = (scheduleView.selectedEventView != nil)
        let isThisViewSelected = (scheduleView.selectedEventView == self)

        var fillColor: NSColor

        if isAnyViewSelected && !isThisViewSelected {
            // Set color to gray when another event is selected
            fillColor = NSColor.windowBackgroundColor
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
        if isThisViewSelected, case .draggingContent(_, _, _) = draggingStatus {
            if #available(OSX 10.14, *) {
                fillColor = fillColor.withSystemEffect(.deepPressed)
            } else {
                fillColor = fillColor.blended(withFraction: 0.2, of: .black) ?? .black
            }
        }

        let wholeRect = CGRect(origin: CGPoint.zero, size: frame.size)

        fillColor.setFill()
        wholeRect.fill()
        let strokeColor: NSColor
        if #available(OSX 10.14, *) {
            strokeColor = fillColor.withSystemEffect(.pressed)
        } else {
            strokeColor = fillColor.blended(withFraction: 0.2, of: .black) ?? .black
        }
        let leftStrokeRect = CGRect(origin: .zero, size: CGSize(width: 4.0, height: frame.height))
        let bottomStrokeRect = CGRect(origin: CGPoint(x: 0, y: frame.height-1),
                                      size: CGSize(width: frame.width, height: 1))
        strokeColor.setFill()
        leftStrokeRect.fill()
        bottomStrokeRect.fill()
        if scheduleView.contentRect.origin.y > scheduleView.convert(frame.origin, from: self).y
            || scheduleView.contentRect.maxY < frame.maxY {
            fillColor.withAlphaComponent(0.2).setFill()
        }

    }

    // MARK: - View lifecycle

    /// <#Description#>
    var widthConstraint: NSLayoutConstraint!
    /// <#Description#>
    var heightConstraint: NSLayoutConstraint!
    /// <#Description#>
    var leadingConstraint: NSLayoutConstraint!
    /// <#Description#>
    var topConstraint: NSLayoutConstraint!

    /// The `SCKView` instance th which this view has been added.
    internal weak var scheduleView: SCKView!

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

    public override var isOpaque: Bool {
        return true
    }

    public override var isFlipped: Bool {
        return true
    }

    public override func resetCursorRects() {
        let rect = NSRect(x: 0, y: frame.height-2.0, width: frame.width, height: 4.0)
        addCursorRect(rect, cursor: .resizeUpDown)
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
        case .idle where NSCursor.current == NSCursor.resizeUpDown:
            draggingStatus = .draggingDuration(oldValue: eventHolder.cachedDuration,
                                              lastValue: eventHolder.cachedDuration)
            scheduleView.beginDragging(eventView: self)
            parseDurationDrag(with: event)
        // User continued dragging
        case .draggingDuration:
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
                        relativeEnd = 1.0
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
        if newStartLoc != SCKRelativeTimeLocationInvalid {
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
            let event = eventHolder.representedObject
            var shouldContinue = true
            if let eventManager = scheduleView.controller.eventManager {
                shouldContinue = eventManager.scheduleController(scheduleView.controller,
                                                                 shouldChangeDurationOfEvent: event,
                                                                 from: old,
                                                                 to: new)
            }
            if shouldContinue {
                commitDraggingOperation {
                    event.duration = new
                }
            } else {
                eventHolder.cachedDuration = old
                flushUncommitedDraggingOperation()
            }

            scheduleView.endDragging()

        case .draggingContent(let oldStart, let newStart, _):
            if let scheduledDate = scheduleView.calculateDate(for: newStart) {
                let event = eventHolder.representedObject
                var shouldContinue = true
                if let eventManager = scheduleView.controller.eventManager {
                    shouldContinue = eventManager.scheduleController(scheduleView.controller,
                                                                     shouldChangeDateOfEvent: event,
                                                                     from: eventHolder.representedObject.scheduledDate,
                                                                     to: scheduledDate)
                }
                if shouldContinue {
                    commitDraggingOperation {
                        event.scheduledDate = scheduledDate
                    }
                } else {
                    let oldDate = scheduleView.calculateDate(for: oldStart)!
                    eventHolder.cachedScheduledDate = oldDate
                    flushUncommitedDraggingOperation()
                }
            }
            scheduleView.endDragging()

        case .idle where event.clickCount == 2:
            scheduleView.controller.eventManager?.scheduleController(scheduleView.controller,
                                                                     didDoubleClickEvent: eventHolder.representedObject)
        default: break
        }
        draggingStatus = .idle
        needsDisplay = true
    }

    private func commitDraggingOperation(withChanges closure: () -> Void) {
        eventHolder.stopObservingRepresentedObjectChanges()
        closure()
        eventHolder.resumeObservingRepresentedObjectChanges()
        eventHolder.recalculateRelativeValues()
    }

    private func flushUncommitedDraggingOperation() {
        eventHolder.recalculateRelativeValues()
        scheduleView.invalidateLayout(for: self)
    }

    // MARK: Right mouse events

    public override func menu(for event: NSEvent) -> NSMenu? {
        guard let controller = scheduleView.controller, let eventManager = controller.eventManager else {
            return nil
        }
        return eventManager.scheduleController(controller, menuForEvent: eventHolder.representedObject)
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
