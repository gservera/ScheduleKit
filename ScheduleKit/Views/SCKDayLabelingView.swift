/*
 *  SCKDayLabelingView.swift
 *  ScheduleKit
 *
 *  Created:    Guillem Servera on 25/12/2018.
 *  Copyright:  © 2018-2019 Guillem Servera (https://github.com/gservera)
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

/// The SCKGridView's subview that displays a suitable set of weekday and month labels.
class SCKDayLabelingView: NSVisualEffectView {

    /// A class to group a each weekday label with its month label and layout constraints.
    class WeekdayLabelWrapper {

        /// The weekday label.
        let weekdayLabel = NSTextField.makeLabel(fontSize: 14, color: .labelColor)
        /// A month label. Shown in first day of week or first day of month.
        let monthLabel = NSTextField.makeLabel(fontSize: 12, color: .secondaryLabelColor)
        /// Whether this wrapper represents the first day of the month.
        var isFirstDayOfMonth: Bool = false
        /// The weekday label's top constraint regarding the labeling view.
        var weekdayLabelYConstraint: NSLayoutConstraint!
        /// The weekday label's leading constraint regarding the labeling view.
        var weekdayLabelXConstraint: NSLayoutConstraint!
        /// The month label's leading constraint regarding the labeling view.
        var monthLabelXConstraint: NSLayoutConstraint!
        /// The month label's top constraint regarding the labeling view.
        var monthLabelYConstraint: NSLayoutConstraint!

        /// Activates the leading and top constraints for the week and month labels.
        func activateConstraints() {
            NSLayoutConstraint.activate([
                weekdayLabelXConstraint, weekdayLabelYConstraint, monthLabelXConstraint, monthLabelYConstraint
                ].compactMap {$0})
        }

        /// Deactivates the leading and top constraints for the week and month labels.
        func deactivateConstraints() {
            NSLayoutConstraint.deactivate([
                weekdayLabelXConstraint, weekdayLabelYConstraint, monthLabelXConstraint, monthLabelYConstraint
                ].compactMap {$0})
        }

        deinit {
            weekdayLabel.removeFromSuperview()
            monthLabel.removeFromSuperview()
        }
    }

    /// The date formatter for day labels.
    private let dayLabelsDateFormatter: DateFormatter = {
        let formatter = DateFormatter(); formatter.dateFormat = "EEEE d"; return formatter
    }()

    /// The date formatter for month labels.
    private let monthLabelsDateFormatter: DateFormatter = {
        let formatter = DateFormatter(); formatter.dateFormat = "MMMM"; return formatter
    }()

    /// An array containing all generated day label wrappers.
    private var labelWrappers: [WeekdayLabelWrapper] = []

    /// A local copy of the SCKGridView's day count.
    private var dayCount: Int = 0

    /// A local copy of the SCKGridView's start date.
    private var startDate: Date!

    /// Generates all the day and month labels for the displayed day range
    /// which have not been generated yet and installs them as subviews of this
    /// view, while also removing the unneeded ones from its superview. This
    /// method also updates the label's string value to match the displayed date
    /// interval. Eventually marks the view as needing layout. This method is
    /// called whenever the day interval property changes.
    /// - Warning: View is not inserted nor has a valid frame the first time this
    ///            method is called.
    func configure(dayCount: Int, startDate: Date) {
        blendingMode = .withinWindow
        self.dayCount = dayCount
        self.startDate = startDate
        // 1. Generate missing labels
        for day in 0..<dayCount where day >= labelWrappers.count { // Skip already created wrappers
            labelWrappers.append(WeekdayLabelWrapper())
        }
        labelWrappers.removeSubrange(dayCount..<labelWrappers.count)

        // 2. Prepare date formatters
        reconfigureDateFormatAccordingToFrameWidth()

        // 3. Add visible days' labels as subviews. Remove others if installed.
        // In addition, change label string values to the correct ones.
        for (day, wrapper) in labelWrappers.enumerated() {
            if wrapper.weekdayLabel.superview != nil && day >= dayCount {
                wrapper.deactivateConstraints()
                wrapper.weekdayLabel.removeFromSuperview()
                wrapper.monthLabel.removeFromSuperview()
            } else {
                let date = sharedCalendar.date(byAdding: .day, value: day, to: startDate)!
                let text = dayLabelsDateFormatter.string(from: date).uppercased()
                wrapper.isFirstDayOfMonth = (sharedCalendar.component(.day, from: date) == 1)
                wrapper.weekdayLabel.stringValue = text
                wrapper.weekdayLabel.sizeToFit()

                if wrapper.weekdayLabel.superview == nil {
                    addSubview(wrapper.weekdayLabel)
                    addSubview(wrapper.monthLabel)

                    wrapper.weekdayLabelYConstraint = wrapper.weekdayLabel.topAnchor.constraint(equalTo: topAnchor)
                    wrapper.weekdayLabelXConstraint = wrapper.weekdayLabel.leftAnchor.constraint(equalTo: leftAnchor)
                    wrapper.monthLabelXConstraint = wrapper.monthLabel.leftAnchor.constraint(equalTo: leftAnchor)
                    wrapper.monthLabelYConstraint = wrapper.monthLabel.topAnchor.constraint(equalTo: topAnchor)
                    wrapper.activateConstraints()
                }

                // Show month label if first day in week or first day in month.
                let midY = frame.height/2.0
                if day == 0 || wrapper.isFirstDayOfMonth {
                    wrapper.weekdayLabelYConstraint.constant = midY - wrapper.weekdayLabel.frame.height/2.0 - 8.0
                    let monthText = monthLabelsDateFormatter.string(from: date)
                    wrapper.monthLabel.stringValue = monthText
                    wrapper.monthLabel.sizeToFit()
                    wrapper.monthLabelYConstraint.constant = midY - wrapper.monthLabel.frame.height/2 + 7
                    wrapper.monthLabel.isHidden = false
                } else {
                    wrapper.weekdayLabelYConstraint.constant = midY - wrapper.weekdayLabel.frame.height/2.0
                    wrapper.monthLabel.isHidden = true
                }
            }
        }

        // 4. Set needs update constraints
        needsUpdateConstraints = true
    }

    override func updateConstraints() {
        // 1. Calculate the available room for each wrapper's labels
        let wrapperWidth = frame.width / CGFloat(labelWrappers.count)

        for (weekdayIndex, wrapper) in labelWrappers.enumerated() {
            // 2. Calculate each wrapper's X origin.
            let wrapperMinX = CGFloat(weekdayIndex) * wrapperWidth
            // 3. Place weekday label in the horizontal axis
            let weekdayLabelHalfWidth = wrapper.weekdayLabel.frame.width / 2.0
            let weekdayLabelMinX = wrapperMinX + wrapperWidth/2.0 - weekdayLabelHalfWidth
            wrapper.weekdayLabelXConstraint.constant = weekdayLabelMinX
            // 4. Place month label in the horizontal axis if needed
            if weekdayIndex == 0 || wrapper.isFirstDayOfMonth {
                let monthLeftMargin = wrapperMinX + wrapperWidth/2.0 - wrapper.monthLabel.frame.width / 2.0
                wrapper.monthLabelXConstraint.constant = monthLeftMargin
            }
        }
        super.updateConstraints()
    }

    override func resize(withOldSuperviewSize oldSize: NSSize) {
        super.resize(withOldSuperviewSize: oldSize)
        // Reconfigure weekday and month labels' text to match the new size
        guard let superview = superview else { return }
        let oldWidth = oldSize.width / CGFloat(dayCount)
        let newWidth = superview.frame.width / CGFloat(dayCount)
        if oldWidth <= 110 && newWidth > 110 {
            configure(dayCount: dayCount, startDate: startDate)
        } else if oldWidth > 110 && newWidth <= 110 {
            configure(dayCount: dayCount, startDate: startDate)
        }
    }

    /// Changes the weekday and month date formatters' format to match a new size
    private func reconfigureDateFormatAccordingToFrameWidth() {
        guard let superview = superview else { return }
        let prefersWiderFormat = superview.frame.width / CGFloat(dayCount) > 110
        dayLabelsDateFormatter.dateFormat = prefersWiderFormat ? "EEEE d" : "EEE d"
        monthLabelsDateFormatter.dateFormat = prefersWiderFormat ? "MMMM" : "MMM"
    }
}
