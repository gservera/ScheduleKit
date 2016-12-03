//
//  SCKGridView.swift
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 28/10/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

import Cocoa



@objc public protocol SCKGridViewDelegate: SCKViewDelegate {
    @objc(unavailableTimeRangesForGridView:) optional func unavailableTimeRanges(for gridView: SCKGridView) -> [SCKUnavailableTimeRange]
}


private let kHourLabelWidth: CGFloat = 56.0
private let kDayLabelHeight: CGFloat = 40.0
private let kMaxHourHeight: CGFloat = 300.0


public class SCKGridView: SCKView {
    
    private let dayLabelingView = NSView(frame: .zero)
    
    private static let zoomLevelKey = "MEKZoom"
    
    override public weak var delegate: SCKViewDelegate? {
        didSet {
            readDefaultsFromDelegate()
        }
    }
    
    
    var hourHeight: CGFloat = 0.0 {
        didSet {
            if hourHeight != oldValue {
                let zoomKey = SCKGridView.zoomLevelKey + ".\(type(of:self))"
                UserDefaults.standard.set(hourHeight, forKey: zoomKey)
                invalidateIntrinsicContentSize()
            }
            for (_, label) in halfHourLabels {
                label.isHidden = (hourHeight < 40.0)
            }
            for (_, label) in quarterHourLabels {
                label.isHidden = (hourHeight < 80.0 || hourHeight >= 120)
            }
            for (_, label) in tenMinuteLabels {
                label.isHidden = (hourHeight < 120.0)
            }
        }
    }
    
    override var contentRect: CGRect {
        return CGRect(x: kHourLabelWidth, y: kDayLabelHeight + 20.0,
                      width: frame.width - kHourLabelWidth, height: frame.height - kDayLabelHeight - 20.0)
    }
    
    private var hourLabels: [Int: NSTextField] = [:] // hour
    private var halfHourLabels: [Int: NSTextField] = [:] // hour
    private var quarterHourLabels: [Int: NSTextField] = [:] //min*10 + hour
    private var tenMinuteLabels: [Int: NSTextField] = [:] //min*10 + hour
    private var dayLabels: [NSTextField] = []
    private var monthLabels: [NSTextField] = []
    
    private func generateMissingDayLabels() {
        func commonLabel() -> NSTextField {
            let label = NSTextField(frame: .zero)
            //label.translatesAutoresizingMaskIntoConstraints = false
            label.isBordered = false
            label.isEditable = false
            label.isBezeled = false
            label.drawsBackground = false
            return label
        }
        for day in 0..<dayCount {
            if dayLabels.count > day {
                continue
            }
            let dayLabel = commonLabel()
            dayLabel.textColor = NSColor.darkGray
            dayLabel.font = NSFont.systemFont(ofSize: 14.0)
            dayLabels.append(dayLabel)
            
            let monthLabel = commonLabel()
            monthLabel.textColor = NSColor.lightGray
            monthLabel.font = NSFont.systemFont(ofSize: 12.0)
            monthLabel.isHidden = true
            monthLabels.append(monthLabel)
            
        }
    }
    
    private func addOrRemoveDesiredDayAndMonthLabels() {
        for dayLabel in dayLabels {
            let day = dayLabels.index(of: dayLabel)!
            if day >= dayCount && dayLabel.superview != nil {
                dayLabel.removeFromSuperview()
                monthLabels[day].removeFromSuperview()
            } else if day < dayCount {
                if dayLabel.superview == nil {
                    dayLabelingView.addSubview(dayLabel)
                    dayLabelingView.addSubview(monthLabels[day])
                }
                let wStart = sharedCalendar.date(byAdding: .day, value: day, to: startDate)!
                let wLabel = dayLabelDateFormatter.string(from: wStart).uppercased()
                dayLabel.stringValue = wLabel
                dayLabel.sizeToFit()
                monthLabels[day].isHidden = true
                if day == 0 || (Int(wLabel.components(separatedBy:" ")[1])! == 1) {
                    let monthText = monthLabelDateFormatter.string(from: wStart)
                    monthLabels[day].stringValue = monthText
                    monthLabels[day].sizeToFit()
                    monthLabels[day].isHidden = false
                }
            }
        }
        needsLayout = true
    }
    
