/*
 *  SCKView.swift
 *  ScheduleKit
 *
 *  Created:    Guillem Servera on 24/12/2014.
 *  Copyright:  © 2014-2016 Guillem Servera (http://github.com/gservera)
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


/** SCKView is an abstract NSView subclass which implements common functionality for any
 * subclasses that display a collection of @c SCKEventView subviews provided by the
 * delegate of an associated @c SCKEventManager object. This base class provides:
 * - Basic date scope management via @c startDate, @c endDate and @c absoluteTimeInterval.
 * - Functional conversion between @c NSDate and @c SCKRelativeTimeLocation values, and
 *   also the @c relativeTimeLocationForPoint: which subclasses should override.
 * - Ability to get/set the coloring policy used to draw subviews' background.
 * - Basic event selection and deselection handling.
 * - Handling of double click on an empty space.
 * - Drag and drop feedback methods for SCKEventView class.
 * - Common event view (un)locking and relayout workflow.
 */
@objc public class SCKView: ViewBaseClass {
    /** This property is set to YES when a relayout has been triggered and back to NO when the
     process finishes. Mind that relayout methods are invoked quite often. */
    private(set) var isRelayoutInProgress: Bool = false
    
    /** Returns the number of seconds between @c startDate and @c endDate. */
    var absoluteTimeInterval: TimeInterval {
        return absoluteEndTimeRef - absoluteStartTimeRef
    }
    
    /** The minimum date being repesented. Setter sets view as needing display. Call super. */
    public internal(set) var startDate: Date = Date() {
        didSet {
            absoluteStartTimeRef = startDate.timeIntervalSinceReferenceDate
        }
    }
    
    /** The maximum date being repesented. Setter sets view as needing display. Call super. */
    public internal(set) var endDate: Date = Date() {
        didSet {
            absoluteEndTimeRef = endDate.timeIntervalSinceReferenceDate
        }
    }
    
    //Must call reloadData after
    @objc public func setDateBounds(lower sD: Date, upper eD: Date) {
        startDate = sD
        endDate = eD
        needsDisplay = true
    }
    
    /** The style used by subviews to draw their background. @see ScheduleKitDefinitions.h */
    @objc public var colorMode: SCKEventColorMode = .byEventKind {
        didSet {
            if colorMode != oldValue {
                for eventView in eventViews {
                    eventView.needsDisplay = true
                }
            }
        }
    }
    
    weak var selectedEventView: SCKEventView? {
        willSet {
            if selectedEventView != nil && newValue == nil {
                controller.eventManager?.scheduleControllerDidClearSelection(controller)
            }
        }
        didSet {
            for eventView in eventViews {
                eventView.needsDisplay = true
            }
            if selectedEventView != nil {
                controller.eventManager?.scheduleController(controller, didSelectEvent: selectedEventView!.eventHolder.representedObject)
            }
        }
    }
    
