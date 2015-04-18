//
//  CDCountedColor.swift
//  colorDetector
//
//  Created by ERIC DEJONCKHEERE on 03/04/2015.
//  Copyright (c) 2015 Eric Dejonckheere. All rights reserved.
//

import Cocoa

public struct ColorCandidates {
    public var primary: NSColor?
    public var secondary: NSColor?
    public var detail: NSColor?
    public var background: NSColor?
    public var backgroundIsDark: Bool?
    public var backgroundIsBlackOrWhite: Bool?
}

class CDCountedColor: NSObject {
    var color: NSColor
    var count: NSInteger
    init(color: NSColor, count: NSInteger) {
        self.color = color
        self.count = count
        super.init()
    }
}
