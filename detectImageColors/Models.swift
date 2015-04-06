//
//  PCCountedColor.swift
//  colortunes
//
//  Created by ERIC DEJONCKHEERE on 03/04/2015.
//  Copyright (c) 2015 Eric Dejonckheere. All rights reserved.
//

import Cocoa

struct ColorCandidates {
    var primary: NSColor?
    var secondary: NSColor?
    var detail: NSColor?
    var background: NSColor?
}

class PCCountedColor: NSObject {

    var color: NSColor
    var count: NSInteger

    init(color: NSColor, count: NSInteger) {
        self.color = color
        self.count = count
        super.init()
    }

}
