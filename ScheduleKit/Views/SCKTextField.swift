/*
 *  SCKTextField.swift
 *  ScheduleKit
 *
 *  Created:    Guillem Servera on 3/10/2016.
 *  Copyright:  © 2014-2016 Guillem Servera (https://github.com/gservera)
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

private final class SCKTextFieldCell: NSTextFieldCell {
    
    /// A flag property to track whether the text field is selected or being
    /// edited.
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
    
    override func select(withFrame rect: NSRect, in controlView: NSView,
                         editor textObj: NSText, delegate: Any?,
                         start selStart: Int,    length selLength: Int) {
        let newRect = drawingRect(forBounds: rect)
        editingOrSelected = true
        super.select(withFrame: newRect, in: controlView, editor: textObj,
                     delegate: delegate, start: selStart, length: selLength)
        editingOrSelected = false
    }
    
    override func edit(withFrame rect: NSRect, in controlView: NSView,
                       editor textObj: NSText, delegate: Any?, event: NSEvent?) {
        let newRect = drawingRect(forBounds: rect)
        editingOrSelected = true
        super.edit(withFrame: newRect, in: controlView, editor: textObj,
                   delegate: delegate, event: event)
        editingOrSelected = false
    }
}


/// This class provides a custom NSTextField whose cell renders its string value
/// vertically centered when the actual text is not selected and/or being edited.
internal final class SCKTextField: NSTextField {

    override class func cellClass() -> AnyClass {
        return SCKTextFieldCell.self
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setUpDefaultProperties()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpDefaultProperties()
    }
    
    /// Sets up the text field default properties.
    private func setUpDefaultProperties() {
        drawsBackground = false
        isEditable = false
        isBezeled = false
        alignment = .center
        font = NSFont.systemFont(ofSize: 12.0)
    }
}
