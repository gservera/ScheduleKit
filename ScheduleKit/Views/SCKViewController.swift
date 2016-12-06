//
//  SCKViewController.swift
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 2/11/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

import Cocoa

public enum SCKViewControllerMode {
    case day
    case week
}

@objc open class SCKViewController: NSViewController {
    
    
    public var mode: SCKViewControllerMode = .day {
        didSet {
            if mode != oldValue {
                switch mode {
                    case .day:  setUpDayView()
                    case .week: setUpWeekView()
                }
            }
        }
    }
    
    public private(set) var scrollView: NSScrollView!
    @objc public private(set) var scheduleView: SCKView!

    override open func viewDidLoad() {
        super.viewDidLoad()
        scrollView = NSScrollView(frame: CGRect(origin: CGPoint.zero, size: view.frame.size))
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView, positioned: .below, relativeTo: nil)
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.hasVerticalScroller = true
        switch mode {
            case .day:  setUpDayView()
            case .week: setUpWeekView()
        }
    }
    
    private func setUpDayView() {
        scrollView.documentView?.removeFromSuperview()
        scheduleView = nil
        scheduleView = SCKDayView(frame: scrollView.bounds)
        scheduleView.controller = self
        scheduleView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = scheduleView
        scheduleView.leadingAnchor.constraint(equalTo: scheduleView.superview!.leadingAnchor).isActive = true
        scheduleView.trailingAnchor.constraint(equalTo: scheduleView.superview!.trailingAnchor).isActive = true
        scheduleView.topAnchor.constraint(equalTo: scheduleView.superview!.topAnchor).isActive = true
        scheduleView.setContentCompressionResistancePriority(NSLayoutPriorityDragThatCannotResizeWindow, for: .vertical)
    }
    
    private func setUpWeekView() {
        scrollView.documentView?.removeFromSuperview()
        scheduleView = nil
        scheduleView = SCKWeekView(frame: scrollView.bounds)
        scheduleView.controller = self
        scheduleView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = scheduleView
        scheduleView.leadingAnchor.constraint(equalTo: scheduleView.superview!.leadingAnchor).isActive = true
        scheduleView.trailingAnchor.constraint(equalTo: scheduleView.superview!.trailingAnchor).isActive = true
        scheduleView.topAnchor.constraint(equalTo: scheduleView.superview!.topAnchor).isActive = true
        scheduleView.setContentCompressionResistancePriority(NSLayoutPriorityDragThatCannotResizeWindow, for: .vertical)
    }
    
    
    //MARK: - User actions
    
    @IBAction open func decreaseOffset(_ sender: AnyObject) {
        switch mode {
        case .day: ( scheduleView as! SCKDayView).decreaseDayOffset(sender: sender)
        case .week: (scheduleView as! SCKWeekView).decreaseWeekOffset(sender: sender)
        }
    }
    
    @IBAction public func increaseOffset(_ sender: AnyObject) {
        switch mode {
        case .day: ( scheduleView as! SCKDayView).increaseDayOffset(sender: sender)
        case .week: (scheduleView as! SCKWeekView).increaseWeekOffset(sender: sender)
        }
    }
    
    @IBAction public func resetOffset(_ sender: AnyObject) {
        switch mode {
        case .day: ( scheduleView as! SCKDayView).resetDayOffset(sender: sender)
        case .week: (scheduleView as! SCKWeekView).resetWeekOffset(sender: sender)
        }
    }
    
    @IBAction public func increaseZoomFactor(_ sender: AnyObject) {
        (scheduleView as! SCKGridView).increaseZoomFactor(sender: sender)
    }
    
    @IBAction public func decreaseZoomFactor(_ sender: AnyObject) {
        (scheduleView as! SCKGridView).decreaseZoomFactor(sender: sender)
    }
    
    
    
    
    //MARK: - Inherited from eventmanager
    
    
    public weak var eventManager: SCKEventManaging?
    
    public var loadsEventsAsynchronously: Bool = false
    
    private weak var completingRequest: SCKEventRequest?
    
    internal var eventHolders: [SCKEventHolder] = []
    
    private var lastRequest: NSPointerArray = NSPointerArray.weakObjects()
    
    internal var asynchronousRequests: Set<SCKEventRequest> = []
    
    public func stopObservingEvent(_ event: SCKEvent) {
        for holder in eventHolders {
            if holder.representedObject.isEqual(event) {
                holder.stopObservingRepresentedObjectChanges()
                break
            }
        }
    }
    
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
                } else {
                    return a.description.compare(b.description) == .orderedAscending
                }
            }
        }
        return sortedConflicts
    }
    
    private func _asyncReloadData(request: SCKEventRequest) {
        for request in asynchronousRequests {
            request.cancel()
        }
        // Not removing, cancel will remove previous
        asynchronousRequests.insert(request)
        eventManager?.scheduleController(self, didMakeEventRequest: request)
    }
    
    private func _syncReloadData() {
        guard let view = scheduleView else { return }
        guard !view.isInvalidatingLayout else {
            NSLog("Waiting for relayout to terminate before reloading data")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self._syncReloadData()
            }
            return
        }
        if let events = eventManager?.events(from: view.dateInterval.start, to: view.dateInterval.end.addingTimeInterval(-1), for: self) {
            parseEvents(events)
        }
    }
    
    private var requestInitClosure: (SCKViewController,Date,Date) -> SCKEventRequest = SCKEventRequest.init(controller:startDate:endDate:)
    
    internal func _internalReloadData() {
        guard let view = scheduleView else { return }
        if loadsEventsAsynchronously {
            let request = requestInitClosure(self, view.dateInterval.start, view.dateInterval.end.addingTimeInterval(-1))
            _asyncReloadData(request: request )
        } else {
            _syncReloadData()
        }
    }
    
    public func reloadData() {
        requestInitClosure = SCKEventRequest.init(controller:startDate:endDate:)
        _internalReloadData()
    }
    
    public func reloadData<T: SCKEvent>(ofConcreteType: T.Type) {
        requestInitClosure = SCKConcreteEventRequest<T>.init(controller:startDate:endDate:)
        _internalReloadData()
    }
    
    internal func parseEvents(_ events: [SCKEvent]) {
        guard let view = scheduleView else {return}
        if let completingRequest = completingRequest {
            guard !completingRequest.isCanceled && completingRequest.startDate == view.dateInterval.start && completingRequest.endDate == view.dateInterval.end.addingTimeInterval(-1) else {
                NSLog("Skipping request")
                return
            }
        }
        let passedSet = NSSet(array: events)
        let oldSet = NSSet(array: lastRequest.allObjects)
        guard passedSet != oldSet else {
            NSLog("Skipping, equal")
            view.invalidateLayoutForAllEventViews()
            return
        }
        var events = events
        lastRequest = NSPointerArray.weakObjects()
        
        for e in events {
            assert(e.scheduledDate > view.dateInterval.start && e.scheduledDate < view.dateInterval.end, "Invalid scheduledDate (\(e.scheduledDate)) for new event: \(e) (INFO: View \(view.dateInterval.start) \(view.dateInterval.end); Request: \(completingRequest!)")
            lastRequest.addPointer(Unmanaged.passUnretained(e).toOpaque())
        }
        
        for holder in eventHolders {
            if !passedSet.contains(holder.representedObject) || holder.representedObject.scheduledDate != holder.cachedScheduledDate {
                // Remove
                
                holder.stopObservingRepresentedObjectChanges()
                view.removeEventView(holder.eventView!)
                holder.eventView?.removeFromSuperview()
                eventHolders.remove(at: eventHolders.index(of: holder)!)
            } else {
                let index = events.index(where: { (e) -> Bool in
                    return e.isEqual(holder.representedObject)
                })
                events.remove(at: index!)
            }
        }
        
        for e in events {
            let aView = SCKEventView(frame: .zero)
            view.addSubview(aView)
            view.addEventView(aView)
            if let holder = SCKEventHolder(event: e, view: aView, controller: self) {
                aView.eventHolder = holder
                eventHolders.append(holder)
            } else {
                print("Warning: Could not generate event holder")
            }
            
        }
        
        view.invalidateLayoutForAllEventViews()
    }
    
    public func reset() {
        eventHolders.removeAll()
        lastRequest = NSPointerArray.weakObjects()
        asynchronousRequests.removeAll()
    }
    
    internal func parseData(in asynchronouslyLoadedEvents: [SCKEvent], from request: SCKEventRequest) {
        guard scheduleView != nil && !scheduleView!.isInvalidatingLayout else {
            NSLog("Waiting for relayout to terminate before reloading data")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.parseData(in: asynchronouslyLoadedEvents, from: request)
            }
            return
        }
        completingRequest = request
        parseEvents(asynchronouslyLoadedEvents)
        completingRequest = nil
    }
    
    
    @objc public private(set) weak var delegate: SCKObjCEventManaging?
    
    private var _delegateProxy: _SCKObjCEventManagingProxy?
    
    @available(*, unavailable)
    @objc public func setObjCDelegate(_ delegate: SCKObjCEventManaging?) {
        self.delegate = delegate
        if let delegate = delegate {
            _delegateProxy = _SCKObjCEventManagingProxy(delegate)
        } else {
            _delegateProxy = nil
        }
        self.eventManager = _delegateProxy
    }
}

