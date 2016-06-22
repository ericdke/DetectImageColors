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
    let defaultPreset: Bool
    
    init(name: String,
         brightness: CGFloat,
         distinct: CGFloat,
         saturation: CGFloat,
         contrast: CGFloat, 
         noise: Int, 
         contrasted: Bool,
         defaultPreset: Bool = false) {
        self.name = name
        self.thresholdFloorBrightness = brightness
        self.thresholdDistinctColor = distinct
        self.thresholdMinimumSaturation = saturation
        self.contrastRatio = contrast
        self.thresholdNoiseTolerance = noise
        self.contrastedCandidates = contrasted
        self.defaultPreset = defaultPreset
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.thresholdFloorBrightness = aDecoder.decodeObject(forKey: "thresholdFloorBrightness") as! CGFloat
        self.thresholdDistinctColor = aDecoder.decodeObject(forKey: "thresholdDistinctColor") as! CGFloat
        self.thresholdMinimumSaturation = aDecoder.decodeObject(forKey: "thresholdMinimumSaturation") as! CGFloat
        self.contrastRatio = aDecoder.decodeObject(forKey: "contrastRatio") as! CGFloat
        self.thresholdNoiseTolerance = aDecoder.decodeInteger(forKey: "thresholdNoiseTolerance")
        self.contrastedCandidates = aDecoder.decodeBool(forKey: "contrastedCandidates")
        self.defaultPreset = aDecoder.decodeBool(forKey: "defaultPreset")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(thresholdFloorBrightness, forKey: "thresholdFloorBrightness")
        aCoder.encode(thresholdDistinctColor, forKey: "thresholdDistinctColor")
        aCoder.encode(thresholdMinimumSaturation, forKey: "thresholdMinimumSaturation")
        aCoder.encode(contrastRatio, forKey: "contrastRatio")
        aCoder.encode(thresholdNoiseTolerance, forKey: "thresholdNoiseTolerance")
        aCoder.encode(contrastedCandidates, forKey: "contrastedCandidates")
        aCoder.encode(defaultPreset, forKey: "defaultPreset")
    }
    
}
