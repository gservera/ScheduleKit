//
//  EventLoadingView.swift
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 2/11/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

import Cocoa

final class EventLoadingView: NSView {

    let label = NSTextField(frame: .zero)
    let spinner = NSProgressIndicator(frame: .zero)

    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        if label.superview == nil {
            label.translatesAutoresizingMaskIntoConstraints = false
            label.isBordered = false
            label.isEditable = false
            label.isBezeled = false
            label.drawsBackground = false
            label.stringValue = "Loading events asynchronously…"
            label.font = NSFont.systemFont(ofSize: 30.0, weight: .thin)
            addSubview(label)
            label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 10.0).isActive = true
            label.sizeToFit()
            label.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(rawValue: 1000), for: .horizontal)
            label.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 1000), for: .horizontal)
            label.textColor = NSColor.labelColor

            spinner.style = .spinning
            spinner.translatesAutoresizingMaskIntoConstraints = false
            spinner.isIndeterminate = true
            addSubview(spinner)
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -30.0).isActive = true
            spinner.startAnimation(nil)
        } else if superview == nil {
            spinner.stopAnimation(nil)
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.controlBackgroundColor.set()
        dirtyRect.fill()
    }
}
