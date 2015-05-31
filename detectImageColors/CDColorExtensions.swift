import Cocoa

public extension NSColor {

    public func lighterColor(threshold: CGFloat = CDSettings.ThresholdFloorBrightness, ratio: CGFloat = CDSettings.LighterRatio) -> NSColor {
        var convertedColor = self.colorUsingColorSpaceName(NSCalibratedRGBColorSpace)
        var h: CGFloat = 0.0
        var s: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        convertedColor!.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        if b < threshold {
            b = threshold
        }
        return NSColor(calibratedHue: h, saturation: s, brightness: min(b * ratio, 1.0), alpha: a)
    }

    public func darkerColor(threshold: CGFloat = CDSettings.ThresholdCeilingBrightness, ratio: CGFloat = CDSettings.DarkerRatio) -> NSColor {
        var convertedColor = self.colorUsingColorSpaceName(NSCalibratedRGBColorSpace)
        var h: CGFloat = 0.0
        var s: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        convertedColor!.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        if b > threshold {
            b = threshold
        }
        return NSColor(calibratedHue: h, saturation: s, brightness: b * ratio, alpha: a)
    }

    public func isMostlyDarkColor() -> Bool {
        var convertedColor = self.colorUsingColorSpaceName(NSCalibratedRGBColorSpace)
        var a: CGFloat = 0.0
        var b: CGFloat = 0.0
        var g: CGFloat = 0.0
        var r: CGFloat = 0.0
        convertedColor!.getRed(&r, green: &g, blue: &b, alpha: &a)
        var lum: CGFloat = CDSettings.YUVRedRatio * r + CDSettings.YUVGreenRatio * g + CDSettings.YUVBlueRatio * b
        if lum < 0.5 {
            return true
        }
        return false
    }

    public func isNearOf(color: NSColor) -> Bool {
        var convertedColor = self.colorUsingColorSpaceName(NSCalibratedRGBColorSpace)
        var convertedCompareColor = color.colorUsingColorSpaceName(NSCalibratedRGBColorSpace)
        var a: CGFloat = 0.0
        var b: CGFloat = 0.0
        var g: CGFloat = 0.0
        var r: CGFloat = 0.0
        var a1: CGFloat = 0.0
        var b1: CGFloat = 0.0
        var g1: CGFloat = 0.0
        var r1: CGFloat = 0.0
        convertedColor!.getRed(&r, green: &g, blue: &b, alpha: &a)
        convertedCompareColor!.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        var threshold: CGFloat = CDSettings.ThresholdDistinctColor
        if fabs(r - r1) > threshold || fabs(g - g1) > threshold || fabs(b - b1) > threshold || fabs(a - a1) > threshold {
            // check for grays, prevent multiple gray colors
            if fabs(r - g) < CDSettings.ThresholdGrey && fabs(r - b) < CDSettings.ThresholdGrey {
                if fabs(r1 - g1) < CDSettings.ThresholdGrey && fabs(r1 - b1) < CDSettings.ThresholdGrey {
                    return true
                }
            }
            return false
        }
        return true
    }

    public func withMinimumSaturation(minimumSaturation: CGFloat) -> NSColor {
        // color could be hue/rgb/other so we convert to rgb
        if var tempColor = self.colorUsingColorSpaceName(NSCalibratedRGBColorSpace) {
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
        var tempColor = self.colorUsingColorSpaceName(NSCalibratedRGBColorSpace)
        if tempColor != nil {
            var a: CGFloat = 0.0
            var b: CGFloat = 0.0
            var g: CGFloat = 0.0
            var r: CGFloat = 0.0
            tempColor!.getRed(&r, green: &g, blue: &b, alpha: &a)
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
        var backgroundColor = self.colorUsingColorSpaceName(NSCalibratedRGBColorSpace)
        var foregroundColor = color.colorUsingColorSpaceName(NSCalibratedRGBColorSpace)
        if backgroundColor != nil && foregroundColor != nil {
            var ba: CGFloat = 0.0
            var bb: CGFloat = 0.0
            var bg: CGFloat = 0.0
            var br: CGFloat = 0.0
            var fa: CGFloat = 0.0
            var fb: CGFloat = 0.0
            var fg: CGFloat = 0.0
            var fr: CGFloat = 0.0
            backgroundColor!.getRed(&br, green: &bg, blue: &bb, alpha: &ba)
            foregroundColor!.getRed(&fr, green: &fg, blue: &fb, alpha: &fa)
            var bLum: CGFloat = CDSettings.YUVRedRatio * br + CDSettings.YUVGreenRatio * bg + CDSettings.YUVBlueRatio * bb
            var fLum: CGFloat = CDSettings.YUVRedRatio * fr + CDSettings.YUVGreenRatio * fg + CDSettings.YUVBlueRatio * fb
            var contrast: CGFloat = 0.0
            if bLum > fLum {
                contrast = (bLum + CDSettings.LuminanceAddedWeight) / (fLum + CDSettings.LuminanceAddedWeight)
            } else {
                contrast = (fLum + CDSettings.LuminanceAddedWeight) / (bLum + CDSettings.LuminanceAddedWeight)
            }
            return contrast < CDSettings.ContrastRatio
        }
        return false
    }

}
