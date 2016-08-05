import Cocoa

public struct ColorCandidates {
    public var primary: NSColor?
    public var secondary: NSColor?
    public var detail: NSColor?
    public var background: NSColor?
    public var backgroundIsDark: Bool?
    public var backgroundIsBlackOrWhite: Bool?
    
    public func toJSONData() -> Data {
        return try! JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
    }
    
    private var dictionary: [String : [String : AnyObject]] {
        guard let primary = getRGBColor(from: self.primary),
            let alternative = getRGBColor(from: self.secondary),
            let detail = getRGBColor(from: self.detail),
            let background = getRGBColor(from: self.background) else {
                return [:]
        }
        var dic = [String:[String:AnyObject]]()
        dic["main"] = getDictionaryComponents(for: primary)
        dic["alternative"] = getDictionaryComponents(for: alternative)
        dic["detail"] = getDictionaryComponents(for: detail)
        dic["background"] = getDictionaryComponents(for: background)
        dic["settings"] = getDictionarySettings()
        return dic
    }
    
    private func getRGBColor(from color: NSColor?) -> NSColor? {
        return color?.usingColorSpaceName(NSCalibratedRGBColorSpace)
    }
    
    private func getDictionaryComponents(for color: NSColor) -> [String:AnyObject] {
        return ["red": color.redComponent,
                "green": color.greenComponent,
                "blue": color.blueComponent,
                "css": color.componentsCSS()!.css]
    }
    
    private func getDictionarySettings() -> [String:AnyObject] {
        return ["EnsureContrastedColorCandidates": CDSettings.ensureContrastedColorCandidates,
                "ThresholdDistinctColor": CDSettings.thresholdDistinctColor,
                "ContrastRatio": CDSettings.contrastRatio,
                "ThresholdNoiseTolerance": CDSettings.thresholdNoiseTolerance,
                "ThresholdFloorBrightness": CDSettings.thresholdFloorBrightness,
                "ThresholdMinimumSaturation": CDSettings.thresholdMinimumSaturation]
    }
}
