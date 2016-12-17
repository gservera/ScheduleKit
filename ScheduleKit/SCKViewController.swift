/*
 *  SCKViewController.swift
 *  ScheduleKit
 *
 *  Created:    Guillem Servera on 2/11/2016.
 *  Copyright:  © 2014-2016 Guillem Servera (https://github.com/gservera)
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

import AppKit

/// The date interval mode for a SCKViewController.
@objc public enum SCKViewControllerMode: Int {
    
    /// The controller works with a single day date interval.
    case day
    /// The controller works with a week date interval.
    case week
}

/// A NSViewController subclass that sets up a schedule view embedded in a scroll
/// view and displays a set of events within a day or a week time interval. The
/// SCKViewController implements all the event processing and conflict handling
/// logic. It also manages the zooming and the day/week offsetting for you.
///
/// To provide events to a SCKViewController, just make an object or a subclass
/// conform to `SCKEventManaging` or `SCKConcreteEventManaging` and set the 
/// `eventManager`property. Finally, call a suitable reload data method to execute 
/// the first event fetch.
/// 
/// If you use Swift, you may choose between implementing `SCKEventManaging` or
/// working in concrete mode by conforming to `SCKConcreteEventManaging` and
/// declaring an event type. Use the concrete mode when working with a single
/// event class to benefit from Swift's type safety and work with better-typed
/// methods in your event manager implementation. If you do so, you must also use
/// the `reloadData(ofConcreteType:)` method to begin new event fetches. If you
/// work with multiple event classes, you'll have to use `SCKEventManaging` and
/// call `reloadData()` to load new events instead.
///
/// Events are fetched synchronously by default, but asynchronous event fetching
/// is also available by setting the `loadsEventsAsynchronously` property to true
/// and implementing the proper event manager methods.
///
/// - Note: `SCKConcreteEventManaging` is not available in Objective-C. In
///         addition, the event manager must be set via `-setObjCDelegate:`.
///
@objc open class SCKViewController: NSViewController, AsynchronousRequestParsing {
    
    // MARK: - UI setup
    
    /// Set this attribute to control whether events must be displayed in a
    /// `SCKDayView` or in a `SCKWeekView`. Ideally, set the appropiate value
    /// before the controller's view is loaded, overriding `loadView()` if 
    /// necessary. You may also use this property to switch between modes once
    /// a schedule view is already installed.
    @objc public var mode: SCKViewControllerMode = .day {
        didSet {
            // If value changed and a view was already installed, replace it.
            if mode != oldValue && isViewLoaded {
                setUpScheduleView()
            }
        }
    }
    
    /// The scroll view managed by the controller.
    @objc public private(set) var scrollView: NSScrollView = {
        let sV = NSScrollView(frame: CGRect.zero)
        sV.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        sV.hasVerticalScroller = true
        return sV
    }()
    
    /// The schedule view managed by the controller
    @objc public private(set) var scheduleView: SCKView!
    
    /// Installs a new schedule view as the scroll view's document view, according
    /// to the value set in `mode`.
    private func setUpScheduleView() {
        let oldDelegate = scheduleView?.delegate
        let f = CGRect(origin: CGPoint.zero, size: scrollView.contentSize)
        let sView = (mode == .day) ? SCKDayView(frame: f) : SCKWeekView(frame: f)
        scrollView.documentView?.removeFromSuperview()
        scheduleView = nil
        scheduleView = sView
        sView.controller = self
        sView.delegate = oldDelegate
        sView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = scheduleView
        let p = sView.superview!
        sView.leadingAnchor.constraint(equalTo: p.leadingAnchor).isActive = true
        sView.trailingAnchor.constraint(equalTo: p.trailingAnchor).isActive = true
        sView.topAnchor.constraint(equalTo: p.topAnchor).isActive = true
        
        print("Setting up \(mode)")
    }
    
    
    
    
    // MARK: - View lifecycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        // Install the scroll view and the schedule view
        scrollView.frame = CGRect(origin: CGPoint.zero, size: view.frame.size)
        view.addSubview(scrollView, positioned: .below, relativeTo: nil)
        setUpScheduleView()
    }
    
    
    
    
    // MARK: - Event management
    
    /// The set of event holders backing the events managed by this controller.
    private(set) var eventHolders: Set<SCKEventHolder> = []
    
    
    /// The object that works as the data source and delegate for this controller.
    /// A common implementation when subclassing `SCKViewController` is to make
    /// the subclass conform to either `SCKEventManaging` or 
    /// `SCKConcreteEventManaging` and set itself as the event manager.
    ///
    /// - Note: In an Objective-C target, you must use the `delegate` property 
    ///         instead.
    public weak var eventManager: SCKEventManaging?
    
    // Set to true when `reloadData()` or `reloadData(ofConcreteType:)` have been
    // called at least once.
    private var _hasLoadedEventsAtLeastOnce: Bool = false
    
    // Set to true when working with an event manager conforming to 
    // `SCKConcreteEventManaging`.
    private var _eventManagerIsConcrete: Bool = false
    
    
    /// Triggers a synchronous or asynchronous event fetch operation on the event
    /// manager object. The used method will depend on the value of the
    /// `loadsEventsAsynchronously` property.
    ///
    /// - Important: This is the method you should call to reload data from an
    ///              Objective-C target or when working with multiple event 
    ///              classes, but *never* in the concrete type mode. See more
    ///              about the available options in the class description. Once
    ///              you've called this, *you must always reload data using the
    ///              same method* (and not `reloadData(ofConcreteType)`.
    ///
    @objc public final func reloadData() {
        guard !(_hasLoadedEventsAtLeastOnce && _eventManagerIsConcrete) else {
            NSLog("Warning: Attempting to reload data using `reloadData()` in " +
                  "concrete mode. Use `reloadData(ofConcreteType:)` instead.")
            return
        }
        _requestInit = SCKEventRequest.init(controller:dateInterval:)
        _internalReloadData()
        _eventManagerIsConcrete = false
        _hasLoadedEventsAtLeastOnce = true
    }
    
    /// Triggers a synchronous or asynchronous event fetch operation on the event
    /// manager object. The used method will depend on the value of the
    /// `loadsEventsAsynchronously` property.
    ///
    /// - Important: This is the method you should call to reload data when 
    ///              working with a single event class in Swift, but *never* when
    ///              working with multiple event classes. See more about the 
    ///              available options in the class description. Once you've 
    ///              called this, *you must always reload data using the same 
    ///              method* (and not `reloadData()`.
    ///
    /// - Parameter ofConcreteType: The event class being used with this controller.
    public final func reloadData<T: SCKEvent>(ofConcreteType: T.Type) {
        guard !(_hasLoadedEventsAtLeastOnce && !_eventManagerIsConcrete) else {
            NSLog("Warning: Attempting to reload data using `reloadData(ofConcreteType:)`" +
                  "in the default mode. Use `reloadData()` instead.")
            return
        }
        _requestInit = SCKConcreteEventRequest<T>.init(controller:dateInterval:)
        _internalReloadData()
        _eventManagerIsConcrete = true
        _hasLoadedEventsAtLeastOnce = true
    }
    
    
    
    // MARK: - Asynchronous event loading
    
    /// Set this property to `true` to perform event fetching asyncronously.
    /// Default value is `false`.
    public var loadsEventsAsynchronously: Bool = false
    
    
    /// A set to track all the event requests initiated by this controller.
    public var asynchronousRequests: Set<SCKEventRequest> = []
    
    /// Parses the data from a completed asynchronous event request. Called by
    /// `SCKEventRequest` or `SCKConcreteEventRequest<T>` objects when matching
    /// events are passed to the `complete(with:)` method. Cancelled requests or
    /// requests with date intervals different than the schedule view interval are
    /// ignored.
    ///
    /// - Parameters:
    ///   - asynchronouslyLoadedEvents: The fetched events.
    ///   - request: The event request that was completed.
    public final func parseData(in asynchronouslyLoadedEvents: [SCKEvent],
                                  from request: SCKEventRequest) {
        guard scheduleView != nil && !scheduleView.isInvalidatingLayout else {
            NSLog("Waiting for relayout to terminate before reloading data")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.parseData(in: asynchronouslyLoadedEvents, from: request)
            }
            return
        }
        guard !request.isCanceled && request.dateInterval == scheduleView.dateInterval else {
            NSLog("Skipping request")
            return
        }
        parseEvents(asynchronouslyLoadedEvents)
    }
    
    
    // The closure that should be used to create asynchronous event requests. It
    // depens on whether we're working in the concrete type mode or not.
    private(set) var _requestInit = SCKEventRequest.init(controller:dateInterval:)
    
    
    
    
    // MARK: - Internal event parsing
    
    // Triggers the actual reload data operation. This method is necessary to
    // ensure that the right data source methods get called on the event manager,
    // since they may vary when working with a `SCKConcreteEventManaging` object
    // in the asynchronous mode.
    internal func _internalReloadData() {
        guard scheduleView != nil else { return }
        if loadsEventsAsynchronously {
            let request = _requestInit(self, scheduleView.dateInterval)
            _asyncReloadData(request: request )
        } else {
            _syncReloadData()
        }
    }
    
    // Cancels previous asynchronous event requests and triggers a new one.
    private func _asyncReloadData(request: SCKEventRequest) {
        for request in asynchronousRequests {
            request.cancel()
            // Not removing, cancel will remove it from the array
        }
        asynchronousRequests.insert(request)
        eventManager?.scheduleController(self, didMakeEventRequest: request)
    }
    
    // Triggers a new synchronous event fetch.
    private func _syncReloadData() {
        guard !scheduleView.isInvalidatingLayout else {
            NSLog("Waiting for relayout to terminate before reloading data")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?._syncReloadData()
            }
            return
        }
        if let events = eventManager?.events(in: scheduleView.dateInterval, for: self) {
            parseEvents(events)
        }
    }
    
    
    // A reference to the events loaded in the last fetch that is compared to the
    // newly loaded ones to determine if both sets are equal and thus, the event
    // processing is innecessary.
    private var _lastFetch: NSPointerArray = NSPointerArray.weakObjects()

    
    /// The common pathway for parsing both syncrhonously and asynchronously
    /// loaded events. This method performs a series of operations:
    ///
    /// 1. Compares the passed events to the last fetch. If they're the same, the
    ///    processing ends by simply invalidating their event views' layout.
    /// 2. If the sets are different, updates the _lastFecth property and
    ///    continues.
    ///
    /// - Parameter events: The events to be parsed.
    private func parseEvents(_ events: [SCKEvent]) {
        let eventSet = NSSet(array: events)
        guard eventSet != NSSet(array: _lastFetch.allObjects) else {
            print("Fetched events are the same as in last fetch. Will just re-layout them.")
            scheduleView.invalidateLayoutForAllEventViews(animated: false)
            return
        }
        
        // Update last fetch
        _lastFetch = NSPointerArray.weakObjects()
        for e in events {
            assert(scheduleView.dateInterval.contains(e.scheduledDate), "Invalid scheduledDate (\(e.scheduledDate)) for new event: \(e) in schedule view with date interval \(scheduleView.dateInterval); Asynchronous: \(loadsEventsAsynchronously)")
            _lastFetch.addPointer(Unmanaged.passUnretained(e).toOpaque())
        }
        
        // Create a mutable copy for events to be added.
        let eventsToBeInserted = eventSet.mutableCopy() as! NSMutableSet
        
        // Evaluate previously created event holders
        for existingHolder in eventHolders {
            if eventSet.contains(existingHolder.representedObject) &&
                existingHolder.representedObject.scheduledDate == existingHolder.cachedScheduledDate {
                // The holder's represented object is still included and has the 
                // same date. We'll reuse the event holder.
                eventsToBeInserted.remove(existingHolder.representedObject)
            } else {
                // The holder's represented object is now excluded or has a 
                // different date. We'll destroy the event holder.
                existingHolder.stopObservingRepresentedObjectChanges()
                scheduleView.removeEventView(existingHolder.eventView!)
                existingHolder.eventView?.removeFromSuperview()
                eventHolders.remove(at: eventHolders.index(of: existingHolder)!)
            }
        }
        
        // Insert new events
        for e in eventsToBeInserted {
            let eventView = SCKEventView(frame: .zero)
            scheduleView.addSubview(eventView)
            scheduleView.addEventView(eventView)
            if let holder = SCKEventHolder(event: e as! SCKEvent, view: eventView, controller: self) {
                eventView.eventHolder = holder
                eventHolders.insert(holder)
            } else {
                print("Warning: Could not generate event holder")
            }
            
        }
        
        // Invalidate the view's layout.
        scheduleView.invalidateLayoutForAllEventViews(animated: false)
    }
    
    
    
    
    // MARK: - Conflict handling
    
    /// Returns an array of event holders whose time interval intersects with a 
    /// given event holder, sorted by the criteria: relativeStart > cachedTitle
    /// > description (all ordered ascending).
    ///
    ///
    /// - Parameter holder: The event holder whose values should be compared.
    /// - Returns: The resulting event holder array. It always includes `holder`.
    internal func resolvedConflicts(for holder: SCKEventHolder) -> [SCKEventHolder] {
        let eStart = holder.relativeStart
        let eEnd = holder.relativeEnd
        let unsortedConflicts = eventHolders.filter {
            $0.isReady && !($0.relativeEnd <= eStart || $0.relativeStart >= eEnd)
        }
        assert(unsortedConflicts.count > 0)
        let sortedConflicts = unsortedConflicts.sorted { (a, b) -> Bool in
            if a.relativeStart != b.relativeStart {
                return (a.relativeStart < b.relativeStart)
            } else {
                if a.cachedTitle != b.cachedTitle {
                    return a.cachedTitle.compare(b.cachedTitle) == .orderedAscending
                }
                return String(describing:a).compare(String(describing:b)) == .orderedAscending
            }
        }
        return sortedConflicts
    }
    
    
    
    
    // MARK: - User actions
    
    /// Displays the previous day or week and performs a new event fetch.
    ///
    /// - Parameter sender: The UI control that initiated the action.
    @IBAction public func decreaseOffset(_ sender: AnyObject) {
        switch mode {
        case .day:  (scheduleView as? SCKDayView)?.decreaseDayOffset(sender)
        case .week: (scheduleView as? SCKWeekView)?.decreaseWeekOffset(sender)
        }
    }
    
    
    /// Displays the next day or week and performs a new event fetch.
    ///
    /// - Parameter sender: The UI control that initiated the action.
    @IBAction public func increaseOffset(_ sender: AnyObject) {
        switch mode {
        case .day:  (scheduleView as? SCKDayView)?.increaseDayOffset(sender)
        case .week: (scheduleView as? SCKWeekView)?.increaseWeekOffset(sender)
        }
    }
    
    
    /// Displays the default date interval (today or this week) and performs a new
    /// event fetch.
    ///
    /// - Parameter sender: The UI control that initiated the action.
    @IBAction public func resetOffset(_ sender: AnyObject) {
        switch mode {
        case .day:  (scheduleView as? SCKDayView)?.resetDayOffset(sender)
        case .week: (scheduleView as? SCKWeekView)?.resetWeekOffset(sender)
        }
    }
    
    
    /// Decreases the schedule view's hour height.
    ///
    /// - Parameter sender: The UI control that initiated the action.
    @IBAction public func decreaseZoomFactor(_ sender: AnyObject) {
        (scheduleView as? SCKGridView)?.decreaseZoomFactor()
    }
    
    
    /// Increases the schedule view's hour height.
    ///
    /// - Parameter sender: The UI control that initiated the action.
    @IBAction public func increaseZoomFactor(_ sender: AnyObject) {
        (scheduleView as? SCKGridView)?.increaseZoomFactor()
    }
    
    
    
    // MARK: - Objective-C Compatibility
    
    /// The object that works as the data source and delegate for this controller.
    /// Use the `-setObjCDelegate:` method to set it.
    ///
    /// - Note: In a Swift target, you must use the `eventManager` property
    ///         instead.
    @objc public private(set) weak var delegate: SCKObjCEventManaging?
    
    // The proxy object set as `eventManager` to represent the `delegate` in an
    // Objective-C target.
    private var _delegateProxy: _SCKObjCEventManagingProxy?
    
    @available(*, unavailable)
    // Sets the `delegate` property (Objective-C only).
    @objc public func setObjCDelegate(_ delegate: SCKObjCEventManaging?) {
        self.delegate = delegate
        if let delegate = delegate {
            _delegateProxy = _SCKObjCEventManagingProxy(delegate)
        } else {
            _delegateProxy = nil
        }
        self.eventManager = _delegateProxy
    }
    
    
    
    
    // MARK: - Advanced features
    
    /// Stops observing title, user, duration and scheduledDate changes from a
    /// given object. After calling this method, the schedule view will not
    /// reflect any change in that event.
    ///
    /// - Parameter event: The event that you don't want to be observed.
    @objc public final func stopObservingChanges(from event: SCKEvent) {
        for holder in eventHolders {
            if holder.representedObject.isEqual(event) {
                holder.stopObservingRepresentedObjectChanges()
                break
            }
        }
    }
    
}
