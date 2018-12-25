/*
 *  SCKHourLabelingView.swift
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

final class SCKHourLabelingView: NSView {

    class HourLabelWrapper {

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

        let label: NSTextField

        init(_ text: String, fontSize: CGFloat, color: NSColor) {
            label = HourLabelWrapper.makeLabel(fontSize: fontSize, color: color)
            label.stringValue = text
            label.sizeToFit()
        }

        var labelYConstraint: NSLayoutConstraint!
    }

    /// A dictionary containing all generated hour labels stored using the hour
    /// as the key for n:00 labels and the hour plus 100*m for n:m labels.
    private var labelWrappers: [Int: HourLabelWrapper] = [:]

    private var firstHour: Int = 0
    private var hourCount: Int = 0
    private var hourHeight: CGFloat = 0.0
    var paddingTop: CGFloat = 0.0

    /// Generates all the hour and minute labels for the displayed hour range which have not been generated yet and
    /// installs them as subviews of this view, while also removing the unneeded ones from its superview. Eventually
    /// marks the view as needing layout. This method is called when the first hour or the hour count properties change.
    func configureHourLabels(firstHour: Int, hourCount: Int) {
        self.hourCount = hourCount
        self.firstHour = firstHour
        // 1. Generate missing hour labels
        for hourIdx in 0..<hourCount {
            let hour = firstHour + hourIdx
            if labelWrappers[hour] != nil {
                continue
            }
            labelWrappers[hour] = HourLabelWrapper("\(hour):00", fontSize: 11, color: .darkGray)
            for min in [10, 15, 20, 30, 40, 45, 50] {
                let mWrapper = HourLabelWrapper("\(hour):\(min)  -", fontSize: 10, color: .lightGray)
                mWrapper.label.isHidden = true
                labelWrappers[hour+min*10] = mWrapper
            }
        }

        // 2. Add visible hours' labels as subviews. Remove others if installed.
        for (hour, wrapper) in labelWrappers {
            guard hour < 100 else {continue}
            let shouldBeInstalled = (hour >= firstHour && hour < firstHour + hourCount)
            if wrapper.label.superview != nil && !shouldBeInstalled {
                wrapper.label.removeFromSuperview()
                for min in [10, 15, 20, 30, 40, 45, 50] {
                    labelWrappers[min*10+hour]?.label.removeFromSuperview()
                }
            } else if wrapper.label.superview == nil && shouldBeInstalled {
                addSubview(wrapper.label)
                wrapper.label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
                wrapper.labelYConstraint = wrapper.label.topAnchor.constraint(equalTo: topAnchor)
                for min in [10, 15, 20, 30, 40, 45, 50] {
                    guard let mLabel = labelWrappers[min*10+hour]?.label else {
                        Swift.print("Warning: An hour label was missing")
                        continue
                    }
                    addSubview(mLabel)
                    mLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
                    labelWrappers[min*10+hour]?.labelYConstraint = labelWrappers[min*10+hour]!.label.topAnchor.constraint(equalTo: topAnchor)
                }
            }
        }

        // 3. Set needs layout
        needsUpdateConstraints = true
    }

    /// Shows or hides the half hour, quarter hour and 10-minute hour labels
    /// according to the hour height property. This method is called whenever the
    /// mentioned property changes.
    func updateHourLabelsVisibility(hourHeight: CGFloat, eventViewBeingDragged: NSView?) {
        self.hourHeight = hourHeight
        invalidateIntrinsicContentSize()
        for (key, wrapper) in labelWrappers {
            guard eventViewBeingDragged == nil else {
                wrapper.label.isHidden = true
                continue
            }
            switch key {
            case 300..<324:
                wrapper.label.isHidden = (hourHeight < 40.0)
            case 150..<174, 450..<474:
                wrapper.label.isHidden = (hourHeight < 80.0 || hourHeight >= 120)
            case 100..<124, 200..<224, 400..<424, 500..<524:
                wrapper.label.isHidden = (hourHeight < 120.0)
            default:
                wrapper.label.isHidden = false
            }
        }
    }

    override func updateConstraints() {

        for (i, wrapper) in labelWrappers {
            guard wrapper.label.superview != nil else { continue }
            switch i {
            case 0..<24: // Hour label
                let y = CGFloat(i-firstHour) * hourHeight - 7
                wrapper.labelYConstraint.constant = y + paddingTop
                wrapper.labelYConstraint.isActive = true
            default: // Get the hour and the minute
                var hour = i; while hour >= 50 { hour -= 50 }
                let hourOffset = CGFloat(hour - firstHour) * hourHeight
                let y = hourOffset+hourHeight * CGFloat((i-hour)/10)/60.0 - 7
                wrapper.labelYConstraint.constant = y + paddingTop
                wrapper.labelYConstraint.isActive = true
            }
        }

        super.updateConstraints()
    }

    public override var intrinsicContentSize: NSSize {
        return CGSize(width: NSView.noIntrinsicMetric,
                      height: paddingTop + CGFloat(hourCount) * hourHeight)
    }
}
