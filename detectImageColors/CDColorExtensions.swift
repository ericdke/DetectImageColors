//  SWIFT 2

import Cocoa

public extension NSColor {
    
    public func isNearOf(_ color: NSColor) -> Bool {
        if let (a, r, g, b) = self.componentsNSC(), (a1, r1, g1, b1) = color.componentsNSC() {
            let threshold: CGFloat = CDSettings.ThresholdDistinctColor
            if fabs(r - r1) > threshold || fabs(g - g1) > threshold || fabs(b - b1) > threshold || fabs(a - a1) > threshold {
                // check for grays, prevent multiple gray colors
                if fabs(r - g) < CDSettings.ThresholdGrey && fabs(r - b) < CDSettings.ThresholdGrey {
                    if fabs(r1 - g1) < CDSettings.ThresholdGrey && fabs(r1 - b1) < CDSettings.ThresholdGrey {
                        return true
                    }
                }
                return false
            }
        }
        return true
    }
    
    public func lighterColor(threshold: CGFloat = CDSettings.ThresholdFloorBrightness, ratio: CGFloat = CDSettings.LighterRatio) -> NSColor {
        guard let compsHUE = self.componentsHUE() else { return self }
        var b = compsHUE.brightness
        if b < threshold { b = threshold }
        return NSColor(calibratedHue: compsHUE.hue, saturation: compsHUE.saturation, brightness: min(b * ratio, 1.0), alpha: compsHUE.alpha)
    }
    
    public func darkerColor(threshold: CGFloat = CDSettings.ThresholdCeilingBrightness, ratio: CGFloat = CDSettings.DarkerRatio) -> NSColor {
        guard let compsHUE = self.componentsHUE() else { return self }
        var b = compsHUE.brightness
        if b > threshold { b = threshold }
        return NSColor(calibratedHue: compsHUE.hue, saturation: compsHUE.saturation, brightness: b * ratio, alpha: compsHUE.alpha)
    }
    
    public func isMostlyDarkColor() -> Bool {
        if let (_, r, g, b) = self.componentsNSC() {
            let lum: CGFloat = CDSettings.YUVRedRatio * r + CDSettings.YUVGreenRatio * g + CDSettings.YUVBlueRatio * b
            if lum < 0.5 {
                return true
            }
        }
        return false
    }
    
    public func applying(minimumSaturation: CGFloat) -> NSColor {
        // color could be hue/rgb/other so we convert to rgb
        if let tempColor = self.usingColorSpaceName(NSCalibratedRGBColorSpace) {
            // prepare the values
            var hue: CGFloat = 0.0
            var saturation: CGFloat = 0.0
            var brightness: CGFloat = 0.0
            var alpha: CGFloat = 0.0
            // populate the values
            tempColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            // if color is not enough saturated
            if saturation < minimumSaturation {
                // return same color with more saturation
                return NSColor(calibratedHue: hue, saturation: minimumSaturation, brightness: brightness, alpha: alpha)
            }
        }
        // if detection fails, return same color
        return self
    }
    
    public func isMostlyBlackOrWhite() -> Bool {
        if let (_, r, g, b) = self.componentsNSC() {
            if r > CDSettings.MinThresholdWhite && g > CDSettings.MinThresholdWhite && b > CDSettings.MinThresholdWhite || r < CDSettings.MaxThresholdBlack && g < CDSettings.MaxThresholdBlack && b < CDSettings.MaxThresholdBlack {
                return true // black
            }
        }
        return false
    }
    
    public func contrastsWith(_ color: NSColor) -> Bool {
        return !doesNotContrastWith(color)
    }
    
    public func doesNotContrastWith(_ color: NSColor) -> Bool {
        guard let (_, br, bg, bb) = self.componentsNSC(), (_, fr, fg, fb) = color.componentsNSC() else { return false }
        let bLum: CGFloat = CDSettings.YUVRedRatio * br + CDSettings.YUVGreenRatio * bg + CDSettings.YUVBlueRatio * bb
        let fLum: CGFloat = CDSettings.YUVRedRatio * fr + CDSettings.YUVGreenRatio * fg + CDSettings.YUVBlueRatio * fb
        let contrast: CGFloat
        if bLum > fLum {
            contrast = (bLum + CDSettings.LuminanceAddedWeight) / (fLum + CDSettings.LuminanceAddedWeight)
        } else {
            contrast = (fLum + CDSettings.LuminanceAddedWeight) / (bLum + CDSettings.LuminanceAddedWeight)
        }
        return contrast < CDSettings.ContrastRatio
    }
    
    public func componentsCSS() -> (alpha: String, red: String, green: String, blue: String, css: String, clean: String)? {
        guard let (alpha, red, green, blue) = self.componentsRGB() else { return nil }
        let xalpha = String(alpha, radix: 16, uppercase: true)
        var xred = String(red, radix: 16, uppercase: true)
        var xgreen = String(green, radix: 16, uppercase: true)
        var xblue = String(blue, radix: 16, uppercase: true)
        if xred.length < 2 { xred = "0\(xred)" }
        if xgreen.length < 2 { xgreen = "0\(xgreen)" }
        if xblue.length < 2 { xblue = "0\(xblue)" }
        let clean = "\(xred)\(xgreen)\(xblue)"
        let css = "#\(clean)"
        return (alpha: xalpha, red: xred, green: xgreen, blue: xblue, css: css, clean: clean)
    }
    
    public func componentsNSC() -> (alpha: CGFloat, red: CGFloat, green: CGFloat, blue: CGFloat)? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        guard let color = self.usingColorSpaceName(NSCalibratedRGBColorSpace) else { return nil }
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (alpha: alpha, red: red, green: green, blue: blue)
    }
    
    public func componentsRGB() -> (alpha: Int, red: Int, green: Int, blue: Int)? {
        guard let (alpha, red, green, blue) = self.componentsNSC() else { return nil }
        return (alpha: Int(round(alpha * 255.0)), red: Int(round(red * 255.0)), green: Int(round(green * 255.0)), blue: Int(round(blue * 255.0)))
    }
    
    public func componentsHUE() -> (alpha: CGFloat, hue: CGFloat, saturation: CGFloat, brightness: CGFloat)? {
        guard let convertedColor = self.usingColorSpaceName(NSCalibratedRGBColorSpace) else { return nil }
        var h: CGFloat = 0.0
        var s: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        convertedColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (alpha: a, hue: h, saturation: s, brightness: b)
    }
    
}
