//
//  NSColorExtensions.swift
//  colortunes
//
//  Created by ERIC DEJONCKHEERE on 03/04/2015.
//  Copyright (c) 2015 Eric Dejonckheere. All rights reserved.
//

import Cocoa

extension NSColor {

    func pc_isDarkColor() -> Bool {
        var convertedColor = self.colorUsingColorSpaceName(NSCalibratedRGBColorSpace)
        var a: CGFloat = 0.0
        var b: CGFloat = 0.0
        var g: CGFloat = 0.0
        var r: CGFloat = 0.0
        convertedColor!.getRed(&r, green: &g, blue: &b, alpha: &a)
        var lum: CGFloat = 0.2126 * r + 0.7152 * g + 0.0722 * b
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
        var threshold: CGFloat = 0.25 // original: 0.25
        if fabs(r - r1) > threshold || fabs(g - g1) > threshold || fabs(b - b1) > threshold || fabs(a - a1) > threshold {
            // check for grays, prevent multiple gray colors
            if fabs(r - g) < 0.03 && fabs(r - b) < 0.03 {
                if fabs(r1 - g1) < 0.03 && fabs(r1 - b1) < 0.03 {
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
            if r > 0.91 && g > 0.91 && b > 0.91 {  // original : 0.91
                return true // white
            }
            if r < 0.09 && g < 0.09 && b < 0.09 {  // original: 0.09
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
            var bLum: CGFloat = 0.2126 * br + 0.7152 * bg + 0.0722 * bb
            var fLum: CGFloat = 0.2126 * fr + 0.7152 * fg + 0.0722 * fb
            var contrast: CGFloat = 0.0
            if bLum > fLum {
                contrast = (bLum + 0.05) / (fLum + 0.05)
            } else {
                contrast = (fLum + 0.05) / (bLum + 0.05)
            }
            return contrast > 1.8 // original: 1.6
        }
        return true
    }

}
