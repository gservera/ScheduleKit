/*
 *  SCKGridView.swift
 *  ScheduleKit
 *
 *  Created:    Guillem Servera on 28/10/2016.
 *  Copyright:  © 2016-2017 Guillem Servera (https://github.com/gservera)
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

/// An object conforming to the `SCKGridViewDelegate` protocol may implement a
/// method to provide unavailable time ranges to a grid-style schedule view in
/// addition to other methods defined in `SCKViewDelegate`.
@objc public protocol SCKGridViewDelegate: SCKViewDelegate {

    /// Implement this method to specify the first displayed hour. Defaults to 0.
    ///
    /// - Parameter gridView: The grid view asking for a start hour.
    /// - Returns: An hour value from 0 to 24.
    @objc(dayStartHourForGridView:) func dayStartHour(for gridView: SCKGridView) -> Int

    /// Implement this method to specify the last displayed hour. Defaults to 24.
    ///
    /// - Parameter gridView: The grid view asking for a start hour.
    /// - Returns: An hour value from 0 to 24, where 0 is parsed as 24.
    @objc(dayEndHourForGridView:) func dayEndHour(for gridView: SCKGridView) -> Int

    /// Implemented by a grid-style schedule view's delegate to provide an array
    /// of unavailable time ranges that are drawn as so by the view.
    ///
    /// - Parameter gridView: The schedule view asking for the values.
    /// - Returns: The array of unavailable time ranges (may be empty).
    @objc(unavailableTimeRangesForGridView:)
    optional func unavailableTimeRanges(for gridView: SCKGridView) -> [SCKUnavailableTimeRange]
}

/// An abstract `SCKView` subclass that implements the common functionality of any
/// grid-style schedule view, such as the built in day view and week view. This 
/// class provides conflict management, interaction with the displayed days and 
/// hours, displaying unavailable time intervals and a zoom feature. 
///
/// It also manages a series of day, month, hour and hour fraction labels, which 
/// are automatically updated and laid out by this class.
///
/// - Note: Do not instantiate this class directly.
///
public class SCKGridView: SCKView {

    private struct Constants {
        static let DayAreaHeight: CGFloat = 40.0
        static let DayAreaMarginBottom: CGFloat = 20.0
        static let MaxHeightPerHour: CGFloat = 300.0
        static let HourAreaWidth: CGFloat = 56.0
        static var paddingTop: CGFloat { return DayAreaHeight + DayAreaMarginBottom }
    }

    override func setUp() {
        super.setUp()
        updateHourParameters()
    }

    override public weak var delegate: SCKViewDelegate? {
        didSet {
            readDefaultsFromDelegate()
        }
    }

    // MARK: - Date handling additions

    override func didChangeDateInterval() {
        super.didChangeDateInterval()
        let sD = startDate
        let eD = endDate.addingTimeInterval(1)
        dayCount = sharedCalendar.dateComponents([.day], from: sD, to: eD).day!
        configureDayLabels()
        _ = self.minuteTimer
    }

    /// The number of days displayed. Updated by changing `dateInterval`.
    private(set) var dayCount: Int = 0

    /// A value representing the day start hour.
    private var dayStartPoint = SCKDayPoint.zero

    /// A view representign the day end hour.
    private var dayEndPoint = SCKDayPoint(hour: 24, minute: 0, second: 0)

    /// Called when the `dayStartPoint` and `dayEndPoint` change during
    /// initialisation or when their values are read from the delegate. Sets the
    /// `firstHour` and `hourCount` properties and ensures a minimum height per hour
    /// to fill the view.
    private func updateHourParameters() {
        firstHour = dayStartPoint.hour
        hourCount = dayEndPoint.hour - dayStartPoint.hour
        let minHourHeight = contentRect.height / CGFloat(hourCount)
        if hourHeight < minHourHeight {
            hourHeight = minHourHeight
        }
    }

    /// The first hour of the day displayed.
    internal var firstHour: Int = 0 {
        didSet { configureHourLabels() }
    }

    /// The total number of hours displayed.
    internal var hourCount: Int = 1 {
        didSet { configureHourLabels() }
    }

    /// The height for each hour row. Setting this value updated the saved one in
    /// UserDefaults and updates hour labels visibility.
    internal var hourHeight: CGFloat = 0.0 {
        didSet {
            if hourHeight != oldValue && superview != nil {
                let key = SCKGridView.defaultsZoomKeyPrefix + ".\(type(of: self))"
                UserDefaults.standard.set(hourHeight, forKey: key)
                invalidateIntrinsicContentSize()
            }
            updateHourLabelsVisibility()
        }
    }

    // MARK: - Day and hour labels

    private func label(_ text: String, size: CGFloat, color: NSColor) -> NSTextField {
        let label = NSTextField(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isBordered = false; label.isEditable = false; label.isBezeled = false; label.drawsBackground = false
        label.stringValue = text
        label.font = .systemFont(ofSize: size)
        label.textColor = color
        label.sizeToFit() // Needed
        return label
    }

    // MARK: Day and month labels

    /// An array containing all generated day labels.
    private var dayLabels: [NSTextField] = []

    /// An array containing all generated month labels.
    private var monthLabels: [NSTextField] = []

    /// A container view for day labels. Pinned at the top of the scroll view.
    private let dayLabelingView = NSView(frame: .zero)

    /// A date formatter for day labels.
    private var dayLabelsDateFormatter: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "EEEE d"; return f
    }()

    /// A date formatter for month labels.
    private var monthLabelsDateFormatter: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "MMMM"; return f
    }()

    /// Generates all the day and month labels for the displayed day range
    /// which have not been generated yet and installs them as subviews of this
    /// view, while also removing the unneeded ones from its superview. This
    /// method also updates the label's string value to match the displayed date
    /// interval. Eventually marks the view as needing layout. This method is 
    /// called whenever the day interval property changes.
    private func configureDayLabels() {
        // 1. Generate missing labels
        for day in 0..<dayCount {
            if dayLabels.count > day { // Skip already created labels
                continue
            }
            dayLabels.append(label("", size: 14.0, color: .darkGray))
            let monthLabel = label("", size: 12.0, color: .lightGray)
            monthLabel.isHidden = true
            monthLabels.append(monthLabel)
        }

        // 2. Add visible days' labels as subviews. Remove others if installed.
        // In addition, change label string values to the correct ones.
        for (day, dayLabel) in dayLabels.enumerated() {
            if dayLabel.superview != nil && day >= dayCount {
                dayLabel.removeFromSuperview()
                monthLabels[day].removeFromSuperview()
            } else if day < dayCount {
                if dayLabel.superview == nil {
                    dayLabelingView.addSubview(dayLabel)
                    dayLabelingView.addSubview(monthLabels[day])
                }
                let date = sharedCalendar.date(byAdding: .day, value: day, to: startDate)!
                let text = dayLabelsDateFormatter.string(from: date).uppercased()
                dayLabel.stringValue = text
                dayLabel.sizeToFit()

                // Show month label if first day in week or first day in month.
                if day == 0 || sharedCalendar.component(.day, from: date) == 1 {
                    let monthText = monthLabelsDateFormatter.string(from: date)
                    monthLabels[day].stringValue = monthText
                    monthLabels[day].sizeToFit()
                    monthLabels[day].isHidden = false
                } else {
                    monthLabels[day].isHidden = true
                }
            }
        }
        // 3. Set needs layout
        needsLayout = true
    }

    // MARK: Hour labels

    /// A dictionary containing all generated hour labels stored using the hour
    /// as the key for n:00 labels and the hour plus 100*m for n:m labels.
    private var hourLabels: [Int: NSTextField] = [:]

    /// Generates all the hour and minute labels for the displayed hour range which have not been generated yet and
    /// installs them as subviews of this view, while also removing the unneeded ones from its superview. Eventually
    /// marks the view as needing layout. This method is called when the first hour or the hour count properties change.
    private func configureHourLabels() {
        // 1. Generate missing hour labels
        for hourIdx in 0..<hourCount {
            let hour = firstHour + hourIdx
            if hourLabels[hour] != nil {
                continue
            }
            hourLabels[hour] = label("\(hour):00", size: 11, color: .darkGray)
            for min in [10, 15, 20, 30, 40, 45, 50] {
                let mLabel = label("\(hour):\(min)  -", size: 10, color: .lightGray)
                mLabel.isHidden = true
                hourLabels[hour+min*10] = mLabel
            }
        }

        // 2. Add visible hours' labels as subviews. Remove others if installed.
        for (hour, label) in hourLabels {
            guard hour < 100 else {continue}
            let shouldBeInstalled = (hour >= firstHour && hour < firstHour + hourCount)
            if label.superview != nil && !shouldBeInstalled {
                label.removeFromSuperview()
                for min in [10, 15, 20, 30, 40, 45, 50] {
                    hourLabels[min*10+hour]?.removeFromSuperview()
                }
            } else if label.superview == nil && shouldBeInstalled {
                addSubview(label)
                for min in [10, 15, 20, 30, 40, 45, 50] {
                    guard let mLabel = hourLabels[min*10+hour] else {
                        Swift.print("Warning: An hour label was missing")
                        continue
                    }
                    addSubview(mLabel)
                }
            }
        }

        // 3. Set needs layout
        needsLayout = true
    }

    /// Shows or hides the half hour, quarter hour and 10-minute hour labels 
    /// according to the hour height property. This method is called whenever the
    /// mentioned property changes.
    private func updateHourLabelsVisibility() {
        for (key, value) in hourLabels {
            guard eventViewBeingDragged == nil else {
                value.isHidden = true
                continue
            }
            switch key {
            case 300..<324:                                  value.isHidden = (hourHeight < 40.0)
            case 150..<174, 450..<474:                       value.isHidden = (hourHeight < 80.0 || hourHeight >= 120)
            case 100..<124, 200..<224, 400..<424, 500..<524: value.isHidden = (hourHeight < 120.0)
            default:                                         value.isHidden = false
            }
        }
    }

    // MARK: - Date transform additions

    override func relativeTimeLocation(for point: CGPoint) -> Double {
        if contentRect.contains(point) {
            let dayWidth: CGFloat = contentRect.width / CGFloat(dayCount)
            let offsetPerDay = 1.0 / Double(dayCount)
            let day = Int(trunc((point.x-contentRect.minX)/dayWidth))
            let dayOffset = offsetPerDay * Double(day)
            let offsetPerMin = calculateRelativeTimeLocation(for: startDate.addingTimeInterval(60))
            let offsetPerHour = 60.0 * offsetPerMin
            let totalMinutes = 60.0 * CGFloat(hourCount)
            let minute = totalMinutes * (point.y - contentRect.minY) / contentRect.height
            let minuteOffset = offsetPerMin * Double(minute)
            return dayOffset + offsetPerHour * Double(firstHour) + minuteOffset
        }
        return SCKRelativeTimeLocationInvalid
    }

    /// Returns the Y-axis position in the view's coordinate system that represents a particular hour and
    /// minute combination.
    /// - Parameters:
    ///   - hour: The hour.
    ///   - m: The minute.
    /// - Returns: The calculated Y position.
    internal func yFor(hour: Int, minute: Int) -> CGFloat {
        let canvas = contentRect
        let hours = CGFloat(hourCount)
        let h = CGFloat(hour - firstHour)
        return canvas.minY + canvas.height * (h + CGFloat(minute)/60.0) / hours
    }

    // MARK: - Event Layout overrides

    override public var contentRect: CGRect {
        // Exclude day and hour labeling areas.
        return CGRect(x: Constants.HourAreaWidth, y: Constants.paddingTop,
                      width: frame.width - Constants.HourAreaWidth, height: frame.height - Constants.paddingTop)
    }

    override func invalidateLayout(for eventView: SCKEventView) {
        // Overriden to manage event conflicts. No need to call super in this case.
        let conflicts = controller.resolvedConflicts(for: eventView.eventHolder)
        if !conflicts.isEmpty {
            eventView.eventHolder.conflictCount = conflicts.count
        } else {
            eventView.eventHolder.conflictCount = 1 //FIXME: Should not get here.
            NSLog("Unexpected behavior")
        }
        eventView.eventHolder.conflictIndex = conflicts.index(where: { $0 === eventView.eventHolder }) ?? 0
    }

    override func prepareForDragging() {
        updateHourLabelsVisibility()
        super.prepareForDragging()
    }

    override func restoreAfterDragging() {
        updateHourLabelsVisibility()
        super.restoreAfterDragging()
    }

    // MARK: - NSView overrides

    public override var intrinsicContentSize: NSSize {
        return CGSize(width: NSView.noIntrinsicMetric, height: CGFloat(hourCount) * hourHeight + Constants.paddingTop)
    }

    public override func layout() {
        NSLog("GridView layout triggered")
        super.layout(); let canvas = contentRect
        guard dayCount > 0 else { return } // View is not ready

        // Layout day labels
        let marginLeft = Constants.HourAreaWidth
        let dayLabelsRect = CGRect(x: marginLeft, y: 0, width: frame.width-marginLeft, height: Constants.DayAreaHeight)
        let dayWidth = dayLabelsRect.width / CGFloat(dayCount)

        for day in 0..<dayCount {
            let minX = marginLeft + CGFloat(day) * dayWidth; let midY = Constants.DayAreaHeight/2.0
            let dLabel = dayLabels[day]
            let o = CGPoint(x: minX + dayWidth/2.0 - dLabel.frame.width/2.0, y: midY - dLabel.frame.height/2.0)
            var r = CGRect(origin: o, size: dLabel.frame.size)
            if day == 0 || (Int(dLabel.stringValue.components(separatedBy: " ")[1]) == 1) {
                r.origin.y += 8.0
                let mLabel = monthLabels[day]
                let mOrigin = CGPoint(x: minX + dayWidth/2 - mLabel.frame.width/2, y: midY - mLabel.frame.height/2 - 7)
                mLabel.frame = CGRect(origin: mOrigin, size: mLabel.frame.size)
            }
            dLabel.frame = r
        }

        // Layout hour labels
        for (i, label) in hourLabels {
            let size = label.frame.size
            switch i {
            case 0..<24: // Hour label
                let o = CGPoint(x: marginLeft - size.width - 8, y: canvas.minY + CGFloat(i-firstHour) * hourHeight - 7)
                label.frame = CGRect(origin: o, size: size)
            default: // Get the hour and the minute
                var hour = i; while hour >= 50 { hour -= 50 }
                let hourOffset = canvas.minY + CGFloat(hour - firstHour) * hourHeight
                let o = CGPoint(x: marginLeft-size.width + 4, y: hourOffset+hourHeight * CGFloat((i-hour)/10)/60.0 - 7)
                label.frame = CGRect(origin: o, size: size)
            }
        }

        // Layout events
        let offsetPerDay = 1.0/Double(dayCount)
        for eventView in subviews.compactMap({ $0 as? SCKEventView }) where eventView.eventHolder.isReady {
            let holder = eventView.eventHolder!
            let day = Int(trunc(holder.relativeStart/offsetPerDay))
            let sPoint = SCKDayPoint(date: holder.cachedScheduledDate)
            let eMinute = sPoint.minute + holder.cachedDuration
            let ePoint = SCKDayPoint(hour: sPoint.hour, minute: eMinute, second: sPoint.second)
            var newFrame = CGRect.zero
            newFrame.origin.y = yFor(hour: sPoint.hour, minute: sPoint.minute)
            newFrame.size.height = yFor(hour: ePoint.hour, minute: ePoint.minute)-newFrame.minY
            newFrame.size.width = dayWidth / CGFloat(eventView.eventHolder.conflictCount)
            newFrame.origin.x = canvas.minX + CGFloat(day) * dayWidth + newFrame.width * CGFloat(holder.conflictIndex)
            eventView.frame |= newFrame
        }
    }

    public override func resize(withOldSuperviewSize oldSize: NSSize) {
        NSLog("View willresize")
        super.resize(withOldSuperviewSize: oldSize) // Triggers layout. Try to acommodate hour height.
        let visibleHeight = superview!.frame.height - Constants.paddingTop
        let contentHeight = CGFloat(hourCount) * hourHeight
        if contentHeight < visibleHeight && hourCount > 0 {
            hourHeight = visibleHeight / CGFloat(hourCount)
        }
        var testView: NSView? = self
        while testView != nil {
            NSLog("=========================")
            NSLog("View: %@", testView!)
            NSLog("Translates: %d", testView!.translatesAutoresizingMaskIntoConstraints)
            NSLog("Needs layout: %d", testView!.needsLayout)
            NSLog("=========================")

            testView = testView!.superview
        }
    }

    public override func viewWillMove(toSuperview newSuperview: NSView?) {
        // Insert day labeling view
        NSLog("View will move to %@", newSuperview ?? "NULL")
        guard let superview = newSuperview else { return }
        let height = Constants.DayAreaHeight
        if let parent = newSuperview?.superview?.superview {
            dayLabelingView.translatesAutoresizingMaskIntoConstraints = false
            parent.addSubview(dayLabelingView, positioned: .above, relativeTo: nil)
            NSLayoutConstraint.activate([
                dayLabelingView.leftAnchor.constraint(equalTo: parent.leftAnchor),
                dayLabelingView.rightAnchor.constraint(equalTo: parent.rightAnchor),
                dayLabelingView.topAnchor.constraint(equalTo: parent.topAnchor),
                dayLabelingView.heightAnchor.constraint(equalToConstant: height)
            ])
        }

        // Restore zoom if possible
        let zoomKey = SCKGridView.defaultsZoomKeyPrefix + ".\(String(describing: type(of: self)))"
        hourHeight = CGFloat(UserDefaults.standard.double(forKey: zoomKey))
        let minHourHeight = (superview.frame.height-Constants.paddingTop)/CGFloat(hourCount)
        if hourHeight < minHourHeight || hourHeight > 1000.0 {
            hourHeight = minHourHeight
        }
    }

    // MARK: - Delegate defaults

    /// Calls some of the delegate methods to reflect user preferences. The default implementation asks for
    /// unavailable time ranges and day start/end hours. Subclasses may override this method to set up additional
    /// parameters by importing settings from their delegate objects. This method is called when the view is set
    /// up and when the `invalidateUserDefaults()` method is called. You should not call this method directly.
    internal func readDefaultsFromDelegate() {
        guard let delegate = delegate as? SCKGridViewDelegate else { return }
        if let unavailableRanges = delegate.unavailableTimeRanges?(for: self) {
            unavailableTimeRanges = unavailableRanges
            needsDisplay = true
        }
        let start = delegate.dayStartHour(for: self)
        var end = delegate.dayEndHour(for: self)
        if end == 0 { end = 24 }
        dayStartPoint = SCKDayPoint(hour: start, minute: 0, second: 0)
        dayEndPoint = SCKDayPoint(hour: end, minute: 0, second: 0)
        updateHourParameters()
        invalidateIntrinsicContentSize()
        invalidateLayoutForAllEventViews()
    }

    /// Makes the view update some of its parameters, such as the unavailable time
    /// ranges by reflecting the values supplied by the delegate.
    @objc public final func invalidateUserDefaults() {
        readDefaultsFromDelegate()
    }

    // MARK: - Unavailable time ranges

    /// The time ranges that should be drawn as unavailable in this view.
    private var unavailableTimeRanges: [SCKUnavailableTimeRange] = []

    /// Calculates the rect to be drawn as unavailable from a given unavailable time range.
    /// - Parameter rng: The unavailable time range.
    /// - Returns: The calcualted rect.
    func rectForUnavailableTimeRange(_ rng: SCKUnavailableTimeRange) -> CGRect {
        let canvas = contentRect
        let dayWidth: CGFloat = canvas.width / CGFloat(dayCount)
        let sDate = sharedCalendar.date(bySettingHour: rng.startHour, minute: rng.startMinute, second: 0, of: startDate)!
        let sOffset = calculateRelativeTimeLocation(for: sDate)
        if sOffset != SCKRelativeTimeLocationInvalid {
            let endSeconds = rng.endMinute * 60 + rng.endHour * 3600
            let startSeconds = rng.startMinute * 60 + rng.startHour * 3600
            let eDate = sDate.addingTimeInterval(Double(endSeconds - startSeconds))
            let yOrigin = yFor(hour: rng.startHour, minute: rng.startMinute)
            var yLength: CGFloat = frame.maxY - yOrigin // Assuming SCKRelativeTimeLocationInvalid for eDate
            if calculateRelativeTimeLocation(for: eDate) != SCKRelativeTimeLocationInvalid {
                yLength = yFor(hour: rng.endHour, minute: rng.endMinute) - yOrigin
            }
            let weekday = (rng.weekday == -1) ? 0.0 : CGFloat(rng.weekday)
            return CGRect(x: canvas.minX + weekday * dayWidth, y: yOrigin, width: dayWidth, height: yLength)
        }
        return .zero
    }

    // MARK: - Minute timer

    /// A timer that fires every minute to mark the view as needing display in order to update the "now" line.
    private lazy var minuteTimer: Timer = {
        let sel = #selector(SCKGridView.minuteTimerFired(timer:))
        let t = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: sel, userInfo: nil, repeats: true)
        t.tolerance = 50.0
        return t
    }()

    @objc dynamic func minuteTimerFired(timer: Timer) {
        needsDisplay = true
    }

    // MARK: - Drawing

    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard hourCount > 0 else { return }
        drawUnavailableTimeRanges()
        drawDayDelimiters()
        drawHourDelimiters()
        drawCurrentTimeLine()
        drawDraggingGuidesIfNeeded()
    }

    private func drawUnavailableTimeRanges() {
        NSColor(red: 0.925, green: 0.942, blue: 0.953, alpha: 1.0).set()
        unavailableTimeRanges.forEach { rectForUnavailableTimeRange($0).fill() }
    }

    private func drawDayDelimiters() {
        let canvas = CGRect(x: Constants.HourAreaWidth, y: Constants.DayAreaHeight,
                            width: frame.width-Constants.HourAreaWidth, height: frame.height-Constants.DayAreaHeight)
        let dayWidth = canvas.width / CGFloat(dayCount)
        NSColor(deviceWhite: 0.95, alpha: 1.0).set()
        for day in 0..<dayCount {
            CGRect(x: canvas.minX + CGFloat(day) * dayWidth, y: canvas.minY, width: 1.0, height: canvas.height).fill()
        }
    }

    private func drawHourDelimiters() {
        NSColor(deviceWhite: 0.95, alpha: 1.0).set()
        for hour in 0..<hourCount {
            CGRect(x: contentRect.minX-8.0, y: contentRect.minY + CGFloat(hour) * hourHeight - 0.4,
                   width: contentRect.width + 8.0, height: 1.0).fill()
        }
    }

    private func drawCurrentTimeLine() {
        let canvas = contentRect
        let components = sharedCalendar.dateComponents([.hour, .minute], from: Date())
        let minuteCount = Double(hourCount) * 60.0
        let elapsedMinutes = Double(components.hour!-firstHour) * 60.0 + Double(components.minute!)
        let yOrigin = canvas.minY + canvas.height * CGFloat(elapsedMinutes / minuteCount)
        NSColor.red.setFill()
        CGRect(x: canvas.minX, y: yOrigin-0.25, width: canvas.width, height: 0.5).fill()
        NSBezierPath(ovalIn: CGRect(x: canvas.minX-2.0, y: yOrigin-2.0, width: 4.0, height: 4.0)).fill()
    }

    private func drawDraggingGuidesIfNeeded() {
        guard let dV = eventViewBeingDragged else {return}
        (dV.backgroundColor ?? NSColor.darkGray).setFill()

        func fill(_ xPos: CGFloat, _ yPos: CGFloat, _ wDim: CGFloat, _ hDim: CGFloat) {
            CGRect(x: xPos, y: yPos, width: wDim, height: hDim).fill()
        }
        let canvas = contentRect
        let dragFrame = dV.frame

        // Left, right, top and bottom guides
        fill(canvas.minX, dragFrame.midY-1.0, dragFrame.minX-canvas.minX, 2.0)
        fill(dragFrame.maxX, dragFrame.midY-1.0, frame.width-dragFrame.maxX, 2.0)
        fill(dragFrame.midX-1.0, canvas.minY, 2.0, dragFrame.minY-canvas.minY)
        fill(dragFrame.midX-1.0, dragFrame.maxY, 2.0, frame.height-dragFrame.maxY)

        let dayWidth = canvas.width / CGFloat(dayCount)
        let offsetPerDay = 1.0/Double(dayCount)
        let startOffset = relativeTimeLocation(for: CGPoint(x: dragFrame.midX, y: dragFrame.minY))
        if startOffset != SCKRelativeTimeLocationInvalid {
            fill(canvas.minX+dayWidth*CGFloat(trunc(startOffset/offsetPerDay)), canvas.minY, dayWidth, 2.0)
            let startDate = calculateDate(for: startOffset)!
            let sPoint = SCKDayPoint(date: startDate)
            let ePoint = SCKDayPoint(date: startDate.addingTimeInterval(Double(dV.eventHolder.cachedDuration)*60.0))
            let sLabelText = NSString(format: "%ld:%02ld", sPoint.hour, sPoint.minute)
            let eLabelText = NSString(format: "%ld:%02ld", ePoint.hour, ePoint.minute)
            let attrs: [NSAttributedStringKey: Any] = [
                .foregroundColor: NSColor.darkGray,
                .font: NSFont.systemFont(ofSize: 12.0)
            ]
            let sLabelSize = sLabelText.size(withAttributes: attrs)
            let eLabelSize = eLabelText.size(withAttributes: attrs)
            let sLabelRect = CGRect(x: Constants.HourAreaWidth/2.0-sLabelSize.width/2.0,
                                    y: dragFrame.minY-sLabelSize.height/2.0,
                                    width: sLabelSize.width, height: sLabelSize.height)
            let eLabelRect = CGRect(x: Constants.HourAreaWidth/2.0-eLabelSize.width/2.0,
                                    y: dragFrame.maxY-eLabelSize.height/2.0,
                                    width: eLabelSize.width, height: eLabelSize.height)
            sLabelText.draw(in: sLabelRect, withAttributes: attrs)
            eLabelText.draw(in: eLabelRect, withAttributes: attrs)
            let durationText = "\(dV.eventHolder.cachedDuration) min"
            let dLabelSize = durationText.size(withAttributes: attrs)
            let durationRect = CGRect(x: Constants.HourAreaWidth/2.0-dLabelSize.width/2.0,
                                      y: dragFrame.midY-dLabelSize.height/2.0,
                                      width: dLabelSize.width, height: dLabelSize.height)
            durationText.draw(in: durationRect, withAttributes: attrs)
        }
    }
}

// MARK: - Hour height and zoom

extension SCKGridView {

    /// A prefix that appended to the class name works as a user defaults key for
    /// the last zoom level used by each subclass.
    private static let defaultsZoomKeyPrefix = "MEKZoom"

    /// Increases the hour height property if less than the maximum value. Marks the view as needing display.
    func increaseZoomFactor() {
        if hourHeight < Constants.MaxHeightPerHour {
            hourHeight += 8.0
            needsDisplay = true
        }
    }

    /// Decreases the hour height property if greater than the minimum value. Marks the view as needing display.
    func decreaseZoomFactor() {
        processNewHourHeight(hourHeight - 8.0)
    }

    public override func magnify(with event: NSEvent) {
        processNewHourHeight(hourHeight + 16.0 * event.magnification)
    }

    /// Increases or decreases the hour height property if greater than the minimum value and less than the maximum
    /// hour height. Marks the view as needing display.
    /// - Parameter targetHeight: The calculated new hour height.
    private func processNewHourHeight(_ targetHeight: CGFloat) {
        guard targetHeight < Constants.MaxHeightPerHour else {
            hourHeight = Constants.MaxHeightPerHour
            needsDisplay = true
            return
        }
        let minimumContentHeight = superview!.frame.height - Constants.paddingTop
        if targetHeight * CGFloat(hourCount) >= minimumContentHeight {
            hourHeight = targetHeight
        } else {
            hourHeight = minimumContentHeight / CGFloat(hourCount)
        }
        needsDisplay = true
    }
}
