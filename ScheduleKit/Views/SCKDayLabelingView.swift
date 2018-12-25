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

class SCKDayLabelingView: NSView {

    class WeekdayLabelWrapper {

        static private func makeLabel(fontSize: CGFloat, color: NSColor) -> NSTextField {
            let label = NSTextField(frame: .zero)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.isBordered = false;
            label.isEditable = false;
            label.isBezeled = false;
            label.drawsBackground = false
            label.font = .systemFont(ofSize: fontSize)
            label.textColor = color
            return label
        }

        let weekdayLabel = WeekdayLabelWrapper.makeLabel(fontSize: 14, color: .labelColor)
        let monthLabel = WeekdayLabelWrapper.makeLabel(fontSize: 12, color: .secondaryLabelColor)

        var weekdayLabelYConstraint: NSLayoutConstraint!
        var weekdayLabelXConstraint: NSLayoutConstraint!
        var monthLabelXConstraint: NSLayoutConstraint!
        var monthLabelYConstraint: NSLayoutConstraint!

        func activateConstraints() {
            NSLayoutConstraint.activate([
                weekdayLabelXConstraint, weekdayLabelYConstraint, monthLabelXConstraint, monthLabelYConstraint
            ].compactMap{$0})
        }

        func deactivateConstraints() {
            NSLayoutConstraint.deactivate([
                weekdayLabelXConstraint, weekdayLabelYConstraint, monthLabelXConstraint, monthLabelYConstraint
                ].compactMap{$0})
        }
    }

    /// A date formatter for day labels.
    private let dayLabelsDateFormatter: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "EEEE d"; return f
    }()

    /// A date formatter for month labels.
    private let monthLabelsDateFormatter: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "MMMM"; return f
    }()

    private var labelWrappers: [WeekdayLabelWrapper] = []

    /// Generates all the day and month labels for the displayed day range
    /// which have not been generated yet and installs them as subviews of this
    /// view, while also removing the unneeded ones from its superview. This
    /// method also updates the label's string value to match the displayed date
    /// interval. Eventually marks the view as needing layout. This method is
    /// called whenever the day interval property changes.
    func configure(dayCount: Int, startDate: Date) {

        // 1. Generate missing labels
        for day in 0..<dayCount {
            if labelWrappers.count > day { // Skip already created labels
                continue
            }
            let wrapper = WeekdayLabelWrapper()
            labelWrappers.append(wrapper)
        }
        labelWrappers.removeSubrange(dayCount..<labelWrappers.count)

        // 2. Add visible days' labels as subviews. Remove others if installed.
        // In addition, change label string values to the correct ones.
        for (day, wrapper) in labelWrappers.enumerated() {
            if wrapper.weekdayLabel.superview != nil && day >= dayCount {
                wrapper.deactivateConstraints()
                wrapper.weekdayLabel.removeFromSuperview()
                wrapper.monthLabel.removeFromSuperview()
            } else if day < dayCount {
                let date = sharedCalendar.date(byAdding: .day, value: day, to: startDate)!
                let text = dayLabelsDateFormatter.string(from: date).uppercased()
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
                if day == 0 || sharedCalendar.component(.day, from: date) == 1 {

                    let monthText = monthLabelsDateFormatter.string(from: date)
                    wrapper.monthLabel.stringValue = monthText
                    wrapper.monthLabel.sizeToFit()
                    wrapper.monthLabel.isHidden = false

                } else {
                    wrapper.monthLabel.isHidden = true
                }
            }
        }

        // 3. Set needs update constraints
        needsUpdateConstraints = true

    }

    override func updateConstraints() {

        let rect = CGRect(origin: .zero, size: frame.size)
        let dayWidth = rect.width / CGFloat(labelWrappers.count)

        for (day, wrapper) in labelWrappers.enumerated() {

            let minX = CGFloat(day) * dayWidth;
            let midY = frame.height/2.0
            let leftMargin = minX + dayWidth/2.0 - wrapper.weekdayLabel.frame.width / 2.0

            wrapper.weekdayLabelXConstraint.constant = leftMargin

            if day == 0 || (Int(wrapper.weekdayLabel.stringValue.components(separatedBy: " ")[1]) == 1) {

                wrapper.weekdayLabelYConstraint.constant = midY - wrapper.weekdayLabel.frame.height/2.0 - 8.0

                let monthLeftMargin = minX + dayWidth/2 - wrapper.monthLabel.frame.width/2
                wrapper.monthLabelXConstraint.constant = monthLeftMargin
                wrapper.monthLabelYConstraint.constant = midY - wrapper.monthLabel.frame.height/2 + 7
            } else {
                wrapper.weekdayLabelYConstraint.constant = midY - wrapper.weekdayLabel.frame.height/2.0
            }
        }
        super.updateConstraints()
    }
    
}