    @IBOutlet public weak var controller: SCKViewController!
    
    
    /**< Absolute value for @c startDate */
    private(set) var absoluteStartTimeRef: Double = 0.0
    /**< Absolute value for @c endDate */
    private(set) var absoluteEndTimeRef: Double = 0.0
    /**< SCKEventView subviews */
    private var eventViews: [SCKEventView] = []
    /**< When dragging, the subview being dragged */
    internal weak var eventViewBeingDragged: SCKEventView?
    /**< When dragging, SCKEventView(s) NOT being dragged */
    private var otherEventViews: [SCKEventView]?
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setUp()
    }
    
    func setUp() {
        
    }
    
    //FIXME: Notification observer
    
    class func keyPathsForValuesAffectingAbsoluteTimeInterval() -> NSSet {
        return NSSet(objects: #keyPath(SCKView.startDate),#keyPath(SCKView.endDate))
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        ColorClass.white.setFill()
        NSRectFill(dirtyRect)
    }
    

    public override func mouseDown(with event: NSEvent) {
        // Called when user clicks on an empty space.
        // Deselect selected event view if any
        selectedEventView = nil
        // If double clicked on valid coordinates, notify the event manager's delegate.
        if event.clickCount == 2 {
            let loc = convert(event.locationInWindow, from: nil)
            let offset = relativeTimeLocation(for: loc)
            if offset != Double(NSNotFound) {
                let blankDate = calculateDate(for: offset)!
                controller.eventManager?.scheduleController(controller, didDoubleClickBlankDate: blankDate)
            }
        }
    }

    
    public override var isFlipped: Bool { return true }
    public override var isOpaque: Bool { return true }
    
    
    
    
    
    
    
    
    /**
     *  Calculates the date represented by a specific relative time location between @c
     *  startDate and @c endDate. Note that seconds are rounded so they'll be zero.
     *  @param offset The relative time location. Should be a value between 0.0 and 1.0.
     *  @return The calculated NSDate object or nil if @c offset is not valid.
     */
    func calculateDate(for relativeTimeLocation: Double) -> Date? {
        guard relativeTimeLocation >= 0.0 && relativeTimeLocation <= 1.0 else {
            return nil
        }
        var numberOfSeconds = Int(trunc(absoluteStartTimeRef + relativeTimeLocation * absoluteTimeInterval))
        // Round to next minute
        while numberOfSeconds % 60 > 0 {
            numberOfSeconds += 1
        }
        return Date(timeIntervalSinceReferenceDate: TimeInterval(numberOfSeconds))
    
    }
    
    
    /**
     *  Calculates the relative time location between @c startDate and @c endDate for a given
     *  NSDate object.
     *
     *  @param date The date from which to perform the calculation. Should not be nil.
     *  @return A double value between 0.0 and 1.0 representing the relative position of @c
     *  date between @c startDate and @c endDate; or @c SCKRelativeTimeLocationNotFound if @c
     *  date is before @c startDate or after @c endDate.
     */
    func calculateRelativeTimeLocation(for date: Date) -> Double {
        let timeRef = date.timeIntervalSinceReferenceDate
        guard timeRef >= absoluteStartTimeRef && timeRef <= absoluteEndTimeRef else {
            return Double(SCKRelativeTimeLocationNotFound)
        }
        return (timeRef - absoluteStartTimeRef) / absoluteTimeInterval
    }
    
    /**
     *  Calculates the relative time location between @c startDate and @c for a given point
     *  inside the view coordinates. Default implementation always returns
     *  SCKRelativeLocationNotFound, consider overriding this method in subclasses.
     *
     *  @param location The NSPoint for which to perform the calculation.
     *  @return In subclasses, a double value between 0.0 and 1.0 representing the relative
     *  position of @c location between @c startDate and @c endDate; or @c
     *  SCKRelativeTimeLocationNotFound if @c location falls out of the content rect.
     */
    func relativeTimeLocation(for point: CGPoint) -> Double {
        return Double(SCKRelativeTimeLocationNotFound)
    }
    
    //MARK: - Event view layout
    
    /**
     *  This methods performs a series of operations in order to relayout an array of
     *  SCKEventView objects according to their date, duration and other events in conflict.
     *  The full process implies locking all subviews' event holder (as to prevent changes
     *  on their properties while conflict calculations take place), calling
     *  @c relayoutEventView:animated: for each SCKEventView in @c eventViews and finally
     *  unlocking the previously locked event holders.
     *
     *  @discussion When an event view is being dragged, its event holder does not get locked
     *  or unlocked.
     *  @discussion Don't override this method. See @c beginRelayout and @c endRelayout instead.
     *
     *  @param eventViews The array of SCKEventView objects to be redrawn.
     *  @param animation  Pass YES if you want relayout to have animation. Pass no instead.
     */
    func invalidateFrames(for eventViews: [SCKEventView]) {
        guard !isRelayoutInProgress else {
            Swift.print("Warning: Invalidation already triggered")
            return
        }
        var allHolders = controller.eventHolders
        if eventViewBeingDragged != nil {
            let idx = allHolders.index(where: { (tested) -> Bool in
                return (tested === eventViewBeingDragged!.eventHolder!)
            })!
            allHolders.remove(at: idx)
        }
        
        beginRelayout()
        
        for holder in allHolders {
            holder.lock()
        }
        
        //TODO: Combine animations
        for eventView in eventViews {
            invalidateFrame(for: eventView)
        }
        
        for holder in allHolders {
            holder.unlock()
        }
        
        endRelayout()
    }
    
    /**
     *  Calls @c triggerRelayoutForEventViews:animated: passing all event views and NO as 
     *  parameters.
     */
    func invalidateFrameForAllEventViews() {
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current().duration = 1.0
        invalidateFrames(for: eventViews)
        animator().layoutSubtreeIfNeeded()
        NSAnimationContext.endGrouping()
    }

    
    ///MARK: - Subview management
    
    /**
     *  Adds an SCKEventView to the array of subviews managed by this
     *  instance. This method is typically called from the event manager.
     *  @param eventView The view to be added. Must already be a subview of self.
     */
    internal func addEventView(_ eventView: SCKEventView) {
        eventViews.append(eventView)
    }
    
    /**
     *  Removes an SCKEventView from the array of subviews managed by
     *  this instance. This method is typically called from the event manager.
     *  @param eventView The view to be removed.
     *  @discussion @c -removeFromSuperview should also be called on @c eventView.
     */
    
    internal func removeEventView(_ eventView: SCKEventView) {
        eventViews.remove(at: eventViews.index(of: eventView)!)
    }
    
    //MARK: - Drag & drop support
    
    /**
     *  Called from an @c SCKEventView subview when a drag action begins.
     *  This method sets @c _eventViewBeingDragged and @c _otherEventViews,
     *  and also calls @c -lock on the event view's event holder.
     *  @discussion Locking and unlocking for SCKEventView subviews being dragged are
     *  handled here (and not during successive relayout processes) in order to avoid
     *  inconsistencies between the drag & drop action and changes that could be
     *  observed while the @c SCKEventView is being dragged.
     *  @param eV The @c SCKEventView being dragged.
     */
    internal func beginDraggingEventView(_ eventView: SCKEventView) {
        var subviews = eventViews
        subviews.remove(at: subviews.index(of: eventView)!)
        otherEventViews = subviews
        eventViewBeingDragged = eventView
        eventView.eventHolder.lock()
    }
    
    /**
     *  Called from an @c SCKEventView subview when a drag action moves.
     *  This method sets this view as needing display (to make dragging guides appear)
     *  and triggers a relayout for other event views (since conflicts may have changed).
     *  @param eV The @c SCKEventView being dragged.
     */
    internal func continueDraggingEventView(_ eventView: SCKEventView) {
        invalidateFrames(for: otherEventViews!)
        layoutSubtreeIfNeeded()
        needsDisplay = true
    }
    
    /**
     *  Called from an @c SCKEventView subview when a drag action ends.
     *  This method clears @c _eventViewBeingDragged and @c _otherEventViews,
     *  calls @c -unlock on the event view's event holder, triggers a final relayout
     *  and finally sets this view as needing display (to clear dragging guides).
     *  @discussion Locking and unlocking for SCKEventView subviews being dragged are
     *  handled here (and not during successive relayout processes) in order to avoid
     *  inconsistencies between the drag & drop action and changes that could be
     *  observed while the @c SCKEventView is being dragged.
     *  @param eV The @c SCKEventView being dragged.
     */
    internal func endDraggingEventView(_ eventView: SCKEventView) {
        //FIXME: Needed eventViewBeingDragged having this param?
        guard let dragged = eventViewBeingDragged else {
            return
        }
        dragged.eventHolder.unlock()
        otherEventViews = []
        eventViewBeingDragged = nil
        invalidateFrameForAllEventViews()
        needsDisplay = true
    }
    
    //MARK: - Event view layout
    
    /**
     *  This method is called when a relayout is triggered. You may override it to
     *  perform additional tasks before the actual relayout process takes place. In
     *  that case, you must call super.
     */
    private func beginRelayout() {
        isRelayoutInProgress = true
    }
    
    /**
     *  SCKView subclasses override this method to implement positioning (updating
     *  frame) of their SCKEventView subviews when a relayout process is triggered.
     *  The ultimate objective of this method is to calculate a new frame for a
     *  concrete subview based on the properties of its holder. Conflict calculations
     *  should also be performed here. Default implementation does nothing.
     *
     *  @param eventView The event view whose frame needs to be updated.
     *  @param animation YES if change should be animated, NO instead.
     */
    func invalidateFrame(for eventView: SCKEventView) {
        // Default implementation does nothing
        needsLayout = true
    }
    
    /**
     *  This method is called when a relayout finishes. You may override it to
     *  perform additional tasks after the actual relayout process takes place. In
     *  that case, you must call super.
     */
    func endRelayout() {
        isRelayoutInProgress = false
    }
    
}
