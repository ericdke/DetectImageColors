import Cocoa

public struct ColorCandidates {
    public var primary: NSColor?
    public var secondary: NSColor?
    public var detail: NSColor?
    public var background: NSColor?
    public var backgroundIsDark: Bool?
    public var backgroundIsBlackOrWhite: Bool?
    
    public var dictionary: [String : [String : AnyObject]] {
        guard let primary = getRGBSpaceName(color: self.primary),
            let alternative = getRGBSpaceName(color: self.secondary),
            let detail = getRGBSpaceName(color: self.detail),
            let background = getRGBSpaceName(color: self.background) else {
                return [:]
        }
        var dic = [String:[String:AnyObject]]()
        dic["main"] = getDictionaryColorComponents(color: primary)
        dic["alternative"] = getDictionaryColorComponents(color: alternative)
        dic["detail"] = getDictionaryColorComponents(color: detail)
        dic["background"] = getDictionaryColorComponents(color: background)
        dic["settings"] = getDictionarySettings()
        return dic
    }
    
    public func toJSONData() -> Data {
        return try! JSONSerialization.data(withJSONObject: dictionary, options: JSONSerialization.WritingOptions.prettyPrinted)
    }
    
    private func getRGBSpaceName(color: NSColor?) -> NSColor? {
        guard let thisColor = color, let rgbColor = thisColor.usingColorSpaceName(NSCalibratedRGBColorSpace) else { return nil }
        return rgbColor
    }
    
    private func getDictionaryColorComponents(color: NSColor) -> [String:AnyObject] {
        return ["red": color.redComponent, "green": color.greenComponent, "blue": color.blueComponent, "css": color.componentsCSS()!.css]
    }
    
    private func getDictionarySettings() -> [String:AnyObject] {
        return ["EnsureContrastedColorCandidates": CDSettings.ensureContrastedColorCandidates, "ThresholdDistinctColor": CDSettings.thresholdDistinctColor, "ContrastRatio": CDSettings.contrastRatio, "ThresholdNoiseTolerance": CDSettings.thresholdNoiseTolerance, "ThresholdFloorBrightness": CDSettings.thresholdFloorBrightness, "ThresholdMinimumSaturation": CDSettings.thresholdMinimumSaturation]
    }
}
