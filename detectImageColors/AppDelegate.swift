//
//  AppDelegate.swift
//  detectImageColors

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // Demo App
    
    // ------------------------------------

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var distinctColorsSlider: NSTextField!
    @IBOutlet weak var thresholdNoise: NSTextField!
    @IBOutlet weak var thresholdMinimumSaturation: NSTextField!
    @IBOutlet weak var thresholdFloorBrightness: NSTextField!
    @IBOutlet weak var contrastRatio: NSTextField!
    
    func applicationWillFinishLaunching(notification: NSNotification) {
        window.setFrameUsingName("DetectImageColorsDemo")
        window.title = "DetectImageColors"
        window.backgroundColor = NSColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        distinctColorsSlider.doubleValue = Double(CDSettings.ThresholdDistinctColor)
        thresholdNoise.integerValue = CDSettings.ThresholdNoiseTolerance
        thresholdMinimumSaturation.doubleValue = Double(CDSettings.ThresholdMinimumSaturation)
        thresholdFloorBrightness.doubleValue = Double(CDSettings.ThresholdFloorBrightness)
        contrastRatio.doubleValue = Double(CDSettings.ContrastRatio)
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        window.saveFrameUsingName("DetectImageColorsDemo")
    }


}

