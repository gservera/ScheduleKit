//
//  WhiteView.swift
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 2/11/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

import Cocoa


@IBDesignable final class WhiteView: NSView {

    override var isOpaque: Bool {
        return true
    }

    
    override func draw(_ dirtyRect: NSRect) {
        NSColor.white.set()
        dirtyRect.fill()
    }

}
