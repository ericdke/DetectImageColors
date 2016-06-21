//
//  CDExtensions.swift
//  detectImageColors
//
//  Created by ERIC DEJONCKHEERE on 05/08/2015.
//  Copyright © 2015 Eric Dejonckheere. All rights reserved.
//

import Cocoa

public extension String {
    var length: Int { get { return self.characters.count } }
}

public extension NSImage {
    // Image has to fill a square completely
    private func resizeToSquare(max: CGFloat = CGFloat(600)) -> NSImage? {
        let (myWidth, myHeight): (CGFloat, CGFloat)
        if self.size.width < max {
            (myWidth, myHeight) = (self.size.width, self.size.width)
        } else {
            (myWidth, myHeight) = (max, max)
        }
        let destSize = NSMakeSize(myWidth, myHeight)
        let newImage = NSImage(size: destSize)
        newImage.lockFocus()
        self.draw(in: NSMakeRect(0, 0, destSize.width, destSize.height),
            from: NSMakeRect(0, 0, self.size.width, self.size.height),
            operation: NSCompositingOperation.sourceOver, fraction: CGFloat(1))
        newImage.unlockFocus()
        newImage.size = destSize
        guard let tiff = newImage.tiffRepresentation, let resized = NSImage(data: tiff) else { return nil }
        return resized
    }
    
    
    // Main method
    public func getColorCandidates() -> ColorCandidates? {
        var img = self
        if !self.isImageSquared() {
            img = img.resizeToSquare()!
        }
        let edge = img.findEdgeColor()
        guard let edgeColor = edge.color,
            let colorsFirstPass = findColors(colors: edge.set, backgroundColor: edgeColor),
            let firstBackgroundColorCandidate = colorsFirstPass.background
            else { return nil }
        let backgroundIsDark: Bool = firstBackgroundColorCandidate.isMostlyDarkColor()
        let colorsSecondPass = createColors(textColors: colorsFirstPass, hasDarkBackground: backgroundIsDark)
        if CDSettings.EnsureContrastedColorCandidates {
            return createFadedColors(textColors: colorsSecondPass, hasDarkBackground: backgroundIsDark)
        }
        return colorsSecondPass
    }
    
    // ------------------------------------
    
    private func isImageSquared() -> Bool {
        if self.size.height == self.size.width {
            return true
        }
        return false
    }
    
    // find what we think is the main color + other candidates
    private func findEdgeColor() -> (color: NSColor?, set: CountedSet?) {
        guard let imageRep = self.representations.last as? NSBitmapImageRep else { return (nil, nil) }
        let pixelsWide = imageRep.pixelsWide
        let pixelsHigh = imageRep.pixelsHigh
        // sample the image, beginning with the left edge
        let (colors, leftEdgeColors) = sampleImage(width: pixelsWide, height: pixelsHigh, imageRep: imageRep)
        let (rootColors, lonelyColors) = separateColors(edgeColors: leftEdgeColors, height: pixelsHigh)
        let sortedColors = getMarginalColorsIfNecessary(rootColors: rootColors, lonelyColors: lonelyColors)
        if sortedColors.isEmpty { return (nil, nil) }
        let proposedEdgeColor = tryAvoidBlackOrWhite(sortedColors: sortedColors)
        return (proposedEdgeColor.color, colors)
    }
    
    private func sampleImage(width: Int, height: Int, imageRep: NSBitmapImageRep) -> (CountedSet, CountedSet) {
        let colors = CountedSet(capacity: width * height)
        let leftEdgeColors = CountedSet(capacity: height)
        // Use x = 0 to start scanning from the actual left edge
        // Default .DetectorDistanceFromLeftEdge is non-zero to deal with badly cropped images (only relevant for high-res scanning, without side effect otherwise)
        var x = CDSettings.DetectorDistanceFromLeftEdge
        var y = 0
        while x < width {
            while y < height {
                if let color = imageRep.colorAt(x: x, y: y) {
                    if x == CDSettings.DetectorDistanceFromLeftEdge {
                        leftEdgeColors.add(color)
                    }
                    colors.add(color)
                }
                y += 1
            }
            // Reset y every x loop
            y = 0
            // We sample a vertical line every x pixels
            // Set DetectorResolution to 1 for high-res scanning
            x += CDSettings.DetectorResolution
        }
        return (colors, leftEdgeColors)
    }
    
    private func getMarginalColorsIfNecessary(rootColors: [CDCountedColor], lonelyColors: [CDCountedColor]) -> [CDCountedColor] {
        if rootColors.count > 0 {
            // if we have at least one credible candidate
            return rootColors.sorted { $0.count > $1.count }
        } else {
            // here come the less credible ones
            return lonelyColors.sorted { $0.count > $1.count }
        }
    }
    
    private func tryAvoidBlackOrWhite(sortedColors: [CDCountedColor]) -> CDCountedColor {
        // want to choose color over black/white so we keep looking
        var proposedEdgeColor = sortedColors[0]
        let activeColor = proposedEdgeColor.color
        if activeColor.isMostlyBlackOrWhite() {
            var i = 0
            while i < sortedColors.count {
                let nextProposedColor = sortedColors[i]
                // make sure the second choice color is 30% as common as the first choice
                if (Double(nextProposedColor.count) / Double(proposedEdgeColor.count)) > 0.3 {
                    if nextProposedColor.color.isMostlyBlackOrWhite() == false {
                        proposedEdgeColor = nextProposedColor
                        break
                    }
                } else {
                    // reached color threshold less than 40% of the original proposed edge color
                    break
                }
                i += 1
            }
        }
        return proposedEdgeColor
    }
    
