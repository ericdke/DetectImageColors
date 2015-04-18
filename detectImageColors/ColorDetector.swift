//
//  ColorDetector.swift
//  colorDetector
//
//  ERIC DEJONCKHEERE on 03/04/2015.
//  Copyright (c) 2015 Eric Dejonckheere. All rights reserved.
//
//  Original implementation by PanicSoftware 2011

import Cocoa

class ColorDetector: NSObject {

    func analyzeImage(anImage: NSImage) -> ColorCandidates {
        let edge = findEdgeColor(anImage)
        let colorsFirstPass = findColors(edge.set, backgroundColor: edge.color!)
        let backgroundIsDark = colorsFirstPass.background!.isMostlyDarkColor() // Bool
        let colorsSecondPass = createColors(colorsFirstPass, hasDarkBackground: backgroundIsDark)
        return createFadedColors(colorsSecondPass, hasDarkBackground: backgroundIsDark)
    }
    
    //
    
    private func findEdgeColor(image: NSImage) -> (color: NSColor?, set: NSCountedSet?) {
        let imageRep = image.representations.last as! NSBitmapImageRep
        let pixelsWide = imageRep.pixelsWide
        let pixelsHigh = imageRep.pixelsHigh
        var colors = NSCountedSet(capacity: pixelsWide * pixelsHigh)
        var leftEdgeColors = NSCountedSet(capacity: pixelsHigh)
        
        // Use x = 0 to start scanning from the actual left edge
        // Default .DetectorDistanceFromLeftEdge is non-zero to deal with badly cropped images (only relevant for high-res scanning, without side effect otherwise)
        var x = CDSettings.DetectorDistanceFromLeftEdge
        var y = 0
        while x < pixelsWide {
            while y < pixelsHigh {
                var color = imageRep.colorAtX(x, y: y)
                if x == CDSettings.DetectorDistanceFromLeftEdge {
                    leftEdgeColors.addObject(color!)
                }
                colors.addObject(color!)
                y++
            }
            y = 0
            // We sample a vertical line every x pixels
            // Set to 1 for high-res scanning
            x += CDSettings.DetectorResolution
        }
        
        let enumerator = leftEdgeColors.objectEnumerator()
        var curColor = enumerator.nextObject() as? NSColor
        var rootColors = [CDCountedColor]()
        var lonelyColors = [CDCountedColor]()
        while curColor != nil {
            let colorCount = leftEdgeColors.countForObject(curColor!)
            let randomColorsThreshold = Int(Double(pixelsHigh) * CDSettings.ThresholdMinimumPercentage)
            if colorCount <= randomColorsThreshold {
                lonelyColors.append(CDCountedColor(color: curColor!, count: colorCount))
                curColor = enumerator.nextObject() as? NSColor
                continue
            }
            rootColors.append(CDCountedColor(color: curColor!, count: colorCount))
            curColor = enumerator.nextObject() as? NSColor
        }
        
        // We use the marginal colors if we didn't get enough main colors for some reason
        let sortedColors: [CDCountedColor]
        if rootColors.count > 0 {
            sortedColors = rootColors.sorted({ $0.count > $1.count })
        } else {
            sortedColors = lonelyColors.sorted({ $0.count > $1.count })
        }
        
        var proposedEdgeColor: CDCountedColor?
        if sortedColors.count > 0 {
            proposedEdgeColor = sortedColors[0]
            // want to choose color over black/white so we keep looking
            if proposedEdgeColor!.color.isMostlyBlackOrWhite() {
                var i = 0
                while i < sortedColors.count {
                    var nextProposedColor = sortedColors[i]
                    // make sure the second choice color is 30% as common as the first choice
                    if (Double(nextProposedColor.count) / Double(proposedEdgeColor!.count)) > 0.3 {
                        if nextProposedColor.color.isMostlyBlackOrWhite() == false {
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

    private func findColors(colors: NSCountedSet?, backgroundColor: NSColor) -> ColorCandidates {
        var rootContainer = ColorCandidates()
        rootContainer.background = backgroundColor
        let enumerator = colors!.objectEnumerator()
        var curColor = enumerator.nextObject() as? NSColor
        var rootColors = [CDCountedColor]()
        let isColorDark = backgroundColor.isMostlyDarkColor()
        var lonelyColors = [CDCountedColor]()
        while curColor != nil {
            curColor = curColor!.withMinimumSaturation(CDSettings.ThresholdMinimumSaturation)
            // We don't want to be too close to the bg color
            if curColor!.isMostlyDarkColor() && isColorDark {
                var colorCount = colors!.countForObject(curColor!)
                // We set apart the rarest colors
                if colorCount <= CDSettings.ThresholdNoiseTolerance {
                    lonelyColors.append(CDCountedColor(color: curColor!, count: colorCount))
                    curColor = enumerator.nextObject() as? NSColor
                    continue
                }
                rootColors.append(CDCountedColor(color: curColor!, count: colorCount))
            }
            curColor = enumerator.nextObject() as? NSColor
        }
        
        let sortedColors: [CDCountedColor]
        if rootColors.count > 0 {
            sortedColors = rootColors.sorted({ $0.count > $1.count })
        } else {
            sortedColors = lonelyColors.sorted({ $0.count > $1.count })
        }
        
        // Better have less relevant colors than no colors
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

    private func createColors(textColors: ColorCandidates, hasDarkBackground darkBackground: Bool) -> ColorCandidates {
        var colors = textColors
        
        // Finally, if we still have nil values for the text colors, let's try having at least black or white instead
        
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
    
    private func rescueNilColor(colorName: String, hasDarkBackground: Bool) -> NSColor {
        // NSLog("%@", "Missed \(colorName) detection")
        if hasDarkBackground {
            return NSColor.whiteColor()
        } else {
            return NSColor.blackColor()
        }
    }

    private func createFadedColors(textColors: ColorCandidates, hasDarkBackground: Bool) -> ColorCandidates {
        var colors = textColors
        
        // We try to avoid results that could be mathematically correct but not visually interesting
        
        if colors.primary!.isNearOf(colors.secondary!) || colors.primary!.isNearOf(colors.detail!) || colors.secondary!.isNearOf(colors.detail!) {
            if hasDarkBackground && !colors.primary!.isMostlyDarkColor() {
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

        // Final phase

        if let bw = colors.background?.isMostlyBlackOrWhite() {
            if bw {
                colors.backgroundIsBlackOrWhite = true
            } else {
                colors.backgroundIsBlackOrWhite = false
            }
        }

        if hasDarkBackground {
            // Reinforce the contrast (just a personal preference for the final results)
            colors.background = colors.background!.darkerColor()
            colors.backgroundIsDark = true
        } else {
            colors.backgroundIsDark = false
        }

        return colors
    }

}




















