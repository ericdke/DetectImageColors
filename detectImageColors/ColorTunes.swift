//
//  ColorTunes.swift
//  colortunes
//
//  Adapted & Created by ERIC DEJONCKHEERE on 03/04/2015.
//  Copyright (c) 2015 Eric Dejonckheere. All rights reserved.
//
// Original code (Objective-C) by PanicSoftware

import Cocoa

let kColorThresholdMinimumPercentage = 0.01  // original 0.01
let kColorThresholdMinimumSaturation: CGFloat = 0.15 // original: 0.15
let kColorThresholdMaximumNoise = 2

class ColorTunes: NSObject {

    var scaledSize: NSSize
    var scaledImage: NSImage?
    var backgroundColorCandidate: NSColor?
    var primaryColorCandidate: NSColor?
    var secondaryColorCandidate: NSColor?
    var detailColorCandidate: NSColor?

    init(image: NSImage, size: NSSize) {
        self.scaledSize = size
        super.init()
        let temp = self.scaledImage(image, scaledSize: size)
        self.scaledImage = temp
    }

    func startAnalyze(scaledImage: NSImage) {
        self.analyzeImage(scaledImage)
    }

    func getColorElements() -> (primary: NSColor, secondary: NSColor, detail: NSColor, background: NSColor) {
        return (primaryColorCandidate!, secondaryColorCandidate!, detailColorCandidate!, backgroundColorCandidate!)
    }

    func analyzeImage(anImage: NSImage) {
        let (backgroundColor, imageColors) = findEdgeColor(anImage)
        let backgroundIsDark = backgroundColor!.isMostlyDarkColor()
        let textColorsFirstPass = findTextColors(imageColors, backgroundColor: backgroundColor!)
        let textColorsSecondPass = rescueNilColors(textColorsFirstPass, hasDarkBackground: backgroundIsDark)
        let textColors = createFadedColorsOrKeepDetected(textColorsSecondPass, hasDarkBackground: backgroundIsDark)
        self.backgroundColorCandidate = backgroundColor!
        self.primaryColorCandidate = textColors.primary
        self.secondaryColorCandidate = textColors.secondary
        self.detailColorCandidate = textColors.detail
    }

    private func findTextColors(colors: NSCountedSet?, backgroundColor: NSColor) -> (primary: NSColor?, secondary: NSColor?, detail: NSColor?) {
        var primaryColor: NSColor?
        var secondaryColor: NSColor?
        var detailColor: NSColor?
        let enumerator = colors!.objectEnumerator()
        var curColor = enumerator.nextObject() as? NSColor
        var sortedColors = NSMutableArray(capacity: colors!.count)
        let isColorLight = backgroundColor.isMostlyLightColor()
        while curColor != nil {
            curColor = curColor!.sameOrWithMinimumSaturation(kColorThresholdMinimumSaturation)
            if curColor!.isMostlyDarkColor() == isColorLight { // oops
                var colorCount = colors!.countForObject(curColor!)
                if colorCount <= kColorThresholdMaximumNoise {
                    curColor = enumerator.nextObject() as? NSColor
                    continue
                }
                sortedColors.addObject(PCCountedColor(color: curColor!, count: colorCount))
            }
            curColor = enumerator.nextObject() as? NSColor
        }
        sortedColors.sortUsingSelector("compare:")
        for cc in sortedColors {
            let curContainer = cc as! PCCountedColor
            curColor = curContainer.color
            if primaryColor == nil {
                if curColor!.contrastsWith(backgroundColor) {
                    primaryColor = curColor
                }
            } else if secondaryColor == nil {
                if primaryColor!.isNotDistinctFrom(curColor!) || curColor!.doesNotContrastWith(backgroundColor) {
                    secondaryColor = curColor
                }
            } else if detailColor == nil {
                if secondaryColor!.isNotDistinctFrom(curColor!) || primaryColor!.isNotDistinctFrom(curColor!) || curColor!.doesNotContrastWith(backgroundColor) {
                    continue
                }
                detailColor = curColor
                break
            }
        }
        return (primaryColor, secondaryColor, detailColor)
    }

