//
//  SCKFreeTimeFinder.swift
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 11/12/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

import Foundation

@objc public final class SCKFreeTimeFinder: NSObject, AsynchronousRequestParsing {
    
    private let isAsynchronous: Bool
    private let _requestInit: (AsynchronousRequestParsing,DateInterval) -> SCKEventRequest
    var isCanceled = false
    let dataSource: SCKEventManaging
    let unavailableRanges: [SCKUnavailableTimeRange]
    private weak var controller: SCKViewController!
    
    public init(controller: SCKViewController, excluding unavailable: [SCKUnavailableTimeRange]) {
        dataSource = controller.eventManager!
        isAsynchronous = controller.loadsEventsAsynchronously
        _requestInit = controller._requestInit
        unavailableRanges = unavailable
        self.controller = controller
        super.init()
    }
    
    public var batchSize: Int = 7
    
    public func firstAvailableDate(forEventWithDuration d: Int,
                            user: SCKUser?,
                            from date: Date = Date()) -> Date {
        var foundDate: Date?
        var lastStart: Date = date
        while foundDate == nil {
            let searchInterval = DateInterval(start: lastStart, duration: TimeInterval(batchSize * 24 * 3600))
            var events = dataSource.events(in: searchInterval, for: controller)
            if let user = user {
                events = events.filter {$0.user === user}
            }
            foundDate = evaluateAvailability(among: events, user: user, duration: d, interval: searchInterval)
            lastStart = searchInterval.end
        }
        return foundDate!
    }
    
    internal var asynchronousRequests: Set<SCKEventRequest> = []
    private let asynchronousQueue = DispatchQueue(label: String(describing: SCKFreeTimeFinder.self), qos: .userInitiated)
    private var asynchronousUser: SCKUser?
    private var asynchronousCallback: ((Date) -> Void)?
    private var asynchronousDuration: Int = 0
    
    public func findFirstAvailableDate(forEventWithDuration d: Int,
                                user: SCKUser?,
                                from date: Date = Date(),
                                callback: @escaping (Date) -> Void) {
        guard asynchronousRequests.count == 0 else {
            print("Already triggered a free time search")
            return
        }
        asynchronousUser = user
        asynchronousCallback = callback
        asynchronousDuration = d
        
        // Truncate date to seconds
        var seconds = Int(trunc(date.timeIntervalSinceReferenceDate))
        while seconds % 60 > 0 {
            seconds -= 1
        }
        let cleanDate = Date(timeIntervalSinceReferenceDate: TimeInterval(seconds))
        
        let searchInterval = DateInterval(start: cleanDate, duration: TimeInterval(batchSize * 24 * 3600))
        let request = _requestInit(self, searchInterval)
        asynchronousRequests.insert(request)
        dataSource.scheduleController(controller, didMakeEventRequest: request)
        print("Making free time event request")
    }
    
    func parseData(in eventArray: [SCKEvent], from request: SCKEventRequest) {
        guard !request.isCanceled else {
            NSLog("Skipping request")
            asynchronousUser = nil
            asynchronousCallback = nil
            return
        }
        
        var events = eventArray
        if let user = asynchronousUser {
            events = events.filter {$0.user === user}
        }
        if let foundDate = evaluateAvailability(among: events,
                                                user: asynchronousUser,
                                                duration: asynchronousDuration,
                                                interval: request.dateInterval) {
            asynchronousCallback?(foundDate)
            print("Found date: \(foundDate)")
            asynchronousUser = nil
            asynchronousCallback = nil
        } else {
            let nextStart = request.dateInterval.end
            let nextInterval = DateInterval(start: nextStart, duration: TimeInterval(batchSize * 24 * 3600))
            let nextRequest = _requestInit(self, nextInterval)
            asynchronousRequests.insert(nextRequest)
            dataSource.scheduleController(controller, didMakeEventRequest: nextRequest)
            print("Sending another event request")
        }
        
    }
    
    
    private func evaluateAvailability(among events: [SCKEvent],
                                      user: SCKUser?,
                                      duration: Int,
                                      interval: DateInterval) -> Date? {
        let length = TimeInterval(duration * 60)
        let eventIntervals: [DateInterval] = events.map {
            DateInterval(start: $0.scheduledDate, duration: TimeInterval($0.duration * 60) - 1.0) //Avoid bound collisions.
        }
        
        var unavailableIntervals: [DateInterval] = []
        for unavailable in unavailableRanges {
            let matching = unavailable.matchingOccurrences(in: interval)
            unavailableIntervals += matching
        }
        
        let maxStart = interval.end.addingTimeInterval(-length)
        
        var startIntent = interval.start
        while startIntent < maxStart {
            
            let intervalIntent = DateInterval(start: startIntent, duration: length)
            
            // Check conflicts with unavailable ranges
            var isUnavailable = false
            for u in unavailableIntervals {
                if u.intersects(intervalIntent) {
                    isUnavailable = true
                    break
                }
            }
            
            guard !isUnavailable else {
                startIntent = startIntent.addingTimeInterval(60)
                continue
            }
            
            // Check conflicts with other events
            var foundConflict = false
            for otherInterval in eventIntervals {
                if intervalIntent.intersects(otherInterval) {
                    foundConflict = true
                    break
                }
            }
            guard !foundConflict else {
                startIntent = startIntent.addingTimeInterval(60)
                continue
            }
            
            // Date is valid!
            return intervalIntent.start
        }
        return nil
    }
    

    
}
