//
//  DemoBackgroundView.swift
//  detectImageColors

import Cocoa

class DemoBackgroundView: NSView {
    
    var colorCandidates: ColorCandidates? {
        didSet {
            self.display()
        }
    }

    override func drawRect(dirtyRect: NSRect) {
        if let color = self.colorCandidates?.background {
            color.setFill()
            NSRectFill(dirtyRect)
        }
        super.drawRect(dirtyRect)
    }
    
}
