//  SWIFT 2

import Cocoa

// MAGIC NUMBERS, YEAH!

// Standard values are noted above each variable.

// "Standard" means "correct value on average", but sometimes average is not what we want...
// ...so the defaults values here are better than standards *according to me* for the demo image. Please experiment.

public class CDSettings {
    // 0.01
    public static var thresholdMinimumPercentage = 0.01
    // 0.15
    public static var thresholdMinimumSaturation: CGFloat = 0.15
    // 2
    public static var thresholdNoiseTolerance: Int = 1
    // 0.25
    public static var thresholdFloorBrightness: CGFloat = 0.25
    // 0.75
    public static var thresholdCeilingBrightness: CGFloat = 0.75
    // 0.25
    public static var thresholdDistinctColor: CGFloat = 0.43
    // 0.03
    public static var thresholdGrey: CGFloat = 0.03
    // 0.91
    public static var minThresholdWhite: CGFloat = 0.91
    // 0.09
    public static var maxThresholdBlack: CGFloat = 0.09
    
    // 1.3
    public static var lighterRatio: CGFloat = 1.6
    // 0.75
    public static var darkerRatio: CGFloat = 0.6
    // 1.6
    public static var contrastRatio: CGFloat = 2.1
    // 0.05
    public static var luminanceAddedWeight: CGFloat = 0.05
    
    // Taken from various sources as "official" values for conversion
    public static var YUVRedRatio: CGFloat = 0.2126
    public static var YUVGreenRatio: CGFloat = 0.7152
    public static var YUVBlueRatio: CGFloat = 0.0722
    
    // Set it to 0 for "classic" behavior
    public static var detectorDistanceFromLeftEdge: Int = 5
    // Detects a Y line of pixels every DetectorResolution pixels on X. Smaller = better & slower.
    public static var detectorResolution: Int = 10
    
    // Set to false to have more precise but less contrasted results
    public static var ensureContrastedColorCandidates = true
}
