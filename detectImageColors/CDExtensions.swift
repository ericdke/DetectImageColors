import Cocoa

public extension NSImage {
    // Main method
    public func getColorCandidates() -> ColorCandidates? {
        var img = self
        if !self.isImageSquared {
            img = img.resizeToSquare()!
        }
        let edge = img.findEdgeColor()
        guard let edgeColor = edge.color,
            let colorsFirstPass = findColors(in: edge.set, withBackgroundColor: edgeColor),
            let firstBackgroundColorCandidate = colorsFirstPass.background
            else { return nil }
        let backgroundIsDark = firstBackgroundColorCandidate.isMostlyDarkColor
        let colorsSecondPass = createColors(from: colorsFirstPass, withDarkBackground: backgroundIsDark)
        if CDSettings.ensureContrastedColorCandidates {
            return createFadedColors(from: colorsSecondPass, withDarkBackground: backgroundIsDark)
        }
        return colorsSecondPass
    }
    
    public var isImageSquared: Bool {
        if self.size.height == self.size.width {
            return true
        }
        return false
    }
    
    // ------------------------------------
    
    // Image has to fill a square completely
    private func resizeToSquare(max: CGFloat = CGFloat(600)) -> NSImage? {
        let imgSize: NSSize
        if self.size.width < max {
            imgSize = NSSize(width: self.size.width, height: self.size.width)
        } else {
            imgSize = NSSize(width: max, height: max)
        }
        let destSize = NSSize(width: imgSize.width, height: imgSize.height)
        let newImage = NSImage(size: destSize)
        newImage.lockFocus()
        self.draw(in: NSRect(x: 0, y: 0, width: destSize.width, height: destSize.height),
                  from: NSRect(x: 0, y: 0, width: self.size.width, height: self.size.height),
                  operation: NSCompositingOperation.sourceOver, fraction: CGFloat(1))
        newImage.unlockFocus()
        newImage.size = destSize
        guard let tiff = newImage.tiffRepresentation,
            let resized = NSImage(data: tiff) else {
                return nil
        }
        return resized
    }

    // find what we think is the main color + other candidates
    private func findEdgeColor() -> (color: NSColor?, set: NSCountedSet?) {
        guard let imageRep = self.representations.last as? NSBitmapImageRep else { return (nil, nil) }
        // sample the image, beginning with the left edge
        let (colors, leftEdgeColors) = sampleImage(width: imageRep.pixelsWide, height: imageRep.pixelsHigh, imageRep: imageRep)
        let (rootColors, lonelyColors) = separateColors(edge: leftEdgeColors, height: imageRep.pixelsHigh)
        let sortedColors = findMarginalColorsIn(rootColors: rootColors, lonelyColors: lonelyColors)
        if sortedColors.isEmpty { return (nil, nil) }
        let proposedEdgeColor = tryAvoidBlackOrWhite(colors: sortedColors)
        return (proposedEdgeColor.color, colors)
    }
    