    // sort the credible candidates from the noise
    private func separateColors(edgeColors: CountedSet, height: Int) -> ([CDCountedColor], [CDCountedColor]) {
        var rootColors = [CDCountedColor]()
        var lonelyColors = [CDCountedColor]()
        for case let current as NSColor in edgeColors {
            let colorCount = edgeColors.count(for: current)
            let randomColorsThreshold = Int(Double(height) * CDSettings.ThresholdMinimumPercentage)
            if colorCount <= randomColorsThreshold {
                lonelyColors.append(CDCountedColor(color: current, count: colorCount))
                continue
            }
            rootColors.append(CDCountedColor(color: current, count: colorCount))
        }
        return (rootColors, lonelyColors)
    }
    
    // ------------------------------------
    
    private func findColors(colors: CountedSet?, backgroundColor: NSColor) -> ColorCandidates? {
        guard let sourceColors = colors else { return nil }
        var candidates = ColorCandidates()
        var rootColors = [CDCountedColor]()
        var lonelyColors = [CDCountedColor]()
        let isColorDark = backgroundColor.isMostlyDarkColor()
        candidates.background = backgroundColor
        for case let current as NSColor in sourceColors {
            let currentColor = current.applying(minimumSaturation: CDSettings.ThresholdMinimumSaturation)
            if currentColor.isMostlyDarkColor() && isColorDark {
                let colorCount = sourceColors.count(for: currentColor)
                if colorCount <= CDSettings.ThresholdNoiseTolerance {
                    lonelyColors.append(CDCountedColor(color: currentColor, count: colorCount))
                    continue
                }
                rootColors.append(CDCountedColor(color: currentColor, count: colorCount))
            }
        }
        
        let sortedColors = getMarginalColorsIfNecessary(rootColors: rootColors, lonelyColors: lonelyColors)
        
        for cc in sortedColors {
            if candidates.primary == nil {
                if cc.color.contrastsWith(backgroundColor) {
                    candidates.primary = cc.color
                }
            } else if candidates.secondary == nil {
                if let prim = candidates.primary where prim.isNearOf(cc.color) || cc.color.doesNotContrastWith(backgroundColor) {
                    candidates.secondary = cc.color
                }
            } else if candidates.detail == nil {
                if let sec = candidates.secondary where sec.isNearOf(cc.color) || cc.color.doesNotContrastWith(backgroundColor) {
                    continue
                }
                if let prim = candidates.primary where prim.isNearOf(cc.color) {
                    continue
                }
                candidates.detail = cc.color
                break
            }
        }
        
        return candidates
    }
    
    
    private func createColors(textColors: ColorCandidates, hasDarkBackground darkBackground: Bool) -> ColorCandidates {
        var colors = textColors
        
        // Finally, if we still have nil values for the text colors, let's try having at least black or white instead
        
        if textColors.primary == nil {
            colors.primary = rescueNilColor(colorName: "primary", hasDarkBackground: darkBackground)
        }
        if textColors.secondary == nil {
            colors.secondary = rescueNilColor(colorName: "secondary", hasDarkBackground: darkBackground)
        }
        if textColors.detail == nil {
            colors.detail = rescueNilColor(colorName: "detail", hasDarkBackground: darkBackground)
        }
        return colors
    }
    
    private func rescueNilColor(colorName: String, hasDarkBackground: Bool) -> NSColor {
        // NSLog("%@", "Missed \(colorName) detection")
        if hasDarkBackground {
            return NSColor.white()
        } else {
            return NSColor.black()
        }
    }
    
    private func createFadedColors(textColors: ColorCandidates, hasDarkBackground: Bool) -> ColorCandidates {
        var colors = textColors
        
        // We try to avoid results that could be mathematically correct but not visually interesting
        
        if let prim = colors.primary, let sec = colors.secondary, let det = colors.detail, let back = colors.background {
            if prim.isNearOf(sec) || prim.isNearOf(det) || sec.isNearOf(det) {
                if hasDarkBackground && !prim.isMostlyDarkColor() {
                    colors.secondary = prim.darkerColor()
                    colors.detail = sec.darkerColor()
                } else {
                    colors.secondary = prim.lighterColor()
                    colors.detail = sec.lighterColor()
                }
            }
            if prim.isNearOf(back) {
                colors.primary = rescueNilColor(colorName: "primary, 2nd pass", hasDarkBackground: hasDarkBackground)
            }
            if sec.isNearOf(back) {
                if hasDarkBackground {
                    colors.secondary = prim.darkerColor()
                } else {
                    colors.secondary = prim.lighterColor()
                }
            }
            if det.isNearOf(back) {
                if hasDarkBackground {
                    colors.detail = back.lighterColor()
                } else {
                    colors.detail = back.darkerColor()
                }
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
            colors.backgroundIsDark = true
        } else {
            colors.backgroundIsDark = false
        }
        
        return colors
    }
}