    private func findEdgeColor(image: NSImage) -> (NSColor?, NSCountedSet?) {
        let imageRep = image.representations.last as! NSBitmapImageRep
        let pixelsWide = imageRep.pixelsWide
        let pixelsHigh = imageRep.pixelsHigh
        var colors = NSCountedSet(capacity: pixelsWide * pixelsHigh)
        var leftEdgeColors = NSCountedSet(capacity: pixelsHigh)
        var x: NSInteger = 0
        var y: NSInteger = 0
        while x < pixelsWide {
            while y < pixelsHigh {
                var color = imageRep.colorAtX(x, y: y)
                if x == 0 {
                    leftEdgeColors.addObject(color!)
                }
                colors.addObject(color!)
                y++
            }
            x++
        }
        let enumerator = leftEdgeColors.objectEnumerator()
        var curColor = enumerator.nextObject() as? NSColor
        var sortedColors = NSMutableArray(capacity: leftEdgeColors.count)
        while curColor != nil {
            let colorCount = leftEdgeColors.countForObject(curColor!)
            let randomColorsThreshold = NSInteger(Double(pixelsHigh) * kColorThresholdMinimumPercentage)
            sortedColors.addObject(PCCountedColor(color: curColor!, count: colorCount))
            curColor = enumerator.nextObject() as? NSColor
        }
        //        println(sortedColors.count)
        sortedColors.sortUsingSelector("compare:")
        var proposedEdgeColor: PCCountedColor?
        if sortedColors.count > 0 {
            proposedEdgeColor = (sortedColors.objectAtIndex(0) as! PCCountedColor)
            // want to choose color over black/white so we keep looking
            if proposedEdgeColor!.color.isMostlyBlackOrWhite() {
                var i: NSInteger = 0
                while i < sortedColors.count {
                    var nextProposedColor = sortedColors.objectAtIndex(i) as! PCCountedColor
                    // make sure the second choice color is 30% as common as the first choice
                    if (Double(nextProposedColor.count) / Double(proposedEdgeColor!.count)) > 0.3 {
                        if nextProposedColor.color.isNotMostlyBlackOrWhite() {
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
        return (proposedEdgeColor!.color, colors)
    }

    private func scaledImage(image: NSImage, scaledSize: NSSize) -> NSImage {
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

    private func rescueNilColor(colorName: String, hasDarkBackground: Bool) -> NSColor {
        NSLog("%@", "Missed \(colorName) detection")
        if hasDarkBackground {
            return NSColor.whiteColor()
        } else {
            return NSColor.blackColor()
        }
    }

    private func rescueNilColors(textColors: (primary: NSColor?, secondary: NSColor?, detail: NSColor?), hasDarkBackground darkBackground: Bool) -> (primary: NSColor, secondary: NSColor, detail: NSColor) {
        var colors = textColors
        if textColors.primary == nil {
            colors.primary = rescueNilColor("primary", hasDarkBackground: darkBackground)
        }
        if textColors.secondary == nil {
            colors.secondary = rescueNilColor("secondary", hasDarkBackground: darkBackground)
        }
        if textColors.detail == nil {
            colors.detail = rescueNilColor("detail", hasDarkBackground: darkBackground)
        }
        return (primary: colors.primary!, secondary: colors.secondary!, detail: colors.detail!)
    }

    private func createFadedColorsOrKeepDetected(textColors: (primary: NSColor, secondary: NSColor, detail: NSColor), hasDarkBackground backgroundIsDark: Bool) -> (primary: NSColor, secondary: NSColor, detail: NSColor) {
        var colors = textColors
        if let tprim = textColors.primary.colorUsingColorSpaceName(NSCalibratedRGBColorSpace), let tsec = textColors.secondary.colorUsingColorSpaceName(NSCalibratedRGBColorSpace) {
            if tprim == tsec {
                if backgroundIsDark {
                    colors.secondary = textColors.primary.darkerColor()
                    colors.detail = colors.secondary.darkerColor()
                } else {
                    colors.secondary = textColors.primary.lighterColor()
                    colors.detail = colors.secondary.lighterColor()
                }
            }
        }
        return (primary: colors.primary, secondary: colors.secondary, detail: colors.detail)
    }

}




