    private func sampleImage(width: Int, height: Int, imageRep: NSBitmapImageRep) -> (NSCountedSet, NSCountedSet) {
        let colors = NSCountedSet(capacity: width * height)
        let leftEdgeColors = NSCountedSet(capacity: height)
        // Use x = 0 to start scanning from the actual left edge
        // Default .DetectorDistanceFromLeftEdge is non-zero to deal with badly cropped images (only relevant for high-res scanning, without side effect otherwise)
        var x = CDSettings.detectorDistanceFromLeftEdge
        var y = 0
        while x < width {
            while y < height {
                if let color = imageRep.colorAt(x: x, y: y) {
                    if x == CDSettings.detectorDistanceFromLeftEdge {
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
            x += CDSettings.detectorResolution
        }
        return (colors, leftEdgeColors)
    }
    
    private func findMarginalColorsIn(rootColors: [CDCountedColor], lonelyColors: [CDCountedColor]) -> [CDCountedColor] {
        if rootColors.count > 0 {
            // if we have at least one credible candidate
            return rootColors.sorted { $0.count > $1.count }
        } else {
            // here come the less credible ones
            return lonelyColors.sorted { $0.count > $1.count }
        }
    }
    
    private func tryAvoidBlackOrWhite(colors: [CDCountedColor]) -> CDCountedColor {
        // want to choose color over black/white so we keep looking
        var proposedEdgeColor = colors[0]
        let activeColor = proposedEdgeColor.color
        if activeColor.isMostlyBlackOrWhite {
            var i = 0
            while i < colors.count {
                let nextProposedColor = colors[i]
                // make sure the second choice color is 30% as common as the first choice
                if (Double(nextProposedColor.count) / Double(proposedEdgeColor.count)) > 0.3 {
                    if nextProposedColor.color.isMostlyBlackOrWhite == false {
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
    private func separateColors(edge: NSCountedSet, height: Int) -> ([CDCountedColor], [CDCountedColor]) {
        var rootColors = [CDCountedColor]()
        var lonelyColors = [CDCountedColor]()
        for case let current as NSColor in edge {
            let colorCount = edge.count(for: current)
            let randomColorsThreshold = Int(Double(height) * CDSettings.thresholdMinimumPercentage)
            if colorCount <= randomColorsThreshold {
                lonelyColors.append(CDCountedColor(color: current, count: colorCount))
                continue
            }
            rootColors.append(CDCountedColor(color: current, count: colorCount))
        }
        return (rootColors, lonelyColors)
    }
    
    // ------------------------------------
    
    private func findColors(in colors: NSCountedSet?, withBackgroundColor backgroundColor: NSColor) -> ColorCandidates? {
        guard let sourceColors = colors else { return nil }
        var candidates = ColorCandidates()
        var rootColors = [CDCountedColor]()
        var lonelyColors = [CDCountedColor]()
        let isColorDark = backgroundColor.isMostlyDarkColor
        candidates.background = backgroundColor
        for case let current as NSColor in sourceColors {
            let currentColor = current.applyingSaturation(minimum: CDSettings.thresholdMinimumSaturation)
            if currentColor.isMostlyDarkColor && isColorDark {
                let colorCount = sourceColors.count(for: currentColor)
                if colorCount <= CDSettings.thresholdNoiseTolerance {
                    lonelyColors.append(CDCountedColor(color: currentColor, count: colorCount))
                    continue
                }
                rootColors.append(CDCountedColor(color: currentColor, count: colorCount))
            }
        }
        
        let sortedColors = findMarginalColorsIn(rootColors: rootColors, lonelyColors: lonelyColors)
        
        for cc in sortedColors {
            if candidates.primary == nil {
                if cc.color.contrastsWith(backgroundColor) {
                    candidates.primary = cc.color
                }
            } else if candidates.secondary == nil {
                if let prim = candidates.primary, prim.isNear(of: cc.color) || !cc.color.contrastsWith(backgroundColor) {
                    candidates.secondary = cc.color
                }
            } else if candidates.detail == nil {
                if let sec = candidates.secondary, sec.isNear(of: cc.color) || !cc.color.contrastsWith(backgroundColor) {
                    continue
                }
                if let prim = candidates.primary, prim.isNear(of: cc.color) {
                    continue
                }
                candidates.detail = cc.color
                break
            }
        }
        return candidates
    }
    
    
    private func createColors(from textColors: ColorCandidates, withDarkBackground darkBackground: Bool) -> ColorCandidates {
        var colors = textColors
        let rescueColor = darkBackground ? NSColor.white : NSColor.black
        // Finally, if we still have nil values for the text colors, let's try having at least black or white instead
        if textColors.primary == nil {
            colors.primary = rescueColor
        }
        if textColors.secondary == nil {
            colors.secondary = rescueColor
        }
        if textColors.detail == nil {
            colors.detail = rescueColor
        }
        return colors
    }
    
    private func createFadedColors(from colors: ColorCandidates, withDarkBackground hasDarkBackground: Bool) -> ColorCandidates {
        var colors = colors
        
        // We try to avoid results that could be mathematically correct but not visually interesting
        
        if let prim = colors.primary, let sec = colors.secondary, let det = colors.detail, let back = colors.background {
            if prim.isNear(of: sec) || prim.isNear(of: det) || sec.isNear(of: det) {
                if hasDarkBackground && !prim.isMostlyDarkColor {
                    colors.secondary = prim.darker()
                    colors.detail = sec.darker()
                } else {
                    colors.secondary = prim.lighter()
                    colors.detail = sec.lighter()
                }
            }
            if prim.isNear(of: back) {
                colors.primary = hasDarkBackground ? NSColor.white : NSColor.black
            }
            if sec.isNear(of: back) {
                if hasDarkBackground {
                    colors.secondary = prim.darker()
                } else {
                    colors.secondary = prim.lighter()
                }
            }
            if det.isNear(of: back) {
                if hasDarkBackground {
                    colors.detail = back.lighter()
                } else {
                    colors.detail = back.darker()
                }
            }
        }
        
        // Final phase
        
        if let bw = colors.background?.isMostlyBlackOrWhite {
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
