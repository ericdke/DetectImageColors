//
//  DemoBackgroundView.swift
//  detectImageColors

import Cocoa

class DemoBackgroundView: NSView {
    
    var color: NSColor? {
        didSet {
            self.display()
        }
    }

    override func drawRect(dirtyRect: NSRect) {
        if let color = self.color {
            color.setFill()
            NSRectFill(dirtyRect)
        }
        super.drawRect(dirtyRect)
    }
    
}
