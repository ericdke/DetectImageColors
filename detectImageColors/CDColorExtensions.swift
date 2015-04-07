//
//  NSColorExtensions.swift
//  colorDetector
//
//  Created by ERIC DEJONCKHEERE on 03/04/2015.
//  Copyright (c) 2015 Eric Dejonckheere. All rights reserved.
//

import Cocoa

extension NSColor {

    func lighterColor(threshold: CGFloat = kColorThresholdFloorBrightness, ratio: CGFloat = kColorLighterRatio) -> NSColor {
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

    func darkerColor(threshold: CGFloat = kColorThresholdCeilingBrightness, ratio: CGFloat = kColorDarkerRatio) -> NSColor {
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

    func isMostlyDarkColor() -> Bool {
        return !isMostlyLightColor()
    }

    func isMostlyLightColor() -> Bool {
        var convertedColor = self.colorUsingColorSpaceName(NSCalibratedRGBColorSpace)
        var a: CGFloat = 0.0
        var b: CGFloat = 0.0
        var g: CGFloat = 0.0
        var r: CGFloat = 0.0
        convertedColor!.getRed(&r, green: &g, blue: &b, alpha: &a)
        var lum: CGFloat = kColorYUVRedRatio * r + kColorYUVGreenRatio * g + kColorYUVBlueRatio * b
        if lum < 0.5 {
            return false
        }
        return true
    }

    func isNearOf(color: NSColor) -> Bool {
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
        var threshold: CGFloat = kColorThresholdDistinctColor
        if fabs(r - r1) > threshold || fabs(g - g1) > threshold || fabs(b - b1) > threshold || fabs(a - a1) > threshold {
            // check for grays, prevent multiple gray colors
            if fabs(r - g) < kColorThresholdGrey && fabs(r - b) < kColorThresholdGrey {
                if fabs(r1 - g1) < kColorThresholdGrey && fabs(r1 - b1) < kColorThresholdGrey {
                    return true
                }
            }
            return false
        }
        return true
    }

    func sameOrWithMinimumSaturation(minSaturation: CGFloat) -> NSColor {
        var tempColor = self.colorUsingColorSpaceName(NSCalibratedRGBColorSpace)
        if tempColor != nil {
            var hue: CGFloat = 0.0
            var saturation: CGFloat = 0.0
            var brightness: CGFloat = 0.0
            var alpha: CGFloat = 0.0
            tempColor!.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            if saturation < minSaturation {
                return NSColor(calibratedHue: hue, saturation: minSaturation, brightness: brightness, alpha: alpha)
            }
        }
        return self
    }

    func isMostlyBlackOrWhite() -> Bool {
        return !isNotMostlyBlackOrWhite()
    }

    func isNotMostlyBlackOrWhite() -> Bool {
        var tempColor = self.colorUsingColorSpaceName(NSCalibratedRGBColorSpace)
        if tempColor != nil {
            var a: CGFloat = 0.0
            var b: CGFloat = 0.0
            var g: CGFloat = 0.0
            var r: CGFloat = 0.0
            tempColor!.getRed(&r, green: &g, blue: &b, alpha: &a)
            if r > kColorMinThresholdWhite && g > kColorMinThresholdWhite && b > kColorMinThresholdWhite {
                return false // white
            }
            if r < kColorMaxThresholdBlack && g < kColorMaxThresholdBlack && b < kColorMaxThresholdBlack {
                return false // black
            }
        }
        return true
    }

    func contrastsWith(color: NSColor) -> Bool {
        return !doesNotContrastWith(color)
    }

    func doesNotContrastWith(color: NSColor) -> Bool {
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
            var bLum: CGFloat = kColorYUVRedRatio * br + kColorYUVGreenRatio * bg + kColorYUVBlueRatio * bb
            var fLum: CGFloat = kColorYUVRedRatio * fr + kColorYUVGreenRatio * fg + kColorYUVBlueRatio * fb
            var contrast: CGFloat = 0.0
            if bLum > fLum {
                contrast = (bLum + kColorLuminanceAddedWeight) / (fLum + kColorLuminanceAddedWeight)
            } else {
                contrast = (fLum + kColorLuminanceAddedWeight) / (bLum + kColorLuminanceAddedWeight)
            }
            return contrast < kColorContrastRatio
        }
        return false
    }

}
