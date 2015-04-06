//
//  Constants.swift
//  detectImageColors
//
//  Created by ERIC DEJONCKHEERE on 06/04/2015.
//  Copyright (c) 2015 Eric Dejonckheere. All rights reserved.
//

import Foundation

// Magic numbers!

let kColorThresholdMinimumPercentage = 0.01  // original 0.01
let kColorThresholdMinimumSaturation: CGFloat = 0.15 // original: 0.15
let kColorThresholdNoiseTolerance: Int = 1 // original: 2
let kColorThresholdFloorBrightness: CGFloat = 0.35 // original: 0.25
let kColorThresholdCeilingBrightness: CGFloat = 0.75
let kColorLighterRatio: CGFloat = 1.3
let kColorDarkerRatio: CGFloat = 0.75
let kColorYUVRedRatio: CGFloat = 0.2126
let kColorYUVGreenRatio: CGFloat = 0.7152
let kColorYUVBlueRatio: CGFloat = 0.0722
let kColorThresholdDistinctColor: CGFloat = 0.35 // original: 0.25
let kColorThresholdGrey: CGFloat = 0.03 // original: 0.03
let kColorMinThresholdWhite: CGFloat = 0.91 // original: 0.91
let kColorMaxThresholdBlack: CGFloat = 0.09 // original: 0.09
let kColorLuminanceAddedWeight: CGFloat = 0.05
let kColorContrastRatio: CGFloat = 1.58  // original: 1.6
