//
//  Image.swift
//  detectImageColors
//
//  Created by ERIC DEJONCKHEERE on 06/04/2015.
//  Copyright (c) 2015 Eric Dejonckheere. All rights reserved.
//

import Cocoa

class ImageManager: NSObject {

    func scaleImage(image: NSImage, scaledSize: NSSize) -> NSImage {
        let imageSize = image.size
        let squareImage = drawSquareImage(NSImage(size: NSMakeSize(imageSize.width, imageSize.width)), withImage: image, atSize: imageSize)
        let localScaledImage = drawScaledSquare(squareImage, withImage: NSImage(size: scaledSize), atSize: imageSize)
        return finalImageFromSquaredImage(localScaledImage)
    }

    private func makeImageSquareRect(imageSize: NSSize) -> NSRect {
        if imageSize.height > imageSize.width {
            return NSMakeRect(0, imageSize.height - imageSize.width, imageSize.width, imageSize.width)
        } else {
            return NSMakeRect(0, 0, imageSize.height, imageSize.height)
        }
    }

    private func drawSquareImage(squareImage: NSImage, withImage image: NSImage, atSize imageSize: NSSize) -> NSImage {
        let drawRect = makeImageSquareRect(imageSize)
        squareImage.lockFocus()
        image.drawInRect(NSMakeRect(0, 0, imageSize.width, imageSize.height), fromRect: drawRect, operation: NSCompositingOperation.CompositeSourceOver, fraction: 1.0)
        squareImage.unlockFocus()
        return squareImage
    }

    private func drawScaledSquare(squareImage: NSImage, withImage image: NSImage, atSize imageSize: NSSize) -> NSImage {
        image.lockFocus()
        squareImage.drawInRect(NSMakeRect(0, 0, imageSize.width, imageSize.height), fromRect: NSZeroRect, operation: NSCompositingOperation.CompositeSourceOver, fraction: 1.0)
        image.unlockFocus()
        return image
    }

    private func finalImageFromSquaredImage(scaledImage: NSImage) -> NSImage {
        let cgImage = scaledImage.CGImageForProposedRect(nil, context: nil, hints: nil)
        let bitmapRep = NSBitmapImageRep(CGImage: cgImage!.takeRetainedValue())
        var finalImage = NSImage(size: scaledImage.size)
        finalImage.addRepresentation(bitmapRep)
        return finalImage
    }

}
