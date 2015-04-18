//
//  DCSettings.swift
//  detectImageColors
//
//  Created by ERIC DEJONCKHEERE on 06/04/2015.
//  Copyright (c) 2015 Eric Dejonckheere. All rights reserved.
//

import Cocoa

// MAGIC NUMBERS, YEAH!

// "Standard" means "correct value on average", but sometimes average is not what we want.

class CDSettings {
    static var ThresholdMinimumPercentage = 0.01
    static var ThresholdMinimumSaturation: CGFloat = 0.15
    static var ThresholdNoiseTolerance: Int = 1 // Standard: 2
    static var ThresholdFloorBrightness: CGFloat = 0.25
    static var ThresholdCeilingBrightness: CGFloat = 0.75
    static var ThresholdDistinctColor: CGFloat = 0.40 // Standard: 0.25
    static var ThresholdGrey: CGFloat = 0.03
    static var MinThresholdWhite: CGFloat = 0.91
    static var MaxThresholdBlack: CGFloat = 0.09
    
    static var LighterRatio: CGFloat = 1.6 // Standard: 1.3
    static var DarkerRatio: CGFloat = 0.6 // Standard: 0.75
    static var ContrastRatio: CGFloat = 1.8  // Standard: 1.6
    static var LuminanceAddedWeight: CGFloat = 0.05
    
    // Taken from various sources as "official" values for conversion
    static var YUVRedRatio: CGFloat = 0.2126
    static var YUVGreenRatio: CGFloat = 0.7152
    static var YUVBlueRatio: CGFloat = 0.0722
    
    // Set it to 0 for "classic" behavior
    static var DetectorDistanceFromLeftEdge: Int = 5
    // Detects a Y line of pixels every DetectorResolution pixels on X. Smaller = better & slower.
    static var DetectorResolution: Int = 10
}