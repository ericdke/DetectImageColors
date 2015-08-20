//
//  DemoPresetModel.swift
//  detectImageColors
//
//  Created by ERIC DEJONCKHEERE on 20/08/2015.
//  Copyright © 2015 Eric Dejonckheere. All rights reserved.
//

import Cocoa

final class Preset: NSObject, NSCoding {
    
    let name: String
    let thresholdFloorBrightness: CGFloat
    let thresholdDistinctColor: CGFloat
    let thresholdMinimumSaturation: CGFloat
    let contrastRatio: CGFloat
    let contrastedCandidates: Bool
    let thresholdNoiseTolerance: Int
    
    init(name: String, brightness: CGFloat, distinct: CGFloat, saturation: CGFloat, contrast: CGFloat, noise: Int, contrasted: Bool) {
        self.name = name
        self.thresholdFloorBrightness = brightness
        self.thresholdDistinctColor = distinct
        self.thresholdMinimumSaturation = saturation
        self.contrastRatio = contrast
        self.thresholdNoiseTolerance = noise
        self.contrastedCandidates = contrasted
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObjectForKey("name") as! String
        self.thresholdFloorBrightness = aDecoder.decodeObjectForKey("thresholdFloorBrightness") as! CGFloat
        self.thresholdDistinctColor = aDecoder.decodeObjectForKey("thresholdDistinctColor") as! CGFloat
        self.thresholdMinimumSaturation = aDecoder.decodeObjectForKey("thresholdMinimumSaturation") as! CGFloat
        self.contrastRatio = aDecoder.decodeObjectForKey("contrastRatio") as! CGFloat
        self.thresholdNoiseTolerance = aDecoder.decodeIntegerForKey("thresholdNoiseTolerance")
        self.contrastedCandidates = aDecoder.decodeBoolForKey("contrastedCandidates")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(thresholdFloorBrightness, forKey: "thresholdFloorBrightness")
        aCoder.encodeObject(thresholdDistinctColor, forKey: "thresholdDistinctColor")
        aCoder.encodeObject(thresholdMinimumSaturation, forKey: "thresholdMinimumSaturation")
        aCoder.encodeObject(contrastRatio, forKey: "contrastRatio")
        aCoder.encodeInteger(thresholdNoiseTolerance, forKey: "thresholdNoiseTolerance")
        aCoder.encodeBool(contrastedCandidates, forKey: "contrastedCandidates")
    }
    
}
