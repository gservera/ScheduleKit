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

import Foundation

let SCKRelativeTimeLocationNotFound = NSNotFound

public typealias SCKRelativeLength = Double

struct SCKEventChangeHolder {
    let keyPath: String
    let object: SCKEvent
    let change: [NSKeyValueChangeKey:Any?]
}

/// Instances of this class work in conjunction with an `SCKEventView` and represent
/// an object conforming to the `SCKEvent` protocol.
internal final class SCKEventHolder: NSObject {
    
    internal var uuid = UUID()

    /** Indicates wether cached relative values are valid so drawing is safe.*/
    private(set) var isReady: Bool = false
    private(set) var isLocked: Bool = false
    private(set) var representedObject: SCKEvent
    private(set) weak var owningView: SCKEventView?
    
    // Cached values
    public internal(set) var cachedRelativeStart: SCKRelativeTimeLocation = 0.0
    public internal(set) var cachedRelativeEnd: SCKRelativeTimeLocation = 0.0
    public internal(set) var cachedRelativeLength: SCKRelativeLength = 0
    public internal(set) var cachedUserLabelColor: ColorClass?
    public internal(set) var cachedTitle: String
    public internal(set) var cachedScheduledDate: Date
    public internal(set) var cachedDuration: Int
    
    /// A set to track holders in conflict before a change in either @c representedObject 's @c scheduledDate or @c duration takes place, since that info won't be accessible afterwards. Set when a prior KVO notification for these properties is triggered and set back to @c nil after KVO parsing. @discussion We use NSSet instead of NSArray to prevent objects being included multiple times when combining with conflicts after the change.
    private var previousConflicts: Set<SCKEventHolder> = []
    
    /// Indicates wether we're observing changes in represented object or not.
    private var isObserving: Bool = false
    
    /// A weak reference to @c representedObject's user (to safely parse labelColor changes)
    private(set) weak var cachedUser: SCKUser?
    
    /// A convenience reference to the event manager.
    private weak var owner: SCKViewController?
    
    /// A convenience reference to owningView's superview.
    private weak var rootView: SCKView?
    
    /// The number of times @c lock: has been called over @c unlock:
    private var lockBalance = 0
    
    /// Set to YES when dragging to prevent observing our own changes.
    private var shouldIgnoreChanges: Bool = false
    
    /// Set to YES if we recieve changes while the event holder is locked.
    private var changedWhileLocked: Bool = false
    
    /// The array of changes observed while the object was locked.
    private var changesWhileLocked: [SCKEventChangeHolder]?
    
    
    public var conflictIndex: Int = 1
    public var conflictCount: Int = 1
    
    
    
    /**
     *  SCKEventHolder designated initializer. Sets up a new instance
     *  representing any object conforming to the @c SCKEvent protocol
     *  for the specified @c SCKEventView.
     *
     *  @param e The represented object. Can't be nil.
     *  @param v The owning view for this instance. Must have been already
     *  added to a view hierarchy. Can't be nil. */
    init(event: SCKEvent, view: SCKEventView, controller: SCKViewController) {
        cachedUser = event.user
        cachedUserLabelColor = event.user.labelColor
        cachedTitle = event.title
        cachedScheduledDate = event.scheduledDate
        cachedDuration = event.duration
        owningView = view
        rootView = view.superview as? SCKView
        self.owner = controller
        representedObject = event
        super.init()
        recalculateRelativeValues()
        assert(isReady, "Should be ready")
        startObservingRepresentedObject()
    }
    
    /** We stop observing @c representedObject's properties at this point. */
    deinit {
        stopObservingRepresentedObjectChanges()
    }
    
