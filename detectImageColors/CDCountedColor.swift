//
//  CDCountedColor.swift
//  detectImageColors
//
//  Created by ERIC DEJONCKHEERE on 22/06/2016.
//  Copyright © 2016 Eric Dejonckheere. All rights reserved.
//

import Cocoa

struct CDCountedColor {
    var color: NSColor
    var count: Int
    init(color: NSColor, count: Int) {
        self.color = color
        self.count = count
    }
}
