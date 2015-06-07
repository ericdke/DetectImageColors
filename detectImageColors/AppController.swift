//
//  AppController.swift
//  detectImageColors
//  Demo app

import Cocoa

class AppController: NSObject {

    let colorsFromImage = ColorsFromImage(image: NSImage(named: "elton")!)

    var colorCandidates: ColorCandidates? {
        didSet {
            refreshWindowElements()
        }
    }

    // sliders

    @IBAction func noiseToleranceSlider(sender: NSSlider) {
        noiseToleranceValue.integerValue = sender.integerValue
        CDSettings.ThresholdNoiseTolerance = sender.integerValue
        updateColorCandidates()
    }

    @IBAction func thresholdMinimumSaturationSlider(sender: NSSlider) {
        let val = makeDoubleValFromSlider(sender)
        thresholdMinimumSaturationValue.stringValue = String(format: "%.2f", val)
        CDSettings.ThresholdMinimumSaturation = CGFloat(val)
        updateColorCandidates()
    }

    @IBAction func distinctColorsSlider(sender: NSSlider) {
        let val = makeDoubleValFromSlider(sender)
        distinctColorsValue.stringValue = String(format: "%.2f", val)
        CDSettings.ThresholdDistinctColor = CGFloat(val)
        updateColorCandidates()
    }

    @IBAction func thresholdFloorBrightnessSlider(sender: NSSlider) {
        let val = makeDoubleValFromSlider(sender)
        thresholdFloorBrightnessValue.stringValue = String(format: "%.2f", val)
        CDSettings.ThresholdFloorBrightness = CGFloat(val)
        updateColorCandidates()
    }

    @IBAction func contrastRatioSlider(sender: NSSlider) {
        let val = makeDoubleValFromSlider(sender, divider: 10)
        contrastRatioValue.stringValue = String(format: "%.1f", val)
        CDSettings.ContrastRatio = CGFloat(val)
        updateColorCandidates()
    }

    @IBAction func ensureContrastedColorCandidates(sender: NSButton) {
        CDSettings.EnsureContrastedColorCandidates = Bool(sender.state)
        updateColorCandidates()
    }

    private func updateColorCandidates() {
        colorCandidates = colorsFromImage.getColors()
    }

    private func makeDoubleValFromSlider(sender: NSSlider, divider: Int = 100) -> Double {
        return Double(sender.integerValue) / Double(divider)
    }

    // methods

    override func awakeFromNib() {
        analyseImageAndSetImageView(NSImage(named: "elton")!)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateImage:", name: "updateImageByDropOK", object: nil)
    }

    func updateImage(notification: NSNotification) {
        if let dic = notification.userInfo as? [String: NSImage], let img = dic["image"] {
            analyseImageAndSetImageView(img)
        }
    }

    private func analyseImageAndSetImageView(image: NSImage) {
        colorCandidates = colorsFromImage.getColorsFromImage(image)
        imageView.image = image
    }

    private func refreshWindowElements() {
        if let cols = colorCandidates {
            label1.textColor = cols.primary
            label2.textColor = cols.secondary
            label3.textColor = cols.detail
            backgroundView?.colorCandidates = cols
        }
    }

    // outlets

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var label1: NSTextField!
    @IBOutlet weak var label2: NSTextField!
    @IBOutlet weak var label3: NSTextField!
    @IBOutlet weak var imageView: NSImageView!
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
    @IBOutlet weak var backgroundView: DemoBackgroundView!

}
