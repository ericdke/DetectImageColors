//
//  DemoExtensions.swift
//  detectImageColors
//
//  Created by ERIC DEJONCKHEERE on 05/08/2015.
//  Copyright © 2015 Eric Dejonckheere. All rights reserved.
//

import Cocoa

enum DragType {
    case Path, URL
}

extension NSView {
    func makePNGFromView() -> NSData? {
        guard let rep = self.bitmapImageRepForCachingDisplayInRect(self.bounds) else { return nil }
        self.cacheDisplayInRect(self.bounds, toBitmapImageRep: rep)
        guard let data = rep.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: [:]) else { return nil }
        return data
    }
}

extension CGFloat {
    func formatSliderDouble(multiplier: Double = 100.0) -> Double {
        return Double(self) * multiplier
    }
}