    private func generateMissingHourLabels() {
        func commonLabel() -> NSTextField {
            let label = NSTextField(frame: .zero)
            //label.translatesAutoresizingMaskIntoConstraints = false
            label.isBordered = false
            label.isEditable = false
            label.isBezeled = false
            label.drawsBackground = false
            return label
        }
        for hour in 0..<hourCount {
            if hourLabels[hour] != nil {
                continue
            }
            let hourLabel = commonLabel()
            hourLabel.stringValue = "\(hour):00"
            hourLabel.textColor = NSColor.darkGray
            hourLabel.font = NSFont.systemFont(ofSize: 11.0)
            hourLabel.sizeToFit()
            hourLabels[hour] = hourLabel
            
            let halfHourLabel = commonLabel()
            halfHourLabel.stringValue = "\(hour):30  -"
            halfHourLabel.textColor = NSColor.lightGray
            halfHourLabel.font = NSFont.systemFont(ofSize: 10.0)
            halfHourLabel.sizeToFit()
            halfHourLabel.isHidden = true
            halfHourLabels[hour] = halfHourLabel
            
            for min in stride(from: 15, through: 45, by: 15) {
                if min != 30 {
                let quarterLabel = commonLabel()
                quarterLabel.stringValue = "\(firstHour+hour):\(min)  -"
                quarterLabel.textColor = NSColor.lightGray
                quarterLabel.font = NSFont.systemFont(ofSize: 10.0)
                quarterLabel.sizeToFit()
                quarterLabel.isHidden = true
                quarterHourLabels[hour+min*10] = quarterLabel
                }
            }
            
            for min in stride(from: 10, through: 50, by: 10) {
                if min != 30 {
                let tenMinuteLabel = commonLabel()
                tenMinuteLabel.stringValue = "\(firstHour+hour):\(min)  -"
                tenMinuteLabel.textColor = NSColor.lightGray
                tenMinuteLabel.font = NSFont.systemFont(ofSize: 10.0)
                tenMinuteLabel.sizeToFit()
                tenMinuteLabel.isHidden = true
                tenMinuteLabels[hour+min*10] = tenMinuteLabel
                }
            }
            
        }
    }
    
    //dayLabelDateFormatter.dateFormat = (weekdayWidth < 100.0) ? "EEE d" : "EEEE d"
    //monthLabelDateFormatter.dateFormat = (weekdayWidth < 100.0) ? "MMM" : "MMMM"
    
    private func addOrRemoveDesiredHourLabels() {
        for (hour, label) in hourLabels {
            if (hour < firstHour || hour > firstHour + hourCount) && label.superview != nil {
                label.removeFromSuperview()
                (halfHourLabels[hour]!).removeFromSuperview()
                (quarterHourLabels[hour+150]!).removeFromSuperview()
                (quarterHourLabels[hour+450]!).removeFromSuperview()
                (tenMinuteLabels[hour+100]!).removeFromSuperview()
                (tenMinuteLabels[hour+200]!).removeFromSuperview()
                (tenMinuteLabels[hour+400]!).removeFromSuperview()
                (tenMinuteLabels[hour+500]!).removeFromSuperview()
            } else if hour >= firstHour && hour < firstHour + hourCount {
                if label.superview == nil {
                    addSubview(label)
                    addSubview(halfHourLabels[hour]!)
                    addSubview(quarterHourLabels[hour+150]!)
                    addSubview(quarterHourLabels[hour+450]!)
                    addSubview(tenMinuteLabels[hour+100]!)
                    addSubview(tenMinuteLabels[hour+200]!)
                    addSubview(tenMinuteLabels[hour+400]!)
                    addSubview(tenMinuteLabels[hour+500]!)
                }
            }
        }
        needsLayout = true
    }
    
