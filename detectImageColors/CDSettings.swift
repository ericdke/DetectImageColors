//
//  DCSettings.swift
//  detectImageColors
//
//  Created by ERIC DEJONCKHEERE on 06/04/2015.
//  Copyright (c) 2015 Eric Dejonckheere. All rights reserved.
//

import Cocoa

class CDSettings {
    static var ThresholdMinimumPercentage = 0.01  // original 0.01
    static var ThresholdMinimumSaturation: CGFloat = 0.15 // original: 0.15
    static var ThresholdNoiseTolerance: Int = 1 // original: 2
    static var ThresholdFloorBrightness: CGFloat = 0.25 // original: 0.25
    static var ThresholdCeilingBrightness: CGFloat = 0.75
    static var LighterRatio: CGFloat = 1.6 // original: 1.3
    static var DarkerRatio: CGFloat = 0.6 // original: 0.75
    static var YUVRedRatio: CGFloat = 0.2126
    static var YUVGreenRatio: CGFloat = 0.7152
    static var YUVBlueRatio: CGFloat = 0.0722
    static var ThresholdDistinctColor: CGFloat = 0.45 // original: 0.25
    static var ThresholdGrey: CGFloat = 0.03 // original: 0.03
    static var MinThresholdWhite: CGFloat = 0.91 // original: 0.91
    static var MaxThresholdBlack: CGFloat = 0.09 // original: 0.09
    static var LuminanceAddedWeight: CGFloat = 0.05
    static var ContrastRatio: CGFloat = 1.8  // original: 1.6
    static var DetectorDistanceFromLeftEdge: Int = 5
    static var DetectorResolution: Int = 10 // Detects an Y line of pixels every DetectorResolution pixels on X. Smaller = better & slower. 10 is a good average for 600x600 pics.
}