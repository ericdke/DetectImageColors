//
//  ColorTunes.swift
//  colortunes
//
//  Adapted & Created by ERIC DEJONCKHEERE on 03/04/2015.
//  Copyright (c) 2015 Eric Dejonckheere. All rights reserved.
//
// Original code (Objective-C) by PanicSoftware

import Cocoa

let kColorThresholdMinimumPercentage = 0.01

class ColorTunes: NSObject {

    var scaledSize: NSSize
    var scaledImage: NSImage?
    var backgroundColor: NSColor?
    var primaryColor: NSColor?
    var secondaryColor: NSColor?
    var detailColor: NSColor?

    init(image: NSImage, size: NSSize) {
        self.scaledSize = size
        super.init()
        let temp = self.scaledImage(image, scaledSize: size)
        self.scaledImage = temp
        self.analyzeImage(temp)
    }

    func scaledImage(image: NSImage, scaledSize: NSSize) -> NSImage {
        var imageSize = image.size
        var squareImage = NSImage(size: NSMakeSize(imageSize.width, imageSize.width))
        var scaledImage = NSImage(size: scaledSize)
        var drawRect: NSRect?

        // make the image square
        if imageSize.height > imageSize.width {
            drawRect = NSMakeRect(0, imageSize.height - imageSize.width, imageSize.width, imageSize.width)
        } else {
            drawRect = NSMakeRect(0, 0, imageSize.height, imageSize.height)
        }

        squareImage.lockFocus()
        image.drawInRect(NSMakeRect(0, 0, imageSize.width, imageSize.height), fromRect: drawRect!, operation: NSCompositingOperation.CompositeSourceOver, fraction: 1.0)
        squareImage.unlockFocus()

        // scale the image to the desired size
        scaledImage.lockFocus()
        squareImage.drawInRect(NSMakeRect(0, 0, scaledSize.width, scaledSize.height), fromRect: NSZeroRect, operation: NSCompositingOperation.CompositeSourceOver, fraction: 1.0)
        scaledImage.unlockFocus()

        // convert back to readable bitmap data
        var cgImage = scaledImage.CGImageForProposedRect(nil, context: nil, hints: nil)
        var bitmapRep = NSBitmapImageRep(CGImage: cgImage!.takeRetainedValue())
        var finalImage = NSImage(size: scaledImage.size)
        finalImage.addRepresentation(bitmapRep)

        return finalImage
    }


    func analyzeImage(anImage: NSImage) {
        var imageColors: NSCountedSet?
        var backgroundColor = self.findEdgeColor(anImage, colors: &imageColors)
        var primaryColor: NSColor?
        var secondaryColor: NSColor?
        var detailColor: NSColor?
        var darkBackground = backgroundColor!.pc_isDarkColor()
        self.findTextColors(imageColors, primaryColor: &primaryColor, secondaryColor: &secondaryColor, detailColor: &detailColor, backgroundColor: backgroundColor!)
        if primaryColor == nil {
            NSLog("%@", "missed primary")
            if darkBackground {
                primaryColor = NSColor.whiteColor()
            } else {
                primaryColor = NSColor.blackColor()
            }
        }
        if secondaryColor == nil {
            NSLog("%@", "missed secondary")
            if darkBackground {
                secondaryColor = NSColor.whiteColor()
            } else {
                secondaryColor = NSColor.blackColor()
            }
        }
        if detailColor == nil {
            NSLog("%@", "missed detail")
            if darkBackground {
                detailColor = NSColor.whiteColor()
            } else {
                detailColor = NSColor.blackColor()
            }
        }
        self.backgroundColor = backgroundColor
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.detailColor = detailColor
    }