    private var minuteTimer: Timer!
    private var unavailableTimeRanges: [SCKUnavailableTimeRange] = []
    var dayCount: Int = 0 {
        didSet {
            generateMissingDayLabels()
            addOrRemoveDesiredDayAndMonthLabels()
        }
    }
    var hourCount: Int = 1 {
        didSet {
            generateMissingHourLabels()
            addOrRemoveDesiredHourLabels()
        }
    }
    var firstHour: Int = 1 {
        didSet {
            generateMissingHourLabels()
            addOrRemoveDesiredHourLabels()
        }
    }
    
    lazy private var dayLabelDateFormatter: DateFormatter = {
        let formatter = DateFormatter(); formatter.dateFormat = "EEEE d"; return formatter
    }()
    
    lazy private var monthLabelDateFormatter: DateFormatter = {
        let formatter = DateFormatter(); formatter.dateFormat = "MMMM"; return formatter
    }()
    
    public override func setDateBounds(lower sD: Date, upper eD: Date) {
        super.setDateBounds(lower: sD, upper: eD)
        generateMissingDayLabels()
        addOrRemoveDesiredDayAndMonthLabels()
    }
    
    func readDefaultsFromDelegate() {
        unavailableTimeRanges = (delegate as? SCKGridViewDelegate)?.unavailableTimeRanges?(for: self) ?? []
        needsDisplay = true
    }
    
    @objc public func invalidateUserDefaults() {
        readDefaultsFromDelegate()
    }
    
    func rectForUnavailableTimeRange(_ rng: SCKUnavailableTimeRange) -> CGRect {
        return CGRect.zero
    }
    
    
    @IBAction func increaseZoomFactor(sender: Any?) {
        if hourHeight < kMaxHourHeight {
            hourHeight += 8.0
            needsDisplay = true
        }
    }
    
    @IBAction func decreaseZoomFactor(sender: Any?) {
        let targetHeight = hourHeight - 8.0
        if targetHeight * CGFloat(hourCount) >= superview!.frame.height-kDayLabelHeight-20.0 {
            hourHeight = targetHeight
        } else {
            hourHeight = (superview!.frame.height-kDayLabelHeight-20.0) / CGFloat(hourCount)
        }
        needsDisplay = true
    }
    
    //MARK: Drawing
    
    private func drawHourDelimiters() {
        let canvas = contentRect
        NSColor(deviceWhite: 0.95, alpha: 1.0).set()
        for hour in 0..<hourCount {
            let r = CGRect(x: canvas.minX-8.0,
                           y: canvas.minY + CGFloat(hour) * hourHeight - 0.4,
                           width: canvas.width + 8.0,
                           height: 0.8)
            NSRectFill(r)
        }
    }
    
    private func drawDayDelimiters() {
        let canvas = CGRect(x: kHourLabelWidth, y: kDayLabelHeight,
                            width: frame.width - kHourLabelWidth, height: frame.height - kDayLabelHeight)
        let dayWidth = canvas.width / CGFloat(dayCount)
        NSColor(deviceWhite: 0.95, alpha: 1.0).set()
        for day in 0..<dayCount {
            let r = CGRect(x: canvas.minX + CGFloat(day) * dayWidth,
                           y: canvas.minY,
                           width: 0.8,
                           height: canvas.height)
            NSRectFill(r)
        }
    }
    
    private func drawUnavailableTimeRanges() {
        NSColor(red: 0.925, green: 0.942, blue: 0.953, alpha: 1.0).set()
        for range in unavailableTimeRanges {
            NSRectFill(rectForUnavailableTimeRange(range))
        }
    }
    
    private func drawCurrentTimeLine() {
        let canvas = contentRect
        let components = sharedCalendar.dateComponents([.hour,.minute], from: Date())
        let minuteCount = Double(hourCount) * 60.0
        let elapsedMinutes = Double(components.hour!-firstHour) * 60.0 + Double(components.minute!)
        let yOrigin = canvas.minY + canvas.height * CGFloat(elapsedMinutes / minuteCount)
        
        NSColor.red.setFill()
        NSRectFill(CGRect(x: canvas.minX, y: yOrigin-0.25, width: canvas.width, height: 0.5))
        let circle = NSBezierPath(ovalIn: CGRect(x: canvas.minX-2.0, y: yOrigin-2.0, width: 4.0, height: 4.0))
        circle.fill()
    }
    
