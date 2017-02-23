/*
 *  SCKEventHolder.swift
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

/// Instances of this class work in conjunction with an `SCKEventView` and 
/// represent an object conforming to the `SCKEvent` protocol. These objects are
/// automatically created by the `SCKViewController` reloadData methods.
internal final class SCKEventHolder: NSObject {
    
    /// Initializes a new instance representing a given event object associated
    /// with a concrete `SCKEventView`, managed by the same controller. Returns
    /// `nil` when the represented object's scheduled date or duration cannot
    /// be represented in the controller's schedule view date bounds.
    /// - Parameters:
    ///   - event: The represented object.
    ///   - view: The event view for this instance. Must have been added to a 
    ///           view hierarchy at this point.
    ///   - controller: The `SCKViewController` instance managing this holder.
    ///
    init?(event: SCKEvent, view: SCKEventView, controller c: SCKViewController) {
        representedObject = event
        
        cachedDuration = event.duration
        cachedScheduledDate = event.scheduledDate
        cachedTitle = event.title
        cachedUser = event.user
        
        eventView = view
        scheduleView = view.superview as? SCKView
        controller = c
        
        super.init()
        
        recalculateRelativeValues()
        
        guard isReady else {
            return nil
        }
        
        let obj = representedObject as AnyObject
        obj.addObserver(self, forKeyPath: #keyPath(SCKEvent.scheduledDate), options: [.new,.prior], context: nil)
        obj.addObserver(self, forKeyPath: #keyPath(SCKEvent.duration), options: [.new,.prior], context: nil)
        obj.addObserver(self, forKeyPath: #keyPath(SCKEvent.title), options: [.new], context: nil)
        obj.addObserver(self, forKeyPath: #keyPath(SCKEvent.user.eventColor), options: [.new], context: nil)
        _observersRegistered = true
    }
    
    deinit { // We stop observing represented object changes at this point.
        if _observersRegistered {
            let o = representedObject as AnyObject
            o.removeObserver?(self, forKeyPath: #keyPath(SCKEvent.scheduledDate), context: nil)
            o.removeObserver?(self, forKeyPath: #keyPath(SCKEvent.duration), context: nil)
            o.removeObserver?(self, forKeyPath: #keyPath(SCKEvent.title), context: nil)
            o.removeObserver?(self, forKeyPath: #keyPath(SCKEvent.user.eventColor), context: nil)
        }
    }
    
    private var _observersRegistered = false
    
    
    //MARK: - Object state
    
    /// The event object backed by this event holder. Cannot be changed.
    let representedObject: SCKEvent
    
    /// A reference to the `SCKEventView` associated with this event holder.
    private(set) weak var eventView: SCKEventView?
    
    /// A reference the `SCKView` displaying the event.
    private weak var scheduleView: SCKView?
    
    /// A convenience reference to the controller that created this holder.
    private weak var controller: SCKViewController?
    
    
    // MARK: Cached properties
    
    // These properties ensure the integrity of the layout process by keeping
    // their values until the layout process has ended, even if a change from 
    // represented object is observed.
    
    /// A local copy of the represented object's duration. It is automatically
    /// uppdated when observed changes from the represented object are processed.
    internal var cachedDuration: Int
    
    /// A local copy of the represented object's date. It is automatically
    /// uppdated when observed changes from the represented object are processed.
    internal var cachedScheduledDate: Date
    
    /// A local copy of the represented object's title. It is automatically
    /// uppdated when observed changes from the represented object are processed.
    internal var cachedTitle: String
    
    /// A local copy of the represented object's user. It is automatically
    /// uppdated when observed changes from the represented object are processed.
    /// - Note: We observe the user instead of her color directly to make sure
    ///         the user changes trigger a notification.
    internal weak var cachedUser: SCKUser?
    
    
    // MARK: Relative properties
    
    /// The relative start time of the event in the `scheduleView` date bounds.
    internal var relativeStart = SCKRelativeTimeLocationInvalid
    
    /// The relative end time of the event in the `scheduleView` date bounds.
    internal var relativeEnd = SCKRelativeTimeLocationInvalid
    
    /// The relative duration of the event in the `scheduleView` date bounds.
    internal var relativeLength = SCKRelativeTimeLengthInvalid
    
    /// Indicates whether relative values are valid or not, thus if layout is safe.
    private(set) var isReady: Bool = false
    
    
    /// Invalidates the holder's cached properties and recalculates them by
    /// comparin the values from the represented object's `duration` and
    /// `scheduledDate` properties and the schedule view date bounds.
    /// This method might be invoked automatically:
    /// - When the `SCKEventHolder` object is initialized.
    /// - Whenever `scheduledDate` and/or `duration` change if unlocked.
    /// - When the schedule view ends a dragging operation.
    /// - On already existing event holders during a reload data phase (such as
    ///   changing the day count in a week view).
    ///
    /// - Note: This method is not called automatically when the schedule view
    ///         date bounds change, since the respective reloadData method is
    ///         called instead.
    internal func recalculateRelativeValues() {
        // If view is not set, then do nothing.
        guard let rootView = scheduleView else { return }
        // Invalidate state.
        isReady = false
        relativeStart = SCKRelativeTimeLocationInvalid
        relativeEnd = SCKRelativeTimeLocationInvalid
        relativeLength = 0
        // Calculate new start
        relativeStart = rootView.calculateRelativeTimeLocation(for: cachedScheduledDate)
        if relativeStart != SCKRelativeTimeLocationInvalid {
            if cachedDuration > 0 {
                let inSeconds = SCKRelativeTimeLength(cachedDuration * 60)
                let endDate = cachedScheduledDate.addingTimeInterval(inSeconds)
                relativeEnd = rootView.calculateRelativeTimeLocation(for: endDate)
                if relativeEnd == SCKRelativeTimeLocationInvalid {
                    relativeEnd = 1.0;
                }
                relativeLength = relativeEnd - relativeStart
                isReady = true
            }
        }
    }
    
    
    // MARK: - Conflict tracking
    
    /// The number of events in conflict with this. Includes self, so min is 1.
    internal var conflictCount: Int = 1

    /// The position of this event among the events in conflict (zero based).
    internal var conflictIndex: Int = 0
    
    /// When observing represented object changes, the events in conflict whith
    /// this one before the actual change takes place.
    private var previousConflicts: Set<SCKEventHolder> = []
    
    
    // MARK: - Change observing
    
    /// A wrapper around a deferred change from the `representedObject`.
    private struct DelayedChange {
        /// The changed key path.
        let keyPath: String
        /// The observed change dictionary.
        let change: [NSKeyValueChangeKey:Any]?
    }
    
    /// Set to `true` when observed changes observed from `representedObject`
    /// should be ignored (either when the schedule view itself is making the 
    /// change or when the represented object is not valid anymore).
    private var shouldIgnoreChanges: Bool = false
    
    /// Begins ignoring changes observed from `representedObject`. This method is
    /// called by the event view when commiting a dragging operation to avoid
    /// observing its own changes. It's also called before deallocation when the
    /// controller discards it during a reload data phase.
    internal func stopObservingRepresentedObjectChanges() {
        shouldIgnoreChanges = true
    }
    
    /// Stops ignoring changes observed from `representedObject`. This method is
    /// called by the event view after commiting a dragging operation.
    internal func resumeObservingRepresentedObjectChanges() {
        shouldIgnoreChanges = false
    }
    
    
    override func observeValue(forKeyPath k: String?,
                               of object: Any?,
                               change c: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        // Safety assertions
        guard !shouldIgnoreChanges else {
            return
        }
        guard let o = object as? SCKEvent, let change = c,
            let keyPath = k, let eventView = eventView,
            let rootView = scheduleView, let controller = controller else {
                print("Warning: Received unexpected KVO notification. Object: \(object), eventView: \(self.eventView), keyPath: \(k), change: \(c)")
                return
        }
        
        
        if change[.notificationIsPriorKey] != nil {
            // Track conflicts before value change (KVO-prior)
            previousConflicts = Set(controller.resolvedConflicts(for: self))
        }
        
        else {
            //Notification is not prior. We'll cache it if frozen.
            guard !isFrozen else {
                let cachedChange = DelayedChange(keyPath: keyPath, change: change)
                changesWhileFrozen.append(cachedChange)
                return
            }
            
            switch keyPath {
            case #keyPath(SCKEvent.duration):
                let newDuration = (change[.newKey] as! NSNumber).intValue
                cachedDuration = newDuration
                recalculateRelativeValues()
                let conflictsNow = Set(controller.resolvedConflicts(for: self))
                let updatingHolders = previousConflicts.union(conflictsNow)
                let updatingViews = updatingHolders.map {$0.eventView!}
                rootView.invalidateLayout(for: updatingViews)
            case #keyPath(SCKEvent.scheduledDate):
                let newDate = change[.newKey] as! Date
                cachedScheduledDate = newDate
                recalculateRelativeValues()
                if !(newDate >= rootView.startDate && newDate < rootView.endDate) {
                    // TODO: Use !rootView.dateInterval.contains(newDate) on 10.12
                    // Holder is now invalid, reload data will get rid of it.
                    controller._internalReloadData()
                } else {
                    let conflictsNow = Set(controller.resolvedConflicts(for: self))
                    let updatingHolders = previousConflicts.union(conflictsNow)
                    let updatingViews = updatingHolders.map {$0.eventView!}
                    rootView.invalidateLayout(for: updatingViews, animated: true)
                }
            case #keyPath(SCKEvent.title) where change[.newKey] is String:
                cachedTitle = change[.newKey] as! String
                eventView.innerLabel.stringValue = cachedTitle
            case #keyPath(SCKEvent.user.eventColor):
                let newUser = o.user
                if let oldUser = cachedUser, oldUser === newUser,
                    rootView.colorMode == .byEventOwner {
                    if newUser.eventColor != eventView.backgroundColor {
                        eventView.backgroundColor = newUser.eventColor
                        eventView.needsDisplay = true
                    }
                } else {
                    cachedUser = newUser
                    if rootView.colorMode == .byEventOwner {
                        eventView.backgroundColor = newUser.eventColor
                        eventView.needsDisplay = true
                    }
                }
            default: break
            }
        }
    }
    
    // MARK: - State freezing
    
    /// Indicates whether the event holder is frozen or not. When an instance is
    /// frozen, it works as a snapshot of the instance's state when it was frozen,
    /// so its cached values don't get updated when the corresponding properties
    /// in the represented object change.
    ///
    /// Nevertheless, changes in represented object are still observed in frozen
    /// objects, with the difference that they're not parsed until the
    /// `unfreeze()` method is called.
    ///
    /// This is particularly useful and so invoked automatically during layout,
    /// where cached values should remain the same during the whole process.
    private(set) var isFrozen: Bool = false
    
    
    /// The changes observed while the object was frozen.
    private var changesWhileFrozen: [DelayedChange] = []
    
    
    /// Snapshots the holder's relative properties and begins caching subsequent
    /// changes observed from the represented object until `unfreeze()` is called.
    /// Called by the schedule view during relayout and dragging operations to
    /// preserve data integrity.
    internal func freeze() {
        guard !isFrozen else {
            print("Warning: Called freeze() on an already frozen holder.")
            return
        }
        isFrozen = true
    }
    
    
    /// Stops caching changes observed from the represented object and processes
    /// any pending changes cached while the object was frozen. Called by the 
    /// schedule view during relayout and dragging operations to preserve data 
    /// integrity.
    internal func unfreeze() {
        guard isFrozen else {
            print("Warning: Called unfreeze() on an already unfrozen holder.")
            return
        }
        isFrozen = false
        
        // Process pending changes
        for c in changesWhileFrozen {
            observeValue(forKeyPath: c.keyPath, of: representedObject,
                         change: c.change, context: nil)
        }
        changesWhileFrozen = []
    }
    
}
