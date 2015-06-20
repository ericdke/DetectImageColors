//
//  DemoColorView.swift
//  detectImageColors
//
//  Created by ERIC DEJONCKHEERE on 20/06/2015.
//  Copyright (c) 2015 Eric Dejonckheere. All rights reserved.
//

import Cocoa

class DemoColorView: NSView {
    @IBOutlet weak var backgroundColorLabel: NSTextField!
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
