//
//  SCKDayView.swift
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 29/10/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

import Cocoa

public class SCKDayView: SCKGridView {

    @IBAction func decreaseDayOffset(sender: Any) {
        let sD = sharedCalendar.date(byAdding: .day, value: -1, to: startDate)!
        let eD = sharedCalendar.date(byAdding: .day, value: -1, to: endDate)!
        setDateBounds(lower: sD, upper: eD)
        controller._internalReloadData()
    }
    
    @IBAction func increaseDayOffset(sender: Any) {
        let sD = sharedCalendar.date(byAdding: .day, value: 1, to: startDate)!
        let eD = sharedCalendar.date(byAdding: .day, value: 1, to: endDate)!
        setDateBounds(lower: sD, upper: eD)
        controller._internalReloadData()
    }
    
    @IBAction public func resetDayOffset(sender: Any) {
        let startHour = sharedCalendar.component(.hour, from: startDate)
        let endHour = sharedCalendar.component(.hour, from: endDate)
        
        let sD = sharedCalendar.date(bySettingHour: startHour, minute: 0, second: 0, of: Date())!
        if endHour < startHour {
            let next = sharedCalendar.date(byAdding: .day, value: 1, to: Date())!
            let eD = sharedCalendar.date(bySettingHour: endHour, minute: 0, second: 0, of: next)!
            setDateBounds(lower: sD, upper: eD)
        } else {
            let eD = sharedCalendar.date(bySettingHour: endHour, minute: 0, second: 0, of: Date())!
            setDateBounds(lower: sD, upper: eD)
        }
        controller._internalReloadData()
    }
    
    //MARK: - Overrides
    
    override func setUp() {
        super.setUp()
        dayCount = 1
        firstHour = 0
        hourCount = 23
    }
    
    public override func setDateBounds(lower sD: Date, upper eD: Date) {
        super.setDateBounds(lower: sD, upper: eD)
        firstHour = sharedCalendar.component(.hour, from: startDate)
        hourCount = Int(trunc(absoluteTimeInterval/3600.0))
        let minHourHeight = contentRect.height / CGFloat(hourCount)
        if hourHeight < minHourHeight {
            hourHeight = minHourHeight
        }
    }
    
    override func relativeTimeLocation(for point: CGPoint) -> Double {
        let canvas = contentRect
        if contentRect.contains(point) {
            return Double((point.y - canvas.minY) / canvas.height)
        }
        return Double(SCKRelativeTimeLocationNotFound)
    }
    
    override func rectForUnavailableTimeRange(_ rng: SCKUnavailableTimeRange) -> CGRect {
        let canvas = contentRect
        let sDate = sharedCalendar.date(bySettingHour: rng.startHour, minute: rng.startMinute, second: 0, of: startDate)!
        let sOffset = calculateRelativeTimeLocation(for: sDate)
        guard sOffset != Double(SCKRelativeTimeLocationNotFound) else {
            return CGRect.zero
        }
        let eDate = sharedCalendar.date(bySettingHour: rng.endHour, minute: rng.endMinute, second: 0, of: startDate)!
        let eOffset = calculateRelativeTimeLocation(for: eDate)
        var yOrigin: CGFloat, yLength: CGFloat
        
        yOrigin = canvas.minY + CGFloat(sOffset) * canvas.height
        if eOffset != Double(SCKRelativeTimeLocationNotFound) {
            yLength = CGFloat(eOffset-sOffset) * canvas.height
        } else {
            yLength = frame.maxY - yOrigin
        }
        
        return CGRect(x: canvas.minX, y: yOrigin, width: canvas.width, height: yLength)
    }
    
    
    public override func layout() {
        super.layout()
        
        let canvas = contentRect
        
        for eventView in (subviews.filter{$0 is SCKEventView} as! [SCKEventView]) {
            
            let oldFrame = eventView.frame
            
            var newFrame = CGRect.zero
            newFrame.origin.y = canvas.minY + canvas.height * CGFloat(eventView.eventHolder.cachedRelativeStart)
            newFrame.size.height = canvas.height * CGFloat(eventView.eventHolder.cachedRelativeLength)
            newFrame.size.width = canvas.width / CGFloat(eventView.eventHolder.conflictCount)
            newFrame.origin.x = canvas.minX + newFrame.width * CGFloat(eventView.eventHolder.conflictIndex - 1)
            
            if oldFrame != newFrame {
                eventView.frame = newFrame
            }
        }
    }
    
}
