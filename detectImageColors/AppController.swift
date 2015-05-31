//
//  AppController.swift
//  detectImageColors
//  Demo app

import Cocoa

class AppController: NSObject {
    
    // ------------------------------------
    
    // MARK: HOW TO USE
    
    // 1. Create color-detector objects

    var colorDetector: ColorDetector?
    var colorCandidates: ColorCandidates? {
        // this is for the demo app
        didSet {
            refreshWindowElements()
        }
    }
    
    // 2. Optional: tweak CDSettings class variables

    // 3. Create color candidates from image
    
    private func analyzeImage(image: NSImage) {
        var candidates: ColorCandidates?
        // If our ColorDetector instance exists
        if let cd = self.colorDetector {
            // Avoid big images
            if let resized = cd.resize(image) {
                // Keep it around for the demo app
                self.resizedImage = resized
                // Get the Optional ColorCandidates object from the resized image
                candidates = cd.getColorCandidatesFromImage(resized)
            }
        } else {
            // Create ColorDetector instance
            self.colorDetector = ColorDetector()
            if let cd = self.colorDetector, let resized = cd.resize(image) {
                self.resizedImage = resized
                candidates = cd.getColorCandidatesFromImage(resized)
            }
        }
        // Result
        if let validCandidates = candidates {
            self.colorCandidates = validCandidates
        }
    }
    
    // ------------------------------------
    
    // MARK: DEMO APP
    
    // objects
    
    var resizedImage: NSImage?
    
    // sliders
    
    @IBAction func noiseToleranceSlider(sender: NSSlider) {
        noiseToleranceValue.integerValue = sender.integerValue
        CDSettings.ThresholdNoiseTolerance = sender.integerValue
        updateColorCandidates()
    }
    
    @IBAction func thresholdMinimumSaturationSlider(sender: NSSlider) {
        let val = makeDoubleValFromSlider(sender)
        thresholdMinimumSaturationValue.doubleValue = val
        CDSettings.ThresholdMinimumSaturation = CGFloat(val)
        updateColorCandidates()
    }
    
    @IBAction func distinctColorsSlider(sender: NSSlider) {
        let val = makeDoubleValFromSlider(sender)
        distinctColorsValue.doubleValue = val
        CDSettings.ThresholdDistinctColor = CGFloat(val)
        updateColorCandidates()
    }
    
    @IBAction func thresholdFloorBrightnessSlider(sender: NSSlider) {
        let val = makeDoubleValFromSlider(sender)
        thresholdFloorBrightnessValue.doubleValue = val
        CDSettings.ThresholdFloorBrightness = CGFloat(val)
        updateColorCandidates()
    }
    
    @IBAction func contrastRatioSlider(sender: NSSlider) {
        let val = makeDoubleValFromSlider(sender, divider: 10)
        contrastRatioValue.doubleValue = val
        CDSettings.ContrastRatio = CGFloat(val)
        updateColorCandidates()
    }
    
    @IBAction func ensureContrastedColorCandidates(sender: NSButton) {
        CDSettings.EnsureContrastedColorCandidates = Bool(sender.state)
        updateColorCandidates()
    }
    
    private func updateColorCandidates() {
        self.colorCandidates = self.colorDetector!.getColorCandidatesFromImage(self.resizedImage!)
    }
    
    private func makeDoubleValFromSlider(sender: NSSlider, divider: Int = 100) -> Double {
        return Double(sender.integerValue) / Double(divider)
    }
    
    // methods

    override func awakeFromNib() {
        // Default image when demo app starts
        if let elton = NSImage(named: "elton") {
            analyseImageAndSetImageView(elton)
        }
        // Observe for dropped images
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateImage:", name: "updateImageByDropOK", object: nil)
    }
    
    func updateImage(notification: NSNotification) {
        if let dic = notification.userInfo as? [String: NSImage], let img = dic["image"] {
            analyseImageAndSetImageView(img)
        }
    }
    
    private func analyseImageAndSetImageView(image: NSImage) {
        analyzeImage(image)
        imageView.image = image
    }
    
    private func refreshWindowElements() {
        if let cols = self.colorCandidates {
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
