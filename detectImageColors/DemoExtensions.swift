//
//  DemoExtensions.swift
//  detectImageColors
//
//  Created by ERIC DEJONCKHEERE on 05/08/2015.
//  Copyright © 2015 Eric Dejonckheere. All rights reserved.
//

import Cocoa

enum DragType {
    case path, url
}

extension NSView {
    func makePNGFromView() -> Data? {
        guard let rep = self.bitmapImageRepForCachingDisplay(in: self.bounds) else { return nil }
        self.cacheDisplay(in: self.bounds, to: rep)
        guard let data = rep.representation(using: NSBitmapImageFileType.PNG, properties: [:]) else { return nil }
        return data
    }
}

extension CGFloat {
    func formatSliderDouble(multiplier: Double = 100.0) -> Double {
        return Double(self) * multiplier
    }
}
