//  DEMO APP

//  SWIFT 2

import Cocoa

extension CGFloat {
    func formatSliderDouble(multiplier: Double = 100.0) -> Double {
        return Double(self) * multiplier
    }
}

class DemoControlsView: NSView {

    @IBOutlet weak var distinctColors: NSSlider!
    @IBOutlet weak var distinctColorsValue: NSTextField!
    @IBOutlet weak var noiseTolerance: NSSlider!
    @IBOutlet weak var noiseToleranceValue: NSTextField!
    @IBOutlet weak var distinctColorsTitle: NSTextField!
    @IBOutlet weak var noiseToleranceTitle: NSTextField!
    @IBOutlet weak var thresholdMinimumSaturation: NSSlider!
    @IBOutlet weak var thresholdMinimumSaturationTitle: NSTextField!
    @IBOutlet weak var thresholdMinimumSaturationValue: NSTextField!
    @IBOutlet weak var thresholdFloorBrightness: NSSlider!
    @IBOutlet weak var thresholdFloorBrightnessTitle: NSTextField!
    @IBOutlet weak var thresholdFloorBrightnessValue: NSTextField!
    @IBOutlet weak var contrastRatio: NSSlider!
    @IBOutlet weak var contrastRatioValue: NSTextField!
    @IBOutlet weak var contrastRatioTitle: NSTextField!
    @IBOutlet weak var ensureContrastedColorCandidates: NSButton!

    override func awakeFromNib() {
        setSlidersDefaults()
    }

    func setSlidersDefaults() {
        distinctColors.doubleValue = CDSettings.ThresholdDistinctColor.formatSliderDouble()
        distinctColorsValue.stringValue = String(format: "%.2f", CDSettings.ThresholdDistinctColor)
        noiseTolerance.integerValue = CDSettings.ThresholdNoiseTolerance
        noiseToleranceValue.integerValue = CDSettings.ThresholdNoiseTolerance
        thresholdMinimumSaturation.doubleValue = CDSettings.ThresholdMinimumSaturation.formatSliderDouble()
        thresholdMinimumSaturationValue.stringValue = String(format: "%.2f", CDSettings.ThresholdMinimumSaturation)
        thresholdFloorBrightness.doubleValue = CDSettings.ThresholdFloorBrightness.formatSliderDouble()
        thresholdFloorBrightnessValue.stringValue = String(format: "%.2f", CDSettings.ThresholdFloorBrightness)
        contrastRatio.doubleValue = CDSettings.ContrastRatio.formatSliderDouble(10.0)
        contrastRatioValue.stringValue = String(format: "%.1f", CDSettings.ContrastRatio)
        ensureContrastedColorCandidates.state = NSOnState
    }

    @IBAction func resetToDefaults(sender: NSButton) {
        if let defaults =  NSUserDefaults.standardUserDefaults().objectForKey("defaultSettings") as? NSDictionary {
            CDSettings.ThresholdDistinctColor = defaults["ThresholdDistinctColor"] as! CGFloat
            CDSettings.ThresholdNoiseTolerance = defaults["ThresholdNoiseTolerance"] as! Int
            CDSettings.ThresholdMinimumSaturation = defaults["ThresholdMinimumSaturation"] as! CGFloat
            CDSettings.ThresholdFloorBrightness = defaults["ThresholdFloorBrightness"] as! CGFloat
            CDSettings.ContrastRatio = defaults["ContrastRatio"] as! CGFloat
            CDSettings.EnsureContrastedColorCandidates = true
            setSlidersDefaults()
            updateColors(sender)
        }
    }

    @IBAction func ensureContrastedColorCandidates(sender: NSButton) {
        CDSettings.EnsureContrastedColorCandidates = Bool(sender.state)
        updateColors(sender)
    }

    @IBAction func noiseToleranceSlider(sender: NSSlider) {
        noiseToleranceValue.integerValue = sender.integerValue
        CDSettings.ThresholdNoiseTolerance = sender.integerValue
        updateColors(sender)
    }

    @IBAction func thresholdMinimumSaturationSlider(sender: NSSlider) {
        let val = makeDoubleValFromSlider(sender)
        thresholdMinimumSaturationValue.stringValue = val.string
        CDSettings.ThresholdMinimumSaturation = val.cgFloat
        updateColors(sender)
    }

    @IBAction func distinctColorsSlider(sender: NSSlider) {
        let val = makeDoubleValFromSlider(sender)
        distinctColorsValue.stringValue = val.string
        CDSettings.ThresholdDistinctColor = val.cgFloat
        updateColors(sender)
    }

    @IBAction func thresholdFloorBrightnessSlider(sender: NSSlider) {
        let val = makeDoubleValFromSlider(sender)
        thresholdFloorBrightnessValue.stringValue = val.string
        CDSettings.ThresholdFloorBrightness = val.cgFloat
        updateColors(sender)
    }

    @IBAction func contrastRatioSlider(sender: NSSlider) {
        let val = makeDoubleValFromSlider(sender, divider: 10, format: "%.1f")
        contrastRatioValue.stringValue = val.string
        CDSettings.ContrastRatio = val.cgFloat
        updateColors(sender)
    }

    private func makeDoubleValFromSlider(sender: NSSlider, divider: Int = 100, format: String = "%.2f") -> (string: String, cgFloat: CGFloat, double: Double) {
        let val = Double(sender.integerValue) / Double(divider)
        let str = String(format: format, val)
        return (str, CGFloat(val), val)
    }

    private func updateColors(sender: AnyObject? = nil) {
        var dict = ["mouseUp":false]
        if let sdr = sender as? NSSlider ?? sender as? NSButton {
            if let event = sdr.window?.currentEvent where event.type == NSEventType.LeftMouseUp {
                dict = ["mouseUp":true]
            }
        }
        NSNotificationCenter.defaultCenter().postNotificationName("updateColorCandidatesOK", object: nil, userInfo: dict)
    }

}
