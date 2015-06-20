import Cocoa

public extension NSColor {

    public func isNearOf(color: NSColor) -> Bool {
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
        if var (a, h, s, b) = self.componentsHUE() {
            if b < threshold {
                b = threshold
            }
            return NSColor(calibratedHue: h, saturation: s, brightness: min(b * ratio, 1.0), alpha: a)
        }
        return self
    }

    public func darkerColor(threshold: CGFloat = CDSettings.ThresholdCeilingBrightness, ratio: CGFloat = CDSettings.DarkerRatio) -> NSColor {
        if var (a, h, s, b) = self.componentsHUE() {
            if b > threshold {
                b = threshold
            }
            return NSColor(calibratedHue: h, saturation: s, brightness: b * ratio, alpha: a)
        }
        return self
    }

    public func isMostlyDarkColor() -> Bool {
        if let (a, r, g, b) = self.componentsNSC() {
            let lum: CGFloat = CDSettings.YUVRedRatio * r + CDSettings.YUVGreenRatio * g + CDSettings.YUVBlueRatio * b
            if lum < 0.5 {
                return true
            }
        }
        return false
    }

    public func withMinimumSaturation(minimumSaturation: CGFloat) -> NSColor {
        // color could be hue/rgb/other so we convert to rgb
        if let tempColor = self.colorUsingColorSpaceName(NSCalibratedRGBColorSpace) {
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
        if let (a, r, g, b) = self.componentsNSC() {
            if r > CDSettings.MinThresholdWhite && g > CDSettings.MinThresholdWhite && b > CDSettings.MinThresholdWhite {
                return true // white
            }
            if r < CDSettings.MaxThresholdBlack && g < CDSettings.MaxThresholdBlack && b < CDSettings.MaxThresholdBlack {
                return true // black
            }
        }
        return false
    }

    public func contrastsWith(color: NSColor) -> Bool {
        return !doesNotContrastWith(color)
    }

    public func doesNotContrastWith(color: NSColor) -> Bool {
        if let (ba, br, bg, bb) = self.componentsNSC(), (fa, fr, fg, fb) = color.componentsNSC() {
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
        return false
    }

    public func componentsCSS() -> (alpha: String, red: String, green: String, blue: String, css: String)? {
        if let (alpha, red, green, blue) = self.componentsRGB() {
            let xalpha = String(alpha, radix: 16, uppercase: true)
            let xred = String(red, radix: 16, uppercase: true)
            let xgreen = String(green, radix: 16, uppercase: true)
            let xblue = String(blue, radix: 16, uppercase: true)
            let css = "#\(xred)\(xgreen)\(xblue)"
            return (alpha: xalpha, red: xred, green: xgreen, blue: xblue, css: css)
        }
        return nil
    }

    public func componentsNSC() -> (alpha: CGFloat, red: CGFloat, green: CGFloat, blue: CGFloat)? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        if let color = self.colorUsingColorSpaceName(NSCalibratedRGBColorSpace) {
            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            return (alpha: alpha, red: red, green: green, blue: blue)
        }
        return nil
    }

    public func componentsRGB() -> (alpha: Int, red: Int, green: Int, blue: Int)? {
        if let (alpha, red, green, blue) = self.componentsNSC() {
            return (alpha: Int(round(alpha * 255.0)), red: Int(round(red * 255.0)), green: Int(round(green * 255.0)), blue: Int(round(blue * 255.0)))
        }
        return nil
    }

    public func componentsHUE() -> (alpha: CGFloat, hue: CGFloat, saturation: CGFloat, brightness: CGFloat)? {
        if let convertedColor = self.colorUsingColorSpaceName(NSCalibratedRGBColorSpace) {
            var h: CGFloat = 0.0
            var s: CGFloat = 0.0
            var b: CGFloat = 0.0
            var a: CGFloat = 0.0
            convertedColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
            return (alpha: a, hue: h, saturation: s, brightness: b)
        }
        return nil
    }

}
