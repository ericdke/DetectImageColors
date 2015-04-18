//
//  DCSettings.swift
//  detectImageColors
//
//  Created by ERIC DEJONCKHEERE on 06/04/2015.
//  Copyright (c) 2015 Eric Dejonckheere. All rights reserved.
//

import Cocoa

var kColorThresholdMinimumPercentage = 0.01  // original 0.01
var kColorThresholdMinimumSaturation: CGFloat = 0.15 // original: 0.15
var kColorThresholdNoiseTolerance: Int = 1 // original: 2
var kColorThresholdFloorBrightness: CGFloat = 0.25 // original: 0.25
var kColorThresholdCeilingBrightness: CGFloat = 0.75
var kColorLighterRatio: CGFloat = 1.6 // original: 1.3
var kColorDarkerRatio: CGFloat = 0.6 // original: 0.75
var kColorYUVRedRatio: CGFloat = 0.2126
var kColorYUVGreenRatio: CGFloat = 0.7152
var kColorYUVBlueRatio: CGFloat = 0.0722
var kColorThresholdDistinctColor: CGFloat = 0.35 // original: 0.25
var kColorThresholdGrey: CGFloat = 0.03 // original: 0.03
var kColorMinThresholdWhite: CGFloat = 0.91 // original: 0.91
var kColorMaxThresholdBlack: CGFloat = 0.09 // original: 0.09
var kColorLuminanceAddedWeight: CGFloat = 0.05
var kColorContrastRatio: CGFloat = 1.6  // original: 1.6
var kColorDetectorDistanceFromLeftEdge: Int = 5
var kColorDetectorResolution: Int = 10 // Detects an Y line of pixels every kColorDetectorResolution pixels on X. Smaller = better & slower. 10 is a good average for 600x600 pics.