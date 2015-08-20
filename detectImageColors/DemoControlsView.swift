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
    
    
    func setSliders(preset: Preset?) {
        do {
            guard let pres = preset else { throw DemoAppError.CouldNotSetSlidersFromPreset }
            CDSettings.ThresholdDistinctColor = pres.thresholdDistinctColor
            distinctColors.doubleValue = CDSettings.ThresholdDistinctColor.formatSliderDouble()
            distinctColorsValue.stringValue = String(format: "%.2f", CDSettings.ThresholdDistinctColor)
            CDSettings.ThresholdNoiseTolerance = pres.thresholdNoiseTolerance
            noiseTolerance.integerValue = CDSettings.ThresholdNoiseTolerance
            noiseToleranceValue.integerValue = CDSettings.ThresholdNoiseTolerance
            CDSettings.ThresholdMinimumSaturation = pres.thresholdMinimumSaturation
            thresholdMinimumSaturation.doubleValue = CDSettings.ThresholdMinimumSaturation.formatSliderDouble()
            thresholdMinimumSaturationValue.stringValue = String(format: "%.2f", CDSettings.ThresholdMinimumSaturation)
            CDSettings.ThresholdFloorBrightness = pres.thresholdFloorBrightness
            thresholdFloorBrightness.doubleValue = CDSettings.ThresholdFloorBrightness.formatSliderDouble()
            thresholdFloorBrightnessValue.stringValue = String(format: "%.2f", CDSettings.ThresholdFloorBrightness)
            CDSettings.ContrastRatio = pres.contrastRatio
            contrastRatio.doubleValue = CDSettings.ContrastRatio.formatSliderDouble(10.0)
            contrastRatioValue.stringValue = String(format: "%.1f", CDSettings.ContrastRatio)
            CDSettings.EnsureContrastedColorCandidates = pres.contrastedCandidates
            ensureContrastedColorCandidates.state = Int(pres.contrastedCandidates)
            NSNotificationCenter.defaultCenter().postNotificationName("updateColorCandidatesOK", object: nil, userInfo: ["mouseUp":true])
        } catch let demoAppError as DemoAppError {
            Swift.print(demoAppError.rawValue)
        } catch {
            Swift.print(error)
        }
    }

    @IBAction func resetToDefaults(sender: NSButton) {
        do {
            guard let defaults =  NSUserDefaults.standardUserDefaults().objectForKey("defaultSettings") as? NSDictionary,
                distinct = defaults["ThresholdDistinctColor"] as? CGFloat,
                noise = defaults["ThresholdNoiseTolerance"] as? Int,
                saturation = defaults["ThresholdMinimumSaturation"] as? CGFloat,
                brightness = defaults["ThresholdFloorBrightness"] as? CGFloat,
                contrast = defaults["ContrastRatio"] as? CGFloat
                else { throw DemoAppError.CouldNotfindDefaultConfiguration
            }
            CDSettings.ThresholdDistinctColor = distinct
            CDSettings.ThresholdNoiseTolerance = noise
            CDSettings.ThresholdMinimumSaturation = saturation
            CDSettings.ThresholdFloorBrightness = brightness
            CDSettings.ContrastRatio = contrast
            CDSettings.EnsureContrastedColorCandidates = true
            setSlidersDefaults()
            updateColors(sender)
        } catch let demoAppError as DemoAppError {
            Swift.print(demoAppError.rawValue)
        } catch let error {
            Swift.print(error)
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
        if let sdr = sender as? NSSlider ?? sender as? NSButton,
            event = sdr.window?.currentEvent where event.type == NSEventType.LeftMouseUp {
            dict = ["mouseUp":true]
        }
        NSNotificationCenter.defaultCenter().postNotificationName("updateColorCandidatesOK", object: nil, userInfo: dict)
    }

}
