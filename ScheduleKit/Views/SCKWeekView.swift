//
//  SCKWeekView.swift
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 29/10/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

import Cocoa

@objc public protocol SCKWeekViewDelegate: SCKGridViewDelegate {
    @objc(dayStartHourForWeekView:) func dayStartHour(for weekView: SCKWeekView) -> Int
    @objc(dayEndHourForWeekView:) func dayEndHour(for weekView: SCKWeekView) -> Int
    
    @objc(dayCountForWeekView:) optional func dayCount(for weekView: SCKWeekView) -> Int
}

public class SCKWeekView: SCKGridView {
    private var dayStartPoint: SCKDayPoint = SCKDayPoint(hour: 0, minute: 0, second: 0)
    private var dayEndPoint: SCKDayPoint = SCKDayPoint(hour: 21, minute: 0, second: 0)
    
    override func setUp() {
        super.setUp()
        dayCount = 7
        firstHour = dayStartPoint.hour
        hourCount = dayEndPoint.hour - dayStartPoint.hour
    }
    
    @IBAction func decreaseWeekOffset(sender: Any) {
        let sD = sharedCalendar.date(byAdding: .weekOfYear, value: -1, to: startDate)!
        let eD = sharedCalendar.date(byAdding: .weekOfYear, value: -1, to: endDate)!
        setDateBounds(lower: sD, upper: eD)
        controller._internalReloadData()
    }
    
    
    @IBAction func increaseWeekOffset(sender: Any) {
        let sD = sharedCalendar.date(byAdding: .weekOfYear, value: 1, to: startDate)!
        let eD = sharedCalendar.date(byAdding: .weekOfYear, value: 1, to: endDate)!
        setDateBounds(lower: sD, upper: eD)
        controller._internalReloadData()
    }
    
    
    @IBAction func resetWeekOffset(sender: Any) {
        let weekComponents = sharedCalendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: Date())
        let weekStart = sharedCalendar.date(from: weekComponents)!
        let sD = weekStart
        if let dayCount = (delegate as? SCKWeekViewDelegate)?.dayCount?(for: self) {
            let eD = sharedCalendar.date(byAdding: .day, value: dayCount, to: weekStart)!
            setDateBounds(lower: sD, upper: eD)
        } else {
            let eD = sharedCalendar.date(byAdding: .weekOfYear, value: 1, to: weekStart)!
            setDateBounds(lower: sD, upper: eD)
        }
        controller._internalReloadData()
    }
    
    private func yFor(hour: Int, minute: Int) -> CGFloat {
        let canvas = contentRect
        return canvas.minY + canvas.height * (CGFloat(hour-firstHour) + CGFloat(minute)/60.0) / CGFloat(hourCount)
        
        //return NSMinY(canvas) + NSHeight(canvas) * ((CGFloat)(h-_firstHour) + (CGFloat)m/60.0) / (CGFloat)_hourCount;
    }
    
    // MARK: - Overrides
    
    public override func setDateBounds(lower sD: Date, upper eD: Date) {
        super.setDateBounds(lower: sD, upper: eD)
        if eD > sD {
            dayCount = sharedCalendar.dateComponents([.day], from: sD, to: eD).day!
        }
    }
    
    override func readDefaultsFromDelegate() {
        // Sets up unavailable ranges and marks as needing display
        super.readDefaultsFromDelegate()
        
        guard let delegate = delegate as? SCKWeekViewDelegate else {
            return
        }
        
        dayStartPoint = SCKDayPoint(hour: delegate.dayStartHour(for: self), minute: 0, second: 0)
        dayEndPoint = SCKDayPoint(hour: delegate.dayEndHour(for: self), minute: 0, second: 0)
        firstHour = dayStartPoint.hour
        hourCount = dayEndPoint.hour - dayStartPoint.hour
        invalidateIntrinsicContentSize()
        
        if let delegateDayCount = delegate.dayCount?(for: self) {
            if dayCount != delegateDayCount {
                let endDate = sharedCalendar.date(byAdding: .day, value: delegateDayCount, to: startDate)!
                setDateBounds(lower: startDate, upper: endDate)
                controller._internalReloadData()
                for holder in controller.eventHolders {
                    holder.recalculateRelativeValues()  
                }
                // Invalidate would lead to crash on asynchronous events (holders not ready)
                return
            }
        }
        invalidateFrameForAllEventViews()
    }
    
    override func rectForUnavailableTimeRange(_ rng: SCKUnavailableTimeRange) -> CGRect {
        let canvas = contentRect
        let dayWidth: CGFloat = canvas.width / CGFloat(dayCount)
        let sDate = sharedCalendar.date(bySettingHour: rng.startHour, minute: rng.startMinute, second: 0, of: startDate)!
        let sOffset = calculateRelativeTimeLocation(for: sDate)
        
        if sOffset != SCKRelativeTimeLocationInvalid {
            let endSeconds = rng.endMinute * 60 + rng.endHour * 3600
            let startSeconds = rng.startMinute * 60 + rng.startHour * 3600
            let eDate = sDate.addingTimeInterval(Double(endSeconds - startSeconds))
            let eOffset = calculateRelativeTimeLocation(for: eDate)
            let yOrigin = yFor(hour: rng.startHour, minute: rng.startMinute)
            var yLength: CGFloat
            if eOffset != SCKRelativeTimeLocationInvalid {
                yLength = yFor(hour: rng.endHour, minute: rng.endMinute) - yOrigin
            } else {
                yLength = frame.maxY - yOrigin
            }
            return CGRect(x: canvas.minX + CGFloat(rng.weekday) * dayWidth, y: yOrigin, width: dayWidth, height: yLength)
        }
        return CGRect.zero
    }
    
    override func relativeTimeLocation(for point: CGPoint) -> Double {
        let canvas = contentRect
        if canvas.contains(point) {
            let dayWidth: CGFloat = canvas.width / CGFloat(dayCount)
            let offsetPerDay = 1.0 / Double(dayCount)
            let day = Int(trunc((point.x-canvas.minX)/dayWidth))
            let dayOffset = offsetPerDay * Double(day)
            let offsetPerMin = calculateRelativeTimeLocation(for: startDate.addingTimeInterval(60))
            let offsetPerHour = 60.0 * offsetPerMin
            let totalMinutes = 60.0 * CGFloat(hourCount)
            let minute = totalMinutes * (point.y - canvas.minY) / canvas.height
            let minuteOffset = offsetPerMin * Double(minute)
            return dayOffset + offsetPerHour * Double(firstHour) + minuteOffset
        }
        return SCKRelativeTimeLocationInvalid
    }
    
    
    public override func layout() {
        super.layout()
        
        let canvas = contentRect
        
        assert(dayCount > 0, "Day count must be greater than zero. Found \(dayCount) instead.")
        let offsetPerDay = 1.0/Double(dayCount)
        
        let dayWidth: CGFloat = canvas.width/CGFloat(dayCount)
        
        for eventView in (subviews.filter{$0 is SCKEventView} as! [SCKEventView]) {
            
            guard eventView.eventHolder.isReady else {
                continue
            }
            
            let oldFrame = eventView.frame
            
            let startOffset = eventView.eventHolder.relativeStart
            assert(startOffset != SCKRelativeTimeLocationInvalid, "Expected relative start to be set for: \(eventView.eventHolder)")
            let day = Int(trunc(startOffset/offsetPerDay))
            
            let date = eventView.eventHolder.cachedScheduledDate
            let sPoint = SCKDayPoint(date: date)
            let ePoint = SCKDayPoint(hour: sPoint.hour, minute: sPoint.minute+eventView.eventHolder.cachedDuration, second: sPoint.second)
            
            var newFrame = CGRect.zero
            newFrame.origin.y = yFor(hour: sPoint.hour, minute: sPoint.minute)
            newFrame.size.height = yFor(hour: ePoint.hour, minute: ePoint.minute)-newFrame.minY
            newFrame.size.width = dayWidth / CGFloat(eventView.eventHolder.conflictCount)
            newFrame.origin.x = canvas.minX + CGFloat(day) * dayWidth + newFrame.width * CGFloat(eventView.eventHolder.conflictIndex)
            
            if oldFrame != newFrame {
                eventView.frame = newFrame
            }
        }
    }
    
}
