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
    @IBOutlet weak var thresholdMinimumSaturationTitle: NSTextField!
    @IBOutlet weak var thresholdMinimumSaturationValue: NSTextField!
    @IBOutlet weak var thresholdFloorBrightnessTitle: NSTextField!
    @IBOutlet weak var thresholdFloorBrightnessValue: NSTextField!
    @IBOutlet weak var contrastRatioValue: NSTextField!
    @IBOutlet weak var contrastRatioTitle: NSTextField!

    override func awakeFromNib() {
        distinctColorsValue.stringValue = String(format: "%.2f", CDSettings.ThresholdDistinctColor)
        noiseToleranceValue.integerValue = CDSettings.ThresholdNoiseTolerance
        thresholdMinimumSaturationValue.stringValue = String(format: "%.2f", CDSettings.ThresholdMinimumSaturation)
        thresholdFloorBrightnessValue.stringValue = String(format: "%.2f", CDSettings.ThresholdFloorBrightness)
        contrastRatioValue.stringValue = String(format: "%.1f", CDSettings.ContrastRatio)
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
        thresholdMinimumSaturationValue.stringValue = String(format: "%.2f", val)
        CDSettings.ThresholdMinimumSaturation = CGFloat(val)
        updateColors()
    }

    @IBAction func distinctColorsSlider(sender: NSSlider) {
        let val = makeDoubleValFromSlider(sender)
        distinctColorsValue.stringValue = String(format: "%.2f", val)
        CDSettings.ThresholdDistinctColor = CGFloat(val)
        updateColors()
    }

    @IBAction func thresholdFloorBrightnessSlider(sender: NSSlider) {
        let val = makeDoubleValFromSlider(sender)
        thresholdFloorBrightnessValue.stringValue = String(format: "%.2f", val)
        CDSettings.ThresholdFloorBrightness = CGFloat(val)
        updateColors()
    }

    @IBAction func contrastRatioSlider(sender: NSSlider) {
        let val = makeDoubleValFromSlider(sender, divider: 10)
        contrastRatioValue.stringValue = String(format: "%.1f", val)
        CDSettings.ContrastRatio = CGFloat(val)
        updateColors()
    }

    private func makeDoubleValFromSlider(sender: NSSlider, divider: Int = 100) -> Double {
        return Double(sender.integerValue) / Double(divider)
    }

    private func updateColors() {
        NSNotificationCenter.defaultCenter().postNotificationName("updateColorCandidatesOK", object: nil)
    }

}