    func findEdgeColor(image: NSImage, inout colors: NSCountedSet?) -> NSColor? {
        var imageRep = image.representations.last as! NSBitmapImageRep
        if !imageRep.isKindOfClass(NSBitmapImageRep) {
            return nil
        }
        var pixelsWide = imageRep.pixelsWide
        var pixelsHigh = imageRep.pixelsHigh
        colors = NSCountedSet(capacity: pixelsWide * pixelsHigh)
        var leftEdgeColors = NSCountedSet(capacity: pixelsHigh)
        var x: NSInteger = 0
        var y: NSInteger = 0
        while x < pixelsWide {
            while y < pixelsHigh {
                var color = imageRep.colorAtX(x, y: y)
                if x == 0 {
                    leftEdgeColors.addObject(color!)
                }
                colors!.addObject(color!)
                y++
            }
            x++
        }
        var enumerator = leftEdgeColors.objectEnumerator()
        var curColor = enumerator.nextObject() as? NSColor
        var sortedColors = NSMutableArray(capacity: leftEdgeColors.count)
        while curColor != nil {
            var colorCount = leftEdgeColors.countForObject(curColor!)
            var randomColorsThreshold = NSInteger(Double(pixelsHigh) * kColorThresholdMinimumPercentage)
            var container = PCCountedColor(color: curColor!, count: colorCount)
            sortedColors.addObject(container)
            curColor = enumerator.nextObject() as? NSColor
            println(curColor)
        }
        println(sortedColors.count)
        sortedColors.sortUsingSelector("compare:")
        var proposedEdgeColor: PCCountedColor?
        if sortedColors.count > 0 {
            proposedEdgeColor = (sortedColors.objectAtIndex(0) as! PCCountedColor)
            // want to choose color over black/white so we keep looking
            if proposedEdgeColor!.color.pc_isBlackOrWhite() {
                var i: NSInteger = 0
                while i < sortedColors.count {
                    var nextProposedColor = sortedColors.objectAtIndex(i) as! PCCountedColor
                    // make sure the second choice color is 30% as common as the first choice
                    if (Double(nextProposedColor.count) / Double(proposedEdgeColor!.count)) > 0.3 {
                        if !nextProposedColor.color.pc_isBlackOrWhite() {
                            proposedEdgeColor = nextProposedColor
                            break
                        }
                    } else {
                        // reached color threshold less than 40% of the original proposed edge color so bail
                        break
                    }
                    i++
                }
            }
        }
        return proposedEdgeColor!.color
    }

    func findTextColors(colors: NSCountedSet?, inout primaryColor: NSColor?, inout secondaryColor: NSColor?, inout detailColor: NSColor?, backgroundColor: NSColor) {
        var enumerator = colors!.objectEnumerator()
        var curColor = enumerator.nextObject() as? NSColor
        var sortedColors = NSMutableArray(capacity: colors!.count)
        var findDarkTextColor = !backgroundColor.pc_isDarkColor()
        while curColor != nil {
            curColor = curColor!.pc_colorWithMinimumSaturation(0.15)
            if curColor!.pc_isDarkColor() == !findDarkTextColor {
                var colorCount = colors!.countForObject(curColor!)
                var container = PCCountedColor(color: curColor!, count: colorCount)
                sortedColors.addObject(container)
            }
            curColor = enumerator.nextObject() as? NSColor
        }
        sortedColors.sortUsingSelector("compare:")
        for cc in sortedColors {
            var curContainer = cc as! PCCountedColor
            curColor = curContainer.color
            if primaryColor == nil {
                if curColor!.pc_isContrastingColor(backgroundColor) {
                    primaryColor = curColor
                }
            } else if secondaryColor == nil {
                if !primaryColor!.pc_isDistinct(curColor!) || !curColor!.pc_isContrastingColor(backgroundColor) {
                    secondaryColor = curColor
                }
            } else if detailColor == nil {
                if !secondaryColor!.pc_isDistinct(curColor!) || !primaryColor!.pc_isDistinct(curColor!) || !curColor!.pc_isContrastingColor(backgroundColor) {
                    continue
                }
                detailColor = curColor
                break
            }
        }
    }

}




















