//
//  CDExtensions.swift
//  detectImageColors
//
//  Created by ERIC DEJONCKHEERE on 05/08/2015.
//  Copyright © 2015 Eric Dejonckheere. All rights reserved.
//

import Cocoa

extension NSImage {
    // Image has to fill a square completely
    public func resizeToSquare(max: CGFloat = CGFloat(600)) -> NSImage? {
        let (myWidth, myHeight): (CGFloat, CGFloat)
        if self.size.width < max {
            (myWidth, myHeight) = (self.size.width, self.size.width)
        } else {
            (myWidth, myHeight) = (max, max)
        }
        let destSize = NSMakeSize(myWidth, myHeight)
        let newImage = NSImage(size: destSize)
        newImage.lockFocus()
        self.drawInRect(NSMakeRect(0, 0, destSize.width, destSize.height),
            fromRect: NSMakeRect(0, 0, self.size.width, self.size.height),
            operation: NSCompositingOperation.CompositeSourceOver, fraction: CGFloat(1))
        newImage.unlockFocus()
        newImage.size = destSize
        guard let tiff = newImage.TIFFRepresentation, let resized = NSImage(data: tiff) else { return nil }
        return resized
    }
}