//
//  ColorTunes.swift
//  colortunes
//
//  ERIC DEJONCKHEERE on 03/04/2015.
//  Copyright (c) 2015 Eric Dejonckheere. All rights reserved.
//
//  Original code (Objective-C) by PanicSoftware

import Cocoa

class ColorTunes: NSObject {

    var scaledSize: NSSize
    var scaledImage: NSImage?
    var candidates: ColorCandidates?

    init(image: NSImage, size: NSSize) {
        self.scaledSize = size
        super.init()
        self.scaledImage = self.scaleImage(image, scaledSize: size)
        self.analyzeImage(image)
    }

    func analyzeImage(anImage: NSImage) {
        let edge = findEdgeColor(anImage)
        let colorsFirstPass = findColors(edge.set, backgroundColor: edge.color!)
        let backgroundIsDark = colorsFirstPass.background!.isMostlyDarkColor()
        let colorsSecondPass = createColors(colorsFirstPass, hasDarkBackground: backgroundIsDark)
        self.candidates = createFadedColors(colorsSecondPass, hasDarkBackground: backgroundIsDark)
    }

    private func findColors(colors: NSCountedSet?, backgroundColor: NSColor) -> ColorCandidates {
        var rootContainer = ColorCandidates()
        rootContainer.background = backgroundColor
        let enumerator = colors!.objectEnumerator()
        var curColor = enumerator.nextObject() as? NSColor
        var rootColors = [PCCountedColor]()
        let isColorLight = backgroundColor.isMostlyLightColor()
        while curColor != nil {
            curColor = curColor!.sameOrWithMinimumSaturation(kColorThresholdMinimumSaturation)
            if curColor!.isMostlyLightColor() == isColorLight { // oops
                var colorCount = colors!.countForObject(curColor!)
                if colorCount <= kColorThresholdNoiseTolerance {
                    curColor = enumerator.nextObject() as? NSColor
                    continue
                }
                rootColors.append(PCCountedColor(color: curColor!, count: colorCount))
            }
            curColor = enumerator.nextObject() as? NSColor
        }
        let sortedColors = rootColors.sorted({ $0.count > $1.count })
        for cc in sortedColors {
            if rootContainer.primary == nil {
                if cc.color.contrastsWith(backgroundColor) {
                    rootContainer.primary = cc.color
                }
            } else if rootContainer.secondary == nil {
                if rootContainer.primary!.isNearOf(cc.color) || cc.color.doesNotContrastWith(backgroundColor) {
                    rootContainer.secondary = cc.color
                }
            } else if rootContainer.detail == nil {
                if rootContainer.secondary!.isNearOf(cc.color) || rootContainer.primary!.isNearOf(cc.color) || cc.color.doesNotContrastWith(backgroundColor) {
                    continue
                }
                rootContainer.detail = cc.color
                break
            }
        }
        return rootContainer
    }

    private func findEdgeColor(image: NSImage) -> (color: NSColor?, set: NSCountedSet?) {
        let imageRep = image.representations.last as! NSBitmapImageRep
        let pixelsWide = imageRep.pixelsWide
        let pixelsHigh = imageRep.pixelsHigh
        var colors = NSCountedSet(capacity: pixelsWide * pixelsHigh)
        var leftEdgeColors = NSCountedSet(capacity: pixelsHigh)
        var x = 0
        var y = 0
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
        var rootColors = [PCCountedColor]()
        var lonelyColors = [PCCountedColor]()
        while curColor != nil {
            let colorCount = leftEdgeColors.countForObject(curColor!)
            let randomColorsThreshold = Int(Double(pixelsHigh) * kColorThresholdMinimumPercentage)
            if colorCount <= randomColorsThreshold {
                lonelyColors.append(PCCountedColor(color: curColor!, count: colorCount))
                curColor = enumerator.nextObject() as? NSColor
                continue
            }
            rootColors.append(PCCountedColor(color: curColor!, count: colorCount))
            curColor = enumerator.nextObject() as? NSColor
        }
        let sortedColors: [PCCountedColor]
        if rootColors.count > 0 {
            sortedColors = rootColors.sorted({ $0.count > $1.count })
        } else {
            sortedColors = lonelyColors.sorted({ $0.count > $1.count })
        }
        var proposedEdgeColor: PCCountedColor?
        if sortedColors.count > 0 {
            proposedEdgeColor = sortedColors[0]
            // want to choose color over black/white so we keep looking
            if proposedEdgeColor!.color.isMostlyBlackOrWhite() {
                var i = 0
                while i < sortedColors.count {
                    var nextProposedColor = sortedColors[i]
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

    private func scaleImage(image: NSImage, scaledSize: NSSize) -> NSImage {
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
        // NSLog("%@", "Missed \(colorName) detection")
        if hasDarkBackground {
            return NSColor.whiteColor()
        } else {
            return NSColor.blackColor()
        }
    }

    private func createColors(textColors: ColorCandidates, hasDarkBackground darkBackground: Bool) -> ColorCandidates {
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
        return colors
    }

    private func createFadedColors(textColors: ColorCandidates, hasDarkBackground: Bool) -> ColorCandidates {
        var colors = textColors

        var flag = false
        if let tprim = textColors.primary?.colorUsingColorSpaceName(NSCalibratedRGBColorSpace), let tsec = textColors.secondary?.colorUsingColorSpaceName(NSCalibratedRGBColorSpace), let tdet = textColors.detail?.colorUsingColorSpaceName(NSCalibratedRGBColorSpace) {
            if tprim.isNearOf(tsec) || tprim.isNearOf(tdet) || tsec.isNearOf(tdet) {
                flag = true
            }
        }

        if flag {
            if hasDarkBackground {
                colors.secondary = textColors.primary!.darkerColor()
                colors.detail = colors.secondary!.darkerColor()
            } else {
                colors.secondary = textColors.primary!.lighterColor()
                colors.detail = colors.secondary!.lighterColor()
            }
        }

        if colors.primary!.isNearOf(colors.background!) {
            colors.primary = rescueNilColor("primary, 2nd pass", hasDarkBackground: hasDarkBackground)
        }

        if colors.secondary!.isNearOf(colors.background!) {
            if hasDarkBackground {
                colors.secondary = colors.primary!.darkerColor()
            } else {
                colors.secondary = colors.primary!.lighterColor()
            }
        }

        if colors.detail!.isNearOf(colors.background!) {
            if hasDarkBackground {
                colors.detail = colors.background!.lighterColor()
            } else {
                colors.detail = colors.background!.darkerColor()
            }
        }

        // make background darker than detected from left edge
        if hasDarkBackground {
            colors.background = colors.background!.darkerColor()
        }

        return colors
    }

}




