    /** Stops observing @c representedObject properties. Called from @c dealloc: */
    internal func stopObservingRepresentedObject() {
        if isObserving {
            let obj = representedObject as AnyObject
            obj.removeObserver(self, forKeyPath: #keyPath(SCKEvent.scheduledDate))
            obj.removeObserver(self, forKeyPath: #keyPath(SCKEvent.duration))
            obj.removeObserver(self, forKeyPath: #keyPath(SCKEvent.title))
            obj.removeObserver(self, forKeyPath: #keyPath(SCKEvent.user))
            isObserving = false
        }
    }
    
    /** Begins or resumes observing @c representedObject properties. Called during initialization */
    internal func startObservingRepresentedObject() {
        if !isObserving {
            let obj = representedObject as AnyObject
            obj.addObserver(self, forKeyPath: #keyPath(SCKEvent.scheduledDate), options: [.new,.prior], context: nil)
            obj.addObserver(self, forKeyPath: #keyPath(SCKEvent.duration), options: [.new,.prior], context: nil)
            obj.addObserver(self, forKeyPath: #keyPath(SCKEvent.title), options: [.new], context: nil)
            obj.addObserver(self, forKeyPath: #keyPath(SCKEvent.user), options: [.new], context: nil)
            isObserving = true
        }
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change c: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let o = object as? SCKEvent, let change = c, let keyPath = keyPath, let rootView = self.rootView else {
            return
        }
        assert(o === representedObject, "Recieved a KVO notification from an unexpected object")
        if change[NSKeyValueChangeKey.notificationIsPriorKey] != nil {
            // Track conflicts before value change (KVO-prior)
            guard !shouldIgnoreChanges else {
                return
            }
            let conflictsBefore = owner?.resolvedConflicts(for: self)
            previousConflicts = Set(conflictsBefore ?? [])
        } else { //Notification is not prior
            if isLocked && !shouldIgnoreChanges {
                changedWhileLocked = true
                if changesWhileLocked == nil {
                    changesWhileLocked = []
                }
                changesWhileLocked?.append(SCKEventChangeHolder(keyPath: keyPath, object: o, change: change))
                return
            } else if isLocked && shouldIgnoreChanges {
                // Change was made by the event view, we'll ignore it.
                return
            }
            
            switch keyPath {
            case #keyPath(SCKEvent.duration):
                let newDuration = (change[.newKey] as! NSNumber).intValue
                cachedDuration = newDuration
                recalculateRelativeValues()
                let conflictsNow = owner?.resolvedConflicts(for: self)
                let updatingHolders = previousConflicts.union(Set(conflictsNow ?? []))
                let updatingViews = updatingHolders.map {$0.owningView!}
                rootView.invalidateFrames(for: updatingViews)
            case #keyPath(SCKEvent.scheduledDate):
                let newDate = change[.newKey] as! Date
                cachedScheduledDate = newDate
                if newDate < rootView.startDate || newDate > rootView.endDate {
                    owner?.reloadData()
                } else {
                    recalculateRelativeValues()
                    let conflictsNow = owner?.resolvedConflicts(for: self)
                    let updatingHolders = previousConflicts.union(Set(conflictsNow ?? []))
                    let updatingViews = updatingHolders.map {$0.owningView!}
                    rootView.invalidateFrames(for: updatingViews)
                }
            case #keyPath(SCKEvent.title):
                cachedTitle = (change[.newKey] as? String) ?? ""
                owningView?.innerLabel.stringValue = cachedTitle 
            case #keyPath(SCKEvent.user):
                if let newUser = change[.newKey] as? SCKUser {
                    if cachedUser != nil && cachedUser! !== newUser {
                        cachedUser = newUser
                        cachedUserLabelColor = newUser.labelColor
                        owningView?.needsDisplay = true
                    }
                }
            default:
                return
            }
            
        }
    }
    
    
    /**
     *  Configures this instance to ignore observed @c representedObject changes
     *  until the @c -resumeObservingRepresentedObjectChanges method is called.
     *  This method gets called before changes triggered by the @c owningView in
     *  order to prevent observing of our own changes. Don't call this method
     *  yourself.
     */
    public func stopObservingRepresentedObjectChanges() {
        shouldIgnoreChanges = true
    }
    
    /**
     *  Configures this instance to resume tracking observed @c representedObject
     *  changes after a previous @c -stopObservingRepresentedObjectChanges call.
     *  This method gets called after changes triggered by the @c owningView.
     *  Don't call this method yourself.
     */
    public func resumeObservingRepresentedObjectChanges() {
        shouldIgnoreChanges = false
    }
    
    /**
     *  Begins delaying updates from represented object. Called by SCKView
     *  on every @c SCKEventHolder object at the beginning of a relayout or
     *  drag to prevent conflict-related errors in case these properties
     *  change during the process. Also called by SCKEventManager before
     *  invalidating an instance. Don't call this method yourself. */
    func lock() {
        lockBalance += 1
        assert(lockBalance == 1, "Overlocked (\(lockBalance) times)")
        changedWhileLocked = false
        isLocked = true
    }
    
    /**
     *  Stops delaying updates from represented object. Called by SCKView
     *  on every @c SCKEventHolder item at the end of a relayout or drag
     *  to prevent conflict-related errors in case these properties change
     *  during the process. Don't call this method yourself.
     *  @discussion In the case any change was observed while the event
     *  holder was locked, it finally will get applied when this method is
     *  called.*/
    func unlock() {
        lockBalance -= 1
        assert(lockBalance == 0, "Overlocked (\(lockBalance) times)")
        isLocked = false
        if let changes = changesWhileLocked {
            for change in changes {
                observeValue(forKeyPath: change.keyPath, of: change.object, change: change.change, context: nil)
            }
            changesWhileLocked = nil
        }
    }
    
    /**
     *  Recalculates @c cachedRelativeStart, @c cachedRelativeEnd and @c
     *  cachedRelativeLength according to the values set for properties
     *  @c duration and @c scheduledDate, based on the owning view limits
     *  (@c startDate and @c endDate). This  is called automatically:
     *  - Immediatly after initialization.
     *  - Whenever @c scheduledDate and/or @c duration change if unlocked.
     *  - When the owning view ends either content or duration dragging.
     *  - NOT when owningView's @c startDate or @endDate change, because
     *    SCKEventManager's @c reloadData gets called instead. */
    public func recalculateRelativeValues() {
        guard let rootView = rootView else {
            return
        }
        isReady = false
        cachedRelativeStart = Double(NSNotFound)
        cachedRelativeEnd = Double(NSNotFound)
        cachedRelativeLength = 0
        cachedRelativeStart = rootView.calculateRelativeTimeLocation(for: cachedScheduledDate)
        if cachedRelativeStart != Double(NSNotFound) {
            if cachedDuration > 0 {
                let inSeconds = cachedDuration * 60
                let endDate = cachedScheduledDate.addingTimeInterval(Double(inSeconds))
                cachedRelativeEnd = rootView.calculateRelativeTimeLocation(for: endDate)
                if cachedRelativeEnd == Double(NSNotFound) {
                    cachedRelativeEnd = 1.0;
                }
                cachedRelativeLength = cachedRelativeEnd - cachedRelativeStart
                isReady = true
            }
        }
    }
}