    private func drawDraggingGuides() {
        guard let dV = eventViewBeingDragged else {return}
        
        if colorMode == .byEventKind {
            delegate?.color?(for: dV.eventHolder.representedObject.eventKind, in: self).setFill()
        } else if let cachedUserColor = dV.eventHolder.cachedUser?.eventColor {
            cachedUserColor.setFill()
        } else {
            NSColor.darkGray.setFill()
        }
    
        func fill(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) {
            NSRectFill(CGRect(x: x, y: y, width: w, height: h))
        }
        
        let canvas = contentRect
        let dragFrame = dV.frame
        
        // Left guide
        fill(canvas.minX, dragFrame.midY-1.0, dragFrame.minX-canvas.minX, 2.0)
        // Right guide
        fill(dragFrame.maxX, dragFrame.midY-1.0, frame.width-dragFrame.maxX, 2.0)
        // Top guide
        fill(dragFrame.midX-1.0, canvas.minY, 2.0, dragFrame.minY-canvas.minY)
        // Bottom guide
        fill(dragFrame.midX-1.0, dragFrame.maxY, 2.0, frame.height-dragFrame.maxY)
        
        let dayWidth = canvas.width / CGFloat(dayCount)
        let offsetPerDay = 1.0/Double(dayCount)
        let startOffset = relativeTimeLocation(for: CGPoint(x: dragFrame.midX, y: dragFrame.minY))
        if startOffset != SCKRelativeTimeLocationInvalid {
            fill(canvas.minX+dayWidth*CGFloat(trunc(startOffset/offsetPerDay)),
                 canvas.minY,
                 dayWidth,
                 2.0)
            
            let startDate = calculateDate(for: startOffset)!
            let sPoint = SCKDayPoint(date: startDate)
            let ePoint = SCKDayPoint(date: startDate.addingTimeInterval(Double(dV.eventHolder.cachedDuration)*60.0))
            
            let sLabelText = NSString(format: "%ld:%02ld", sPoint.hour, sPoint.minute)
            let eLabelText = NSString(format: "%ld:%02ld", ePoint.hour, ePoint.minute)
            
            let attrs = [
                NSForegroundColorAttributeName: NSColor.darkGray,
                NSFontAttributeName: NSFont.systemFont(ofSize: 14.0)
            ]
            
            let labelHeight = sLabelText.size(withAttributes: attrs).height
            let sLabelRect = CGRect(x: 0.0, y: dragFrame.minY-labelHeight/2.0, width: canvas.minX-12.0, height: labelHeight)
            let eLabelRect = CGRect(x: 0.0, y: dragFrame.maxY-labelHeight/2.0, width: canvas.minX-12.0, height: labelHeight)
            sLabelText.draw(in: sLabelRect, withAttributes: attrs)
            eLabelText.draw(in: eLabelRect, withAttributes: attrs)
            
            let durationText = "\(dV.eventHolder.cachedDuration) min"
            let durationRect = CGRect(x: 0.0, y: dragFrame.midY-labelHeight/2.0, width: canvas.minX-12, height: labelHeight)
            durationText.draw(in: durationRect, withAttributes: attrs)
            
        }
        
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard absoluteStartTimeRef < absoluteEndTimeRef && hourCount > 0 else { return }
        
        drawUnavailableTimeRanges()
        drawDayDelimiters()
        drawHourDelimiters()
        drawCurrentTimeLine()
        if eventViewBeingDragged != nil {
            drawDraggingGuides()
        }
    }
    
    //MARK: - Overrides
    
