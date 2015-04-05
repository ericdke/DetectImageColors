//
//  NSColorExtensions.swift
//  colortunes
//
//  Created by ERIC DEJONCKHEERE on 03/04/2015.
//  Copyright (c) 2015 Eric Dejonckheere. All rights reserved.
//

import Cocoa

// Magic numbers!

let kColorThresholdFloorBrightness: CGFloat = 0.25
let kColorThresholdCeilingBrightness: CGFloat = 0.75
let kColorLighterRatio: CGFloat = 1.3
let kColorDarkerRatio: CGFloat = 0.75
let kColorYUVRedRatio: CGFloat = 0.2126
let kColorYUVGreenRatio: CGFloat = 0.7152
let kColorYUVBlueRatio: CGFloat = 0.0722
let kColorThresholdDistinctColor: CGFloat = 0.25
let kColorThresholdGrey: CGFloat = 0.03 // original: 0.03
let kColorMinThresholdWhite: CGFloat = 0.91
let kColorMaxThresholdBlack: CGFloat = 0.09
let kColorLuminanceAddedWeight: CGFloat = 0.05
let kColorContrastRatio: CGFloat = 1.6  // original: 1.6


extension NSColor {

    func lighterColor() -> NSColor {
        var convertedColor = self.colorUsingColorSpaceName(NSCalibratedRGBColorSpace)
        var h: CGFloat = 0.0
        var s: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        convertedColor!.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        if b < kColorThresholdFloorBrightness {
            b = kColorThresholdFloorBrightness
        }
        return NSColor(calibratedHue: h, saturation: s, brightness: min(b * kColorLighterRatio, 1.0), alpha: a)
    }

    func darkerColor() -> NSColor {
        var convertedColor = self.colorUsingColorSpaceName(NSCalibratedRGBColorSpace)
        var h: CGFloat = 0.0
        var s: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        convertedColor!.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        if b > kColorThresholdCeilingBrightness {
            b = kColorThresholdCeilingBrightness
        }
        return NSColor(calibratedHue: h, saturation: s, brightness: b * kColorDarkerRatio, alpha: a)
    }

    func pc_isDarkColor() -> Bool {
        var convertedColor = self.colorUsingColorSpaceName(NSCalibratedRGBColorSpace)
        var a: CGFloat = 0.0
        var b: CGFloat = 0.0
        var g: CGFloat = 0.0
        var r: CGFloat = 0.0
        convertedColor!.getRed(&r, green: &g, blue: &b, alpha: &a)
        var lum: CGFloat = kColorYUVRedRatio * r + kColorYUVGreenRatio * g + kColorYUVBlueRatio * b
        if lum < 0.5 {
            return true
        }
        return false
    }

    func pc_isDistinct(compareColor: NSColor) -> Bool {
        var convertedColor = self.colorUsingColorSpaceName(NSCalibratedRGBColorSpace)
        var convertedCompareColor = compareColor.colorUsingColorSpaceName(NSCalibratedRGBColorSpace)
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
                    return false
                }
            }
            return true
        }
        return false
    }

    func pc_colorWithMinimumSaturation(minSaturation: CGFloat) -> NSColor {
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

    func pc_isBlackOrWhite() -> Bool {
        var tempColor = self.colorUsingColorSpaceName(NSCalibratedRGBColorSpace)
        if tempColor != nil {
            var a: CGFloat = 0.0
            var b: CGFloat = 0.0
            var g: CGFloat = 0.0
            var r: CGFloat = 0.0
            tempColor!.getRed(&r, green: &g, blue: &b, alpha: &a)
            if r > kColorMinThresholdWhite && g > kColorMinThresholdWhite && b > kColorMinThresholdWhite {
                return true // white
            }
            if r < kColorMaxThresholdBlack && g < kColorMaxThresholdBlack && b < kColorMaxThresholdBlack {
                return true // black
            }
        }
        return false
    }

    func pc_isContrastingColor(color: NSColor) -> Bool {
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
            return contrast > kColorContrastRatio
        }
        return true
    }

}
