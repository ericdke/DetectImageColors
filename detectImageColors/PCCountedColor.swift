//
//  PCCountedColor.swift
//  colortunes
//
//  Created by ERIC DEJONCKHEERE on 03/04/2015.
//  Copyright (c) 2015 Eric Dejonckheere. All rights reserved.
//

import Cocoa

class PCCountedColor: NSObject {

    var color: NSColor
    var count: NSInteger

    init(color: NSColor, count: NSInteger) {
        self.color = color
        self.count = count
        super.init()
    }

    func compare(object: PCCountedColor) -> NSComparisonResult {
        if self.count < object.count {
            return NSComparisonResult.OrderedDescending
        } else if self.count == object.count {
            return NSComparisonResult.OrderedSame
        }
        return NSComparisonResult.OrderedAscending
    }

}