    public override func layout() {
        super.layout()
        
        let canvas = contentRect
        
        // Layout day labels
        
        let weekdayLabelingRect = CGRect(x: kHourLabelWidth, y: 0.0, width: frame.width - kHourLabelWidth, height: kDayLabelHeight)
        let weekdayWidth = (frame.width - kHourLabelWidth) / CGFloat(dayCount)
        
        for weekday in 0..<dayCount {
            let wLabel = dayLabels[weekday]
            let wLabelSize = wLabel.frame.size
            var wLabelRect = CGRect(x: weekdayLabelingRect.minX + CGFloat(weekday) * weekdayWidth + weekdayWidth / 2.0 - wLabelSize.width/2.0,
                                  y: kDayLabelHeight/2.0-wLabelSize.height/2.0,
                                  width: wLabelSize.width,
                                  height: wLabelSize.height)
            
            if weekday == 0 || (Int(wLabel.stringValue.components(separatedBy:" ")[1])! == 1) {
                wLabelRect.origin.y += 8.0
                
                let mLabel = monthLabels[weekday]
                let mLabelSize = mLabel.frame.size
                mLabel.frame = CGRect(x: weekdayLabelingRect.minX + CGFloat(weekday) * weekdayWidth + weekdayWidth / 2.0 - mLabelSize.width/2.0,
                                        y: kDayLabelHeight/2.0-wLabelSize.height/2.0 - 7.0,
                                        width: mLabelSize.width,
                                        height: mLabelSize.height)
            }
            wLabel.frame = wLabelRect
        }
        
        
        // Layout hour labels
        for (hour, label) in hourLabels {
            let size = label.frame.size
            let rect = CGRect(x: kHourLabelWidth - size.width - 8.0,
                              y: canvas.minY + CGFloat(hour - firstHour) * hourHeight - 7.0,
                              width: size.width,
                              height: size.height)
            label.frame = rect
            
            if hourHeight >= 40.0 {
                let half = halfHourLabels[hour]!
                let size = half.frame.size
                let rect = CGRect(x: kHourLabelWidth - size.width + 4.0,
                                  y: canvas.minY + CGFloat(hour - firstHour) * hourHeight + hourHeight/2.0 - 7.0,
                                  width: size.width,
                                  height: size.height)
                half.frame = rect
            }
            if hourHeight >= 80.0 && hourHeight < 120.0 {
                let q1 = quarterHourLabels[hour+150]!
                let q3 = quarterHourLabels[hour+450]!
                let q1size = q1.frame.size
                let q3size = q3.frame.size
                q1.frame = CGRect(x: kHourLabelWidth - q1size.width + 4.0,
                                  y: canvas.minY + CGFloat(hour - firstHour) * hourHeight + hourHeight/60.0*15.0 - 7.0,
                                  width: q1size.width,
                                  height: q1size.height)
                q3.frame = CGRect(x: kHourLabelWidth - q3size.width + 4.0,
                                  y: canvas.minY + CGFloat(hour - firstHour) * hourHeight + hourHeight/60.0*45.0 - 7.0,
                                  width: q3size.width,
                                  height: q3size.height)
            }
            if hourHeight >= 120.0 {
                let m10 = tenMinuteLabels[hour+100]!
                let m20 = tenMinuteLabels[hour+200]!
                let m40 = tenMinuteLabels[hour+400]!
                let m50 = tenMinuteLabels[hour+500]!
                let m10size = m10.frame.size
                let m20size = m20.frame.size
                let m40size = m40.frame.size
                let m50size = m50.frame.size
                m10.frame = CGRect(x: kHourLabelWidth - m10size.width + 4.0,
                                   y: canvas.minY + CGFloat(hour - firstHour) * hourHeight + hourHeight/60.0*10.0 - 7.0,
                                   width: m10size.width, height: m10size.height)
                m20.frame = CGRect(x: kHourLabelWidth - m20size.width + 4.0,
                                   y: canvas.minY + CGFloat(hour - firstHour) * hourHeight + hourHeight/60.0*20.0 - 7.0,
                                   width: m20size.width, height: m20size.height)
                m40.frame = CGRect(x: kHourLabelWidth - m40size.width + 4.0,
                                   y: canvas.minY + CGFloat(hour - firstHour) * hourHeight + hourHeight/60.0*40.0 - 7.0,
                                   width: m40size.width, height: m40size.height)
                m50.frame = CGRect(x: kHourLabelWidth - m50size.width + 4.0,
                                   y: canvas.minY + CGFloat(hour - firstHour) * hourHeight + hourHeight/60.0*50.0 - 7.0,
                                   width: m50size.width, height: m50size.height)
            }
        }
    }
    
