/*
 *  SCKView.swift
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

/// An object conforming to the `SCKViewDelegate` protocol must implement a
/// method required to set a color schedule view events.
@objc public protocol SCKViewDelegate {

    /// Implemented by a schedule view's delegate to provide different background
    /// colors for the different event types when the view's color mode is set to
    /// `.byEventKind`.
    ///
    /// - Parameters:
    ///   - eventKindValue: The event kind for which to return a color.
    ///   - scheduleView: The schedule view asking for the color.
    /// - Returns: The color that will be used as the corresponding event view's
    ///            background.
    @objc (colorForEventKind:inScheduleView:)
    optional func color(for eventKindValue: Int, in scheduleView: SCKView) -> NSColor
}

/// An abstract NSView subclass that implements the basic functionality to manage
/// a set of event views provided by an `SCKViewController` object. This class
/// provides basic handling of the displayed date interval and methods to convert
/// between these date values and view coordinates.
///
/// In addition, `SCKView` provides the default (and required) implementation for
/// event coloring, selection and deselection, handling double clicks on empty
/// dates and drag & drop.
///
/// - Note: Do not instantiate this class directly.
///
@objc public class SCKView: NSView {

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setUp()
    }

    /// This method is intended to provide a common initialization point for all 
    /// instances, regardless of whether they have been initialized using
    /// `init(frame:)` or `init(coder:)`. Default implementation does nothing.
    func setUp() { }

    /// The controller managing this view.
    @IBOutlet public weak var controller: SCKViewController!

    /// The schedule view's delegate.
    @objc public weak var delegate: SCKViewDelegate?

    // MARK: - NSView overrides

    override open var isFlipped: Bool {
        return true
    }

    override open var isOpaque: Bool {
        return true
    }

    public override func draw(_ dirtyRect: NSRect) {
        NSColor.controlBackgroundColor.setFill()
        dirtyRect.fill()
    }

    // MARK: - Date handling

    @objc public private(set) var startDate: Date = Date()
    @objc public private(set) var endDate: Date = Date()
    @objc public private(set) var duration: TimeInterval = 0
    
    /// The displayed date interval. Setting this value marks the view as needing
    /// display. You should call a reload data method on the controller object to
    /// provide matching events after calling this method.
    @available(OSX 10.12, *)
    @objc public var dateInterval: DateInterval {
        get { return DateInterval(start: startDate, end: endDate) }
        set { startDate = newValue.start; endDate = newValue.end; duration = newValue.duration; didChangeDateInterval() }
    }
    
    @available(OSX, deprecated: 10.12, message: "Use dateInterval property instead")
    @objc public func setDateIntervalWithDates(from start: Date, to end: Date) {
        startDate = start; endDate = end; duration = end.timeIntervalSince(start); didChangeDateInterval()
    }
    
    internal func didChangeDateInterval() {
        needsDisplay = true
    }


    // MARK: - Date transforms

    /// Calculates a date by transforming a relative time point in the schedule
    /// view's date interval.
    ///
    /// - Parameter relativeTimeLocation: A valid relative time location.
    /// - Note: Seconds are rounded to the next minute.
    /// - Returns: The calculated date or `nil` if `relativeTimeLocation` is not
    ///            a value compressed between 0.0 and 1.0.
    final func calculateDate(for relativeTimeLocation: SCKRelativeTimeLocation) -> Date? {
        guard relativeTimeLocation >= 0.0 && relativeTimeLocation <= 1.0 else {
            return nil
        }
        let start = startDate.timeIntervalSinceReferenceDate
        let length = duration * relativeTimeLocation
        var numberOfSeconds = Int(trunc(start + length))
        // Round to next minute
        while numberOfSeconds % 60 > 0 {
            numberOfSeconds += 1
        }
        return Date(timeIntervalSinceReferenceDate: TimeInterval(numberOfSeconds))
    }

    /// Calculates the relative time location for a given date.
    ///
    /// - Parameter date: A date contained in the schedule view's date interval.
    /// - Returns: A value between 0.0 and 1.0 representing the relative position
    ///            of `date` in the schedule view's date interval; or 
    ///            `SCKRelativeTimeLocationInvalid` if `date` is not contained in
    ///            that interval.
    final func calculateRelativeTimeLocation(for date: Date) -> SCKRelativeTimeLocation {
        guard startDate <= date && date <= endDate else {
            return SCKRelativeTimeLocationInvalid
        }
        let dateRef = date.timeIntervalSinceReferenceDate
        let startDateRef = startDate.timeIntervalSinceReferenceDate
        return (dateRef - startDateRef) / duration
    }

    /// Calculates the relative time location in the view's date interval for a
    /// given point in the view's coordinate system. The default implementation
    /// returns `SCKRelativeTimeLocationInvalid`. Subclasses must override this
    /// method in order to be able to transform screen points into date values.
    ///
    /// - Parameter point: The point for which to perform the calculation.
    /// - Returns: A value between 0.0 and 1.0 representing the relative time
    ///            location for the given point, or `SCKRelativeTimeLocationInvalid`
    ///            in case `point` falls out of the view's content rect.
    func relativeTimeLocation(for point: CGPoint) -> SCKRelativeTimeLocation {
        return SCKRelativeTimeLocationInvalid
    }

    // MARK: - Subview management

    /// An array containing all the event views displayed in this view.
    private(set) var eventViews: [SCKEventView] = []

    /// Registers a recently created `SCKEventView` with this instance. This
    /// method is called from the controller after adding the view as a subview
    /// of this schedule view. You should not call this method directly.
    ///
    /// - Parameter eventView: The event view to be added.
    internal final func addEventView(_ eventView: SCKEventView) {
        eventViews.append(eventView)
    }

    /// Removes an `SCKEventView` from the array of subviews managed by this
    /// instance. This method is called from the controller before removing the
    /// view from its superview. You should not call this method directly.
    ///
    /// - Parameter eventView: The event view to be removed. Must have been added
    ///                        previously via `addEventView(_:)`.
    internal final func removeEventView(_ eventView: SCKEventView) {
        guard let index = eventViews.firstIndex(of: eventView) else {
            Swift.print("Warning: Attempting to remove an unregistered event view")
            return
        }
        eventViews.remove(at: index)
    }

    // MARK: - Event view layout

    /// The portion of the view used to display events. Defaults to the full view
    /// frame. Subclasses override this property if they display additional items
    /// such as day or hour labels alongside the event views.
    public var contentRect: CGRect {
        return CGRect(origin: .zero, size: frame.size)
    }

    /// Indicates whether an event layout invalidation has been triggered by
    /// invoking the `invalidateFrames(for:)` method. Turns back to `false` when
    /// the invalidation process completes.
    private(set) var isInvalidatingLayout: Bool = false

    /// Override this method to perform additional tasks before the layout
    /// invalidation takes place. If you do so, don't forget to call super.
    public func beginLayoutInvalidation() {
        isInvalidatingLayout = true
    }

    /// Override this method to perform additional tasks after the layout
    /// invalidation has finished. If you do so, don't forget to call super.
    public func endLayoutInvalidation() {
        isInvalidatingLayout = false
    }

    /// Subclasses may override this method to perform additional calculations
    /// required to compute the event view's frame when the `layout()` method is 
    /// called. An example of these calculations include conflict management. The
    /// default implementation does nothing.
    ///
    /// - Parameter eventView: The event view whose frame will be updated soon.
    /// - Note: Since the event view's frame will be eventually calculated in the
    ///         `layout()` method, you must avoid changing its frame in this one.
    func invalidateLayout(for eventView: SCKEventView) { }

    /// Triggers a series of operations that determine the frame of an array of
    /// `SCKEventView`s according to their event holder's properties and to other
    /// events which could be potentially in conflict with them. Eventually, the
    /// schedule view is marked as needing layout in order to perform the actual
    /// subview positioning and sizing.
    ///
    /// These opertations include freezing all subviews' event holder to guarantee
    /// that their data remains consistent during the whole process even if their
    /// represented object properties change.
    ///
    /// - Parameters:
    ///   - eventViews: The array of event views to be laid out.
    ///   - animated: Pass true to perform an animated subview layout.
    ///
    public final func invalidateLayout(for eventViews: [SCKEventView], animated: Bool = false) {
        guard !isInvalidatingLayout else {
            Swift.print("Warning: Invalidation already triggered")
            return
        }

        // 1. Prepare to invalidate (subclass customization point)
        beginLayoutInvalidation()

        // 2. Freeze event holders
        var holdersToFreeze = controller.eventHolders
        // Exclude event view being dragged (already frozen)
        if let draggedView = eventViewBeingDragged, let idx = holdersToFreeze.firstIndex(of: draggedView.eventHolder) {
            holdersToFreeze.remove(at: idx)
        }

        holdersToFreeze.forEach { $0.freeze() }

        // 3. Perform invalidation
        eventViews.forEach { invalidateLayout(for: $0) }

        // 4. Unfreeze event holders
        holdersToFreeze.forEach { $0.unfreeze() }

        // 5. Mark as needing layout
        needsUpdateConstraints = true

        // 6. Animate if requested
        if animated {
            NSAnimationContext.runAnimationGroup({ [unowned self] (context) in
                context.duration = 0.3
                context.allowsImplicitAnimation = true
                self.layoutSubtreeIfNeeded()
            }, completionHandler: nil)
        }

        // 7. Finish (subclass customization point)
        endLayoutInvalidation()
    }

    /// A convenience method to trigger layout invalidation for all event views.
    ///
    /// - Parameter animated: Pass true to perform an animated subview layout.
    public final func invalidateLayoutForAllEventViews(animated: Bool = false) {
        invalidateLayout(for: eventViews, animated: animated)
    }

    // MARK: - Event coloring

    /// The color style used to draw the different event views. Setting this
    /// value to a different style marks event views as needing display.
    @objc public var colorMode: SCKEventColorMode = .byEventKind {
        didSet {
            if colorMode != oldValue {
                for eventView in eventViews {
                    eventView.backgroundColor = nil
                    eventView.needsDisplay = true
                }
            }
        }
    }

    // MARK: - Event selection

    /// The currently selected event view or `nil` if none. Setting this value may
    /// trigger the `scheduleControllerDidClearSelection(_:)` and/or the
    /// `scheduleController(_:didSelectEvent:)` methods on the controller`s event
    /// manager when appropiate. In addition, it marks all event views as needing
    /// display in order to make them reflect the current selection.
    public weak var selectedEventView: SCKEventView? {
        willSet {
            if selectedEventView != nil && newValue == nil {
                controller.eventManager?.scheduleControllerDidClearSelection(controller)
            }
        }
        didSet {
            for eventView in eventViews {
                eventView.needsDisplay = true
            }
            if let selected = selectedEventView, let eventManager = controller.eventManager {
                //Event view has already checked if `s` was the same as old value.
                let theEvent = selected.eventHolder.representedObject
                eventManager.scheduleController(controller, didSelectEvent: theEvent)
            }
        }
    }

    public override func mouseDown(with event: NSEvent) {
        // Called when user clicks on an empty space.
        // Deselect selected event view if any
        selectedEventView = nil
        // If double clicked on valid coordinates, notify the event manager's delegate.
        if event.clickCount == 2 {
            let loc = convert(event.locationInWindow, from: nil)
            let offset = relativeTimeLocation(for: loc)
            if offset != SCKRelativeTimeLocationInvalid, let eventManager = controller.eventManager {
                let blankDate = calculateDate(for: offset)!
                eventManager.scheduleController(controller, didDoubleClickBlankDate: blankDate)
            }
        }
    }

    // MARK: - Drag & drop support

    /// When dragging, the subview being dragged.
    internal weak var eventViewBeingDragged: SCKEventView?

    internal func prepareForDragging() {
    }

    /// Called by an `SCKEventView` when a drag operation begins. This method
    /// sets the `eventViewBeingDragged` property and freezes the event view's
    /// holder to guarantee that its data remains consistent during the whole 
    /// process even if the represented object properties change.
    ///
    /// - Parameter eventView: The event view being dragged.
    internal final func beginDragging(eventView: SCKEventView) {
        eventViewBeingDragged = eventView
        eventView.eventHolder.freeze()
        prepareForDragging()
    }

    /// Called by an `SCKEventView` every time that `mouseDragged(_:)` is called.
    /// Performs a layout invalidation to handle new conflicts, applies layout and 
    /// marks the schedule view as needing display.
    internal final func continueDragging() {
        invalidateLayoutForAllEventViews()
        layoutSubtreeIfNeeded()
        needsDisplay = true
    }

    /// Called by an `SCKEventView` when a drag operation ends. This method sets
    /// the `eventViewBeingDragged` property to nil, unfreezes the draged view's
    /// event holder and triggers a final layout invalidation and drawing for this
    /// instance.
    internal final func endDragging() {
        guard let draggedEventView = eventViewBeingDragged else {
            Swift.print("Called endDragging() without an event view being dragged")
            return
        }
        draggedEventView.eventHolder.unfreeze()
        eventViewBeingDragged = nil
        invalidateLayoutForAllEventViews(animated: true)
        restoreAfterDragging()
        needsDisplay = true
    }

    internal func restoreAfterDragging() {
    }
}
