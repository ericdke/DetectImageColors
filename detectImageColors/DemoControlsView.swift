//
//  DemoControlsView.swift
//  detectImageColors
//
//  Created by ERIC DEJONCKHEERE on 07/06/2015.
//  Copyright (c) 2015 Eric Dejonckheere. All rights reserved.
//

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

    override func awakeFromNib() {
        setSlidersDefaults()
    }

    func setSlidersDefaults() {
        distinctColors.doubleValue = Double(CDSettings.ThresholdDistinctColor) * 100.0
        distinctColorsValue.stringValue = String(format: "%.2f", CDSettings.ThresholdDistinctColor)
        noiseTolerance.integerValue = CDSettings.ThresholdNoiseTolerance
        noiseToleranceValue.integerValue = CDSettings.ThresholdNoiseTolerance
        thresholdMinimumSaturation.doubleValue = Double(CDSettings.ThresholdMinimumSaturation) * 100.0
        thresholdMinimumSaturationValue.stringValue = String(format: "%.2f", CDSettings.ThresholdMinimumSaturation)
        thresholdFloorBrightness.doubleValue = Double(CDSettings.ThresholdFloorBrightness) * 100.0
        thresholdFloorBrightnessValue.stringValue = String(format: "%.2f", CDSettings.ThresholdFloorBrightness)
        contrastRatio.doubleValue = Double(CDSettings.ThresholdFloorBrightness) * 100.0
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
            updateColors()
        }
    }

    @IBAction func ensureContrastedColorCandidates(sender: NSButton) {
        CDSettings.EnsureContrastedColorCandidates = Bool(sender.state)
        updateColors()
    }

    @IBAction func noiseToleranceSlider(sender: NSSlider) {
        noiseToleranceValue.integerValue = sender.integerValue
        CDSettings.ThresholdNoiseTolerance = sender.integerValue
        updateColors()
    }

    @IBAction func thresholdMinimumSaturationSlider(sender: NSSlider) {
        let val = makeDoubleValFromSlider(sender)
        thresholdMinimumSaturationValue.stringValue = val.string
        CDSettings.ThresholdMinimumSaturation = val.cgFloat
        updateColors()
    }

    @IBAction func distinctColorsSlider(sender: NSSlider) {
        let val = makeDoubleValFromSlider(sender)
        distinctColorsValue.stringValue = val.string
        CDSettings.ThresholdDistinctColor = val.cgFloat
        updateColors()
    }

    @IBAction func thresholdFloorBrightnessSlider(sender: NSSlider) {
        let val = makeDoubleValFromSlider(sender)
        thresholdFloorBrightnessValue.stringValue = val.string
        CDSettings.ThresholdFloorBrightness = val.cgFloat
        updateColors()
    }

    @IBAction func contrastRatioSlider(sender: NSSlider) {
        let val = makeDoubleValFromSlider(sender, divider: 10)
        contrastRatioValue.stringValue = val.string
        CDSettings.ContrastRatio = val.cgFloat
        updateColors()
    }

    private func makeDoubleValFromSlider(sender: NSSlider, divider: Int = 100) -> (string: String, cgFloat: CGFloat, double: Double) {
        let val = Double(sender.integerValue) / Double(divider)
        let str = String(format: "%.2f", val)
        return (str, CGFloat(val), val)
    }

    private func updateColors() {
        NSNotificationCenter.defaultCenter().postNotificationName("updateColorCandidatesOK", object: nil)
    }

}