    public override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if superview != nil {
            setContentCompressionResistancePriority(NSLayoutPriorityDragThatCannotResizeWindow, for: .vertical)
            
            minuteTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(minuteTimerFired(timer:)), userInfo: nil, repeats: true)
            minuteTimer.tolerance = 10.0
        }
    }
    
    public override func viewWillMove(toSuperview newSuperview: NSView?) {
        //dayLabelingView.removeFromSuperview()
        guard let superview = newSuperview else { return }
        if let parent = newSuperview?.superview as? NSScrollView {
            dayLabelingView.translatesAutoresizingMaskIntoConstraints = false
            parent.addSubview(dayLabelingView, positioned: .above, relativeTo: nil)
            dayLabelingView.layer?.backgroundColor = NSColor.white.cgColor
            dayLabelingView.layer?.opacity = 0.95
            dayLabelingView.leftAnchor.constraint(equalTo: parent.leftAnchor).isActive = true
            dayLabelingView.rightAnchor.constraint(equalTo: parent.rightAnchor).isActive = true
            dayLabelingView.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
            dayLabelingView.heightAnchor.constraint(equalToConstant: kDayLabelHeight).isActive = true
        }
        let zoomKey = SCKGridView.zoomLevelKey + ".\(String(describing:type(of:self)))"
        hourHeight = CGFloat(UserDefaults.standard.double(forKey: zoomKey))
        let minHourHeight = (superview.frame.height-kDayLabelHeight-20.0)/CGFloat(hourCount)
        if hourHeight < minHourHeight || hourHeight > 1000.0 {
            hourHeight = minHourHeight
        }
    }
    
    @objc func minuteTimerFired(timer: Timer) {
        needsDisplay = true
    }
    
    public override func magnify(with event: NSEvent) {
        let targetHourHeight = hourHeight + 16.0 * event.magnification
        if targetHourHeight * CGFloat(hourCount) >= superview!.frame.height-kDayLabelHeight {
            hourHeight = targetHourHeight
        } else {
            hourHeight = (superview!.frame.height-kDayLabelHeight) / CGFloat(hourCount)
        }
        needsDisplay = true
    }
    
    override func invalidateFrame(for eventView: SCKEventView) {
        let conflicts = controller.resolvedConflicts(for: eventView.eventHolder)
        if conflicts.count > 0 {
            eventView.eventHolder.conflictCount = conflicts.count
        } else {
            eventView.eventHolder.conflictCount = 1 //FIXME: Should not get here.
        }
        let idx = conflicts.index(where: { (tested) -> Bool in
            return (tested === eventView.eventHolder)
        }) ?? 0
        eventView.eventHolder.conflictIndex = idx 
        super.invalidateFrame(for: eventView)
    }
    
    public override var intrinsicContentSize: NSSize {
        return CGSize(width: NSViewNoIntrinsicMetric, height: kDayLabelHeight+20.0+CGFloat(hourCount)*hourHeight)
    }
    
    public override func resize(withOldSuperviewSize oldSize: NSSize) {
        super.resize(withOldSuperviewSize: oldSize) //Triggers relayout
        let visibleHeight = superview!.frame.height - kDayLabelHeight - 20.0
        let contentHeight = CGFloat(hourCount) * hourHeight
        if contentHeight < visibleHeight && hourCount > 0 {
            hourHeight = visibleHeight / CGFloat(hourCount)
        }
    }
    
    override func endRelayout() {
        super.endRelayout()
    }
}
