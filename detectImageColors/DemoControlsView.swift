// DEMO APP

import Cocoa

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
    
    var controlsDelegate: ControlsDelegate?

    func setSlidersDefaults() {
        distinctColors.doubleValue = CDSettings.thresholdDistinctColor.formatSliderDouble()
        distinctColorsValue.stringValue = String(format: "%.2f", CDSettings.thresholdDistinctColor)
        noiseTolerance.integerValue = CDSettings.thresholdNoiseTolerance
        noiseToleranceValue.integerValue = CDSettings.thresholdNoiseTolerance
        thresholdMinimumSaturation.doubleValue = CDSettings.thresholdMinimumSaturation.formatSliderDouble()
        thresholdMinimumSaturationValue.stringValue = String(format: "%.2f", CDSettings.thresholdMinimumSaturation)
        thresholdFloorBrightness.doubleValue = CDSettings.thresholdFloorBrightness.formatSliderDouble()
        thresholdFloorBrightnessValue.stringValue = String(format: "%.2f", CDSettings.thresholdFloorBrightness)
        contrastRatio.doubleValue = CDSettings.contrastRatio.formatSliderDouble(multiplier: 10.0)
        contrastRatioValue.stringValue = String(format: "%.1f", CDSettings.contrastRatio)
        ensureContrastedColorCandidates.state = NSOnState
    }
    
    
    func setSliders(preset: Preset?) {
        do {
            guard let pres = preset else { throw DemoAppError.couldNotSetSlidersFromPreset }
            CDSettings.thresholdDistinctColor = pres.thresholdDistinctColor
            distinctColors.doubleValue = CDSettings.thresholdDistinctColor.formatSliderDouble()
            distinctColorsValue.stringValue = String(format: "%.2f", CDSettings.thresholdDistinctColor)
            CDSettings.thresholdNoiseTolerance = pres.thresholdNoiseTolerance
            noiseTolerance.integerValue = CDSettings.thresholdNoiseTolerance
            noiseToleranceValue.integerValue = CDSettings.thresholdNoiseTolerance
            CDSettings.thresholdMinimumSaturation = pres.thresholdMinimumSaturation
            thresholdMinimumSaturation.doubleValue = CDSettings.thresholdMinimumSaturation.formatSliderDouble()
            thresholdMinimumSaturationValue.stringValue = String(format: "%.2f", CDSettings.thresholdMinimumSaturation)
            CDSettings.thresholdFloorBrightness = pres.thresholdFloorBrightness
            thresholdFloorBrightness.doubleValue = CDSettings.thresholdFloorBrightness.formatSliderDouble()
            thresholdFloorBrightnessValue.stringValue = String(format: "%.2f", CDSettings.thresholdFloorBrightness)
            CDSettings.contrastRatio = pres.contrastRatio
            contrastRatio.doubleValue = CDSettings.contrastRatio.formatSliderDouble(multiplier: 10.0)
            contrastRatioValue.stringValue = String(format: "%.1f", CDSettings.contrastRatio)
            CDSettings.ensureContrastedColorCandidates = pres.contrastedCandidates
            ensureContrastedColorCandidates.state = Int(pres.contrastedCandidates)
            controlsDelegate?.updateColorCandidates(mouseUp: true)
        } catch let demoAppError as DemoAppError {
            Swift.print(demoAppError)
        } catch {
            Swift.print(error.localizedDescription)
        }
    }
    
    func reset(_ sender: AnyObject?) {
        do {
            guard let defaults =  UserDefaults.standard.object(forKey: "defaultSettings") as? NSDictionary,
                let distinct = defaults["ThresholdDistinctColor"] as? CGFloat,
                let noise = defaults["ThresholdNoiseTolerance"] as? Int,
                let saturation = defaults["ThresholdMinimumSaturation"] as? CGFloat,
                let brightness = defaults["ThresholdFloorBrightness"] as? CGFloat,
                let contrast = defaults["ContrastRatio"] as? CGFloat
                else {
                    throw DemoAppError.couldNotfindDefaultConfiguration
            }
            CDSettings.thresholdDistinctColor = distinct
            CDSettings.thresholdNoiseTolerance = noise
            CDSettings.thresholdMinimumSaturation = saturation
            CDSettings.thresholdFloorBrightness = brightness
            CDSettings.contrastRatio = contrast
            CDSettings.ensureContrastedColorCandidates = true
            setSlidersDefaults()
            if let sender = sender as? NSButton {
                updateColors(sender)
            }
        } catch let demoAppError as DemoAppError {
            Swift.print(demoAppError)
        } catch {
            Swift.print(error.localizedDescription)
        }
    }

    @IBAction func resetToDefaults(_ sender: NSButton) {
        reset(sender)
    }

    @IBAction func ensureContrastedColorCandidates(_ sender: NSButton) {
        CDSettings.ensureContrastedColorCandidates = Bool(sender.state)
        updateColors(sender)
    }

    @IBAction func noiseToleranceSlider(_ sender: NSSlider) {
        noiseToleranceValue.integerValue = sender.integerValue
        CDSettings.thresholdNoiseTolerance = sender.integerValue
        updateColors(sender)
    }

    @IBAction func thresholdMinimumSaturationSlider(_ sender: NSSlider) {
        let val = makeDoubleValFromSlider(sender)
        thresholdMinimumSaturationValue.stringValue = val.string
        CDSettings.thresholdMinimumSaturation = val.cgFloat
        updateColors(sender)
    }

    @IBAction func distinctColorsSlider(_ sender: NSSlider) {
        let val = makeDoubleValFromSlider(sender)
        distinctColorsValue.stringValue = val.string
        CDSettings.thresholdDistinctColor = val.cgFloat
        updateColors(sender)
    }

    @IBAction func thresholdFloorBrightnessSlider(_ sender: NSSlider) {
        let val = makeDoubleValFromSlider(sender)
        thresholdFloorBrightnessValue.stringValue = val.string
        CDSettings.thresholdFloorBrightness = val.cgFloat
        updateColors(sender)
    }

    @IBAction func contrastRatioSlider(_ sender: NSSlider) {
        let val = makeDoubleValFromSlider(sender, divider: 10, format: "%.1f")
        contrastRatioValue.stringValue = val.string
        CDSettings.contrastRatio = val.cgFloat
        updateColors(sender)
    }

    private func makeDoubleValFromSlider(_ sender: NSSlider,
                                         divider: Int = 100,
                                         format: String = "%.2f")
                                            -> (string: String, cgFloat: CGFloat, double: Double)
    {
        let val = Double(sender.integerValue) / Double(divider)
        let str = String(format: format, val)
        return (str, CGFloat(val), val)
    }

    private func updateColors(_ sender: AnyObject? = nil) {
        if let sdr = sender as? NSSlider,
            let event = sdr.window?.currentEvent,
            event.type == .leftMouseUp {
            controlsDelegate?.updateColorCandidates(mouseUp: true)
        } else {
            controlsDelegate?.updateColorCandidates(mouseUp: false)
        }
    }

}
