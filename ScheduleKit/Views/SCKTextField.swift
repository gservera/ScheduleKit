//
//  SCKTextField.swift
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 30/10/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

import Cocoa


private final class SCKTextFieldCell: NSTextFieldCell {
    
    private var editingOrSelected = false
    
    fileprivate override func drawingRect(forBounds rect: NSRect) -> NSRect {
        var rect = super.drawingRect(forBounds: rect)
        if !editingOrSelected {
            let size = cellSize(forBounds: rect)
            let Δheight = rect.height - size.height
            if Δheight > 0.0 {
                rect.size.height -= Δheight
                rect.origin.y = Δheight/2.0
            }
        }
        return rect
    }
    
    override func select(withFrame rect: NSRect,
                         in controlView: NSView,
                         editor textObj: NSText,
                         delegate: Any?,
                         start selStart: Int,
                         length selLength: Int) {
        let newRect = drawingRect(forBounds: rect)
        editingOrSelected = true
        super.select(withFrame: newRect, in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
        editingOrSelected = false
    }
    
    override func edit(withFrame rect: NSRect,
                       in controlView: NSView,
                       editor textObj: NSText,
                       delegate: Any?,
                       event: NSEvent?) {
        let newRect = drawingRect(forBounds: rect)
        editingOrSelected = true
        super.edit(withFrame: newRect, in: controlView, editor: textObj, delegate: delegate, event: event)
        editingOrSelected = false
    }
}



/**
 *  This class provides a custom NSTextField whose cell renders its string value
 *  vertically centered when the actual text is not being selected and/or edited.
 */
final class SCKTextField: NSTextField {

    override class func cellClass() -> AnyClass {
        return SCKTextFieldCell.self
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setUpDefaultProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpDefaultProperties() {
        drawsBackground = false
        isEditable = false
        isBezeled = false
        alignment = .center
        font = NSFont.systemFont(ofSize: 12.0)
    }

}
